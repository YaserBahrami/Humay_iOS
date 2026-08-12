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
            .background(backgroundColor, in: Capsule())
            .overlay {
                if kind == .secondary {
                    Capsule()
                        .strokeBorder(
                            Color.humayHairline,
                            lineWidth: HumayMetrics.hairline(displayScale: displayScale)
                        )
                }
            }
            .contentShape(Capsule())
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.12),
                value: configuration.isPressed
            )
    }

    private var backgroundColor: Color {
        guard isEnabled else { return .humayHairline }

        return switch kind {
        case .primary:
            colorScheme == .light ? Color.humayTextPrimary : Color.humayCoral
        case .secondary:
            Color.humaySurface
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return .humayTextSecondary }

        return switch kind {
        case .primary:
            // Midnight text keeps the approved dark coral treatment above 4.5:1.
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
