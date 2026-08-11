import SwiftUI

/// The primary action: an ink fill with paper text.
///
/// Square by default. There is one of these per screen at most — when everything is
/// emphasised, nothing is.
struct HumayPrimaryButtonStyle: ButtonStyle {
    @Environment(\.humayTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .humayFont(.label)
            .foregroundStyle(theme.colors.actionLabel)
            .frame(maxWidth: .infinity, minHeight: HumayHitTarget.minimum)
            .background(theme.colors.actionFill.opacity(isEnabled ? 1 : 0.35))
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(HumayMotion.strike, value: configuration.isPressed)
    }
}

/// A secondary action: a hairline outline, no fill.
struct HumayOutlineButtonStyle: ButtonStyle {
    @Environment(\.humayTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .humayFont(.label)
            .foregroundStyle(theme.colors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: HumayHitTarget.minimum)
            .overlay(Rectangle().stroke(theme.colors.hairlineStrong, lineWidth: HumayBorder.hairline))
            .opacity(configuration.isPressed ? 0.6 : (isEnabled ? 1 : 0.4))
            .animation(HumayMotion.strike, value: configuration.isPressed)
    }
}

/// A quiet, text-only action.
struct HumayQuietButtonStyle: ButtonStyle {
    @Environment(\.humayTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .humayFont(.label)
            .foregroundStyle(theme.colors.accentText)
            .frame(minHeight: HumayHitTarget.minimum)
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(HumayMotion.strike, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == HumayPrimaryButtonStyle {
    static var humayPrimary: HumayPrimaryButtonStyle { HumayPrimaryButtonStyle() }
}

extension ButtonStyle where Self == HumayOutlineButtonStyle {
    static var humayOutline: HumayOutlineButtonStyle { HumayOutlineButtonStyle() }
}

extension ButtonStyle where Self == HumayQuietButtonStyle {
    static var humayQuiet: HumayQuietButtonStyle { HumayQuietButtonStyle() }
}

/// A segmented control drawn as underlined labels rather than a filled pill.
///
/// The system control is a rounded translucent capsule, which fights a design built on
/// square edges and hairlines. This keeps the interaction native — a row of buttons
/// with a selection — while looking like the rest of the application.
struct HumaySegmentedControl<Value: Hashable>: View {
    let options: [Value]
    let title: (Value) -> String
    @Binding var selection: Value

    @Environment(\.humayTheme) private var theme
    @Namespace private var underline

    var body: some View {
        HStack(spacing: HumaySpacing.l) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(HumayMotion.strike) { selection = option }
                } label: {
                    VStack(spacing: HumaySpacing.xs) {
                        Text(title(option))
                            .humayFont(.label)
                            .foregroundStyle(
                                option == selection ? theme.colors.textPrimary : theme.colors.textLabel
                            )
                        Group {
                            if option == selection {
                                Rectangle()
                                    .fill(theme.colors.accentMark)
                                    .frame(height: 1.5)
                                    .matchedGeometryEffect(id: "underline", in: underline)
                            } else {
                                Color.clear.frame(height: 1.5)
                            }
                        }
                    }
                    .frame(minHeight: HumayHitTarget.minimum)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(option == selection ? [.isSelected, .isButton] : .isButton)
            }
            Spacer(minLength: 0)
        }
    }
}

/// A tappable row that pushes somewhere. The standard list idiom, restyled.
struct HumayDisclosureRow<Leading: View>: View {
    let title: String
    var detail: String?
    var action: () -> Void
    @ViewBuilder var leading: Leading

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: HumaySpacing.s) {
                leading
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .humayFont(.titleS)
                        .foregroundStyle(theme.colors.textPrimary)
                        .multilineTextAlignment(.leading)
                    if let detail {
                        Text(detail)
                            .humayFont(.callout)
                            .foregroundStyle(theme.colors.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: HumaySpacing.s)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(theme.colors.textLabel)
            }
            .frame(minHeight: HumayHitTarget.minimum)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension HumayDisclosureRow where Leading == EmptyView {
    init(title: String, detail: String? = nil, action: @escaping () -> Void) {
        self.init(title: title, detail: detail, action: action) { EmptyView() }
    }
}

/// A small circular info trigger beside a term.
///
/// Visually small, but with a full 44pt target — the glyph is the affordance, not the
/// hit area.
struct InfoTrigger: View {
    let termID: String
    let termName: String
    let action: (String) -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Button {
            action(termID)
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.colors.accentText)
                .frame(width: HumayHitTarget.minimum, height: HumayHitTarget.minimum)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("What does \(termName) mean?")
    }
}
