import SwiftUI

/// Semantic Soulful Celestial roles. Literal Light/Dark values live in the asset
/// catalog; Xcode generates the corresponding type-safe `Color` symbols.
enum HumayColorRole: CaseIterable {
    case ground
    case surface
    case raisedSurface
    case textPrimary
    case textSecondary
    case hairline
    case coral
    case lavender
    case solarGold
    case celestialBlue
    case sage

    var color: Color {
        switch self {
        case .ground: .humayGround
        case .surface: .humaySurface
        case .raisedSurface: .humayRaisedSurface
        case .textPrimary: .humayTextPrimary
        case .textSecondary: .humayTextSecondary
        case .hairline: .humayHairline
        case .coral: .humayCoral
        case .lavender: .humayLavender
        case .solarGold: .humaySolarGold
        case .celestialBlue: .humayCelestialBlue
        case .sage: .humaySage
        }
    }
}

extension Color {
    /// Decorative liquid tone used only by the Welcome companion illustration.
    /// Literal illustration colors remain centralized with the design tokens rather
    /// than being embedded in production Presentation code.
    static let humayCosmicCoffee = Color(red: 0.35, green: 0.24, blue: 0.16)
}
