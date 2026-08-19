import SwiftUI

enum HumaySpacing {
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let largePlus: CGFloat = 20
    static let extraLarge: CGFloat = 24
    static let extraExtraLarge: CGFloat = 32
    static let section: CGFloat = 40
    static let hero: CGFloat = 56
    static let expansive: CGFloat = 72
}

enum HumayRadius {
    static let compact: CGFloat = 10
    static let surface: CGFloat = 16
    static let feature: CGFloat = 24
    static let pill: CGFloat = 999
}

enum HumayMetrics {
    static let minimumHitTarget: CGFloat = 44
    static let primaryControlMinimumHeight: CGFloat = 54
    static let rootTabContentBreathingRoom: CGFloat = 12
    static let orbitalLineWidth: CGFloat = 0.75
    static let selectedLineWidth: CGFloat = 1.5

    static func hairline(displayScale: CGFloat) -> CGFloat {
        1 / max(displayScale, 1)
    }
}

enum HumayElevation {
    static let subtleShadowOpacity: CGFloat = 0.045
    static let subtleShadowRadius: CGFloat = 18
    static let subtleShadowY: CGFloat = 8
}

enum HumayMotion {
    static let pressDuration = 0.12
    static let selectionDuration = 0.22
    static let revealDuration = 0.42

    static func reveal(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .smooth(duration: revealDuration)
    }

    static func selection(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .snappy(duration: selectionDuration)
    }
}
