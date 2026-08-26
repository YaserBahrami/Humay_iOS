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

    /// Primary title for a single deep-detail destination.
    static let detailTitle = newsreader(size: 32, relativeTo: .title, weight: .medium)

    static let editorialTitle = newsreader(size: 28, relativeTo: .title, weight: .medium)

    /// Repeated section heading for user-owned content regions.
    static let sectionTitle = newsreader(size: 22, relativeTo: .title2, weight: .medium)

    static let onboardingCardTitle = newsreader(size: 22, relativeTo: .title2, weight: .medium)

    static let expressiveScore = newsreader(size: 56, relativeTo: .largeTitle)

    static let compatibilityScore = newsreader(size: 68, relativeTo: .largeTitle)

    /// Big numerals for meters and counters.
    static let meterValue = Font.system(.title3, design: .rounded, weight: .semibold)

    /// Oversized editorial numeral for hero metrics (share cards, collisions).
    static let heroNumber = newsreader(size: 64, relativeTo: .largeTitle, weight: .medium)

    static let cardTitle = newsreader(size: 25, relativeTo: .title2, weight: .medium)

    static let body = Font.body
    static let bodyEmphasized = Font.body.weight(.semibold)
    static let supporting = Font.subheadline
    static let supportingEmphasized = Font.subheadline.weight(.semibold)
    static let control = Font.body.weight(.semibold)
    static let caption = Font.caption
    static let utility = Font.caption.weight(.semibold)
    static let micro = Font.caption2

    /// Large rounded SF Symbol role for state and status surfaces.
    static let statusSymbol = Font.system(.largeTitle, design: .rounded, weight: .medium)

    /// Civil-calendar roles remain system typography, but use stable semantic names
    /// so month/week surfaces do not drift through local system-style choices.
    static let calendarWeekday = Font.caption.weight(.bold)
    static let calendarDate = Font.callout.weight(.semibold)
    static let calendarDateSelected = Font.callout.weight(.bold)
    static let calendarBoundary = Font.caption2.weight(.bold)
    static let calendarMarker = Font.caption2.weight(.bold)

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
