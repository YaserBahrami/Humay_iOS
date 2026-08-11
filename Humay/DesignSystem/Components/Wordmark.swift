import SwiftUI

/// The Humay wordmark.
///
/// Set in Cormorant Garamond Light, all caps, with wide tracking. Tracking adds space
/// after the final glyph as well as between them, so an equal leading inset is applied
/// to keep the block optically centred — the brand lock calls for exactly this.
///
/// Never set the wordmark in another face, never add a tagline beside it, and never
/// render it below the minimum size; use the occultation mark alone instead.
struct Wordmark: View {
    /// Point size. Clamped to the 10pt minimum in the component rather than by callers.
    var size: CGFloat = 15
    var color: Color?

    private static let minimumSize: CGFloat = 10
    private static let tracking: CGFloat = 0.34

    @Environment(\.humayTheme) private var theme

    var body: some View {
        let resolved = max(size, Self.minimumSize)
        Text(verbatim: "HUMAY")
            .font(Font(font(at: resolved)))
            .tracking(resolved * Self.tracking)
            .padding(.leading, resolved * Self.tracking)
            .foregroundStyle(color ?? theme.colors.textPrimary)
            .accessibilityLabel("Humay")
    }

    private func font(at resolved: CGFloat) -> UIFont {
        UIFont(name: HumayFontFace.light.postScriptName, size: resolved)
            ?? .systemFont(ofSize: resolved, weight: .light)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 32) {
        Wordmark()
        Wordmark(size: 22)
        Wordmark(size: 44)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .padding(HumaySpacing.gutter)
    .humayBackground()
}
