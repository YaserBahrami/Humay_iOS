import SwiftUI

/// Compatibility roles backed by the Premium Celestial semantic palette.
/// Literal Light/Dark values live in the asset catalog so system appearance,
/// increased contrast, previews, and generated color symbols keep working.
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
    // MARK: Semantic aliases

    static var humayCanvas: Color { .humayGround }
    static var humaySurfaceElevated: Color { .humayRaisedSurface }
    static var humayAccentPrestige: Color { .humaySolarGold }
    static var humayAccentCelestial: Color { .humayLavender }
    static var humayAccentRoast: Color { .humayCoral }
    static var humaySeparator: Color { .humayHairline }
    static var humayOrbit: Color { .humayHairline }

    static var humayChartHarmonious: Color { .humayCelestialBlue }
    static var humayChartDynamic: Color { .humayCoral }
    static var humayChartSelected: Color { .humaySolarGold }

    /// Stable dark ink for prestige-gold controls in both appearances.
    static let humayInkOnGold = Color(red: 0.09, green: 0.09, blue: 0.07)

    /// Legacy onboarding illustration token. New post-onboarding surfaces use
    /// semantic aliases above rather than local decorative color literals.
    static let humayCosmicCoffee = Color(red: 0.35, green: 0.24, blue: 0.16)
}
