import SwiftUI

/// Semantic type roles.
///
/// Views name a role rather than a face and a size. Three families do all the work:
///
/// - **Cormorant Garamond** — wordmark, major titles, editorial headlines.
/// - **SF Pro** — body copy, navigation, buttons, forms, settings, general UI.
/// - **SF Mono** — degrees, coordinates, dates, technical chart data. Never prose.
enum HumayTypeRole: Sendable {
    /// HUMAY, set in caps with wide tracking. Only `Wordmark` should use this.
    case wordmark

    /// Screen-defining editorial headline.
    case displayXL
    /// Screen title.
    case displayL
    /// Section headline within a reading.
    case displayM
    /// Row and card titles.
    case titleM
    /// Compact title, e.g. a list row heading.
    case titleS

    /// Reading paragraphs.
    case body
    /// Supporting paragraphs and secondary explanation.
    case bodySmall
    /// Inline supporting copy, footnotes, disclosures.
    case callout
    /// Control labels and form field labels.
    case label
    /// The smallest supporting text.
    case caption

    /// Uppercase tracked kicker above a section. Mono.
    case monoKicker
    /// A single technical fact line. Mono.
    case monoFact
    /// A degree, coordinate or timestamp inline with text. Mono, tabular.
    case monoDegree

    // MARK: - Resolution

    /// The Cormorant face for this role, or `nil` when the role uses a system face.
    var face: HumayFontFace? {
        switch self {
        case .wordmark, .displayXL, .displayL, .displayM: .light
        case .titleM, .titleS: .regular
        default: nil
        }
    }

    var size: CGFloat {
        switch self {
        case .wordmark: 15
        case .displayXL: 38
        case .displayL: 29
        case .displayM: 23
        case .titleM: 20
        case .titleS: 17
        case .body: 16
        case .bodySmall: 15
        case .callout: 14
        case .label: 13
        case .caption: 12
        case .monoKicker: 11
        case .monoFact: 12
        case .monoDegree: 13
        }
    }

    /// The text style this role scales against.
    var textStyle: UIFont.TextStyle {
        switch self {
        case .wordmark: .headline
        case .displayXL: .largeTitle
        case .displayL: .title1
        case .displayM: .title2
        case .titleM: .title3
        case .titleS: .headline
        case .body: .body
        case .bodySmall: .subheadline
        case .callout: .callout
        case .label: .footnote
        case .caption: .caption1
        case .monoKicker: .caption2
        case .monoFact: .caption1
        case .monoDegree: .footnote
        }
    }

    /// Dynamic Type ceiling, as a multiple of the base size.
    ///
    /// A ceiling exists because a 38pt editorial headline at the largest accessibility
    /// size would be 120pt and fit four characters to a line. But a ceiling has a cost:
    /// a capped role stops growing while the text beneath it keeps going, and a title
    /// ends up smaller than its own subtitle. A single flat 1.4x cap on every display
    /// and title role did exactly that — at the accessibility sizes a person's name was
    /// set smaller than "Leo · Partner" underneath it.
    ///
    /// So the ceilings are staggered to preserve the hierarchy rather than to hold a
    /// single number, and the roles that title a row are not capped at all: they are UI
    /// titles rather than editorial display, and they have to keep pace with the body
    /// copy they sit above. `HumayTypeRoleTests` asserts the resulting order.
    var maxScale: CGFloat? {
        switch self {
        // Chrome. The mark is a fixed piece of brand furniture, not reading text.
        case .wordmark: 1.4
        case .displayXL: 1.8
        case .displayL: 2.2
        case .displayM: 2.6
        // Uncapped: a row title must never end up smaller than its own subtitle.
        case .titleM, .titleS: nil
        // Tables stay legible only if the columns stay roughly aligned.
        case .monoKicker, .monoFact, .monoDegree: 1.2
        case .body, .bodySmall, .callout, .label, .caption: nil
        }
    }

    /// Letter spacing, in ems. Positive opens mono kickers; negative tightens display.
    var trackingEm: CGFloat {
        switch self {
        case .wordmark: 0.34
        case .displayXL, .displayL: -0.022
        case .displayM: -0.018
        case .titleM, .titleS: -0.01
        case .monoKicker: 0.14
        case .monoFact: 0.06
        case .monoDegree: 0.02
        default: 0
        }
    }

    var isMonospaced: Bool {
        switch self {
        case .monoKicker, .monoFact, .monoDegree: true
        default: false
        }
    }

    var systemWeight: Font.Weight {
        switch self {
        case .label: .medium
        case .monoKicker: .medium
        default: .regular
        }
    }

    /// Extra leading beyond the font's own, for reading comfort.
    var lineSpacing: CGFloat {
        switch self {
        case .body: 6
        case .bodySmall: 5
        case .callout: 4
        case .displayXL, .displayL, .displayM: 2
        default: 0
        }
    }
}
