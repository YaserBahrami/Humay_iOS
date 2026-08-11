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
            .font(Font(resolvedFont()))
            .tracking(role.trackingEm * role.size)
            .lineSpacing(role.lineSpacing)
    }

    private func resolvedFont() -> UIFont {
        let base: UIFont
        if let face = role.face {
            base = UIFont(name: face.postScriptName, size: role.size)
                ?? .systemFont(ofSize: role.size, weight: uiWeight)
        } else if role.isMonospaced {
            base = .monospacedSystemFont(ofSize: role.size, weight: uiWeight)
        } else {
            base = .systemFont(ofSize: role.size, weight: uiWeight)
        }

        let metrics = UIFontMetrics(forTextStyle: role.textStyle)
        let traits = UITraitCollection(preferredContentSizeCategory: dynamicTypeSize.contentSizeCategory)

        guard let maxScale = role.maxScale else {
            return metrics.scaledFont(for: base, compatibleWith: traits)
        }
        return metrics.scaledFont(
            for: base,
            maximumPointSize: role.size * maxScale,
            compatibleWith: traits
        )
    }

    private var uiWeight: UIFont.Weight {
        switch role.systemWeight {
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
