import Foundation

/// Hybrid offline provider: bundled AI content when available, deterministic fallback otherwise.
///
/// Stable pipeline identity (§28): humay-offline-hybrid-v1 participates in fingerprint/staleness.
/// Actual content source (bundled/deterministic/mixed) is recorded honestly via provenance
/// but does NOT change the pipeline fingerprint.
actor HybridOfflineContentProvider: PersonalizedContentProviding {
    static let pipelineIdentifier = "humay-offline-hybrid"
    static let pipelineVersion = "humay-offline-hybrid-v1"

    private let primary: BundledAIContentProvider
    private let fallback: DeterministicContentProvider
    private let repository: BundledContentPackRepository

    nonisolated var descriptor: PersonalizedContentProviderDescriptor {
        PersonalizedContentProviderDescriptor(
            providerIdentifier: Self.pipelineIdentifier,
            generatorVersion: Self.pipelineVersion,
            promptCatalogVersion: IntelligenceVersions.promptCatalog,
            basis: .aiGenerated(modelIdentifier: Self.pipelineIdentifier),
            modelIdentifier: Self.pipelineIdentifier
        )
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
                return result
            } catch {
                // Fall through to deterministic fallback for coordinator paths where bundled
                // is unavailable for this month.
            }
        }
        let fallbackResult = try await fallback.generateMonthChunk(
            subject: subject, outline: outline, anchor: anchor, monthIndex: monthIndex
        )
        return fallbackResult
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
    /// Produces a full `YearlyForecast` with bundled days where available and honest mixed provenance.
    /// Generator version is always the stable pipeline version.
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

        let bundledDays = YearlyForecast.dayCount - fallbackCount
        let manifest = repository.manifest
        let packVersion = manifest?.packVersion
        let cycleVersion = manifest?.contentCycleVersion
        let contentSource: ForecastContentSource
        let basis: ContentBasis
        if fallbackCount == YearlyForecast.dayCount {
            contentSource = .deterministic(days: YearlyForecast.dayCount)
            basis = .entertainmentFixture
        } else if fallbackCount == 0 {
            contentSource = .bundled(days: bundledDays, packVersion: packVersion, contentCycleVersion: cycleVersion)
            basis = .aiGenerated(modelIdentifier: BundledAIContentProvider.identifier)
        } else {
            contentSource = .mixed(bundledDays: bundledDays, deterministicDays: fallbackCount, packVersion: packVersion, contentCycleVersion: cycleVersion)
            basis = .aiGenerated(modelIdentifier: BundledAIContentProvider.identifier)
        }
        let provenance = ContentProvenance(
            generatorVersion: Self.pipelineVersion,
            generatedAt: .now,
            basis: basis
        )
        let forecast = YearlyForecast(profileID: subject.id, days: days, provenance: provenance, contentSource: contentSource)
        return (forecast, fallbackCount)
    }
}
