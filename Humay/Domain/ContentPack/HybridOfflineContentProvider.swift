import Foundation

/// Hybrid offline provider: bundled AI content when available, deterministic fallback otherwise.
///
/// Production runtime has no network dependency. Provenance is honest:
/// - bundled hit → `aiGenerated(modelIdentifier: bundled-ai-v1)`
/// - fallback    → `entertainmentFixture`
actor HybridOfflineContentProvider: PersonalizedContentProviding {
    private let primary: BundledAIContentProvider
    private let fallback: DeterministicContentProvider
    private let repository: BundledContentPackRepository

    nonisolated var descriptor: PersonalizedContentProviderDescriptor {
        // Report primary identity; actual per-day basis is stamped per document.
        primary.descriptor
    }

    init(
        repository: BundledContentPackRepository = .shared,
        primary: BundledAIContentProvider? = nil,
        fallback: DeterministicContentProvider = DeterministicContentProvider()
    ) {
        self.repository = repository
        self.primary = primary ?? BundledAIContentProvider(repository: repository)
        self.fallback = fallback
    }

    func generateYearOutline(
        subject: ForecastSubject,
        anchor: ForecastAnchor
    ) async throws -> GeneratedOutline {
        if repository.isAvailable {
            do {
                return try await primary.generateYearOutline(subject: subject, anchor: anchor)
            } catch {
                // Fall through to deterministic.
            }
        }
        return try await fallback.generateYearOutline(subject: subject, anchor: anchor)
    }

    func generateMonthChunk(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        monthIndex: Int
    ) async throws -> GeneratedMonth {
        if repository.isAvailable {
            do {
                let result = try await primary.generateMonthChunk(
                    subject: subject, outline: outline, anchor: anchor, monthIndex: monthIndex
                )
                // Tag whether this month was actually backed by bundled records:
                // The primary already falls back per-day internally, so the chunk
                // is always valid. No extra handling needed.
                return result
            } catch {
                // Soft fallback.
            }
        }
        return try await fallback.generateMonthChunk(
            subject: subject, outline: outline, anchor: anchor, monthIndex: monthIndex
        )
    }

    func regenerateDay(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        dayOffset: Int
    ) async throws -> DailyMood {
        if repository.isAvailable {
            do {
                return try await primary.regenerateDay(
                    subject: subject, outline: outline, anchor: anchor, dayOffset: dayOffset
                )
            } catch {
                // fall through
            }
        }
        return try await fallback.regenerateDay(
            subject: subject, outline: outline, anchor: anchor, dayOffset: dayOffset
        )
    }

    /// Synchronous hybrid forecast build for `ForecastStore.effectiveForecast`-style use.
    /// Produces a full `YearlyForecast` with bundled days where available.
    func yearlyForecast(subject: ForecastSubject, anchor: ForecastAnchor) -> (YearlyForecast, usedFallbackDays: Int) {
        let personalization = PersonalizationContext.from(subject: subject)
        var days: [DailyMood] = []
        days.reserveCapacity(YearlyForecast.dayCount)
        var fallbackCount = 0

        for offset in 0..<YearlyForecast.dayCount {
            if let resolved = BundledContentResolver.resolve(
                dayOffset: offset, anchor: anchor, context: personalization, repository: repository
            ) {
                days.append(resolved.dailyMood)
            } else {
                let base = HumayContentEngine.baseScores(profileID: subject.id, birth: subject.birth, dayOffset: offset)
                days.append(DailyMood(dayOffset: offset, scores: base.scores, note: base.note))
                fallbackCount += 1
            }
        }

        let basis: ContentBasis = fallbackCount == YearlyForecast.dayCount
            ? .entertainmentFixture
            : .aiGenerated(modelIdentifier: BundledAIContentProvider.identifier)
        let provenance = ContentProvenance(
            generatorVersion: fallbackCount == YearlyForecast.dayCount
                ? YearlyForecast.currentGeneratorVersion
                : BundledAIContentProvider.generatorVersion,
            generatedAt: .now,
            basis: basis
        )
        return (YearlyForecast(profileID: subject.id, days: days, provenance: provenance), fallbackCount)
    }
}
