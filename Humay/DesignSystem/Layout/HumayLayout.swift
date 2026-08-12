import SwiftUI

enum HumayContentWidth: CGFloat, CaseIterable {
    case form = 560
    case readable = 680
    case expanded = 960
}

enum HumayLayout {
    static let compactScreenGutter: CGFloat = 20

    static func screenGutter(for availableWidth: CGFloat) -> CGFloat {
        switch availableWidth {
        case ..<440:
            compactScreenGutter
        case ..<700:
            HumaySpacing.extraLarge
        default:
            HumaySpacing.extraExtraLarge
        }
    }

    static func contentWidth(
        for availableWidth: CGFloat,
        maximum: HumayContentWidth
    ) -> CGFloat {
        max(
            0,
            min(
                maximum.rawValue,
                availableWidth - (screenGutter(for: availableWidth) * 2)
            )
        )
    }
}

/// Centers content in a width-bounded column. Its width comes from the containing
/// window, so iPad multitasking naturally collapses toward the compact composition.
struct HumayContentColumn<Content: View>: View {
    private let maximum: HumayContentWidth
    private let content: Content

    init(
        maximum: HumayContentWidth = .readable,
        @ViewBuilder content: () -> Content
    ) {
        self.maximum = maximum
        self.content = content()
    }

    var body: some View {
        content
            .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                HumayLayout.contentWidth(for: length, maximum: maximum)
            }
    }
}

/// Uses a horizontal composition only when all children fit in available width.
/// Otherwise it reflows to a leading-aligned vertical stack.
struct HumayAdaptiveStack<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    init(
        spacing: CGFloat = HumaySpacing.extraLarge,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: spacing) {
                content
            }

            VStack(alignment: .leading, spacing: spacing) {
                content
            }
        }
    }
}
