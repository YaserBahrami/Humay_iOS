import Foundation

#if DEBUG
/// DEBUG-only inspector for resolved bundled content.
struct ContentPackDebugInspector: Sendable {
    struct Snapshot: Sendable, Hashable {
        let date: Date
        let canonicalDayKey: String
        let sunSign: String?
        let moonSign: String?
        let risingSign: String?
        let archetypeID: String
        let archetypeName: String
        let sunRecordID: String?
        let moonModifierID: String?
        let risingModifierID: String?
        let scores: [String: Int]
        let headline: String?
        let provenance: String
        let fallbackUsed: Bool
        let packVersion: String?
        let loadError: String?
        // I.1 expanded
        let contentCycleVersion: String?
        let generationMethod: String?
        let batchID: String?
        let dominantTheme: String?
        let secondaryTheme: String?
        let selectedMoonFragment: String?
        let selectedRisingFragment: String?
        let selectedArchetypeFragment: String?
        let appliedDeltas: [String: Int]
        let isPilot: Bool?
    }

    struct YearlySnapshot: Sendable, Hashable {
        let bundledDays: Int
        let fallbackDays: Int
        let totalDays: Int
        let kind: String // bundled, deterministic, mixed
        let packVersion: String?
        let contentCycleVersion: String?
    }

    static func snapshot(
        subject: ForecastSubject,
        date: Date,
        calendar: Calendar = .current,
        repository: BundledContentPackRepository = .shared
    ) -> Snapshot {
        let dayKey = CanonicalDayKey.from(date: date, calendar: calendar)
        let ctx = PersonalizationContext.from(subject: subject)
        let archetype = HumayContentEngine.archetype(profileID: subject.id)

        let anchor = ForecastAnchor(date: date, calendar: calendar)
        let offset = anchor.dayOffset(for: date, calendar: calendar) ?? 0

        if let resolved = BundledContentResolver.resolve(
            date: date, dayOffset: offset, context: ctx, calendar: calendar, repository: repository
        ) {
            return Snapshot(
                date: date,
                canonicalDayKey: dayKey.key,
                sunSign: ctx.sunSign,
                moonSign: ctx.moonSign,
                risingSign: ctx.risingSign,
                archetypeID: ctx.archetypeID,
                archetypeName: archetype.name,
                sunRecordID: "\(resolved.context.sunRecord.dayKey)|\(resolved.context.sunRecord.sunSign)",
                moonModifierID: resolved.context.moonModifier?.moonSign,
                risingModifierID: resolved.context.risingModifier?.risingSign,
                scores: Dictionary(uniqueKeysWithValues: MoodDimension.allCases.map { ($0.rawValue, resolved.context.scores[$0]) }),
                headline: resolved.dailyMood.reading?.headline,
                provenance: "bundled-ai \(resolved.provenance.packVersion)",
                fallbackUsed: false,
                packVersion: resolved.provenance.packVersion,
                loadError: nil,
                contentCycleVersion: resolved.provenance.contentCycleVersion,
                generationMethod: resolved.provenance.generationMethod,
                batchID: resolved.provenance.batchID,
                dominantTheme: resolved.context.dominantTheme,
                secondaryTheme: resolved.context.secondaryTheme,
                selectedMoonFragment: resolved.context.selectedMoonFragment,
                selectedRisingFragment: resolved.context.selectedRisingFragment,
                selectedArchetypeFragment: resolved.context.selectedArchetypeFragment,
                appliedDeltas: resolved.context.appliedDeltas,
                isPilot: resolved.provenance.isPilot
            )
        } else {
            let base = HumayContentEngine.baseScores(profileID: subject.id, birth: subject.birth, dayOffset: offset)
            return Snapshot(
                date: date,
                canonicalDayKey: dayKey.key,
                sunSign: ctx.sunSign,
                moonSign: ctx.moonSign,
                risingSign: ctx.risingSign,
                archetypeID: ctx.archetypeID,
                archetypeName: archetype.name,
                sunRecordID: nil,
                moonModifierID: nil,
                risingModifierID: nil,
                scores: Dictionary(uniqueKeysWithValues: MoodDimension.allCases.map { ($0.rawValue, base.scores[$0]) }),
                headline: nil,
                provenance: "deterministic-fallback",
                fallbackUsed: true,
                packVersion: repository.manifest?.packVersion,
                loadError: repository.loadError,
                contentCycleVersion: repository.manifest?.contentCycleVersion,
                generationMethod: repository.manifest?.generationMethod ?? repository.manifest?.provenance.generationMethod,
                batchID: nil,
                dominantTheme: nil,
                secondaryTheme: nil,
                selectedMoonFragment: nil,
                selectedRisingFragment: nil,
                selectedArchetypeFragment: nil,
                appliedDeltas: [:],
                isPilot: repository.manifest?.coverage.isPilot
            )
        }
    }

    static func yearlySnapshot(
        subject: ForecastSubject,
        anchor: ForecastAnchor = ForecastAnchor(date: .now, calendar: .current),
        repository: BundledContentPackRepository = .shared
    ) -> YearlySnapshot {
        let personalization = PersonalizationContext.from(subject: subject)
        var bundled = 0
        for offset in 0..<YearlyForecast.dayCount {
            if BundledContentResolver.resolve(dayOffset: offset, anchor: anchor, context: personalization, repository: repository) != nil {
                bundled += 1
            }
        }
        let fallback = YearlyForecast.dayCount - bundled
        let kind: String
        if fallback == YearlyForecast.dayCount { kind = "deterministic" }
        else if bundled == YearlyForecast.dayCount { kind = "bundled" }
        else { kind = "mixed" }
        return YearlySnapshot(
            bundledDays: bundled,
            fallbackDays: fallback,
            totalDays: YearlyForecast.dayCount,
            kind: kind,
            packVersion: repository.manifest?.packVersion,
            contentCycleVersion: repository.manifest?.contentCycleVersion
        )
    }
}
#endif
