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
        // I.1 thematic diagnostics
        let dominantTheme: String?
        let secondaryTheme: String?
        let selectedMoonFragment: String?
        let selectedRisingFragment: String?
        let selectedArchetypeFragment: String?
        let personalAccentSource: String // "moon", "archetype", "none"
        let socialAccentSource: String // "rising", "none"
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
        let contentCycleVersion: String
        let generationMethod: String?
        let batchID: String? // compact, if available in manifest batches (not per-record)
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

        // Compose scores — all applicable bounded deltas each day (text and score rules differ).
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

        // Thematic selection — deterministic, tag+score driven
        let themes = dominantThemes(for: sunRecord, scores: moodScores)
        let dominantTheme = themes.dominant
        let secondaryTheme = themes.secondary

        let cycleVersion = pack.manifest.contentCycleVersion
        // Deterministic seeds (never Swift hashValue)
        let personalSeed = stableSeed(cycleVersion, dayKey.key, sunSign.rawValue, context.archetypeID, "personal", dominantTheme ?? "none")
        let socialSeed = stableSeed(cycleVersion, dayKey.key, sunSign.rawValue, context.archetypeID, "social", dominantTheme ?? "none")
        let moonSeed = stableSeed(cycleVersion, dayKey.key, sunSign.rawValue, context.moonSign ?? "none", dominantTheme ?? "none", "moon")
        let risingSeed = stableSeed(cycleVersion, dayKey.key, sunSign.rawValue, context.risingSign ?? "none", dominantTheme ?? "none", "rising")
        let archetypeSeed = stableSeed(cycleVersion, dayKey.key, sunSign.rawValue, context.archetypeID, dominantTheme ?? "none", "archetype")

        // Rotation: which accent appears where (ensures archetype not lost when Moon exists)
        let personalChoice = personalSeed % 10
        let personalSource: String
        let chosenMoonFragment: String?
        let chosenArchetypeFragment: String?
        // Resolve fragments theme-aware
        let moonFrag = moonMod?.fragment(for: dominantTheme, stableSeed: moonSeed)
        let archFrag = archetypeMod?.fragment(for: dominantTheme, stableSeed: archetypeSeed)

        if personalChoice < 4 {
            // Prefer Moon when available, else archetype
            if moonMod != nil, moonFrag != nil {
                personalSource = "moon"
            } else if archFrag != nil {
                personalSource = "archetype"
            } else {
                personalSource = "none"
            }
        } else if personalChoice < 8 {
            if archFrag != nil {
                personalSource = "archetype"
            } else if moonFrag != nil {
                personalSource = "moon"
            } else {
                personalSource = "none"
            }
        } else if personalChoice == 8 {
            // both only when composition remains natural — we pick Moon for personal and surface archetype elsewhere
            if moonFrag != nil {
                personalSource = "moon"
            } else if archFrag != nil {
                personalSource = "archetype"
            } else {
                personalSource = "none"
            }
        } else {
            personalSource = "none"
        }

        if personalSource == "moon" {
            chosenMoonFragment = moonFrag
            chosenArchetypeFragment = nil
        } else if personalSource == "archetype" {
            chosenMoonFragment = nil
            chosenArchetypeFragment = archFrag
        } else {
            chosenMoonFragment = nil
            chosenArchetypeFragment = nil
        }

        // Social slot: Rising accent on selected days
        let socialRoll = socialSeed % 10
        let socialSource: String
        let chosenRisingFragment: String?
        let risingFrag = risingMod?.fragment(for: dominantTheme, stableSeed: risingSeed)
        if socialRoll < 7, risingMod != nil, risingFrag != nil {
            socialSource = "rising"
            chosenRisingFragment = risingFrag
        } else {
            socialSource = "none"
            chosenRisingFragment = nil
        }

        // Love slot: Moon romance accent occasionally (if Moon available and theme is romance)
        let loveAccent: String? = {
            if dominantTheme == "romance", let mf = moonMod?.fragment(for: "romance", stableSeed: moonSeed), personalSource != "moon" {
                // Use Moon romance accent if not already used in personal and if deterministic coinflip passes
                let coin = stableSeed(cycleVersion, dayKey.key, "love", dominantTheme ?? "") % 2
                return coin == 0 ? mf : nil
            }
            return nil
        }()

        // Career slot: archetype career accent occasionally
        let careerAccent: String? = {
            if dominantTheme == "career" || secondaryTheme == "career" {
                let af = archetypeMod?.fragment(for: "career", stableSeed: archetypeSeed)
                if personalSource != "archetype", let a = af {
                    let coin = stableSeed(cycleVersion, dayKey.key, "career", dominantTheme ?? "") % 2
                    return coin == 0 ? a : nil
                }
                return nil
            }
            return nil
        }()

        // Text composition with controlled slots (no every-modifier-every-day).
        let headline = sunRecord.headline

        let personalText: String = {
            let extra = personalSource == "moon" ? chosenMoonFragment : (personalSource == "archetype" ? chosenArchetypeFragment : nil)
            return composePersonal(sun: sunRecord.personal, moonFragment: personalSource == "moon" ? extra : nil, archetypeFragment: personalSource == "archetype" ? extra : nil)
        }()

        let socialText = composeSocial(
            base: sunRecord.social,
            risingFragment: socialSource == "rising" ? chosenRisingFragment : nil
        )
        let loveText = appendOptionalAccent(base: sunRecord.love, accent: loveAccent)
        let careerText = appendOptionalAccent(base: sunRecord.career, accent: careerAccent)

        let reading: DayReading
        let flags: DayFlags
        let entertainment: EntertainmentMetrics
        do {
            reading = try DayReading(
                headline: headline,
                sections: [
                    try DayReadingSection(category: .personal, text: personalText),
                    try DayReadingSection(category: .love, text: loveText),
                    try DayReadingSection(category: .career, text: careerText),
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

        // Production summary style: avoid machine-looking "Taurus 03-01: overall..." — prefer humane.
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
            appliedDeltas: applied,
            dominantTheme: dominantTheme,
            secondaryTheme: secondaryTheme,
            selectedMoonFragment: chosenMoonFragment,
            selectedRisingFragment: chosenRisingFragment,
            selectedArchetypeFragment: chosenArchetypeFragment,
            personalAccentSource: personalSource,
            socialAccentSource: socialSource
        )
        let prov = ResolvedProvenance(
            packVersion: pack.manifest.packVersion,
            generatorVersion: pack.manifest.compilerVersion,
            isPilot: pack.manifest.coverage.isPilot,
            contentCycleVersion: cycleVersion,
            generationMethod: pack.manifest.generationMethod ?? pack.manifest.provenance.generationMethod,
            batchID: nil
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

    // MARK: - Theme selection

    private static func dominantThemes(for record: SunDayRecord, scores: MoodScores) -> (dominant: String?, secondary: String?) {
        // Prefer explicit tags that match ContentTheme, else derive from scores
        if let tags = record.tags, !tags.isEmpty {
            let valid = tags.filter { ContentTheme(rawValue: $0) != nil || MoodDimension(rawValue: $0) != nil }
            if !valid.isEmpty {
                return (valid.first, valid.count > 1 ? valid[1] : nil)
            }
        }
        // Score-derived: top 2 dimensions mapped to theme rawValue
        let sorted = MoodDimension.allCases.sorted { scores[$0] > scores[$1] }
        let top = sorted.prefix(2).map(\.rawValue)
        return (top.first, top.count > 1 ? top[1] : nil)
    }

    // MARK: - Deterministic seeding (stable, no Swift hashValue / Python hash)

    static func stableSeed(_ components: String...) -> UInt64 {
        HumayContentEngine.stableHash(components.joined(separator: "|"))
    }

    // MARK: - Text helpers

    private static func composePersonal(sun: String, moonFragment: String?, archetypeFragment: String?) -> String {
        let extra = moonFragment ?? archetypeFragment
        guard let extra, !extra.isEmpty else { return sun }
        let combined = sun + " " + extra
        if combined.count <= DayReadingSection.maxLength { return combined }
        return sun
    }

    private static func composeSocial(base: String, risingFragment: String?) -> String {
        guard let frag = risingFragment, !frag.isEmpty else { return base }
        let combined = base + " " + frag
        if combined.count <= DayReadingSection.maxLength { return combined }
        return base
    }

    private static func appendOptionalAccent(base: String, accent: String?) -> String {
        guard let accent, !accent.isEmpty else { return base }
        let combined = base + " " + accent
        if combined.count <= DayReadingSection.maxLength { return combined }
        return base
    }

    private static func clamp(_ v: Int) -> Int { max(0, min(100, v)) }
}
