import Foundation

/// Deterministic entertainment content generation.
///
/// This is the fixture-grade stand-in for future AI personalization: pure
/// functions, no clock access, fully seeded by stable inputs so the same profile
/// + day always yields identical content. AI generation will replace the copy
/// sources behind these boundaries without changing the models screens consume.
///
/// Information-class discipline:
/// - Sun signs come from the deterministic date table (Category A convention).
/// - Everything else this engine produces is interpretation or Humay-original
///   play (Categories B/C) and must never be presented as astronomical fact.
enum HumayContentEngine {
    // MARK: - Public API

    static func archetype(profileID: UUID) -> HumayArchetype {
        let index = Int(stableHash("archetype", "\(profileID.uuidString)") % UInt64(HumayArchetype.catalog.count))
        return HumayArchetype.catalog[index]
    }

    static func dailyFeed(
        profile: UserProfile,
        date: Date,
        calendar: Calendar,
        mode: PersonalityMode,
        skyEvent: CosmicEventSeed?
    ) -> [FeedItem] {
        let dayNumber = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        let weekday = date.formatted(.dateTime.weekday(.wide).locale(calendar.locale ?? .current)).uppercased()
        let sign = SunSignCalendar.westernSunSign(month: profile.birth.month, day: profile.birth.day)
        let signName = (sign?.displayName ?? "Everyone").uppercased()
        let rng = makeRNG("feed", profile.id.uuidString, String(dayNumber))

        var generator = rng
        var items: [FeedItem] = []

        items.append(headlineItem(kicker: "\(signName) • \(weekday)", sign: sign, mode: mode, rng: &generator))
        items.append(meterSetItem(dayNumber: dayNumber, mode: mode, rng: &generator))

        if Int.random(in: 0..<2, using: &generator) == 0 {
            items.append(revealItem(rng: &generator))
        } else {
            items.append(flagPairItem(rng: &generator))
        }

        if let weather = cosmicWeatherItem(event: skyEvent, rng: &generator) {
            items.append(weather)
        }

        items.append(roastItem(sign: sign, mode: mode, rng: &generator))

        if dayNumber.isMultiple(of: 3) {
            let anchor = ForecastAnchor(date: date, calendar: calendar)
            items.append(forecastTeaserItem(profile: profile, anchor: anchor, rng: &generator))
        }

        return items
    }

    static func yearlyForecast(profileID: UUID, birth: BirthDetails) -> YearlyForecast {
        let days = (0..<YearlyForecast.dayCount).map { offset -> DailyMood in
            let base = baseScores(profileID: profileID, birth: birth, dayOffset: offset)
            return DailyMood(dayOffset: offset, scores: base.scores, note: base.note)
        }
        return YearlyForecast(
            profileID: profileID,
            days: days,
            provenance: .fixture(generatorVersion: YearlyForecast.currentGeneratorVersion)
        )
    }

    /// Deterministic per-day base scores shared by the fixture feed and the
    /// intelligence layer's deterministic provider, so fallback content and
    /// enriched content never disagree about the underlying numbers.
    static func baseScores(
        profileID: UUID,
        birth: BirthDetails,
        dayOffset: Int
    ) -> (scores: MoodScores, note: String?) {
        var rng = makeRNG("year", profileID.uuidString, String(dayOffset))
        let scores = moodScores(offset: dayOffset, birth: birth, rng: &rng)
        let note = dayNote(offset: dayOffset, birth: birth)
        return (scores, note)
    }

    static func compatibility(
        first: ConnectionPerson,
        second: ConnectionPerson,
        mode: PersonalityMode
    ) -> CompatibilityVerdict {
        let pairSeed = [first.id.uuidString, second.id.uuidString].sorted().joined(separator: "|")
        var rng = makeRNG("compat", pairSeed)

        let elementPair = ElementPair(
            first.westernSunSign.flatMap(Element.of),
            second.westernSunSign.flatMap(Element.of)
        )
        let baseScore = elementPair.baseAffinity
        let jitter = Int.random(in: -6...8, using: &rng)
        let overall = max(38, min(97, baseScore + jitter))

        let summary = """
        \(first.name) + \(second.name): \(elementPair.headline.lowercased()) \
        \(second.relationshipKind.contextLine())
        """

        return CompatibilityVerdict(
            firstPersonID: first.id,
            secondPersonID: second.id,
            overall: overall,
            headline: compatibilityHeadline(overall: overall, rng: &rng),
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            funMetrics: [
                FunMeter(metric: .flirtingPotential, value: clampScore(baseScore + Int.random(in: -10...12, using: &rng))),
                FunMeter(metric: .communication, value: Int.random(in: 30...96, using: &rng)),
                FunMeter(metric: .sharedChaos, value: Int.random(in: 35...98, using: &rng)),
                FunMeter(metric: .longTermPotential, value: clampScore(baseScore + Int.random(in: -12...10, using: &rng)))
            ],
            verdictLines: verdictLines(rng: &rng),
            astrologyBasis: elementPair.astrologyNote(
                firstSign: first.westernSunSign?.displayName ?? "unknown",
                secondSign: second.westernSunSign?.displayName ?? "unknown"
            )
        )
    }

    // MARK: - Feed pieces

    private static func headlineItem(
        kicker: String,
        sign: WesternZodiacSign?,
        mode: PersonalityMode,
        rng: inout SeededGenerator
    ) -> FeedItem {
        let pool: [String]
        switch mode {
        case .delulu: pool = DeluluHeadlines.all
        case .drama: pool = DramaHeadlines.all
        case .roast, .savage: pool = SpicyHeadlines.all
        case .normal, .bestie, .soft: pool = BaseHeadlines.all
        }
        let supporting = sign.map { SignFlavor.supportingLine(for: $0) }
        return FeedItem(
            id: "headline",
            kind: .headline(HeadlineContent(
                kicker: kicker,
                headline: pool.pick(using: &rng)!,
                supporting: supporting
            ))
        )
    }

    private static func meterSetItem(dayNumber: Int, mode: PersonalityMode, rng: inout SeededGenerator) -> FeedItem {
        let core: [FunMetric] = [.confidence, .patience, .chaos]
        let rotating = Array(FunMetric.allCases.filter { !core.contains($0) }.shuffled(using: &rng).prefix(2))
        var metrics = (core + rotating).shuffled(using: &rng)

        if mode == .roast || mode == .savage {
            metrics = ([FunMetric.dontTextThem] + metrics.filter { $0 != .dontTextThem })
        }

        let meters = metrics.prefix(4).map { metric -> FunMeter in
            let value = Int.random(in: 18...97, using: &rng)
            return FunMeter(
                metric: metric,
                value: value,
                caption: MeterCopy.caption(for: metric, value: value)
            )
        }

        return FeedItem(
            id: "meters-\(dayNumber)",
            kind: .meterSet(MeterSetContent(title: "Today's energy", meters: Array(meters)))
        )
    }

    private static func revealItem(rng: inout SeededGenerator) -> FeedItem {
        FeedItem(
            id: "reveal",
            kind: .reveal(RevealContent(
                prompt: "Today's secret reading",
                hint: "Hold to reveal",
                secret: RevealSecrets.all.pick(using: &rng)!,
                followUp: RevealFollowUps.all.pick(using: &rng)!
            ))
        )
    }

    private static func flagPairItem(rng: inout SeededGenerator) -> FeedItem {
        FeedItem(
            id: "flags",
            kind: .flagPair(FlagPairContent(
                redFlag: RedFlags.all.pick(using: &rng)!,
                greenFlag: GreenFlags.all.pick(using: &rng)!
            ))
        )
    }

    private static func cosmicWeatherItem(
        event: CosmicEventSeed?,
        rng: inout SeededGenerator
    ) -> FeedItem? {
        if let event {
            return FeedItem(
                id: "weather-\(event.id)",
                kind: .cosmicWeather(CosmicWeatherContent(
                    headline: event.humanHeadline,
                    factLine: event.factLine,
                    skyEventID: event.id
                ))
            )
        }

        guard !GenericSkyLines.all.isEmpty else { return nil }
        let line = GenericSkyLines.all.pick(using: &rng)!
        return FeedItem(
            id: "weather-generic",
            kind: .cosmicWeather(CosmicWeatherContent(
                headline: line.0,
                factLine: line.1,
                skyEventID: nil
            ))
        )
    }

    private static func roastItem(
        sign: WesternZodiacSign?,
        mode: PersonalityMode,
        rng: inout SeededGenerator
    ) -> FeedItem {
        let pair: (String, String)
        switch mode {
        case .delulu: pair = DeluluRoasts.all.pick(using: &rng)!
        case .drama: pair = DramaRoasts.all.pick(using: &rng)!
        case .roast, .savage: pair = SpicyRoasts.all.pick(using: &rng)!
        case .bestie: pair = BestieRoasts.all.pick(using: &rng)!
        case .soft: pair = SoftRoasts.all.pick(using: &rng)!
        case .normal: pair = NormalRoasts.all.pick(using: &rng)!
        }
        return FeedItem(
            id: "roast",
            kind: .roast(RoastContent(title: pair.0, body: pair.1))
        )
    }

    private static func forecastTeaserItem(
        profile: UserProfile,
        anchor: ForecastAnchor,
        rng: inout SeededGenerator
    ) -> FeedItem {
        let forecast = yearlyForecast(profileID: profile.id, birth: profile.birth)
        let window = 30

        let bestRomance = bestDayInWindow(forecast, dimension: .romance, window: window)
        let worstPatience = worstDayInWindow(forecast, dimension: .patience, window: window)
        let peakConfidence = bestDayInWindow(forecast, dimension: .confidence, window: window)

        var entries: [ForecastTeaserContent.Entry] = []
        if let bestRomance {
            entries.append(ForecastTeaserContent.Entry(
                dayOffset: bestRomance.dayOffset,
                label: "Best romance day",
                detail: anchor.date(forDayOffset: bestRomance.dayOffset)?
                    .formatted(.dateTime.day().month(.wide)) ?? ""
            ))
        }
        if let worstPatience {
            entries.append(ForecastTeaserContent.Entry(
                dayOffset: worstPatience.dayOffset,
                label: "Maximum chaos",
                detail: anchor.date(forDayOffset: worstPatience.dayOffset)?
                    .formatted(.dateTime.day().month(.wide)) ?? ""
            ))
        }
        if let peakConfidence {
            entries.append(ForecastTeaserContent.Entry(
                dayOffset: peakConfidence.dayOffset,
                label: "Strongest confidence",
                detail: anchor.date(forDayOffset: peakConfidence.dayOffset)?
                    .formatted(.dateTime.day().month(.wide)) ?? ""
            ))
        }

        return FeedItem(
            id: "teaser",
            kind: .forecastTeaser(ForecastTeaserContent(title: "Next 30 days", entries: entries))
        )
    }

    private static func bestDayInWindow(_ forecast: YearlyForecast, dimension: MoodDimension, window: Int) -> DailyMood? {
        forecast.days.prefix(window).max { $0.scores[dimension] < $1.scores[dimension] }
    }

    private static func worstDayInWindow(_ forecast: YearlyForecast, dimension: MoodDimension, window: Int) -> DailyMood? {
        forecast.days.prefix(window).min { $0.scores[dimension] < $1.scores[dimension] }
    }

    // MARK: - Yearly scores

    private static func moodScores(
        offset: Int,
        birth: BirthDetails,
        rng: inout SeededGenerator
    ) -> MoodScores {
        func wave(_ phase: Double, _ period: Double, _ amplitude: Double) -> Double {
            sin(phase + Double(offset) / period * 2 * Double.pi) * amplitude
        }

        var values: [MoodDimension: Int] = [:]

        let energyBase = 55.0 + wave(0.3, 23, 22) + Double.random(in: -8...8, using: &rng)
        values[.energy] = clampScore(Int(energyBase))

        let socialBase = 50.0 + wave(1.7, 31, 25) + Double.random(in: -9...9, using: &rng)
        values[.social] = clampScore(Int(socialBase))

        let careerBase = 52.0 + wave(2.9, 47, 20) + Double.random(in: -7...7, using: &rng)
        values[.career] = clampScore(Int(careerBase))

        let romanceBase = 54.0 + wave(4.1, 37, 24) + Double.random(in: -8...8, using: &rng)
        values[.romance] = clampScore(Int(romanceBase))

        let confidenceBase = 58.0 + wave(0.9, 41, 18) + Double.random(in: -6...6, using: &rng)
        values[.confidence] = clampScore(Int(confidenceBase))

        let patienceRaw = 50.0 + wave(5.3, 29, 26) + Double.random(in: -7...7, using: &rng)
        values[.patience] = clampScore(Int(patienceRaw))

        // Chaos runs opposite patience with its own weather.
        let chaosRaw = 100 - patienceRaw + wave(2.2, 19, 10) + Double.random(in: -6...6, using: &rng)
        values[.chaos] = clampScore(Int(chaosRaw))

        let energyScore = Double(values[.energy]!)
        let socialScore = Double(values[.social]!)
        let careerScore = Double(values[.career]!)
        let romanceScore = Double(values[.romance]!)
        let confidenceScore = Double(values[.confidence]!)
        let patienceScore = Double(values[.patience]!)
        let chaosInverse = 100 - Double(values[.chaos]!)

        let weighted = energyScore * 0.9
            + socialScore * 0.8
            + careerScore * 0.8
            + romanceScore * 0.9
            + confidenceScore
            + patienceScore * 0.6
            + chaosInverse * 0.5
        let overall = Int(weighted / 5.5)
        values[.overall] = clampScore(overall + Int.random(in: -4...4, using: &rng))

        return MoodScores(values)
    }

    private static func dayNote(offset: Int, birth: BirthDetails) -> String? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let thisYear = calendar.component(.year, from: Date.now)
        guard let januaryFirst = calendar.date(from: DateComponents(year: thisYear, month: 1, day: 1)),
              let date = calendar.date(byAdding: .day, value: offset, to: januaryFirst)
        else { return nil }

        let components = calendar.dateComponents([.month, .day], from: date)
        if components.month == birth.month, components.day == birth.day {
            return "Your birthday. The main character energy is legally mandatory."
        }
        if components.month == 1, components.day == 1 {
            return "New year. Same you, fresh alibi."
        }
        return nil
    }

    // MARK: - Compatibility helpers

    private static func compatibilityHeadline(overall: Int, rng: inout SeededGenerator) -> String {
        let pool: [String]
        switch overall {
        case ..<55: pool = ["Complicated. In a fun way. Probably.", "Handle with snacks.", "High maintenance, high reward."]
        case 55..<75: pool = ["Dangerously convincing.", "Strong vibes, questionable logistics.", "This works. Somehow."]
        default: pool = ["Annoyingly compatible.", "The universe is showing off.", "Suspiciously good."]
        }
        return pool.pick(using: &rng)!
    }

    private static func verdictLines(rng: inout SeededGenerator) -> [VerdictLine] {
        [
            VerdictLine(question: "Who apologizes first?", answer: VerdictAnswers.apology.pick(using: &rng)!),
            VerdictLine(question: "Would they survive IKEA?", answer: VerdictAnswers.ikea.pick(using: &rng)!),
            VerdictLine(question: "Who leaves whom on read?", answer: VerdictAnswers.read.pick(using: &rng)!),
            VerdictLine(question: "Should they share passwords?", answer: VerdictAnswers.passwords.pick(using: &rng)!)
        ]
    }

    private static func clampScore(_ raw: Int) -> Int {
        max(8, min(97, raw))
    }

    // MARK: - Expression surface (mode-local, used by the intelligence layer)

    /// Mode-flavored roast copy. Expression only — never changes data.
    static func roastCopy(mode: PersonalityMode, rng: inout SeededGenerator) -> (title: String, body: String) {
        let pair: (String, String)
        switch mode {
        case .delulu: pair = DeluluRoasts.all.pick(using: &rng)!
        case .drama: pair = DramaRoasts.all.pick(using: &rng)!
        case .roast, .savage: pair = SpicyRoasts.all.pick(using: &rng)!
        case .bestie: pair = BestieRoasts.all.pick(using: &rng)!
        case .soft: pair = SoftRoasts.all.pick(using: &rng)!
        case .normal: pair = NormalRoasts.all.pick(using: &rng)!
        }
        return (pair.0, pair.1)
    }

    static func meterCaption(for metric: FunMetric, value: Int) -> String {
        MeterCopy.caption(for: metric, value: value)
    }

    static func flagPair(rng: inout SeededGenerator) -> (red: String, green: String) {
        (RedFlags.all.pick(using: &rng)!, GreenFlags.all.pick(using: &rng)!)
    }

    static func revealSecret(rng: inout SeededGenerator) -> (secret: String, followUp: String) {
        (RevealSecrets.all.pick(using: &rng)!, RevealFollowUps.all.pick(using: &rng)!)
    }

    // MARK: - Seeding

    static func makeRNG(_ domain: String, _ keys: String...) -> SeededGenerator {
        var combined = domain
        for key in keys { combined += "|" + key }
        return SeededGenerator(seed: stableHash(domain, keys.joined(separator: "|")))
    }

    static func stableHash(_ domains: String...) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for domain in domains {
            for byte in domain.utf8 {
                hash = (hash ^ UInt64(byte)) &* 0x100000001b3
            }
            hash ^= 0xff
        }
        return hash
    }
}

/// A real sky event translated into feed language. Presentation supplies this from
/// Sky data; Domain never depends on Sky types here.
struct CosmicEventSeed: Sendable, Hashable {
    let id: String
    let humanHeadline: String
    let factLine: String
}

// MARK: - Seeded RNG

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

extension RandomAccessCollection where Self: Collection {
    func pick(using generator: inout SeededGenerator) -> Element? {
        guard !isEmpty else { return nil }
        let offset = index(startIndex, offsetBy: Int.random(in: 0..<count, using: &generator))
        return self[offset]
    }
}

// MARK: - Elements

enum Element: String, CaseIterable, Sendable {
    case fire
    case earth
    case air
    case water

    static func of(_ sign: WesternZodiacSign) -> Element {
        switch sign {
        case .aries, .leo, .sagittarius: .fire
        case .taurus, .virgo, .capricorn: .earth
        case .gemini, .libra, .aquarius: .air
        case .cancer, .scorpio, .pisces: .water
        }
    }
}

struct ElementPair {
    let first: Element?
    let second: Element?

    init(_ first: Element?, _ second: Element?) {
        self.first = first
        self.second = second
    }

    var baseAffinity: Int {
        guard let first, let second else { return 62 }
        if first == second { return 78 }
        switch (first, second) {
        case (.fire, .air), (.air, .fire): return 82
        case (.earth, .water), (.water, .earth): return 80
        case (.fire, .earth), (.earth, .fire): return 58
        case (.fire, .water), (.water, .fire): return 52
        case (.air, .earth), (.earth, .air): return 60
        case (.air, .water), (.water, .air): return 64
        default: return 62
        }
    }

    var headline: String {
        guard let first, let second else { return "Two beautiful unknowns." }
        if first == second { return "Same element, double intensity." }
        switch (first, second) {
        case (.fire, .air), (.air, .fire): return "Fire plus air: fast, bright, flammable."
        case (.earth, .water), (.water, .earth): return "Earth plus water: something might grow here."
        case (.fire, .earth), (.earth, .fire): return "One of you is a bonfire. One of you is the fire pit."
        case (.fire, .water), (.water, .fire): return "Steam. Dramatic, useful steam."
        case (.air, .earth), (.earth, .air): return "One plans the trip, one books flights at 2 AM."
        case (.air, .water), (.water, .air): return "Feelings with commentary track."
        default: return "An interesting combination."
        }
    }

    /// Level-3 disclosure: the traditional-astrology note, clearly framed.
    func astrologyNote(firstSign: String, secondSign: String) -> String {
        guard let first, let second else {
            return "Traditional sun-sign pairing needs both signs. Add birth dates to see that part."
        }
        let relation: String
        if first == second {
            relation = "share an element, which astrologers read as natural understanding with doubled quirks"
        } else {
            relation = "combine \(first.rawValue) and \(second.rawValue) energy — traditionally \(affinityWord)"
        }
        return "The traditional bit: \(firstSign) (\(first.rawValue)) and \(secondSign) (\(second.rawValue)) \(relation). Entertainment first, tradition clearly labeled."
    }

    private var affinityWord: String {
        switch baseAffinity {
        case 75...: "highly compatible"
        case 65..<75: "promising"
        case 58..<65: "workable"
        default: "a growth experience"
        }
    }
}

// MARK: - Copy tables

private extension Element {
    var rawValueForCopy: String { rawValue }
}

enum SignFlavor {
    static func supportingLine(for sign: WesternZodiacSign) -> String {
        switch sign {
        case .aries: "First in line, last to check why."
        case .taurus: "Comfort is a strategy."
        case .gemini: "Three opinions before breakfast."
        case .cancer: "Feelings, but make them architecture."
        case .leo: "The spotlight called. It misses you."
        case .virgo: "Correct. Again. Exhausting."
        case .libra: "Deciding is also a decision."
        case .scorpio: "You already know. You always know."
        case .sagittarius: "Blunt is a love language, apparently."
        case .capricorn: "Feelings, but with project management."
        case .aquarius: "Normal was never the plan."
        case .pisces: "Living in three timelines at once."
        }
    }
}

enum BaseHeadlines {
    static let all = [
        "You woke up confident. That's the first problem.",
        "Don't start anything today. Finish one thing instead.",
        "The stars reviewed your decisions. Mixed feedback.",
        "Today has potential. So does a lottery ticket.",
        "Something small will go right. Let it.",
        "You could text them. You could also maintain your dignity.",
        "Mercury has entered the group chat.",
        "Your patience is running a limited beta today.",
        "Good day to be mysterious. Or just quiet. Same effect.",
        "The plot thickens. You are, technically, the plot."
    ]
}

enum SpicyHeadlines {
    static let all = [
        "Today's emotional stability: questionable.",
        "Humay checked. You are indeed the problem today.",
        "Nobody say anything. Especially you.",
        "The stars reviewed your decisions. They laughed.",
        "Do not send the paragraph. We can see you drafting it.",
        "Your patience has left the chat. Respect its journey."
    ]
}

enum DeluluHeadlines {
    static let all = [
        "Everyone is secretly talking about you. Positively!",
        "Today is your montage scene. Trust it.",
        "The universe literally cannot stop favoring you.",
        "Main character confirmed by three independent sources (you).",
        "That eye contact meant everything. Obviously."
    ]
}

enum DramaHeadlines {
    static let all = [
        "Everything changes today. Or Tuesday. Soon.",
        "A message arrives. Everything depends on it. No pressure.",
        "The season finale approaches. You're not ready. Nobody is.",
        "Betrayal looms. Probably minor. Still betrayal."
    ]
}

enum MeterCopy {
    static func caption(for metric: FunMetric, value: Int) -> String {
        let band: Int = value < 40 ? 0 : value < 75 ? 1 : 2
        switch metric {
        case .chaos:
            return ["Suspiciously calm.", "Manageable turbulence.", "Fasten everything."] [band]
        case .delusion:
            return ["Surprisingly grounded.", "Slightly fictional.", "Fully committed to the bit."][band]
        case .mainCharacterEnergy:
            return ["Background character hours.", "Solid supporting role.", "Cameras are rolling."][band]
        case .socialBattery:
            return ["Airplane mode.", "Selective availability.", "Answering every text. Weird."][band]
        case .confidence:
            return ["Gentle today.", "Steady and useful.", "Someone stop you. Kindly."][band]
        case .patience:
            return ["Extremely limited.", "Standard issue.", "Unreasonable amounts."][band]
        case .dontTextThem:
            return ["You're safe.", "Draft, don't send.", "Give Humay your phone."][band]
        case .flirtingPotential:
            return ["Cozy night energy.", "Light sparkle.", "Devastating effectiveness."][band]
        case .overthinking:
            return ["Rare quiet upstairs.", "Usual background hum.", "Seventeen tabs open."][band]
        case .romanticOptimism:
            return ["Realist era.", "Cautiously hopeful.", "Wedding-planner levels."][band]
        case .dramaProbability:
            return ["Peaceful, allegedly.", "Minor episode likely.", "Season finale energy."][band]
        case .chemistry:
            return ["Low-key.", "Noticeable.", "Visible from space."][band]
        case .communication:
            return ["Proceed with subtitles.", "Mostly decoded.", "Fluent in each other."][band]
        case .longTermPotential:
            return ["Enjoy the chapter.", "Promising arc.", "Renewed for seasons."][band]
        case .sharedChaos:
            return ["Mutual calm.", "Coordinated mischief.", "Joint operation, zero witnesses."][band]
        }
    }
}

enum RevealSecrets {
    static let all = [
        "Someone thinks about you more than they admit.",
        "The thing you're postponing will take eleven minutes.",
        "You were right about that. Quietly right.",
        "An old idea of yours deserves another chance.",
        "You will laugh at something today that you shouldn't laugh at.",
        "Somebody finds your stubbornness charming. Annoying, but charming.",
        "The compliment you received yesterday was sincere.",
        "You're closer to finishing something than you think.",
        "Today favors asking directly instead of hinting.",
        "The person you miss also had a weird day. Reach out gently."
    ]
}

enum RevealFollowUps {
    static let all = [
        "You didn't hear this from Humay.",
        "The stars insist this stays between us.",
        "Use responsibly.",
        "Correlation is not causation, but still."
    ]
}

enum RedFlags {
    static let all = [
        "You will reread one message exactly nine times.",
        "The snooze button is winning arguments today.",
        "One more coffee will feel like a personality upgrade. It isn't.",
        "You're about to give advice nobody asked for.",
        "The online cart is open. Close it.",
        "You will say \"quick question\" before a long story.",
        "Someone's story will remind you of your ex. Do not narrate this.",
        "\"I'm fine\" is doing heavy lifting today."
    ]
}

enum GreenFlags {
    static let all = [
        "You will drink water without being told. Growth.",
        "One honest sentence will fix something small.",
        "You'll make someone laugh without trying.",
        "The walk you keep skipping? Today it happens.",
        "You'll finish the boring task first. Elite behavior.",
        "A friend gets exactly the support they needed. From you.",
        "You will go to bed at a reasonable hour. Legendary.",
        "Complimenting someone will cost nothing and land perfectly."
    ]
}

enum GenericSkyLines {
    static let all: [(String, String)] = [
        ("The moon is doing something.", "Lunar motion continues as scheduled."),
        ("Planets are moving. Slowly. As usual.", "All bodies maintain standard orbital speeds."),
        ("The sky is busy today.", "Routine celestial traffic overhead.")
    ]
}

enum NormalRoasts {
    static let all = [
        ("A gentle observation", "The stars reviewed your decisions. Mixed feedback, encouraging tone."),
        ("Perspective", "You're doing better than you think and worse than you tell people. Balanced."),
        ("Today's takeaway", "Confidence looks good on you. Use it before it expires.")
    ]
}

enum BestieRoasts {
    static let all = [
        ("Bestie check", "You're allowed to rest AND allowed to want things. Wild concept, try both."),
        ("Real talk", "They're not confused about how you feel. They saw the paragraph."),
        ("Love you, mean it", "Stop rehearsing conversations with people who aren't rehearsing with you.")
    ]
}

enum SpicyRoasts {
    static let all = [
        ("Official notice", "Humay cannot legally confiscate your phone. Unfortunately."),
        ("Observation", "You've spent longer deciding what to watch than most people spend deciding their careers."),
        ("Feedback", "Your patience is currently a limited beta. Bugs reported. Fix not scheduled.")
    ]
}

enum DeluluRoasts {
    static let all = [
        ("Certified icon", "The universe reviewed you again and gave you a ten. Bias confirmed."),
        ("Prophecy", "Something amazing is loading. Estimated arrival: whenever you believe hard enough.")
    ]
}

enum DramaRoasts {
    static let all = [
        ("Previously, on your life", "Tensions rise. Alliances shift. Someone will reply-all. This is the finale."),
        ("Breaking", "A single emoji response threatens to end everything as we know it.")
    ]
}

enum SoftRoasts {
    static let all = [
        ("Softly noted", "You're carrying more than you mention. Put one thing down today."),
        ("Gentle reminder", "Being tender in a loud world is a skill, not a weakness.")
    ]
}

enum VerdictAnswers {
    static let apology = [
        "Whoever broke it first. Which means both.",
        "The taller one. Physics of guilt.",
        "Neither. A hostage exchange of memes occurs instead."
    ]
    static let ikea = [
        "Yes, but the shelf remembers.",
        "Only if the instructions are pictures-only.",
        "They would thrive. Terrifyingly efficient team."
    ]
    static let read = [
        "Both leave each other on read. Symmetry.",
        "One leaves on read. The other writes paragraphs about it.",
        "Read receipts off. Forever. Mutual treaty."
    ]
    static let passwords = [
        "Absolutely not. Healthy boundaries, honestly.",
        "Sure, but neither checks. Too lazy to snoop.",
        "One knows all. The other suspects everything."
    ]
}
