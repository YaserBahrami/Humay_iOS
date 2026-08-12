import CoreGraphics

enum HumaySpacing {
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
    static let extraExtraLarge: CGFloat = 32
}

enum HumayRadius {
    static let compact: CGFloat = 16
    static let surface: CGFloat = 20
    static let feature: CGFloat = 24
    static let pill: CGFloat = 999
}

enum HumayMetrics {
    static let minimumHitTarget: CGFloat = 44

    static func hairline(displayScale: CGFloat) -> CGFloat {
        1 / max(displayScale, 1)
    }
}

enum HumayElevation {
    static let subtleShadowOpacity: CGFloat = 0.06
    static let subtleShadowRadius: CGFloat = 12
    static let subtleShadowY: CGFloat = 4
}
