import SwiftUI

/// Applies a Humay type role, with Dynamic Type scaling capped per role.
///
/// `Font.custom(_:size:relativeTo:)` scales but cannot be capped, and
/// `UIFontMetrics.scaledFont(for:maximumPointSize:)` snapshots the trait collection at
/// the moment it is called. Reading `dynamicTypeSize` from the environment makes the
/// result recompute when the user changes their text size, which is the behaviour the
/// accessibility contract requires.
private struct HumayFontModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let role: HumayTypeRole

    func body(content: Content) -> some View {
        content
            .font(Font(role.resolvedFont(at: dynamicTypeSize.contentSizeCategory)))
            .tracking(role.trackingEm * role.size)
            .lineSpacing(role.lineSpacing)
    }
}

extension HumayTypeRole {
    /// The font this role resolves to at a given content size category.
    ///
    /// Exposed rather than buried in the modifier so a test can assert what a reader at
    /// the largest accessibility size actually gets — the size ordering between roles is
    /// part of the design contract, and it is not visible from the caps alone.
    func resolvedFont(at category: UIContentSizeCategory) -> UIFont {
        let base: UIFont
        if let face {
            base = UIFont(name: face.postScriptName, size: size)
                ?? .systemFont(ofSize: size, weight: uiWeight)
        } else if isMonospaced {
            base = .monospacedSystemFont(ofSize: size, weight: uiWeight)
        } else {
            base = .systemFont(ofSize: size, weight: uiWeight)
        }

        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let traits = UITraitCollection(preferredContentSizeCategory: category)

        guard let maxScale else {
            return metrics.scaledFont(for: base, compatibleWith: traits)
        }
        return metrics.scaledFont(
            for: base,
            maximumPointSize: size * maxScale,
            compatibleWith: traits
        )
    }

    private var uiWeight: UIFont.Weight {
        switch systemWeight {
        case .medium: .medium
        case .semibold: .semibold
        default: .regular
        }
    }
}

extension View {
    /// Sets the font, tracking and leading for a Humay type role.
    func humayFont(_ role: HumayTypeRole) -> some View {
        modifier(HumayFontModifier(role: role))
    }
}

extension DynamicTypeSize {
    /// UIKit equivalent, so `UIFontMetrics` can be given an explicit trait collection
    /// rather than reading whatever the current one happens to be.
    var contentSizeCategory: UIContentSizeCategory {
        switch self {
        case .xSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .xLarge: .extraLarge
        case .xxLarge: .extraExtraLarge
        case .xxxLarge: .extraExtraExtraLarge
        case .accessibility1: .accessibilityMedium
        case .accessibility2: .accessibilityLarge
        case .accessibility3: .accessibilityExtraLarge
        case .accessibility4: .accessibilityExtraExtraLarge
        case .accessibility5: .accessibilityExtraExtraExtraLarge
        @unknown default: .large
        }
    }
}
