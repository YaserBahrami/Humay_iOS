#if DEBUG
import Foundation

/// Development-owned D2 composition. It is excluded from Release compilation.
enum DevelopmentD2Sample {
    static let profile = UserProfile(
        id: UUID(uuidString: "77777777-7777-4777-8777-777777777777")!,
        displayName: "Yaser",
        birth: BirthDetails(year: 1993, month: 8, day: 7)
    )

    static let yaser = CirclePerson(
        id: UUID(uuidString: "11111111-1111-4111-8111-111111111111")!,
        name: "Yaser",
        birth: BirthDetails(year: 1993, month: 8, day: 7),
        westernSunSign: .leo
    )

    static let salma = CirclePerson(
        id: UUID(uuidString: "22222222-2222-4222-8222-222222222222")!,
        name: "Salma",
        birth: BirthDetails(year: 1995, month: 6, day: 3),
        westernSunSign: .gemini
    )

    static let todayContent = TodayContent(
        greeting: "Good evening,\nYaser",
        introduction: "The universe has a few things for you today.",
        cosmicInsight: "A mix of ambition and main-character energy.",
        highlights: [
            DailyReadingHighlight(
                category: .love,
                text: "Someone’s thinking about you. Don’t overthink it."
            ),
            DailyReadingHighlight(
                category: .career,
                text: "Perfect day to show your ideas. People are listening."
            ),
            DailyReadingHighlight(
                category: .money,
                text: "Good for planning, not for impulsing."
            )
        ],
        roastTitle: "Feeling brave?",
        roastBody: "The stars won’t hold back."
    )

    static let freeReadings: [HoroscopePeriod: DailyHoroscopeContent] = [
        .today: DailyHoroscopeContent(
            period: .today,
            date: sampleDate,
            sign: .leo,
            basis: .freeWesternSunSign(.leo),
            headline: "You’re the main character today",
            body: "The spotlight finds you naturally. Use your confidence for something meaningful, not just for winning arguments.",
            highlights: standardHighlights,
            tip: "Your vibe attracts your tribe. Choose wisely."
        ),
        .tomorrow: DailyHoroscopeContent(
            period: .tomorrow,
            date: sampleDate.addingTimeInterval(86_400),
            sign: .leo,
            basis: .freeWesternSunSign(.leo),
            headline: "Leave room for a pleasant surprise",
            body: "A slower start helps you notice the useful invitation hiding inside an ordinary conversation.",
            highlights: [
                DailyReadingHighlight(category: .love, text: "Say what you mean, then let the answer breathe."),
                DailyReadingHighlight(category: .career, text: "A practical follow-up lands better than a grand pitch."),
                DailyReadingHighlight(category: .money, text: "Review one recurring expense before adding another."),
                DailyReadingHighlight(category: .health, text: "Make your evening gentler than your morning.")
            ],
            tip: "Curiosity opens doors that force cannot."
        ),
        .thisWeek: DailyHoroscopeContent(
            period: .thisWeek,
            date: sampleDate,
            sign: .leo,
            basis: .freeWesternSunSign(.leo),
            headline: "Make confidence useful",
            body: "This week rewards visible effort, honest conversations and plans that leave enough space for other people.",
            highlights: [
                DailyReadingHighlight(category: .love, text: "Warmth works best without a performance attached."),
                DailyReadingHighlight(category: .career, text: "Share the idea, then invite sharper questions."),
                DailyReadingHighlight(category: .money, text: "Choose the plan you can repeat, not the flashy shortcut."),
                DailyReadingHighlight(category: .health, text: "Consistency will feel better than intensity.")
            ],
            tip: "Be memorable for what you build, not only how brightly you enter."
        )
    ]

    static let preciseDailyReading = DailyHoroscopeContent(
        period: .today,
        date: sampleDate,
        sign: .leo,
        basis: .precisePersonalized,
        headline: "Lead warmly, then listen closely",
        body: "Your sample personalized reading emphasizes confident expression alongside a need for patient listening. This is development content, not a provider calculation.",
        highlights: [
            DailyReadingHighlight(category: .love, text: "Direct affection lands well when you leave room for nuance."),
            DailyReadingHighlight(category: .career, text: "Take ownership of the opening, then share the stage."),
            DailyReadingHighlight(category: .money, text: "A measured decision supports the freedom you want later."),
            DailyReadingHighlight(category: .health, text: "Move energy through your body before asking your mind for more.")
        ],
        tip: "Let confidence create safety, not pressure."
    )

    static let freeCompatibility = FreeCompatibilityResult(
        pair: pair,
        catalogKey: WesternSunSignPairKey(first: .leo, second: .gemini),
        overallScore: score(74),
        relationshipLabel: "Bright Connection",
        shortSummary: "Leo warmth meets Gemini curiosity.",
        metrics: [
            CompatibilityMetric(kind: .chemistry, score: score(82)),
            CompatibilityMetric(kind: .communication, score: score(78)),
            CompatibilityMetric(kind: .emotionalConnection, score: score(65)),
            CompatibilityMetric(kind: .adventure, score: score(84))
        ],
        ourTake: "You keep each other interested and energized. Make space for steadiness when the pace gets fast."
    )

    static let preciseCompatibility = PreciseCompatibilityResult(
        pair: pair,
        overallScore: score(81),
        relationshipLabel: "Great Connection",
        shortSummary: "You balance each other beautifully.",
        metrics: [
            CompatibilityMetric(kind: .chemistry, score: score(88)),
            CompatibilityMetric(kind: .communication, score: score(76)),
            CompatibilityMetric(kind: .emotionalConnection, score: score(79)),
            CompatibilityMetric(kind: .adventure, score: score(81))
        ],
        ourTake: "You hype each other up and bring out the best… and the chaos. But it works."
    )

    static func makeInput(arguments: [String] = ProcessInfo.processInfo.arguments) -> D2FeatureInput {
        let todayState = makeTodayState(named: argumentValue(after: "-HumayD2TodayState", in: arguments))
        let dailyStateName = argumentValue(after: "-HumayD2DailyState", in: arguments)
        let circleState = makeCircleState(named: argumentValue(after: "-HumayD2CircleState", in: arguments))
        let compatibilityState = makeCompatibilityState(
            named: argumentValue(after: "-HumayD2CompatibilityState", in: arguments)
        )

        var dailyStates = freeReadings.mapValues(DailyHoroscopeFeatureState.free)
        if let dailyStateName, let todayReading = freeReadings[.today] {
            dailyStates[.today] = switch dailyStateName {
            case "loading": .loading(period: .today)
            case "locked": .preciseLocked(freeReading: todayReading)
            case "precise": .preciseLoaded(preciseDailyReading)
            case "cached": .cached(preciseDailyReading, savedAt: sampleDate)
            case "offline": .offline(cached: preciseDailyReading)
            case "failed": .failed(period: .today, message: "The sample reading could not be opened.")
            default: .free(todayReading)
            }
        }

        return D2FeatureInput(
            source: .developmentSample,
            today: todayState,
            dailyHoroscope: dailyStates,
            circle: circleState,
            compatibility: compatibilityState,
            preciseDailyPreview: preciseDailyReading,
            preciseCompatibilityPreview: preciseCompatibility
        )
    }

    private static let pair = CompatibilityPair(first: yaser, second: salma)

    private static let standardHighlights = [
        DailyReadingHighlight(category: .love, text: "Flirty energy is high. Someone might surprise you."),
        DailyReadingHighlight(category: .career, text: "A conversation opens a new door. Say yes."),
        DailyReadingHighlight(category: .money, text: "Good day for planning and smart moves."),
        DailyReadingHighlight(category: .health, text: "A steady rhythm protects your energy.")
    ]

    private static let sampleDate: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(from: DateComponents(year: 2026, month: 8, day: 12))!
    }()

    private static func score(_ value: Int) -> CompatibilityScore {
        guard let score = CompatibilityScore(value) else {
            preconditionFailure("Development compatibility score must be between 0 and 100")
        }
        return score
    }

    private static func argumentValue(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private static func makeTodayState(named name: String?) -> TodayFeatureState {
        switch name {
        case "loading": .loading
        case "cached": .cached(todayContent, savedAt: sampleDate)
        case "offline": .offline(cached: todayContent)
        case "failed": .failed(message: "Today’s development content could not be opened.")
        default: .loaded(todayContent)
        }
    }

    private static func makeCircleState(named name: String?) -> CircleFeatureState {
        switch name {
        case "loading": .loading
        case "empty": .empty
        case "offline": .offline(cached: [yaser, salma])
        case "failed": .failed(message: "Your development Circle could not be opened.")
        default: .loaded([yaser, salma])
        }
    }

    private static func makeCompatibilityState(named name: String?) -> CompatibilityFeatureState {
        switch name {
        case "entry": .entry
        case "loading": .loading(pair: pair)
        case "locked": .preciseLocked(freeResult: freeCompatibility)
        case "precise": .preciseLoaded(preciseCompatibility)
        case "cached": .cached(preciseCompatibility, savedAt: sampleDate)
        case "offline": .offline(cached: preciseCompatibility)
        case "failed": .failed(pair: pair, message: "The development result could not be opened.")
        default: .freeLoaded(freeCompatibility)
        }
    }
}
#endif
