import SwiftUI

struct TraditionView: View {
    @Bindable var draft: OnboardingDraftState

    let onBack: () -> Void
    let onContinue: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        OnboardingScreen { proxy in
            if proxy.size.width > proxy.size.height {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            primaryAction
                .frame(maxWidth: .infinity)
                .padding(.horizontal, HumaySpacing.large)
                .padding(.top, HumaySpacing.small)
                .padding(.bottom, HumaySpacing.small)
                .background(Color.humayGround)
        }
    }

    private var portraitLayout: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            OnboardingChrome(
                stepLabel: "02 · Tradition",
                progressIndex: 2,
                onBack: onBack
            )

            OnboardingTitleBlock(
                title: "Choose your starting tradition",
                supporting: "This sets the language Humay leads with. You can explore the others anytime.",
                hero: false
            )

            optionCards

            reassurance
        }
        .frame(maxWidth: 960, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                OnboardingChrome(
                    stepLabel: "02 · Tradition",
                    progressIndex: 2,
                    onBack: onBack
                )

                OnboardingTitleBlock(
                    title: "Choose your starting tradition",
                    supporting: "This sets the language Humay leads with. You can explore the others anytime.",
                    hero: false
                )

                reassurance
            }
            .frame(maxWidth: 420, alignment: .leading)

            optionCardsStacked
                .frame(maxWidth: 620, alignment: .leading)
        }
        .frame(maxWidth: 1120, alignment: .center)
    }

    @ViewBuilder
    private var optionCards: some View {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            HStack(alignment: .top, spacing: HumaySpacing.medium) {
                ForEach(AstrologyTradition.allCases) { tradition in
                    TraditionChoiceCard(
                        tradition: tradition,
                        isSelected: draft.selectedTradition == tradition,
                        onSelect: { draft.selectedTradition = tradition }
                    )
                }
            }
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: HumaySpacing.medium) {
                    ForEach(AstrologyTradition.allCases) { tradition in
                        TraditionChoiceCard(
                            tradition: tradition,
                            isSelected: draft.selectedTradition == tradition,
                            onSelect: { draft.selectedTradition = tradition }
                        )
                        .frame(minWidth: 180)
                    }
                }

                optionCardsStacked
            }
        }
    }

    private var optionCardsStacked: some View {
        VStack(spacing: HumaySpacing.medium) {
            ForEach(AstrologyTradition.allCases) { tradition in
                TraditionChoiceCard(
                    tradition: tradition,
                    isSelected: draft.selectedTradition == tradition,
                    onSelect: { draft.selectedTradition = tradition }
                )
            }
        }
    }

    private var reassurance: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text("Your choice is a starting point, not a lock.")
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)

                Text("Change it later from Profile.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
    }

    private var primaryAction: some View {
        OnboardingPrimaryAction(
            title: "Continue",
            identifier: "onboarding.tradition.continue",
            action: onContinue
        )
    }
}

private struct TraditionChoiceCard: View {
    let tradition: AstrologyTradition
    let isSelected: Bool
    let onSelect: () -> Void

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: HumaySpacing.medium) {
                Capsule()
                    .fill(accentColor)
                    .frame(width: 28, height: 6)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text(tradition.shortName)
                        .font(HumayTypography.bodyEmphasized)
                        .foregroundStyle(Color.humayTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(description)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? accentColor : Color.humayTextSecondary)
                    .accessibilityHidden(true)
            }
            .padding(HumaySpacing.large)
            .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: 84, alignment: .leading)
            .background(
                isSelected ? Color.humayLavender.opacity(0.12) : Color.humaySurface,
                in: RoundedRectangle(cornerRadius: HumayRadius.compact)
            )
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.compact)
                    .strokeBorder(
                        isSelected ? accentColor : Color.humayHairline,
                        lineWidth: HumayMetrics.hairline(displayScale: displayScale)
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: HumayRadius.compact))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tradition.shortName)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Sets the leading tradition. Other traditions remain available.")
        .accessibilityIdentifier("onboarding.tradition.\(tradition.rawValue)")
    }

    private var accentColor: Color {
        switch tradition {
        case .western: .humayCoral
        case .vedic: .humayLavender
        case .chinese: .humaySolarGold
        }
    }

    private var description: String {
        switch tradition {
        case .western: "Tropical zodiac · planets · aspects"
        case .vedic: "Sidereal zodiac · Jyotish tradition"
        case .chinese: "Chinese astrology · year-sign tradition"
        }
    }
}

#Preview("Tradition Light") {
    TraditionView(
        draft: OnboardingDraftState(),
        onBack: {},
        onContinue: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Tradition Dark") {
    TraditionView(
        draft: OnboardingDraftState(),
        onBack: {},
        onContinue: {}
    )
    .preferredColorScheme(.dark)
}
