import SwiftUI

enum HumayButtonKind {
    case primary
    case secondary
}

struct HumayButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    @Environment(\.isEnabled) private var isEnabled

    let kind: HumayButtonKind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HumayTypography.control)
            .foregroundStyle(foregroundColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, HumaySpacing.extraLarge)
            .padding(.vertical, HumaySpacing.medium)
            .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: 56)
            .background(backgroundStyle, in: buttonShape)
            .overlay {
                if kind == .secondary {
                    buttonShape
                        .strokeBorder(
                            Color.humayHairline,
                            lineWidth: HumayMetrics.hairline(displayScale: displayScale)
                        )
                }
            }
            .contentShape(buttonShape)
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.12),
                value: configuration.isPressed
            )
    }

    private var buttonShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: HumayRadius.compact,
            style: .continuous
        )
    }

    private var backgroundStyle: AnyShapeStyle {
        guard isEnabled else { return AnyShapeStyle(Color.humayHairline) }

        switch kind {
        case .primary:
            if colorScheme == .light {
                return AnyShapeStyle(Color.humayTextPrimary)
            }

            return AnyShapeStyle(
                LinearGradient(
                    colors: [.humayCoral, .humayLavender],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .secondary:
            return AnyShapeStyle(Color.humaySurface)
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return .humayTextSecondary }

        return switch kind {
        case .primary:
            // Dark foreground remains readable across both approved gradient endpoints.
            Color.humayGround
        case .secondary:
            Color.humayTextPrimary
        }
    }
}

extension ButtonStyle where Self == HumayButtonStyle {
    static var humayPrimary: HumayButtonStyle {
        HumayButtonStyle(kind: .primary)
    }

    static var humaySecondary: HumayButtonStyle {
        HumayButtonStyle(kind: .secondary)
    }
}
