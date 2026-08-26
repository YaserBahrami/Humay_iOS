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
                loadError: nil
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
                loadError: repository.loadError
            )
        }
    }
}
#endif
