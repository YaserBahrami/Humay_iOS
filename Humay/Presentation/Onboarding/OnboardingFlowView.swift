import SwiftUI

/// Onboarding: four beats, one question each.
///
/// Tone is deliberately not asked here. Roast means nothing to someone who has not yet
/// read anything in the Normal register, so the choice would be uninformed. It lives in
/// Settings, where both registers are shown side by side, and in the header chip.
struct OnboardingFlowView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var step: Step = .welcome
    @State private var birthDate = Self.defaultBirthDate
    @State private var tradition: AstrologyTradition = .western

    enum Step: Int, CaseIterable {
        case welcome, birthDate, tradition, reveal
    }

    var body: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()

            Group {
                switch step {
                case .welcome:
                    OnboardingWelcomeView(onContinue: { advance(to: .birthDate) })
                case .birthDate:
                    OnboardingBirthDateView(
                        date: $birthDate,
                        onContinue: { advance(to: .tradition) },
                        onBack: { advance(to: .welcome) }
                    )
                case .tradition:
                    OnboardingTraditionView(
                        selection: $tradition,
                        onContinue: { advance(to: .reveal) },
                        onBack: { advance(to: .birthDate) }
                    )
                case .reveal:
                    OnboardingRevealView(
                        birth: birthDetails,
                        tradition: tradition,
                        onEnter: complete
                    )
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .offset(x: 24)),
                removal: .opacity
            ))
        }
        .animation(HumayMotion.turn, value: step)
    }

    private var birthDetails: BirthDetails {
        let components = Calendar(identifier: .gregorian)
            .dateComponents([.year, .month, .day], from: birthDate)
        return BirthDetails(
            year: components.year ?? 1990,
            month: components.month ?? 1,
            day: components.day ?? 1
        )
    }

    private func advance(to next: Step) {
        step = next
    }

    private func complete() {
        environment.completeOnboarding(
            profile: UserProfile(displayName: "", birth: birthDetails),
            tradition: tradition
        )
    }

    private static var defaultBirthDate: Date {
        var components = DateComponents()
        components.year = 1994
        components.month = 3
        components.day = 14
        return Calendar(identifier: .gregorian).date(from: components) ?? .now
    }
}

/// Shared chrome for an onboarding beat: a step marker, content, and one action.
struct OnboardingScaffold<Content: View>: View {
    var stepLabel: String?
    var onBack: (() -> Void)?
    let actionTitle: String
    var actionEnabled: Bool = true
    /// Lets the content claim the full height so its spacers can centre a composition.
    /// Only the welcome beat wants this; the rest are top-aligned forms.
    var fillsHeight: Bool = false
    let action: () -> Void
    @ViewBuilder var content: Content

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if onBack != nil || stepLabel != nil {
                HStack(spacing: HumaySpacing.xs) {
                    if let onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: HumayIconSize.chrome, weight: .regular))
                                .foregroundStyle(theme.colors.textSecondary)
                                .frame(width: HumayHitTarget.minimum, height: HumayHitTarget.minimum)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Back")
                        .padding(.leading, -HumaySpacing.s)
                    }
                    if let stepLabel {
                        MonoKicker(text: stepLabel)
                    }
                    Spacer(minLength: 0)
                }
                .frame(minHeight: HumayHitTarget.minimum)
            }

            // The content scrolls and the action stays pinned. Onboarding has no
            // navigation bar to fall back on, so a beat that overflows without scrolling
            // is a beat with no way forward — which is exactly what happened to the
            // welcome screen at the accessibility text sizes.
            // A minimum height of one viewport, rather than a fixed one: the spacers in
            // the welcome composition can expand into it at the ordinary text sizes, and
            // the content can still grow past it — and scroll — at the accessibility ones.
            GeometryReader { proxy in
                ScrollView {
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, HumaySpacing.l)
                        .padding(.bottom, HumaySpacing.l)
                        .frame(minHeight: fillsHeight ? proxy.size.height : nil, alignment: .top)
                }
                .scrollIndicators(.hidden)
            }

            Button(actionTitle, action: action)
                .buttonStyle(.humayPrimary)
                .disabled(!actionEnabled)
                .padding(.top, HumaySpacing.s)
                .padding(.bottom, HumaySpacing.s)
        }
        .padding(.horizontal, HumaySpacing.gutter)
        .padding(.top, HumaySpacing.screenTop)
    }
}
