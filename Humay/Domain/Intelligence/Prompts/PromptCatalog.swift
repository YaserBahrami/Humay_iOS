import Foundation

/// Deterministic prompt versioning (§17). Changing a template bumps its version;
/// stored provenance records which prompt generation produced content.
struct PromptIdentifier: Sendable, Hashable, Codable, RawRepresentable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let yearOutline = PromptIdentifier(rawValue: "forecast.year-outline.v2")
    static let monthChunk = PromptIdentifier(rawValue: "forecast.month.v2")
    static let dayRegeneration = PromptIdentifier(rawValue: "forecast.day.v2")
    static let comparisonCommentary = PromptIdentifier(rawValue: "comparison.commentary.v1")
}

/// The product rules every generation prompt must carry (§18).
enum PromptPolicies {
    static let systemConstraints = """
    You generate entertainment content for Humay, a playful astrology app for \
    people who do not take astrology seriously.

    Hard rules:
    - This is entertainment. Never claim scientific, medical, financial or \
    legal certainty. Never give medical, financial or legal advice.
    - Never invent deterministic astrological facts. You receive the only \
    astrology values Humay trusts; leave everything else unavailable.
    - Humay-original metrics (Chaos, Delusion, Main Character Energy, \
    Don't Text Them, Social Battery) are invented fun, not astrology.
    - No dangerous, degrading or coercive instructions. Humor punches up, \
    never at vulnerable people.
    - Contemporary, smart, warm humor. No crystal-shop mysticism, no \
    corporate wellness speak, no dated memes.
    - Vary sentences. Never repeat a headline inside the same month.
    - Not every day is catastrophic; not every day is wonderful. Most days \
    are ordinary with texture.
    - Use Mercury retrograde at most once per year.
    - Respect the requested JSON schema exactly. No commentary outside it.
    """
}

/// A versioned prompt template. Builders produce the full request text from
/// structured context — prompts are never assembled ad hoc in networking code.
struct PromptTemplate<Input>: Sendable {
    let identifier: PromptIdentifier
    let build: @Sendable (Input) -> String
}

/// The v2 prompt catalog. Inputs are structured domain values; outputs are the
/// JSON-schema payloads defined alongside the remote provider contracts.
/// v2 adds explicit PersonalizationContext to month/day generation so they no
/// longer depend only on prose from the year outline.
enum PromptCatalog {
    static let yearOutline = PromptTemplate<YearOutlineInput>(
        identifier: .yearOutline
    ) { input in
        """
        \(PromptPolicies.systemConstraints)

        Task: create the canonical annual plan for one person's entertainment \
        forecast year starting \(input.startDateDescription).

        Person context (the only astrology Humay trusts for them — deterministic Big Three):
        - Sun sign: \(input.sunSign ?? "unavailable")
        - Moon sign: \(input.moonSign ?? "unavailable (needs birth time)")
        - Rising sign: \(input.risingSign ?? "unavailable (needs birth time + place)")
        - Humay archetype: \(input.archetypeName)
        - Birth time known: \(input.birthTimeKnown)
        - Astrology context for flavor (optional degrees): \(input.astrologyContextJSON)

        AI must never overwrite these values or invent other placements.

        Return JSON: {"yearTheme": string (<=140 chars), "monthlyThemes": \
        exactly 12 objects {"monthIndex": 0-11, "theme": string, "tendency": \
        string}, "notablePeriods": 3-6 objects {"startDayOffset": int, \
        "endDayOffset": int, "label": string, "kind": one of \
        romance|chaos|career|social|calm|confidence}}.
        """
    }

    static let monthChunk = PromptTemplate<MonthChunkInput>(
        identifier: .monthChunk
    ) { input in
        """
        \(PromptPolicies.systemConstraints)

        Task: generate days \(input.startDayOffset)–\(input.endDayOffset) \
        (month \(input.monthIndex + 1) of 12) for this person.

        Person context (same canonical Big Three as year outline — do not re-derive):
        - Sun sign: \(input.personalization.sunSign ?? "unavailable")
        - Moon sign: \(input.personalization.moonSign ?? "unavailable")
        - Rising sign: \(input.personalization.risingSign ?? "unavailable")
        - Humay archetype: \(input.personalization.archetypeName)
        - Birth time known: \(input.personalization.birthTimeKnown)
        - Astrology context: \(input.personalization.astrologyContextJSON)

        Annual context you must stay coherent with:
        - Year theme: \(input.yearTheme)
        - This month: \(input.monthTheme) — \(input.monthTendency)
        - Notable periods: \(input.notablePeriodsSummary)

        Temporal coherence rules: adjacent days must correlate (no 15→94→10 \
        whiplash unless a notable period explains it); include ordinary days; \
        rare spikes only where the annual plan hints at them.

        Scores are integers 0–100 across exactly these dimensions: overall, \
        romance, social, career, energy, confidence, patience, chaos. \
        Entertainment metrics (delusion, mainCharacterEnergy, dontTextThem) \
        are integers 0–100 and are Humay-invented fun, not astrology.

        Return JSON: {"days": [one object per day: {"dayOffset": int, \
        "scores": {…8 dimensions…}, "entertainment": {delusion, \
        mainCharacterEnergy, dontTextThem}, "reading": {"headline": string \
        <=120 chars, "personal": string <=600, "love": string <=600, \
        "career": string <=600, "social": string <=600}, "flags": {"green": \
        string <=140, "red": string <=140}, "summary": string <=280, \
        "note": string|null}]}. Exactly \(input.dayCount) days.
        """
    }

    static let dayRegeneration = PromptTemplate<MonthChunkInput>(
        identifier: .dayRegeneration
    ) { input in
        """
        \(PromptPolicies.systemConstraints)

        Task: regenerate exactly one day (dayOffset \(input.startDayOffset)) \
        consistent with month \(input.monthIndex + 1) theme: \
        \(input.monthTheme).

        Person context (same canonical Big Three):
        - Sun sign: \(input.personalization.sunSign ?? "unavailable")
        - Moon sign: \(input.personalization.moonSign ?? "unavailable")
        - Rising sign: \(input.personalization.risingSign ?? "unavailable")
        - Humay archetype: \(input.personalization.archetypeName)
        - Astrology context: \(input.personalization.astrologyContextJSON)

        Return the same day JSON shape as monthly generation, with exactly \
        one day.
        """
    }

    static let comparisonCommentary = PromptTemplate<ComparisonCommentaryInput>(
        identifier: .comparisonCommentary
    ) { input in
        """
        \(PromptPolicies.systemConstraints)

        Task: write one playful line (<=140 chars) about two people's \
        overlapping forecast day. You receive only these structured numbers: \
        \(input.summary). Do not invent additional astrology.

        Return JSON: {"line": string}.
        """
    }
}

// MARK: - Template inputs

struct YearOutlineInput: Sendable {
    let startDateDescription: String
    let sunSign: String?
    let moonSign: String?
    let risingSign: String?
    let astrologyContextJSON: String
    let archetypeName: String
    let birthTimeKnown: Bool

    /// Convenience for callers still using the v1 subset.
    init(startDateDescription: String, sunSign: String?, archetypeName: String, birthTimeKnown: Bool) {
        self.startDateDescription = startDateDescription
        self.sunSign = sunSign
        self.moonSign = nil
        self.risingSign = nil
        self.astrologyContextJSON = "{\"sun\":\"\(sunSign ?? "unavailable")\"}"
        self.archetypeName = archetypeName
        self.birthTimeKnown = birthTimeKnown
    }

    init(
        startDateDescription: String,
        sunSign: String?,
        moonSign: String?,
        risingSign: String?,
        astrologyContextJSON: String,
        archetypeName: String,
        birthTimeKnown: Bool
    ) {
        self.startDateDescription = startDateDescription
        self.sunSign = sunSign
        self.moonSign = moonSign
        self.risingSign = risingSign
        self.astrologyContextJSON = astrologyContextJSON
        self.archetypeName = archetypeName
        self.birthTimeKnown = birthTimeKnown
    }

    /// Factory from PersonalizationContext
    init(context: PersonalizationContext, startDateDescription: String) {
        self.startDateDescription = startDateDescription
        self.sunSign = context.sunSign
        self.moonSign = context.moonSign
        self.risingSign = context.risingSign
        self.astrologyContextJSON = context.astrologyContextJSON
        self.archetypeName = context.archetypeName
        self.birthTimeKnown = context.birthTimeKnown
    }
}

struct MonthChunkInput: Sendable {
    let monthIndex: Int
    let startDayOffset: Int
    let endDayOffset: Int
    let dayCount: Int
    let yearTheme: String
    let monthTheme: String
    let monthTendency: String
    let notablePeriodsSummary: String
    let personalization: PersonalizationContext

    /// Legacy init for deterministic fallback / tests that don't need personalization.
    init(monthIndex: Int, startDayOffset: Int, endDayOffset: Int, dayCount: Int,
         yearTheme: String, monthTheme: String, monthTendency: String, notablePeriodsSummary: String) {
        self.monthIndex = monthIndex
        self.startDayOffset = startDayOffset
        self.endDayOffset = endDayOffset
        self.dayCount = dayCount
        self.yearTheme = yearTheme
        self.monthTheme = monthTheme
        self.monthTendency = monthTendency
        self.notablePeriodsSummary = notablePeriodsSummary
        // Fallback personalization with no astrology (deterministic provider not sensitive)
        self.personalization = PersonalizationContext(
            sunSign: nil, sunDegreeWithinSign: nil,
            moonSign: nil, moonDegreeWithinSign: nil,
            risingSign: nil, risingDegreeWithinSign: nil,
            birthTimeKnown: false, archetypeID: "fallback", archetypeName: "Humay"
        )
    }

    init(monthIndex: Int, startDayOffset: Int, endDayOffset: Int, dayCount: Int,
         yearTheme: String, monthTheme: String, monthTendency: String,
         notablePeriodsSummary: String, personalization: PersonalizationContext) {
        self.monthIndex = monthIndex
        self.startDayOffset = startDayOffset
        self.endDayOffset = endDayOffset
        self.dayCount = dayCount
        self.yearTheme = yearTheme
        self.monthTheme = monthTheme
        self.monthTendency = monthTendency
        self.notablePeriodsSummary = notablePeriodsSummary
        self.personalization = personalization
    }
}

struct ComparisonCommentaryInput: Sendable {
    let summary: String
}
