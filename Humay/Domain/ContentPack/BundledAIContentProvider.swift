import Foundation

/// Offline bundled-AI content provider behind `PersonalizedContentProviding`.
///
/// Produces AI-authored entertainment content from the versioned offline pack;
/// never touches the network, never requires an API key. Content basis is
/// `aiGenerated(modelIdentifier: bundled-ai-v1)` so provenance is honest:
/// this is stored AI copy composed locally, not live AI.
actor BundledAIContentProvider: PersonalizedContentProviding {
    static let identifier = "bundled-ai"
    static let generatorVersion = "bundled-ai-v1"

    nonisolated var descriptor: PersonalizedContentProviderDescriptor {
        PersonalizedContentProviderDescriptor(
            providerIdentifier: Self.identifier,
            generatorVersion: Self.generatorVersion,
            promptCatalogVersion: IntelligenceVersions.promptCatalog,
            basis: .aiGenerated(modelIdentifier: Self.identifier),
            modelIdentifier: Self.identifier
        )
    }

    private let repository: BundledContentPackRepository

    init(repository: BundledContentPackRepository = .shared) {
        self.repository = repository
    }

    // MARK: - PersonalizedContentProviding

    func generateYearOutline(
        subject: ForecastSubject,
        anchor: ForecastAnchor
    ) async throws -> GeneratedOutline {
        try Task.checkCancellation()
        guard repository.isAvailable, let pack = repository.pack else {
            throw GenerationError.providerUnavailable
        }
        // Deterministic year theme derived from pack provenance + subject archetype,
        // preserving the contract that outline is lightweight and coherent.
        let archetype = HumayContentEngine.archetype(profileID: subject.id)
        let yearTheme = "Bundled year — \(pack.manifest.packVersion) · \(archetype.name): a year that actually listens."

        var monthlyThemes: [MonthlyTheme] = []
        for idx in 0..<12 {
            let offsets = anchor.dayOffsets(inMonthIndex: idx, totalDays: YearlyForecast.dayCount)
            let label = monthlyThemeFor(monthIndex: idx, archetype: archetype)
            monthlyThemes.append(MonthlyTheme(monthIndex: idx, theme: label, tendency: "Leans \(label.lowercased())."))
            _ = offsets // touch to avoid warning
        }
        let notable = notablePeriods(subject: subject, anchor: anchor)
        let context = try YearContext(yearTheme: yearTheme, monthlyThemes: monthlyThemes, notablePeriods: notable)
        return GeneratedOutline(context: context, usage: .zero, modelIdentifier: Self.identifier, sourceDescriptor: descriptor, packVersion: repository.manifest?.packVersion, contentCycleVersion: repository.manifest?.contentCycleVersion)
    }

    func generateMonthChunk(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        monthIndex: Int
    ) async throws -> GeneratedMonth {
        try Task.checkCancellation()
        guard (0..<12).contains(monthIndex) else {
            throw GenerationError.validationFailed(.invalidMonthIndex(monthIndex))
        }
        guard repository.isAvailable else {
            throw GenerationError.providerUnavailable
        }
        let personalization = PersonalizationContext.from(subject: subject)
        let offsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)
        guard !offsets.isEmpty else {
            throw GenerationError.validationFailed(.invalidMonthIndex(monthIndex))
        }

        var days: [DailyMood] = []
        days.reserveCapacity(offsets.count)
        for offset in offsets {
            guard let resolved = BundledContentResolver.resolve(
                dayOffset: offset,
                anchor: anchor,
                context: personalization,
                repository: repository
            ) else {
                // Bundled provider does not fabricate deterministic fallback.
                // Hybrid owns fallback; report missing so caller can handle honestly.
                throw GenerationError.providerUnavailable
            }
            days.append(resolved.dailyMood)
        }
        return GeneratedMonth(days: days, usage: .zero, modelIdentifier: Self.identifier, sourceDescriptor: descriptor, packVersion: repository.manifest?.packVersion, contentCycleVersion: repository.manifest?.contentCycleVersion)
    }

    func regenerateDay(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        dayOffset: Int
    ) async throws -> DailyMood {
        try Task.checkCancellation()
        guard (0..<YearlyForecast.dayCount).contains(dayOffset) else {
            throw GenerationError.validationFailed(.dayOffsetOutOfRange(dayOffset))
        }
        guard repository.isAvailable else {
            throw GenerationError.providerUnavailable
        }
        let personalization = PersonalizationContext.from(subject: subject)
        guard let resolved = BundledContentResolver.resolve(
            dayOffset: dayOffset,
            anchor: anchor,
            context: personalization,
            repository: repository
        ) else {
            throw GenerationError.providerUnavailable
        }
        return resolved.dailyMood
    }

    // MARK: - Helpers

    private func monthlyThemeFor(monthIndex: Int, archetype: HumayArchetype) -> String {
        let themes = [
            "Orbit calibration", "Heart weather", "Momentum season", "Nerve training",
            "Voltage month", "Main character block", "Balance arc", "Structural turbulence",
            "Orbit expansion", "Quiet architecture", "Signal month", "Transit season"
        ]
        return themes[monthIndex % themes.count]
    }

    private func notablePeriods(subject: ForecastSubject, anchor: ForecastAnchor) -> [NotablePeriod] {
        let personalization = PersonalizationContext.from(subject: subject)
        var romanceBest: (offset: Int, value: Int)?
        var chaosBest: (offset: Int, value: Int)?
        for offset in 0..<YearlyForecast.dayCount {
            if let resolved = BundledContentResolver.resolve(dayOffset: offset, anchor: anchor, context: personalization, repository: repository) {
                let r = resolved.dailyMood.scores[.romance]
                let c = resolved.dailyMood.scores[.chaos]
                if romanceBest == nil || r > romanceBest!.value { romanceBest = (offset, r) }
                if chaosBest == nil || c > chaosBest!.value { chaosBest = (offset, c) }
            }
        }
        var result: [NotablePeriod] = []
        if let r = romanceBest {
            result.append(NotablePeriod(startDayOffset: r.offset, endDayOffset: r.offset, label: "Bundled romance peak", kind: .romance))
        }
        if let c = chaosBest {
            result.append(NotablePeriod(startDayOffset: c.offset, endDayOffset: c.offset, label: "Bundled chaos crest", kind: .chaos))
        }
        return result
    }
}
