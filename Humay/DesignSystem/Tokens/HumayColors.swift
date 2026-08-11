import SwiftUI

/// Semantic colour facade.
///
/// Views name a *role* — "this is secondary text" — rather than a palette entry or an
/// opacity. That is what lets a second appearance be added without touching a view.
struct HumayColors: Sendable {
    let palette: any HumayPalette

    init(palette: any HumayPalette) {
        self.palette = palette
    }

    // Surfaces
    var background: Color { palette.paper }
    var raised: Color { palette.paper }
    var inverseBackground: Color { palette.ink }
    var inverseRaised: Color { palette.slate }

    // Text on the reading ground
    var textPrimary: Color { palette.ink.opacity(HumayInkOpacity.primary.value) }
    var textBody: Color { palette.ink.opacity(HumayInkOpacity.body.value) }
    var textSecondary: Color { palette.ink.opacity(HumayInkOpacity.secondary.value) }
    var textTertiary: Color { palette.ink.opacity(HumayInkOpacity.tertiary.value) }
    var textLabel: Color { palette.ink.opacity(HumayInkOpacity.label.value) }
    var textDisabled: Color { palette.ink.opacity(HumayInkOpacity.disabled.value) }

    // Text on an ink ground, for the rare inverted element
    var textOnInkPrimary: Color { palette.paper.opacity(HumayInkOpacity.primary.value) }
    var textOnInkBody: Color { palette.paper.opacity(HumayInkOpacity.body.value) }
    var textOnInkSecondary: Color { palette.paper.opacity(HumayInkOpacity.secondary.value) }
    var textOnInkLabel: Color { palette.paper.opacity(HumayInkOpacity.label.value) }

    /// Accent for body-size text. Contrast-safe on paper.
    var accentText: Color { palette.giltText }
    /// Accent for marks, rules and glyphs at display size.
    var accentMark: Color { palette.gilt }

    /// Roast expression only.
    var roast: Color { palette.cinnabar }

    // Rules. The design draws with lines, so these carry real weight.
    var hairline: Color { palette.ink.opacity(0.14) }
    var hairlineStrong: Color { palette.ink.opacity(0.24) }
    var hairlineAccent: Color { palette.gilt.opacity(0.55) }

    /// Fill for the one inverted primary action.
    var actionFill: Color { palette.ink }
    var actionLabel: Color { palette.paper }
}
