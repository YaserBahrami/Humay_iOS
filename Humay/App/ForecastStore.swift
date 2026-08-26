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
    /// Computed once per subject and memoized.
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
            let basis: ContentBasis = bundledHits > 0 ? .aiGenerated(modelIdentifier: BundledAIContentProvider.identifier) : .entertainmentFixture
            let genVersion = bundledHits > 0 ? BundledAIContentProvider.generatorVersion : YearlyForecast.currentGeneratorVersion
            let forecast = YearlyForecast(
                profileID: subject.id,
                days: days,
                provenance: ContentProvenance(generatorVersion: genVersion, generatedAt: .now, basis: basis)
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
    /// exist, honest deterministic fill for the rest (§33).
    func effectiveForecast(for subject: ForecastSubject) -> EffectiveForecast {
        let fallback = fallbackForecast(for: subject)

        guard let document = documents[subject.id], !document.isStale(for: subject) else {
            return EffectiveForecast(
                subject: subject,
                days: fallback.days,
                anchor: fallbackAnchor(),
                yearContext: fallbackYearContext(subject),
                personalizedThroughOffset: nil,
                basis: .entertainmentFixture,
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

        return EffectiveForecast(
            subject: subject,
            days: merged,
            anchor: document.anchor,
            yearContext: document.forecast.yearContext ?? fallbackYearContext(subject),
            personalizedThroughOffset: deepestPersonalized,
            basis: document.provenance.basis,
            usedFallbackOnly: false
        )
    }

    // MARK: - Generation

    /// Ensures a personalized forecast exists and is current. Cache-first;
    /// concurrent calls for the same subject are coalesced (§22).
    func ensureForecast(for subject: ForecastSubject, anchor: ForecastAnchor? = nil) {
        guard inFlight[subject.id] == nil else { return }

        if let existing = documents[subject.id],
           !existing.isStale(for: subject),
           existing.resolvedPhase(for: subject) == .complete {
            return
        }

        let resolvedAnchor = anchor ?? fallbackAnchor()

        let task = Task { [repository, coordinator] in
            ForecastLog.load(profileID: subject.id)

            // Surface whatever exists on disk before generating.
            if documents[subject.id] == nil {
                documents[subject.id] = try? await repository.load(subject: subject)
            }
            if let existing = documents[subject.id],
               !existing.isStale(for: subject),
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
/// personalized versus standby.
struct EffectiveForecast: Sendable, Equatable {
    let subject: ForecastSubject
    let days: [DailyMood]
    let anchor: ForecastAnchor
    let yearContext: YearContext?
    let personalizedThroughOffset: Int?
    let basis: ContentBasis
    let usedFallbackOnly: Bool

    func day(atOffset offset: Int) -> DailyMood? {
        guard days.indices.contains(offset) else { return nil }
        return days[offset]
    }

    var isPersonalized: Bool { personalizedThroughOffset != nil }
}
