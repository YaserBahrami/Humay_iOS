import Foundation

/// Deterministic composable resolver for the offline content pack.
///
/// Composition model (bounded, explainable, inexpensive):
///   resolved = clamp( sunBase + moonDelta*moonInfluence + risingDelta*risingInfluence + archetypeDelta )
///
/// Personality mode never changes scores; it only affects expression via
/// `HumayContentEngine` / copy pools. Unavailable/ambiguous Moon/Rising are
/// omitted honestly, never substituted.
enum BundledContentResolver {
    /// Influence weights (bounded so no modifier destroys the curve).
    static let moonInfluence = 0.55
    static let risingInfluence = 0.45
    static let archetypeInfluence = 0.40

    struct ResolvedContext: Sendable, Hashable {
        let dayKey: CanonicalDayKey
        let sunRecord: SunDayRecord
        let moonModifier: MoonModifier?
        let risingModifier: RisingModifier?
        let archetypeModifier: ArchetypeModifier?
        let scores: MoodScores
        let appliedDeltas: [String: Int]
    }

    struct ResolvedDay: Sendable, Hashable {
        let dailyMood: DailyMood
        let context: ResolvedContext
        let provenance: ResolvedProvenance
    }

    struct ResolvedProvenance: Sendable, Hashable {
        let packVersion: String
        let generatorVersion: String
        let isPilot: Bool
    }

    /// Resolve one day from the pack. Returns nil when no Sun base exists for
    /// the canonical day/sign (caller should use deterministic fallback).
    static func resolve(
        date: Date,
        dayOffset: Int,
        context: PersonalizationContext,
        calendar: Calendar = .current,
        repository: BundledContentPackRepository
    ) -> ResolvedDay? {
        let dayKey = CanonicalDayKey.from(date: date, calendar: calendar)
        guard let pack = repository.pack else { return nil }
        guard let sunSignRaw = context.sunSign,
              let sunSign = WesternZodiacSign(rawValue: sunSignRaw) else {
            return nil
        }
        guard let sunRecord = repository.sunRecord(dayKey: dayKey, sunSign: sunSign) else {
            return nil
        }

        // Collect modifiers honestly.
        let moonMod: MoonModifier? = {
            guard let moonRaw = context.moonSign,
                  let ms = WesternZodiacSign(rawValue: moonRaw)
            else { return nil }
            return repository.moonModifier(sign: ms)
        }()

        let risingMod: RisingModifier? = {
            guard let risingRaw = context.risingSign,
                  let rs = WesternZodiacSign(rawValue: risingRaw)
            else { return nil }
            return repository.risingModifier(sign: rs)
        }()

        let archetypeMod: ArchetypeModifier? = repository.archetypeModifier(id: context.archetypeID)

        // Compose scores.
        guard let baseScores = try? sunRecord.moodScores() else { return nil }
        var applied: [String: Int] = [:]
        var resolved: [MoodDimension: Int] = [:]
        for dim in MoodDimension.allCases {
            let base = baseScores[dim]
            var delta: Double = 0
            if let m = moonMod, let d = m.deltas[dim.rawValue] {
                delta += Double(d) * moonInfluence
            }
            if let r = risingMod, let d = r.deltas[dim.rawValue] {
                delta += Double(d) * risingInfluence
            }
            if let a = archetypeMod, let d = a.deltas[dim.rawValue] {
                delta += Double(d) * archetypeInfluence
            }
            let raw = Int((Double(base) + delta).rounded())
            let clamped = max(0, min(100, raw))
            resolved[dim] = clamped
            if delta != 0 {
                applied[dim.rawValue] = Int(delta.rounded())
            }
        }
        let moodScores = MoodScores(resolved)

        // Text composition (quality over mad-libs).
        let headline = sunRecord.headline

        // Personal: sun personal + at most one compatible modifier sentence.
        let personalText = composePersonal(
            sun: sunRecord.personal,
            moonFragment: moonMod?.emotionalFragment,
            archetypeFragment: archetypeMod?.fragment
        )

        let socialText = composeSocial(
            base: sunRecord.social,
            risingFragment: risingMod?.outwardFragment
        )

        let reading: DayReading
        let flags: DayFlags
        let entertainment: EntertainmentMetrics
        do {
            reading = try DayReading(
                headline: headline,
                sections: [
                    try DayReadingSection(category: .personal, text: personalText),
                    try DayReadingSection(category: .love, text: sunRecord.love),
                    try DayReadingSection(category: .career, text: sunRecord.career),
                    try DayReadingSection(category: .social, text: socialText)
                ]
            )
            flags = try DayFlags(green: sunRecord.greenFlag, red: sunRecord.redFlag)
            // Derive entertainment deterministically from scores when not in pack
            // (pack could carry explicit entertainment; we synthesize cheaply).
            let delusion = clamp( (moodScores[.confidence] + moodScores[.chaos]) / 2 )
            let mce = clamp( (moodScores[.confidence] + moodScores[.social]) / 2 + 4 )
            let dtt = clamp( moodScores[.romance] - moodScores[.patience] / 3 + 8 )
            entertainment = try EntertainmentMetrics(
                delusion: delusion,
                mainCharacterEnergy: mce,
                dontTextThem: dtt
            )
        } catch {
            return nil
        }

        let summary = sunRecord.summary

        let dailyMood = DailyMood(
            dayOffset: dayOffset,
            scores: moodScores,
            note: nil,
            reading: reading,
            entertainment: entertainment,
            flags: flags,
            summary: summary
        )

        let rc = ResolvedContext(
            dayKey: dayKey,
            sunRecord: sunRecord,
            moonModifier: moonMod,
            risingModifier: risingMod,
            archetypeModifier: archetypeMod,
            scores: moodScores,
            appliedDeltas: applied
        )
        let prov = ResolvedProvenance(
            packVersion: pack.manifest.packVersion,
            generatorVersion: pack.manifest.compilerVersion,
            isPilot: pack.manifest.coverage.isPilot
        )
        return ResolvedDay(dailyMood: dailyMood, context: rc, provenance: prov)
    }

    /// Convenience for ForecastAnchor-based calls (same mapping as ForecastStore).
    static func resolve(
        dayOffset: Int,
        anchor: ForecastAnchor,
        context: PersonalizationContext,
        calendar: Calendar = .current,
        repository: BundledContentPackRepository
    ) -> ResolvedDay? {
        guard let date = anchor.date(forDayOffset: dayOffset, calendar: calendar) else { return nil }
        return resolve(date: date, dayOffset: dayOffset, context: context, calendar: calendar, repository: repository)
    }

    // MARK: - Text helpers

    private static func composePersonal(sun: String, moonFragment: String?, archetypeFragment: String?) -> String {
        // Prefer Moon fragment when available; otherwise use archetype.
        let extra = moonFragment ?? archetypeFragment
        guard let extra, !extra.isEmpty else { return sun }
        let combined = sun + " " + extra
        // Respect maxLength; if too long, keep Sun only (quality over cramming).
        if combined.count <= DayReadingSection.maxLength { return combined }
        return sun
    }

    private static func composeSocial(base: String, risingFragment: String?) -> String {
        guard let frag = risingFragment, !frag.isEmpty else { return base }
        let combined = base + " " + frag
        if combined.count <= DayReadingSection.maxLength { return combined }
        return base
    }

    private static func clamp(_ v: Int) -> Int { max(0, min(100, v)) }
}
