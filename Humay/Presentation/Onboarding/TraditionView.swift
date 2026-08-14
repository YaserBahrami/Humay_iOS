import SwiftUI

struct TraditionView: View {
    @Bindable var draft: OnboardingDraftState

    let onBack: () -> Void
    let onContinue: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        OnboardingScreen { proxy in
            let compactHeight = proxy.size.height < 700
            let sectionSpacing = bounded(
                proxy.size.height * (compactHeight ? 0.012 : 0.016),
                minimum: 8,
                maximum: 16
            )

            if proxy.size.width > proxy.size.height {
                landscapeLayout(
                    compactHeight: compactHeight,
                    sectionSpacing: sectionSpacing
                )
            } else {
                portraitLayout(
                    compactHeight: compactHeight,
                    sectionSpacing: sectionSpacing
                )
            }
        }
        .scrollDisabled(!dynamicTypeSize.isAccessibilitySize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            primaryAction
                .frame(maxWidth: .infinity)
                .padding(.horizontal, HumaySpacing.large)
                .padding(.top, HumaySpacing.small)
                .padding(.bottom, HumaySpacing.small)
                .background(Color.humayGround)
        }
    }

    private func portraitLayout(
        compactHeight: Bool,
        sectionSpacing: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
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

            optionCards(compactHeight: compactHeight)

            reassurance(compactHeight: compactHeight)
        }
        .frame(maxWidth: 960, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func landscapeLayout(
        compactHeight: Bool,
        sectionSpacing: CGFloat
    ) -> some View {
        HStack(alignment: .top, spacing: compactHeight ? HumaySpacing.large : HumaySpacing.extraExtraLarge) {
            VStack(alignment: .leading, spacing: sectionSpacing) {
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

                reassurance(compactHeight: compactHeight)
            }
            .frame(maxWidth: 420, alignment: .leading)

            optionCardsStacked(compactHeight: compactHeight)
                .frame(maxWidth: 620, alignment: .leading)
        }
        .frame(maxWidth: 1120, alignment: .center)
    }

    @ViewBuilder
    private func optionCards(compactHeight: Bool) -> some View {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            HStack(alignment: .top, spacing: compactHeight ? HumaySpacing.small : HumaySpacing.medium) {
                ForEach(AstrologyTradition.allCases) { tradition in
                    TraditionChoiceCard(
                        tradition: tradition,
                        isSelected: draft.selectedTradition == tradition,
                        compactHeight: compactHeight,
                        onSelect: { draft.selectedTradition = tradition }
                    )
                }
            }
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: compactHeight ? HumaySpacing.small : HumaySpacing.medium) {
                    ForEach(AstrologyTradition.allCases) { tradition in
                        TraditionChoiceCard(
                            tradition: tradition,
                            isSelected: draft.selectedTradition == tradition,
                            compactHeight: compactHeight,
                            onSelect: { draft.selectedTradition = tradition }
                        )
                        .frame(minWidth: 180)
                    }
                }

                optionCardsStacked(compactHeight: compactHeight)
            }
        }
    }

    private func optionCardsStacked(compactHeight: Bool) -> some View {
        VStack(spacing: compactHeight ? 7 : HumaySpacing.medium) {
            ForEach(AstrologyTradition.allCases) { tradition in
                TraditionChoiceCard(
                    tradition: tradition,
                    isSelected: draft.selectedTradition == tradition,
                    compactHeight: compactHeight,
                    onSelect: { draft.selectedTradition = tradition }
                )
            }
        }
    }

    private func reassurance(compactHeight: Bool) -> some View {
        HumaySurface(padding: compactHeight ? HumaySpacing.medium : HumaySpacing.extraLarge) {
            VStack(alignment: .leading, spacing: compactHeight ? 3 : HumaySpacing.small) {
                Text("Your choice is a starting point, not a lock.")
                    .font(compactHeight ? HumayTypography.supportingEmphasized : HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)

                Text("Change it later from Profile.")
                    .font(compactHeight ? HumayTypography.caption : HumayTypography.supporting)
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

    private func bounded(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }
}

private struct TraditionChoiceCard: View {
    let tradition: AstrologyTradition
    let isSelected: Bool
    let compactHeight: Bool
    let onSelect: () -> Void

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: compactHeight ? HumaySpacing.small : HumaySpacing.medium) {
                HumayIllustration(name: artworkName)
                    .frame(
                        width: compactHeight ? 46 : 58,
                        height: compactHeight ? 46 : 58
                    )

                VStack(alignment: .leading, spacing: compactHeight ? 2 : HumaySpacing.extraSmall) {
                    Text(tradition.shortName)
                        .font(compactHeight ? HumayTypography.supportingEmphasized : HumayTypography.bodyEmphasized)
                        .foregroundStyle(Color.humayTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(description)
                        .font(compactHeight ? HumayTypography.caption : HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: compactHeight ? 19 : 22, weight: .semibold))
                    .foregroundStyle(isSelected ? accentColor : Color.humayTextSecondary)
                    .accessibilityHidden(true)
            }
            .padding(compactHeight ? 9 : HumaySpacing.medium)
            .frame(
                minWidth: HumayMetrics.minimumHitTarget,
                minHeight: compactHeight ? 68 : 88,
                alignment: .leading
            )
            .background(
                isSelected ? accentColor.opacity(0.10) : Color.humaySurface,
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

    private var artworkName: String {
        switch tradition {
        case .western: "IllustrationTraditionWestern"
        case .vedic: "IllustrationTraditionVedic"
        case .chinese: "IllustrationTraditionChinese"
        }
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
