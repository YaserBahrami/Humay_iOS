import Foundation

/// Humay-original entertainment metrics (Category C). Explicitly invented by
/// Humay, explicitly playful — never presented as astrological fact.
enum FunMetric: String, CaseIterable, Sendable, Hashable, Codable {
    case chaos
    case delusion
    case mainCharacterEnergy
    case socialBattery
    case confidence
    case patience
    case dontTextThem
    case flirtingPotential
    case overthinking
    case romanticOptimism
    case dramaProbability
    // Compatibility-specific meters
    case chemistry
    case communication
    case longTermPotential
    case sharedChaos

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chaos: "Chaos level"
        case .delusion: "Delusion"
        case .mainCharacterEnergy: "Main character energy"
        case .socialBattery: "Social battery"
        case .confidence: "Confidence"
        case .patience: "Patience"
        case .dontTextThem: "Don't text them"
        case .flirtingPotential: "Flirting potential"
        case .overthinking: "Overthinking"
        case .romanticOptimism: "Romantic optimism"
        case .dramaProbability: "Drama probability"
        case .chemistry: "Chemistry"
        case .communication: "Communication"
        case .longTermPotential: "Long-term potential"
        case .sharedChaos: "Shared chaos"
        }
    }

    /// Whether a high value is framed as trouble. Used for copy tone, not judgment.
    var highValueIsSpicy: Bool {
        switch self {
        case .chaos, .delusion, .dontTextThem, .overthinking, .dramaProbability: true
        default: false
        }
    }
}

/// Content-category accents keep color meaningful and centralized.
enum FeedAccent: String, Sendable, Hashable, Codable {
    case coral
    case gold
    case lavender
    case sage
    case ink

    static func accent(for metric: FunMetric) -> FeedAccent {
        switch metric {
        case .chaos, .dontTextThem, .dramaProbability, .sharedChaos: .coral
        case .delusion, .mainCharacterEnergy, .flirtingPotential, .chemistry: .lavender
        case .socialBattery, .patience, .overthinking: .gold
        case .confidence, .romanticOptimism, .communication, .longTermPotential: .sage
        }
    }
}

// MARK: - Item payloads

/// Big-type opening statement. Typography is the design.
struct HeadlineContent: Sendable, Hashable {
    let kicker: String
    let headline: String
    let supporting: String?
}

/// A named 0–100 entertainment meter with an optional one-line caption.
struct FunMeter: Identifiable, Sendable, Hashable {
    let metric: FunMetric
    let value: Int
    let caption: String?

    init(metric: FunMetric, value: Int, caption: String? = nil) {
        self.metric = metric
        self.value = max(0, min(100, value))
        self.caption = caption
    }

    var id: FunMetric { metric }
}

/// A group of meters presented together.
struct MeterSetContent: Sendable, Hashable {
    let title: String
    let meters: [FunMeter]
}

/// A prediction hidden until the user interacts with it.
struct RevealContent: Sendable, Hashable {
    let prompt: String
    let hint: String
    let secret: String
    let followUp: String?
}

/// Paired red-flag / green-flag observations.
struct FlagPairContent: Sendable, Hashable {
    let redFlag: String
    let greenFlag: String
}

/// Today's roast — expression only, never facts.
struct RoastContent: Sendable, Hashable {
    let title: String
    let body: String
}

/// Cosmic weather links real sky events to a human translation. The fact line and
/// the interpretation are kept separate so Sky remains the source of truth.
struct CosmicWeatherContent: Sendable, Hashable {
    let headline: String
    let factLine: String
    let skyEventID: String?
}

/// A teaser pointing into the year timeline.
struct ForecastTeaserContent: Sendable, Hashable {
    let title: String
    let entries: [Entry]

    struct Entry: Identifiable, Sendable, Hashable {
        let dayOffset: Int
        let label: String
        let detail: String

        var id: String { "\(dayOffset)-\(label)" }
    }
}

/// A short reading with variable-length sections (AI-ready shape).
struct ReadingSection: Identifiable, Sendable, Hashable {
    let heading: String?
    let text: String

    var id: String { heading ?? text }
}

struct DailyReadingContent: Sendable, Hashable {
    let kicker: String
    let headline: String
    let sections: [ReadingSection]
    let tip: String?
}

/// One modular piece of Cosmic Feed content. New entertainment formats are new
/// cases here plus one renderer — no screen redesign required.
enum FeedItemKind: Sendable, Hashable {
    case headline(HeadlineContent)
    case meterSet(MeterSetContent)
    case reveal(RevealContent)
    case flagPair(FlagPairContent)
    case roast(RoastContent)
    case cosmicWeather(CosmicWeatherContent)
    case forecastTeaser(ForecastTeaserContent)
    case dailyReading(DailyReadingContent)
}

struct FeedItem: Identifiable, Sendable, Hashable {
    let id: String
    let kind: FeedItemKind
}
