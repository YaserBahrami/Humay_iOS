import Foundation

enum D5ContentSource: String, Sendable, Hashable {
    case productionUnavailable
    case developmentSample

    var isDevelopmentSample: Bool { self == .developmentSample }
}

enum AskTone: String, Sendable, Hashable {
    case gentle
}

enum AskContextScope: String, Sendable, Hashable {
    case relevantChartContext
    case noChartContext
}

struct AskQuestion: Sendable, Hashable {
    let questionText: String
    let locale: String
    let tone: AskTone
    let selectedTradition: String
    let selectedSystem: String
    let contextScope: AskContextScope

    var normalizedQuestionText: String {
        questionText
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var cacheIdentity: AskCacheIdentity {
        AskCacheIdentity(
            questionText: normalizedQuestionText,
            locale: locale,
            tone: tone,
            selectedTradition: selectedTradition,
            selectedSystem: selectedSystem,
            contextScope: contextScope
        )
    }
}

/// Cache identity contains only semantic question inputs. Access is deliberately
/// absent so Free, Rewarded and Premium cannot create separate answer identities.
struct AskCacheIdentity: Sendable, Hashable {
    let questionText: String
    let locale: String
    let tone: AskTone
    let selectedTradition: String
    let selectedSystem: String
    let contextScope: AskContextScope
}

enum AskContextAvailability: Sendable, Hashable {
    case available
    case unavailable
}

struct AskContext: Sendable, Hashable {
    let selectedTradition: String
    let selectedSystem: String
    let availability: AskContextAvailability
    let detail: String

    var summary: String {
        switch availability {
        case .available:
            "Using: \(selectedTradition) · available chart context"
        case .unavailable:
            "Using: no chart context available"
        }
    }

    static let productionUnavailable = AskContext(
        selectedTradition: "Western",
        selectedSystem: "Tropical",
        availability: .unavailable,
        detail: "Only relevant astrology context is used for this question."
    )
}

enum AskBasisFactKind: String, Sendable, Hashable {
    case methodology
    case system
    case placement
    case degree
    case house
}

struct AskBasisFact: Sendable, Hashable, Identifiable {
    let kind: AskBasisFactKind
    let label: String
    let value: String

    var id: String { "\(kind.rawValue)-\(label)-\(value)" }
}

struct AskAnswerSection: Sendable, Hashable, Identifiable {
    let title: String
    let body: String

    var id: String { title }
}

struct AskAnswer: Sendable, Hashable {
    let question: AskQuestion
    let disclosure: String?
    let headline: String
    let sections: [AskAnswerSection]
    let tryThis: [String]
    let basis: [AskBasisFact]
}

enum AskAccessState: Sendable, Hashable {
    case free
    case rewardedRequired
    case premiumAlternative
}

struct AskContextIssue: Sendable, Hashable {
    let title: String
    let detail: String
    let missing: [String]
}

struct AskUnsupportedReason: Sendable, Hashable {
    let title: String
    let detail: String
}

struct AskSafetyRefusal: Sendable, Hashable {
    let title: String
    let detail: String
    let recommendation: String
}

struct AskFailure: Sendable, Hashable {
    let title: String
    let detail: String
}

enum AskFeatureState: Sendable, Hashable {
    case empty
    case accessRequired(question: AskQuestion, access: AskAccessState)
    case generating(question: AskQuestion)
    case loaded(AskAnswer)
    case cached(AskAnswer, savedAt: Date)
    case offlineCached(AskAnswer, savedAt: Date)
    case offlineNoCache(question: AskQuestion?)
    case insufficientContext(AskContextIssue)
    case unsupported(AskUnsupportedReason)
    case safetyRefusal(AskSafetyRefusal)
    case failed(AskFailure)

    var answer: AskAnswer? {
        switch self {
        case .loaded(let answer), .cached(let answer, _), .offlineCached(let answer, _):
            answer
        case .empty, .accessRequired, .generating, .offlineNoCache, .insufficientContext,
                .unsupported, .safetyRefusal, .failed:
            nil
        }
    }

    var question: AskQuestion? {
        switch self {
        case .accessRequired(let question, _), .generating(let question):
            question
        case .offlineNoCache(let question):
            question
        case .loaded(let answer), .cached(let answer, _), .offlineCached(let answer, _):
            answer.question
        case .empty, .insufficientContext, .unsupported, .safetyRefusal, .failed:
            nil
        }
    }
}

struct D5FeatureInput: Sendable, Hashable {
    let source: D5ContentSource
    let context: AskContext
    let state: AskFeatureState

    static let productionUnavailable = D5FeatureInput(
        source: .productionUnavailable,
        context: .productionUnavailable,
        state: .empty
    )
}

enum AskProductCopy {
    static let title = "Ask"
    static let prompt = "What’s on your mind?"
    static let contextHeading = "AVAILABLE CONTEXT"
    static let contextDetail = "Only relevant astrology context is used for this question."
    static let questionHeading = "YOUR QUESTION"
    static let readingHeading = "YOUR READING"
    static let tryThisHeading = "TRY THIS"
    static let basisHeading = "WHAT THIS ANSWER USED"
    static let generatingTitle = "Reading the context you shared…"
    static let generatingDetail = "Putting the pieces together…"
    static let generatingFooter = "Your reading will appear here when it’s ready."
    static let accessHeading = "YOUR QUESTION IS READY"
    static let accessDetail = "Create this personal reading by watching an ad."
    static let accessAction = "Watch an ad for this answer"
    static let premiumAlternative = "Premium alternative"
    static let offlineNoCache = "A new answer needs a connection."
    static let failedTitle = "Humay couldn’t finish this reading."
    static let askAnother = "Ask another question"

    static let suggestions = [
        "What should I focus on today?",
        "How can I work with my Moon in Libra?",
        "What pattern should I notice in relationships?"
    ]
}
