import SwiftUI

/// A label-and-value pair that reflows when the text gets large.
///
/// Most rows in this application are a title on the left and a fact on the right. At the
/// accessibility text sizes that arrangement stops working: the two halves fight for a
/// width neither can have, and the fact ends up as one character per line. Rather than
/// shrink the text — which is the thing the reader asked to make bigger — the row turns
/// into a stack and keeps every glyph at full size.
///
/// The switch happens at the accessibility categories rather than gradually, because a
/// row that reflows halfway through the ramp reads as a layout bug.
struct AdaptiveRow<Leading: View, Trailing: View>: View {
    var horizontalSpacing: CGFloat = HumaySpacing.s
    var verticalSpacing: CGFloat = HumaySpacing.xxs
    /// Baseline alignment for the horizontal arrangement. Ignored once stacked.
    var horizontalAlignment: VerticalAlignment = .firstTextBaseline
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: verticalSpacing) {
                leading
                trailing
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(alignment: horizontalAlignment, spacing: horizontalSpacing) {
                leading
                Spacer(minLength: horizontalSpacing)
                trailing
            }
        }
    }
}

extension DynamicTypeSize {
    /// How the trailing half of an `AdaptiveRow` should align its own wrapped lines.
    ///
    /// Right-aligned while the row is still a row. Once it has stacked underneath a
    /// left-aligned label, right-aligned text reads as a mistake rather than a column.
    var rowTrailingAlignment: TextAlignment {
        isAccessibilitySize ? .leading : .trailing
    }
}

/// Lays a fixed set of columns side by side, and stacks them when the text gets large.
///
/// The chart triad and the four BaZi pillars are read as a row of peers, so the columns
/// are worth keeping while they fit. Three or four columns of accessibility-sized text on
/// a phone do not fit, and the dividing rules turn with them.
struct AdaptiveColumns<Item: Identifiable, Content: View>: View {
    let items: [Item]
    @ViewBuilder var content: (Item) -> Content

    @Environment(\.humayTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 { HairlineRule() }
                    content(item)
                }
            }
        } else {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if index > 0 {
                        Rectangle()
                            .fill(theme.colors.hairline)
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)
                    }
                    content(item)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// The sizes at which an SF Symbol may be drawn.
///
/// Before this existed the same chevron was set at 11, 12 and 13 points in different
/// files, which is the kind of drift nobody sees in one screen and everybody feels across
/// twenty. Symbols scale with Dynamic Type; only their hit area is fixed.
enum HumayIconSize {
    /// Disclosure chevrons and other row-level affordances.
    static let row: CGFloat = 12
    /// Toolbar and header controls.
    static let chrome: CGFloat = 15
    /// Inline marks inside a line of text — a caret on a disclosure, a checkmark.
    static let inline: CGFloat = 13
    /// The smallest sanctioned mark. Expansion carets only.
    static let hint: CGFloat = 9
}

/// The disclosure chevron.
///
/// One component, so a row that pushes somewhere always looks the same as every other row
/// that pushes somewhere.
struct DisclosureChevron: View {
    @Environment(\.humayTheme) private var theme

    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: HumayIconSize.row, weight: .regular))
            .foregroundStyle(theme.colors.textLabel)
            .accessibilityHidden(true)
    }
}

extension View {
    /// Guarantees the minimum interactive target without changing what is drawn.
    ///
    /// A 13pt info glyph is the right *mark*; a 13pt tap target is not. This keeps the
    /// glyph small and lets the target extend past it, and the negative padding stops the
    /// enlarged target from pushing its neighbours around.
    func humayHitTarget(compensating: Bool = false) -> some View {
        frame(minWidth: HumayHitTarget.minimum, minHeight: HumayHitTarget.minimum)
            .contentShape(Rectangle())
            .padding(compensating ? -HumaySpacing.s : 0)
    }
}
