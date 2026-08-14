import Foundation

/// Feature-facing saved-person shape. Persistence remains deferred to CIRCLE-001.
struct CirclePerson: Identifiable, Sendable, Hashable {
    let id: UUID
    var name: String
    var birth: BirthDetails
    var westernSunSign: WesternZodiacSign?

    init(
        id: UUID = UUID(),
        name: String,
        birth: BirthDetails,
        westernSunSign: WesternZodiacSign? = nil
    ) {
        self.id = id
        self.name = name
        self.birth = birth
        self.westernSunSign = westernSunSign
    }

    var initials: String {
        let words = name.split(whereSeparator: \.isWhitespace)
        return words.prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }
}

/// Ordered Free Western catalog key. Twelve signs by twelve signs yields 144 keys.
struct WesternSunSignPairKey: Sendable, Hashable {
    let first: WesternZodiacSign
    let second: WesternZodiacSign

    static let allCatalogKeys: [Self] = WesternZodiacSign.allCases.flatMap { first in
        WesternZodiacSign.allCases.map { second in
            Self(first: first, second: second)
        }
    }
}

struct CompatibilityPair: Sendable, Hashable {
    let first: CirclePerson
    let second: CirclePerson
}

struct CompatibilityScore: Sendable, Hashable, Comparable {
    let value: Int

    init?(_ value: Int) {
        guard (0...100).contains(value) else { return nil }
        self.value = value
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

enum CompatibilityMetricKind: String, CaseIterable, Identifiable, Sendable, Hashable {
    case chemistry
    case communication
    case emotionalConnection
    case adventure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chemistry: "Chemistry"
        case .communication: "Communication"
        case .emotionalConnection: "Emotional Connection"
        case .adventure: "Adventure"
        }
    }
}

struct CompatibilityMetric: Identifiable, Sendable, Hashable {
    let kind: CompatibilityMetricKind
    let score: CompatibilityScore

    var id: CompatibilityMetricKind { kind }
}

/// Free compatibility is intentionally limited to an ordered Western Sun-sign pair.
struct FreeCompatibilityResult: Sendable, Hashable {
    let pair: CompatibilityPair
    let catalogKey: WesternSunSignPairKey
    let overallScore: CompatibilityScore
    let relationshipLabel: String
    let shortSummary: String
    let metrics: [CompatibilityMetric]
    let ourTake: String

    var hasCompleteMetricSet: Bool {
        Set(metrics.map(\.kind)) == Set(CompatibilityMetricKind.allCases)
    }
}

/// Precise compatibility remains provider-independent. A real adapter will supply it later.
struct PreciseCompatibilityResult: Sendable, Hashable {
    let pair: CompatibilityPair
    let overallScore: CompatibilityScore
    let relationshipLabel: String
    let shortSummary: String
    let metrics: [CompatibilityMetric]
    let ourTake: String

    var hasCompleteMetricSet: Bool {
        Set(metrics.map(\.kind)) == Set(CompatibilityMetricKind.allCases)
    }
}
