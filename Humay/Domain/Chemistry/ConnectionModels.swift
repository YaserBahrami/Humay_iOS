import Foundation

/// The relationship frame a person sits in for the user. Context changes the
/// generated content. No public social network — this is a private playground.
enum RelationshipKind: String, CaseIterable, Sendable, Hashable, Codable, Identifiable {
    case partner
    case crush
    case friend
    case ex
    case sibling
    case coworker
    case mystery
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .partner: "Partner"
        case .crush: "Crush"
        case .friend: "Friend"
        case .ex: "Ex"
        case .sibling: "Sibling"
        case .coworker: "Coworker"
        case .mystery: "Mystery person"
        case .custom: "Custom"
        }
    }

    var symbol: String {
        switch self {
        case .partner: "heart.circle.fill"
        case .crush: "sparkles.rectangle.stack"
        case .friend: "person.crop.circle"
        case .ex: "arrow.uturn.backward.circle"
        case .sibling: "person.2.circle"
        case .coworker: "briefcase.circle"
        case .mystery: "questionmark.circle"
        case .custom: "star.circle"
        }
    }

    /// Copy used when a compatibility verdict needs the relationship context.
    func contextLine() -> String {
        switch self {
        case .partner: "Long-haul territory."
        case .crush: "Handle with interest."
        case .friend: "Certified chaos colleague."
        case .ex: "Look what the universe dragged in."
        case .sibling: "Built-in rival, lifetime subscription."
        case .coworker: "Professional-adjacent dynamics."
        case .mystery: "Humay has questions. So do you."
        case .custom: "A category of one."
        }
    }
}

/// A saved person in the user's private circle. Persistence is explicit (schema v2,
/// via Data-layer records); unknown birth time/place stay honestly unknown.
struct ConnectionPerson: Identifiable, Sendable, Hashable {
    let id: UUID
    var name: String
    var relationshipKind: RelationshipKind
    var customLabel: String?
    var birth: BirthDetails

    init(
        id: UUID = UUID(),
        name: String,
        relationshipKind: RelationshipKind = .friend,
        customLabel: String? = nil,
        birth: BirthDetails
    ) {
        self.id = id
        self.name = name
        self.relationshipKind = relationshipKind
        self.customLabel = customLabel
        self.birth = birth
    }

    /// Deterministic Western sun sign from the civil birth date. This is the standard
    /// tropical date-range convention; it never claims more precision than that.
    var westernSunSign: WesternZodiacSign? {
        SunSignCalendar.westernSunSign(month: birth.month, day: birth.day)
    }

    var initials: String {
        let words = name.split(whereSeparator: \.isWhitespace)
        return words.prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }

    var displayLabel: String {
        if relationshipKind == .custom, let customLabel, !customLabel.isEmpty {
            return customLabel
        }
        return relationshipKind.displayName
    }
}

/// One playful verdict line in a compatibility result ("Who apologizes first?" → …).
struct VerdictLine: Identifiable, Sendable, Hashable {
    let question: String
    let answer: String

    var id: String { question }
}

/// The entertainment compatibility result for two people. Overall score and fun
/// metrics are Humay-original (Category C). `astrologyBasis` carries the separate,
/// clearly-labeled sun-sign pairing note (Category A adjacency) so the three-layer
/// rule (fun → explanation → astrology basis) stays intact.
struct CompatibilityVerdict: Sendable, Hashable {
    let firstPersonID: UUID
    let secondPersonID: UUID
    let overall: Int
    let headline: String
    let summary: String
    let funMetrics: [FunMeter]
    let verdictLines: [VerdictLine]
    let astrologyBasis: String
}

// MARK: - Sun sign calendar

enum SunSignCalendar {
    /// Standard tropical date-range boundaries. Day ranges are inclusive on the start.
    static func westernSunSign(month: Int, day: Int) -> WesternZodiacSign? {
        switch (month, day) {
        case (3, 21...), (4, ...19): .aries
        case (4, 20...), (5, ...20): .taurus
        case (5, 21...), (6, ...20): .gemini
        case (6, 21...), (7, ...22): .cancer
        case (7, 23...), (8, ...22): .leo
        case (8, 23...), (9, ...22): .virgo
        case (9, 23...), (10, ...22): .libra
        case (10, 23...), (11, ...21): .scorpio
        case (11, 22...), (12, ...21): .sagittarius
        case (12, 22...), (1, ...19): .capricorn
        case (1, 20...), (2, ...18): .aquarius
        case (2, 19...), (3, ...20): .pisces
        default: nil
        }
    }
}
