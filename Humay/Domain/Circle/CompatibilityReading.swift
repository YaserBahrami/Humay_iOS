import Foundation

/// The four axes a compatibility reading is broken into.
///
/// The same four at both tiers, so the vocabulary a person learns from the general
/// reading still applies when they see the precise one. What changes is what each axis
/// is derived from and how much it is entitled to claim.
///
/// "Shared values" is deliberately not an axis. It cannot be responsibly inferred from
/// two Sun signs, so it appears — when it appears at all — inside precise prose, where
/// there are two charts to support it.
enum CompatibilityAxis: String, Sendable, CaseIterable, Identifiable, Codable {
    case loveAndChemistry
    case communication
    case emotionalConnection
    case conflictAndPace

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .loveAndChemistry: "Love & Chemistry"
        case .communication: "Communication"
        case .emotionalConnection: "Emotional Connection"
        case .conflictAndPace: "Conflict & Pace"
        }
    }
}

/// A qualitative verdict on one axis.
///
/// There is no score, no percentage and no ordering. `CompatibilityVerdict` is
/// deliberately not `Comparable`, and there is no case meaning "incompatible" — the
/// product does not rank relationships or tell people theirs is wrong.
enum CompatibilityVerdict: String, Sendable, CaseIterable, Identifiable, Codable {
    case strong
    case balanced
    case mixed
    case friction

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .strong: "Strong"
        case .balanced: "Balanced"
        case .mixed: "Mixed"
        case .friction: "Friction"
        }
    }
}

/// One axis, with its verdict and the sentence that justifies it.
struct CompatibilityAxisReading: Sendable, Hashable, Identifiable {
    var id: String { axis.rawValue }
    let axis: CompatibilityAxis
    let verdict: CompatibilityVerdict
    /// Why. A verdict on its own would be an assertion, which is the thing to avoid.
    let explanation: String

    var spokenSummary: String {
        "\(axis.displayName): \(verdict.displayName). \(explanation)"
    }
}

/// A compatibility reading, at one of two tiers.
///
/// A closed sum rather than one type with optional precise fields, so that a general
/// reading cannot accidentally be presented with a precise badge.
enum CompatibilityReading: Sendable, Hashable {
    case general(GeneralCompatibilityReading)
    case precise(PreciseCompatibilityReading)

    var tier: PrecisionTier {
        switch self {
        case .general: .general
        case .precise: .precise
        }
    }

    var headline: String {
        switch self {
        case .general(let reading): reading.headline
        case .precise(let reading): reading.headline
        }
    }

    var axes: [CompatibilityAxisReading] {
        switch self {
        case .general(let reading): reading.axes
        case .precise(let reading): reading.axes
        }
    }

    var provenance: ContentProvenance {
        switch self {
        case .general(let reading): reading.provenance
        case .precise(let reading): reading.provenance
        }
    }
}

/// Sign-to-sign. Everything here follows from two birth dates.
struct GeneralCompatibilityReading: Sendable, Hashable {
    /// "Pisces + Leo"
    let pairLabel: String
    let firstSign: WesternSign
    let secondSign: WesternSign
    let headline: String
    let body: String
    let axes: [CompatibilityAxisReading]
    let basis: ReadingBasis
    let provenance: ContentProvenance
}

/// From both charts. Claims more, and says what it is claiming it from.
struct PreciseCompatibilityReading: Sendable, Hashable {
    /// "Jordan & Sara"
    let pairLabel: String
    let relationshipLabel: String
    let headline: String
    let body: String
    let axes: [CompatibilityAxisReading]
    /// Where a general reading stops and this one keeps going — shared values, timing,
    /// the things two charts support and two dates do not.
    let deeperNote: String
    let basis: ReadingBasis
    let provenance: ContentProvenance
}
