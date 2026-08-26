import SwiftUI

struct OnboardingFlowView: View {
    @Binding private var route: OnboardingRoute
    @Bindable private var draft: OnboardingDraftState

    private let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        route: Binding<OnboardingRoute>,
        draft: OnboardingDraftState,
        onComplete: @escaping () -> Void
    ) {
        self._route = route
        self._draft = Bindable(wrappedValue: draft)
        self.onComplete = onComplete
    }

    var body: some View {
        Group {
            switch route {
            case .welcome:
                WelcomeView {
                    route = .birthDate
                }

            case .birthDate:
                BirthDateView(
                    draft: draft,
                    onBack: { route = .welcome },
                    onContinue: {
                        guard draft.confirmBirthDate() else { return }
                        route = .name
                    }
                )

            case .name:
                NameView(
                    draft: draft,
                    onBack: { route = .birthDate },
                    onContinue: { route = .tradition }
                )

            case .tradition:
                TraditionView(
                    draft: draft,
                    onBack: { route = .name },
                    onContinue: { route = .profileReveal }
                )

            case .profileReveal:
                if let birthDate = draft.confirmedBirthDate {
                    ProfileRevealView(
                        birthDate: birthDate,
                        displayName: draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                        tradition: draft.selectedTradition,
                        onBack: { route = .tradition },
                        onEnterHumay: onComplete
                    )
                } else {
                    BirthDateView(
                        draft: draft,
                        onBack: { route = .welcome },
                        onContinue: {
                            guard draft.confirmBirthDate() else { return }
                            route = .name
                        }
                    )
                }
            }
        }
        .transition(
            reduceMotion
                ? .opacity
                : .asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                )
        )
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.24),
            value: route
        )
    }
}

struct OnboardingScreen<Content: View>: View {
    private let content: (GeometryProxy) -> Content

    init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content(proxy)
                    .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                    .padding(.vertical, HumaySpacing.large)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
    }
}

struct OnboardingChrome: View {
    let stepLabel: String?
    let progressIndex: Int
    let onBack: (() -> Void)?

    var body: some View {
        HStack(spacing: HumaySpacing.small) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.humayTextPrimary)
                .accessibilityLabel("Back")
                .accessibilityHint("Returns to the previous onboarding step")
                .accessibilityIdentifier("onboarding.step.back")
            } else {
                Text("humay")
                    .font(HumayTypography.wordmark)
                    .foregroundStyle(Color.humayTextPrimary)
                    .accessibilityAddTraits(.isHeader)
            }

            if let stepLabel {
                Text(stepLabel)
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)
                    .tracking(1.1)
            }

            Spacer(minLength: HumaySpacing.small)

            OnboardingProgress(index: progressIndex)
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget)
    }
}

struct OnboardingProgress: View {
    let index: Int

    var body: some View {
        HStack(spacing: HumaySpacing.small) {
            ForEach(0..<5, id: \.self) { step in
                Capsule()
                    .fill(step == index ? Color.humayCoral : Color.humayHairline)
                    .frame(
                        width: step == index ? 22 : 6,
                        height: 6
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue("Step \(index + 1) of 5")
    }
}

struct OnboardingTitleBlock: View {
    let title: String
    let supporting: String
    let hero: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            Text(title)
                .font(hero ? HumayTypography.heroTitle : HumayTypography.editorialTitle)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(supporting)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct OnboardingPrimaryAction: View {
    let title: String
    let identifier: String
    let action: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
            .buttonStyle(.humayPrimary)
            .frame(maxWidth: .infinity)
            .frame(maxWidth: horizontalSizeClass == .compact ? 374 : 260)
            .frame(minHeight: HumayMetrics.minimumHitTarget)
            .accessibilityIdentifier(identifier)
    }
}

struct OnboardingFeatureCue: View {
    let symbol: String
    let tint: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.16), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(title)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)
                Text(detail)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: 44, alignment: .leading)
    }
}

struct OnboardingInfoCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HumaySurface {
            content
        }
    }
}
