import SwiftUI

/// Semantic type roles. Custom editorial roles use `relativeTo` so Dynamic Type
/// scales them with the corresponding system text style.
enum HumayTypography {
    private static let newsreaderPostScriptName = "Newsreader16pt-Regular"

    static let wordmark = Font.custom(
        "CormorantGaramond-Regular",
        size: 36,
        relativeTo: .largeTitle
    )

    static let heroTitle = newsreader(size: 40, relativeTo: .largeTitle, weight: .medium)

    static let editorialTitle = newsreader(size: 28, relativeTo: .title, weight: .medium)

    static let onboardingCardTitle = newsreader(size: 22, relativeTo: .title2, weight: .medium)

    static let expressiveScore = newsreader(size: 56, relativeTo: .largeTitle)

    static let compatibilityScore = newsreader(size: 68, relativeTo: .largeTitle)

    static let cardTitle = newsreader(size: 25, relativeTo: .title2, weight: .medium)

    static let body = Font.body
    static let bodyEmphasized = Font.body.weight(.semibold)
    static let supporting = Font.subheadline
    static let control = Font.body.weight(.semibold)
    static let utility = Font.caption.weight(.semibold)

    /// Reserved for degree-heavy or coordinate-heavy Chart values.
    static let technical = Font.system(.body, design: .monospaced)

    private static func newsreader(
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle,
        weight: Font.Weight = .regular
    ) -> Font {
        Font.custom(newsreaderPostScriptName, size: size, relativeTo: textStyle)
            .weight(weight)
    }
}
