import Foundation
import Observation

/// What presentation sees when it asks for a person's forecast (§27, §33).
enum ForecastAvailability: Sendable {
    case loading
    case available(PersonalizedForecastDocument)
    /// No personalized data and generation is not possible right now.
    case unavailable(reason: String)
}

/// Main-actor facade over the forecast repository + generation coordinator.
///
/// Presentation asks one question — "give me the current forecast for this
/// person" — and never knows whether content came from cache, the deterministic
/// provider, a bundled offline pack, or a partial generation (§27, §45).
@Observable
@MainActor
final class ForecastStore {
    private let repository: any ForecastRepository
    private let coordinator: ForecastGenerationCoordinator
    private let bundledRepository: BundledContentPackRepository
    private let hybridProvider: HybridOfflineContentProvider

    private var documents: [UUID: PersonalizedForecastDocument] = [:]
    private var fallbacks: [UUID: YearlyForecast] = [:]
    private var inFlight: [UUID: Task<Void, Never>] = [:]

    init(
        repository: any ForecastRepository,
        coordinator: ForecastGenerationCoordinator,
        bundledRepository: BundledContentPackRepository = .shared
    ) {
        self.repository = repository
        self.coordinator = coordinator
        self.bundledRepository = bundledRepository
        self.hybridProvider = HybridOfflineContentProvider(repository: bundledRepository)
    }

    // MARK: - Reads

    /// The persisted personalized document, if any. Does not trigger generation.
    func document(for subject: ForecastSubject) -> PersonalizedForecastDocument? {
        documents[subject.id]
    }

    /// Hybrid offline fallback forecast — bundled AI content where available, deterministic fill otherwise.
    /// Computed once per subject and memoized. Includes honest mixed-source provenance.
    func fallbackForecast(for subject: ForecastSubject) -> YearlyForecast {
        if let cached = fallbacks[subject.id] {
            return cached
        }
        if bundledRepository.isAvailable {
            let anchor = fallbackAnchor()
            let personalization = PersonalizationContext.from(subject: subject)
            var days: [DailyMood] = []
            days.reserveCapacity(YearlyForecast.dayCount)
            var bundledHits = 0
            for offset in 0..<YearlyForecast.dayCount {
                if let date = anchor.date(forDayOffset: offset),
                   let resolved = BundledContentResolver.resolve(
                       date: date, dayOffset: offset, context: personalization, repository: bundledRepository
                   ) {
                    days.append(resolved.dailyMood)
                    bundledHits += 1
                } else {
                    let base = HumayContentEngine.baseScores(profileID: subject.id, birth: subject.birth, dayOffset: offset)
                    days.append(DailyMood(dayOffset: offset, scores: base.scores, note: base.note))
                }
            }
            let fallbackCount = YearlyForecast.dayCount - bundledHits
            let manifest = bundledRepository.manifest
            let contentSource: ForecastContentSource
            let basis: ContentBasis
            if bundledHits == 0 {
                contentSource = .deterministic(days: YearlyForecast.dayCount)
                basis = .entertainmentFixture
            } else if fallbackCount == 0 {
                contentSource = .bundled(days: bundledHits, packVersion: manifest?.packVersion, contentCycleVersion: manifest?.contentCycleVersion)
                basis = .aiGenerated(modelIdentifier: BundledAIContentProvider.identifier)
            } else {
                contentSource = .mixed(bundledDays: bundledHits, deterministicDays: fallbackCount, packVersion: manifest?.packVersion, contentCycleVersion: manifest?.contentCycleVersion)
                basis = .aiGenerated(modelIdentifier: BundledAIContentProvider.identifier)
            }
            let forecast = YearlyForecast(
                profileID: subject.id,
                days: days,
                provenance: ContentProvenance(generatorVersion: HybridOfflineContentProvider.pipelineVersion, generatedAt: .now, basis: basis),
                contentSource: contentSource
            )
            fallbacks[subject.id] = forecast
            return forecast
        }
        let forecast = HumayContentEngine.yearlyForecast(
            profileID: subject.id,
            birth: subject.birth
        )
        fallbacks[subject.id] = forecast
        return forecast
    }

    /// Expose hybrid fallback provenance for DEBUG.
    var bundledAvailability: Bool { bundledRepository.isAvailable }

    /// The forecast presentation should render: personalized days where they
    /// exist, honest deterministic fill for the rest (§33). Handles content-cycle staleness (§40-42).
    func effectiveForecast(for subject: ForecastSubject) -> EffectiveForecast {
        let fallback = fallbackForecast(for: subject)
        func isBundledStale(_ doc: PersonalizedForecastDocument) -> Bool {
            doc.isStaleDueToContentCycle(currentContentCycleVersion: self.bundledRepository.manifest?.contentCycleVersion, currentPackVersion: self.bundledRepository.manifest?.packVersion, isBundledAvailable: self.bundledRepository.isAvailable, isPackActive: self.bundledRepository.manifest?.isActive(on: Date()) ?? false)
        }
        guard let document = documents[subject.id], !document.isStale(for: subject), !isBundledStale(document) else {
            return EffectiveForecast(
                subject: subject,
                days: fallback.days,
                anchor: fallbackAnchor(),
                yearContext: fallback.yearContext ?? fallbackYearContext(subject),
                personalizedThroughOffset: nil,
                basis: fallback.provenance.basis,
                contentSource: fallback.contentSource,
                usedFallbackOnly: true
            )
        }

        var merged = fallback.days
        var deepestPersonalized: Int?
        for day in document.days {
            guard merged.indices.contains(day.dayOffset) else { continue }
            merged[day.dayOffset] = day
            if deepestPersonalized == nil || day.dayOffset > deepestPersonalized! {
                deepestPersonalized = day.dayOffset
            }
        }

        // Preserve provenance honestly: persisted doc carries its own basis, fallback carries bundled/mixed truth
        return EffectiveForecast(
            subject: subject,
            days: merged,
            anchor: document.anchor,
            yearContext: document.forecast.yearContext ?? fallback.yearContext ?? fallbackYearContext(subject),
            personalizedThroughOffset: deepestPersonalized,
            basis: document.provenance.basis,
            contentSource: fallback.contentSource,
            usedFallbackOnly: false
        )
    }

    // MARK: - Generation

    /// Ensures a personalized forecast exists and is current. Cache-first;
    /// concurrent calls for the same subject are coalesced (§22). Includes content-cycle invalidation (§40-42).
    func ensureForecast(for subject: ForecastSubject, anchor: ForecastAnchor? = nil) {
        func isBundledStale(_ doc: PersonalizedForecastDocument) -> Bool {
            doc.isStaleDueToContentCycle(currentContentCycleVersion: self.bundledRepository.manifest?.contentCycleVersion, currentPackVersion: self.bundledRepository.manifest?.packVersion, isBundledAvailable: self.bundledRepository.isAvailable, isPackActive: self.bundledRepository.manifest?.isActive(on: Date()) ?? false)
        }
        guard inFlight[subject.id] == nil else { return }

        if let existing = documents[subject.id],
           !existing.isStale(for: subject),
           !isBundledStale(existing),
           existing.resolvedPhase(for: subject) == .complete {
            return
        }

        let resolvedAnchor = anchor ?? fallbackAnchor()
        let bundledRepository = self.bundledRepository

        let task = Task { [repository, coordinator, bundledRepository] in
            ForecastLog.load(profileID: subject.id)

            // Surface whatever exists on disk before generating.
            if documents[subject.id] == nil {
                documents[subject.id] = try? await repository.load(subject: subject)
            }
            func bundledStaleInTask(_ doc: PersonalizedForecastDocument) -> Bool {
                doc.isStaleDueToContentCycle(currentContentCycleVersion: bundledRepository.manifest?.contentCycleVersion, currentPackVersion: bundledRepository.manifest?.packVersion, isBundledAvailable: bundledRepository.isAvailable, isPackActive: bundledRepository.manifest?.isActive(on: Date()) ?? false)
            }
            if let existing = documents[subject.id],
               !existing.isStale(for: subject),
               !bundledStaleInTask(existing),
               existing.resolvedPhase(for: subject) == .complete {
                inFlight[subject.id] = nil
                return
            }

            _ = try? await coordinator.ensureForecast(subject: subject, anchor: resolvedAnchor)

            if let updated = try? await repository.load(subject: subject) {
                documents[subject.id] = updated
            }
            inFlight[subject.id] = nil
        }
        inFlight[subject.id] = task
    }

    /// Debug/QA export: writes the normalized document to a temporary JSON file
    /// and returns its URL (§26). Persisted storage remains untouched.
    func exportFileURL(for subject: ForecastSubject) async throws -> URL {
        let data = try await repository.exportData(subject: subject)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(subject.id.uuidString)-forecast-v\(PersonalizedForecastDocument.schemaVersion).json")
        try data.write(to: url, options: [.atomic])
        return url
    }

    /// Removes stored content (debug/reset paths).
    func clearForecast(for subject: ForecastSubject) async {
        documents.removeValue(forKey: subject.id)
        fallbacks.removeValue(forKey: subject.id)
        try? await repository.remove(subject: subject)
    }

    /// Invalidates caches for a subject whose birth identity changed (§25) or content-cycle expired (§40).
    /// Removes stale documents and forces fallback recomputation. Caller should
    /// trigger `ensureForecast` afterward if personalized generation is desired.
    func invalidateForBirthChange(subject: ForecastSubject) async {
        fallbacks.removeValue(forKey: subject.id)
        func bundledStale(_ doc: PersonalizedForecastDocument) -> Bool {
            doc.isStaleDueToContentCycle(currentContentCycleVersion: self.bundledRepository.manifest?.contentCycleVersion, currentPackVersion: self.bundledRepository.manifest?.packVersion, isBundledAvailable: self.bundledRepository.isAvailable, isPackActive: self.bundledRepository.manifest?.isActive(on: Date()) ?? false)
        }
        if let doc = documents[subject.id], doc.isStale(for: subject) || bundledStale(doc) {
            documents.removeValue(forKey: subject.id)
        }
        // Also remove on-disk stale documents proactively so they don't survive process restart
        if let doc = try? await repository.load(subject: subject), doc.isStale(for: subject) || bundledStale(doc) {
            try? await repository.remove(subject: subject)
        }
    }

    /// Convenience for checking whether a subject's document is stale after birth edit.
    func isStale(for subject: ForecastSubject) -> Bool {
        guard let doc = documents[subject.id] else { return false }
        return doc.isStale(for: subject)
    }

    // MARK: - Helpers

    private func fallbackAnchor() -> ForecastAnchor {
        ForecastAnchor(date: .now, calendar: .current)
    }

    /// Deterministic year context for fallback-only rendering.
    private func fallbackYearContext(_ subject: ForecastSubject) -> YearContext {
        DeterministicContentProvider.yearContext(subject: subject, anchor: fallbackAnchor())
    }
}

/// The render-ready forecast presentation consumes. Personalized days are
/// merged over deterministic fill; consumers can disclose honestly what is
/// personalized versus standby. Retains honest bundled/deterministic/mixed provenance.
struct EffectiveForecast: Sendable, Equatable {
    let subject: ForecastSubject
    let days: [DailyMood]
    let anchor: ForecastAnchor
    let yearContext: YearContext?
    let personalizedThroughOffset: Int?
    let basis: ContentBasis
    /// Honest content source (bundled/deterministic/mixed + counts) where available.
    let contentSource: ForecastContentSource?
    let usedFallbackOnly: Bool

    func day(atOffset offset: Int) -> DailyMood? {
        guard days.indices.contains(offset) else { return nil }
        return days[offset]
    }

    var isPersonalized: Bool { personalizedThroughOffset != nil }
}
