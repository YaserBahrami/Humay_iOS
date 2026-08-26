import Foundation

/// The register Humay speaks in. Modes change expression only — never underlying
/// data, never scores, never facts. One coherent mode system, not seven apps.
enum PersonalityMode: String, CaseIterable, Sendable, Hashable, Codable, Identifiable {
    case normal
    case bestie
    case roast
    case savage
    case delulu
    case drama
    case soft

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .normal: "Normal"
        case .bestie: "Bestie"
        case .roast: "Roast"
        case .savage: "Savage"
        case .delulu: "Delulu"
        case .drama: "Drama"
        case .soft: "Soft"
        }
    }

    /// One-line self-description shown when choosing a mode.
    var tagline: String {
        switch self {
        case .normal: "Balanced. Playful. Mostly harmless."
        case .bestie: "Like advice from your least judgmental friend."
        case .roast: "Humay has had enough."
        case .savage: "No mercy. Still funny. Never cruel."
        case .delulu: "Unreasonably optimistic. On purpose."
        case .drama: "Everything is the season finale."
        case .soft: "Warm. Gentle. Emotionally supportive."
        }
    }

    /// Short spoken-form description for accessibility.
    var accessibilityDescription: String {
        "\(displayName) mode. \(tagline)"
    }

    /// Modes that lean sharper get slightly stronger haptic accents elsewhere,
    /// but every mode remains fully usable and readable.
    var isSpicy: Bool {
        switch self {
        case .roast, .savage: true
        default: false
        }
    }

    /// Sensible fallback for decoding unknown persisted values.
    static func resolve(_ rawValue: String?) -> PersonalityMode {
        rawValue.flatMap(PersonalityMode.init(rawValue:)) ?? .normal
    }
}
