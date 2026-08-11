import CoreGraphics

/// Spacing scale.
///
/// The brand lock never declared a canonical scale, so this one is an engineering
/// choice. It is expressed in semantic steps rather than raw numbers so that an iPad
/// pass can rescale the whole system in one place.
enum HumaySpacing {
    /// Horizontal screen gutter. The single most load-bearing value in the layout.
    static let gutter: CGFloat = 28
    /// Distance from the safe area to the first element on a screen.
    static let screenTop: CGFloat = 20

    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 44
    static let xxxl: CGFloat = 64

    /// Vertical rhythm between major sections of a reading.
    static let section: CGFloat = 40
}

/// Corner radii.
///
/// Square by default — the design draws with rules, not rounded containers. The two
/// exceptions below are the only sanctioned ones.
enum HumayRadius {
    static let square: CGFloat = 0
    /// Widget surfaces only.
    static let widget: CGFloat = 24
    /// Small inline affordances where a hard corner reads as an error rather than a choice.
    static let subtle: CGFloat = 2
}

/// Border widths.
enum HumayBorder {
    /// The default divider and outline.
    static let hairline: CGFloat = 1
    /// Reserved for the single deliberate emphasis case: the core-relationship row.
    static let emphasis: CGFloat = 2
}

/// Minimum interactive target, per the accessibility contract.
enum HumayHitTarget {
    static let minimum: CGFloat = 44
}
