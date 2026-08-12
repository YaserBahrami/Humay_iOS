import SwiftUI

/// Semantic type roles. Cormorant roles use `relativeTo` so Dynamic Type scales
/// them with the corresponding system text style.
enum HumayTypography {
    static let wordmark = Font.custom(
        "CormorantGaramond-Regular",
        size: 36,
        relativeTo: .largeTitle
    )

    static let heroTitle = Font.custom(
        "CormorantGaramond-Regular",
        size: 44,
        relativeTo: .largeTitle
    )

    static let editorialTitle = Font.custom(
        "CormorantGaramond-Regular",
        size: 34,
        relativeTo: .title
    )

    static let expressiveScore = Font.custom(
        "CormorantGaramond-Regular",
        size: 56,
        relativeTo: .largeTitle
    )

    static let body = Font.body
    static let bodyEmphasized = Font.body.weight(.semibold)
    static let supporting = Font.subheadline
    static let control = Font.body.weight(.semibold)
    static let utility = Font.caption.weight(.semibold)
    static let technical = Font.system(.body, design: .monospaced)
}
