import Foundation

/// The shipped deterministic provider.
///
/// Produces schema-valid, temporally coherent, fully personalized-feeling content
/// from seeded inputs alone. It doubles as:
/// - the development fixture provider (§5, §38),
/// - the offline fallback when no AI dataset exists (§33).
///
/// Content basis is always `.entertainmentFixture` — it never impersonates AI.
actor DeterministicContentProvider: PersonalizedContentProviding {
    static let identifier = "deterministic"
    static let generatorVersion = YearlyForecast.currentGeneratorVersion

    nonisolated var descriptor: PersonalizedContentProviderDescriptor {
        PersonalizedContentProviderDescriptor(
            providerIdentifier: Self.identifier,
            generatorVersion: Self.generatorVersion,
            promptCatalogVersion: IntelligenceVersions.promptCatalog,
            basis: .entertainmentFixture,
            modelIdentifier: nil
        )
    }

    init() {}

    // MARK: - Outline

    func generateYearOutline(
        subject: ForecastSubject,
        anchor: ForecastAnchor
    ) async throws -> GeneratedOutline {
        try Task.checkCancellation()
        let context = Self.yearContext(subject: subject, anchor: anchor)
        return GeneratedOutline(
            context: context,
            usage: GenerationUsage(requestCount: 1),
            modelIdentifier: nil
        )
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

        let offsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)
        guard !offsets.isEmpty else {
            throw GenerationError.validationFailed(.invalidMonthIndex(monthIndex))
        }

        var rng = HumayContentEngine.makeRNG("provider-month", subject.id.uuidString, String(monthIndex))
        let days = offsets.map { offset in
            Self.enrichedDay(
                subject: subject,
                anchor: anchor,
                dayOffset: offset,
                outline: outline,
                rng: &rng
            )
        }
        return GeneratedMonth(days: days, usage: GenerationUsage(requestCount: 1), modelIdentifier: nil)
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
        var rng = HumayContentEngine.makeRNG("provider-day", subject.id.uuidString, String(dayOffset))
        return Self.enrichedDay(subject: subject, anchor: anchor, dayOffset: dayOffset, outline: outline, rng: &rng)
    }

    // MARK: - Year context

    static func yearContext(subject: ForecastSubject, anchor: ForecastAnchor) -> YearContext {
        let archetype = HumayContentEngine.archetype(profileID: subject.id)
        let element = subject.sunSign.map(Element.of) ?? .air
        let elementFlavor: String = switch element {
        case .fire: "a year that runs hot and bright"
        case .earth: "a year built slowly, on purpose"
        case .air: "a year with excellent timing and worse focus"
        case .water: "a year felt twice as strongly as announced"
        }
        let yearTheme = "\(archetype.name): \(elementFlavor)."

        // Monthly tendencies from averaged base scores.
        var monthlyThemes: [MonthlyTheme] = []
        monthlyThemes.reserveCapacity(12)
        var notable: [NotablePeriod] = []

        for monthIndex in 0..<12 {
            let offsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)
            guard !offsets.isEmpty else {
                monthlyThemes.append(MonthlyTheme(monthIndex: monthIndex, theme: "Transit season", tendency: "Leans steady."))
                continue
            }
            let days = offsets.map { HumayContentEngine.baseScores(profileID: subject.id, birth: subject.birth, dayOffset: $0).scores }
            let top = dimensionAverages(days).max(by: { $0.value < $1.value })
            let themeName = top.map { monthlyThemeName(for: $0.dimension) } ?? "Transit season"
            let tendency = "Leans \(top.map { $0.dimension.displayName.lowercased() } ?? "steady")."
            monthlyThemes.append(MonthlyTheme(monthIndex: monthIndex, theme: themeName, tendency: tendency))
        }

        // Notable windows from full-year evaluation (cheap: 365 evaluations).
        let allOffsets = 0..<YearlyForecast.dayCount
        let romanceRanking = allOffsets.sorted {
            score(subject, $0, .romance) > score(subject, $1, .romance)
        }
        if romanceRanking.count >= 3 {
            let top3 = Array(romanceRanking.prefix(3))
            notable.append(NotablePeriod(
                startDayOffset: top3.min()!,
                endDayOffset: top3.max()!,
                label: "Strongest romance stretch",
                kind: .romance
            ))
        }
        let chaosRanking = allOffsets.sorted {
            score(subject, $0, .chaos) > score(subject, $1, .chaos)
        }
        if chaosRanking.count >= 1 {
            notable.append(NotablePeriod(
                startDayOffset: chaosRanking[0],
                endDayOffset: chaosRanking[0],
                label: "Peak chaos. Clear the calendar.",
                kind: .chaos
            ))
        }
        let patienceRanking = allOffsets.sorted {
            score(subject, $0, .patience) > score(subject, $1, .patience)
        }
        if patienceRanking.count >= 3 {
            let calm3 = Array(patienceRanking.prefix(3))
            notable.append(NotablePeriod(
                startDayOffset: calm3.min()!,
                endDayOffset: calm3.max()!,
                label: "Calmest window of the year",
                kind: .calm
            ))
        }

        // swiftlint:disable:next force_try
        do {
            return try YearContext(yearTheme: yearTheme, monthlyThemes: monthlyThemes, notablePeriods: notable)
        } catch {
            // Authored inputs are within bounds by construction; this is a
            // programming error, not a runtime condition.
            fatalError("Deterministic year context violated its own bounds: \(error)")
        }
    }

    private static func score(_ subject: ForecastSubject, _ offset: Int, _ dimension: MoodDimension) -> Int {
        HumayContentEngine.baseScores(profileID: subject.id, birth: subject.birth, dayOffset: offset).scores[dimension]
    }

    private static func dimensionAverages(_ days: [MoodScores]) -> [(dimension: MoodDimension, value: Double)] {
        MoodDimension.allCases.map { dimension in
            let total = days.reduce(0) { $0 + $1[dimension] }
            return (dimension, Double(total) / Double(max(days.count, 1)))
        }
    }

    private static func monthlyThemeName(for dimension: MoodDimension) -> String {
        switch dimension {
        case .overall: "Balance arc"
        case .romance: "Heart weather"
        case .social: "Orbit expansion"
        case .career: "Momentum season"
        case .energy: "Voltage month"
        case .confidence: "Main character block"
        case .patience: "Nerve training"
        case .chaos: "Structural turbulence"
        }
    }

    // MARK: - Day enrichment

    /// Builds one schema-valid day: engine scores + deterministic semantic copy.
    static func enrichedDay(
        subject: ForecastSubject,
        anchor: ForecastAnchor,
        dayOffset: Int,
        outline: YearContext,
        rng: inout SeededGenerator
    ) -> DailyMood {
        let base = HumayContentEngine.baseScores(profileID: subject.id, birth: subject.birth, dayOffset: dayOffset)
        let scores = base.scores
        let shape = DayShape(scores: scores)

        let headline = shape.headlines.pick(using: &rng)!
        let sections = [
            try! DayReadingSection(category: .personal, text: shape.personal.pick(using: &rng)!),
            try! DayReadingSection(category: .love, text: bandLine(scores[.romance], Self.loveBands, rng: &rng)),
            try! DayReadingSection(category: .career, text: bandLine(scores[.career], Self.careerBands, rng: &rng)),
            try! DayReadingSection(category: .social, text: bandLine(scores[.social], Self.socialBands, rng: &rng))
        ]
        let flags = HumayContentEngine.flagPair(rng: &rng)

        let entertainment = try! EntertainmentMetrics(
            delusion: clamp((scores[.confidence] + scores[.chaos]) / 2 + Int.random(in: -8...8, using: &rng)),
            mainCharacterEnergy: clamp((scores[.confidence] + scores[.social]) / 2 + Int.random(in: -6...10, using: &rng)),
            dontTextThem: clamp(scores[.romance] - (scores[.patience] / 3) + Int.random(in: -10...14, using: &rng))
        )

        let summary = shape.summaries.pick(using: &rng)!

        // Reading/flags construction uses validated types; the deterministic
        // tables are authored within bounds, so failures here would be
        // programming errors — trap loudly instead of hiding them.
        let reading: DayReading?
        let flagRecord: DayFlags?
        do {
            reading = try DayReading(headline: headline, sections: sections)
            flagRecord = try DayFlags(green: flags.green, red: flags.red)
        } catch {
            fatalError("Deterministic copy violated its own bounds: \(error)")
        }

        return DailyMood(
            dayOffset: dayOffset,
            scores: scores,
            note: base.note,
            reading: reading,
            entertainment: entertainment,
            flags: flagRecord,
            summary: summary
        )
    }

    private static func bandLine(
        _ value: Int,
        _ bands: (low: [String], mid: [String], high: [String]),
        rng: inout SeededGenerator
    ) -> String {
        let pool = value < 40 ? bands.low : value < 75 ? bands.mid : bands.high
        return pool.pick(using: &rng)!
    }

    private static func clamp(_ raw: Int) -> Int {
        max(4, min(98, raw))
    }

    // MARK: - Day shapes

    /// Coarse semantic classification of a day, driving copy selection so the
    /// year reads coherently instead of like random noise (§10).
    struct DayShape {
        let id: String
        let headlines: [String]
        let personal: [String]
        let summaries: [String]

        init(scores: MoodScores) {
            let romance = scores[.romance]
            let chaos = scores[.chaos]
            let confidence = scores[.confidence]
            let career = scores[.career]
            let social = scores[.social]
            let overall = scores[.overall]

            switch true {
            case romance >= 80 && chaos <= 50:
                self.init(
                    id: "warmRomance",
                    headlines: [
                        "Someone is about to make your week.",
                        "The heart department got funding today.",
                        "Soft launch your feelings. It's safe.",
                        "Romance is unusually cooperative.",
                        "Text first. Today you get away with it."
                    ],
                    personal: [
                        "Warmth lands exactly where you aim it.",
                        "Your timing in close conversations is unreasonably good.",
                        "The universe is flirting on your behalf."
                    ],
                    summaries: [
                        "High romance, manageable noise. Use the window.",
                        "The heart stuff goes suspiciously well today.",
                        "Openness pays off disproportionately."
                    ]
                )

            case chaos >= 75 || scores[.patience] <= 25:
                self.init(
                    id: "highChaos",
                    headlines: [
                        "Do not start anything. Finish snacks.",
                        "Today runs on plot twists. Buckle up.",
                        "The group chat will test you. Log off early.",
                        "Chaos levels: personally offensive.",
                        "Everything is fine. Allegedly. Statistically."
                    ],
                    personal: [
                        "Your patience is a limited resource. Ration it.",
                        "Small annoyances are wearing costumes today. Don't fight the costume.",
                        "Delay big decisions by 24 hours if you can."
                    ],
                    summaries: [
                        "Turbulent day. Protect the calendar.",
                        "High friction, survivable with snacks and silence.",
                        "Keep responses short; the storm passes."
                    ]
                )

            case confidence >= 80:
                self.init(
                    id: "highConfidence",
                    headlines: [
                        "You woke up confident. That's the first problem.",
                        "The audacity is fully funded today.",
                        "Main character energy: verified.",
                        "Ask for the thing. Today says yes-ish.",
                        "Your swagger has been approved by committee."
                    ],
                    personal: [
                        "Bold moves read as charming right now.",
                        "People are unusually receptive to your pitch.",
                        "Confidence is high; aim it at something real."
                    ],
                    summaries: [
                        "Strong posture, green lights everywhere.",
                        "A day for asking, starting, sending.",
                        "Charisma surplus detected. Spend it."
                    ]
                )

            case career >= 75:
                self.init(
                    id: "careerStrong",
                    headlines: [
                        "Work respects you today. Enjoy the anomaly.",
                        "Productive without being insufferable. Rare.",
                        "The to-do list fears you now.",
                        "One email could change the month. Send it.",
                        "Momentum found you before coffee did."
                    ],
                    personal: [
                        "Focus comes easy; protect it from meetings.",
                        "Your competence is visible today. Let it be.",
                        "Start the hard task second, not last."
                    ],
                    summaries: [
                        "Career-forward day with real traction.",
                        "Effort converts unusually efficiently.",
                        "Good day to bank a professional win."
                    ]
                )

            case social >= 78:
                self.init(
                    id: "socialBright",
                    headlines: [
                        "Everyone wants a piece of your calendar.",
                        "You're the group chat's main character.",
                        "Say yes to one invitation. Just one.",
                        "Social battery: unexpectedly renewable.",
                        "Someone needs exactly your humor today."
                    ],
                    personal: [
                        "Company energizes rather than drains.",
                        "One conversation will matter more than expected.",
                        "Be reachable. Good things are calling."
                    ],
                    summaries: [
                        "People-day. Choose the good ones.",
                        "High social yield per hour spent.",
                        "Connection beats productivity today."
                    ]
                )

            case overall <= 35:
                self.init(
                    id: "lowTide",
                    headlines: [
                        "Low-power mode is a valid lifestyle.",
                        "Today asks very little of you. Answer politely.",
                        "Coast. Gracefully. On purpose.",
                        "The bar is on the floor. Step over it.",
                        "Rest counts as strategy this quarter."
                    ],
                    personal: [
                        "Scale expectations down to 'survive kindly'.",
                        "Nothing needs your best work today.",
                        "Hydration, daylight, one small win."
                    ],
                    summaries: [
                        "Quiet, low-output day. That's allowed.",
                        "Gentle coasting recommended.",
                        "Recovery day disguised as Tuesday."
                    ]
                )

            default:
                self.init(
                    id: "steady",
                    headlines: [
                        "Steady day. Suspiciously manageable.",
                        "No headlines. Just a decent Tuesday-style day.",
                        "Smooth sailing, mildly boring, secretly great.",
                        "The stars have no notes. Rare.",
                        "Ordinary on the outside. Useful on the inside."
                    ],
                    personal: [
                        "Consistency outperforms heroics today.",
                        "Small steady effort compounds nicely.",
                        "A normal day is sometimes the whole point."
                    ],
                    summaries: [
                        "Even keel with quiet potential.",
                        "Unremarkable in the best way.",
                        "Solid ground. Build something small."
                    ]
                )
            }
        }

        private init(
            id: String,
            headlines: [String],
            personal: [String],
            summaries: [String]
        ) {
            self.id = id
            self.headlines = headlines
            self.personal = personal
            self.summaries = summaries
        }
    }

    private static let loveBands = (
        low: ["Low-key heart weather. Cozy beats dramatic."],
        mid: ["Steady warmth available if you show up for it."],
        high: ["Romance runs hot. Aim it carefully."]
    )

    private static let careerBands = (
        low: ["Career takes a back seat. Fine."],
        mid: ["Work responds to steady effort."],
        high: ["Professional momentum peaks. Use it."]
    )

    private static let socialBands = (
        low: ["Solitude recharges better than plans."],
        mid: ["Balanced company keeps the battery healthy."],
        high: ["Crowds love you today. Pick the fun ones."]
    )
}
