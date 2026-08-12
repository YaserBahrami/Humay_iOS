import SwiftUI

struct WelcomeView: View {
    let onBegin: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
                landscapeLayout(sectionSpacing: sectionSpacing)
            } else {
                portraitLayout(
                    sectionSpacing: sectionSpacing,
                    heroHeight: bounded(
                        proxy.size.height * (compactHeight ? 0.22 : 0.25),
                        minimum: 140,
                        maximum: 220
                    ),
                    compactHeight: compactHeight
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
        sectionSpacing: CGFloat,
        heroHeight: CGFloat,
        compactHeight: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            OnboardingChrome(
                stepLabel: nil,
                progressIndex: 0,
                onBack: nil
            )

            OnboardingTitleBlock(
                title: "Read the sky. Keep the fun.",
                supporting: "Astrology that feels human — with the reasoning close enough to open whenever you want it.",
                hero: true
            )
            .frame(maxWidth: horizontalSizeClass == .compact ? 300 : .infinity, alignment: .leading)

            WelcomeHeroCard(
                height: heroHeight,
                compactHeight: compactHeight
            )

            featureCues(compactHeight: compactHeight)
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func landscapeLayout(sectionSpacing: CGFloat) -> some View {
        HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                OnboardingChrome(
                    stepLabel: nil,
                    progressIndex: 0,
                    onBack: nil
                )

                OnboardingTitleBlock(
                    title: "Read the sky. Keep the fun.",
                    supporting: "Astrology that feels human — with the reasoning close enough to open whenever you want it.",
                    hero: false
                )

                featureCues(compactHeight: false)
            }
            .frame(maxWidth: 420, alignment: .leading)

            WelcomeHeroCard(height: 340, compactHeight: false)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: 1120, alignment: .center)
    }

    private var primaryAction: some View {
        OnboardingPrimaryAction(
            title: "Begin",
            identifier: "onboarding.welcome.begin",
            action: onBegin
        )
    }

    private func featureCues(compactHeight: Bool) -> some View {
        VStack(alignment: .leading, spacing: compactHeight ? 6 : HumaySpacing.medium) {
            OnboardingFeatureCue(
                symbol: "sun.max",
                tint: .humayCoral,
                title: "Daily readings",
                detail: "Personal guidance without cosmic homework"
            )

            OnboardingFeatureCue(
                symbol: "heart",
                tint: .humayLavender,
                title: "Compatibility",
                detail: "People, chemistry, and the messy bits"
            )

            OnboardingFeatureCue(
                symbol: "sparkles",
                tint: .humaySolarGold,
                title: "Three traditions",
                detail: "Western, Vedic and Chinese stay distinct"
            )
        }
    }

    private func bounded(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }
}

private struct WelcomeHeroCard: View {
    let height: CGFloat
    let compactHeight: Bool

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompactWidth: Bool { horizontalSizeClass == .compact }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .fill(
                    LinearGradient(
                        colors: [heroStart, heroEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(alignment: .center, spacing: compactHeight ? 4 : HumaySpacing.small) {
                VStack(alignment: .leading, spacing: compactHeight ? 5 : HumaySpacing.medium) {
                    Text("YOUR COSMIC COMPANION")
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humayCoral)
                        .tracking(1.2)

                    Text("Clear when it matters.\nPlayful when it can be.")
                        .font(HumayTypography.onboardingCardTitle)
                        .foregroundStyle(heroText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("A little perspective. Zero cosmic homework.")
                        .font(compactHeight ? .caption : HumayTypography.supporting)
                        .foregroundStyle(heroText.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(
                    maxWidth: isCompactWidth ? (compactHeight ? 210 : 225) : 520,
                    alignment: .leading
                )

                HumayIllustration(name: "IllustrationCosmicCoffee")
                    .frame(
                        width: compactHeight ? 92 : (isCompactWidth ? 126 : 200),
                        height: compactHeight ? 100 : (isCompactWidth ? 150 : 200)
                    )
            }
            .padding(compactHeight ? 10 : (isCompactWidth ? HumaySpacing.medium : HumaySpacing.extraLarge))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: HumayRadius.feature))
        .shadow(
            color: colorScheme == .light ? .black.opacity(HumayElevation.subtleShadowOpacity) : .clear,
            radius: colorScheme == .light ? HumayElevation.subtleShadowRadius : 0,
            y: colorScheme == .light ? HumayElevation.subtleShadowY : 0
        )
        .accessibilityElement(children: .contain)
    }

    private var heroStart: Color {
        colorScheme == .light ? .humayTextPrimary : .humayRaisedSurface
    }

    private var heroEnd: Color {
        colorScheme == .light ? .humayTextPrimary.opacity(0.88) : .humaySurface
    }

    private var heroText: Color {
        colorScheme == .light ? .humayGround : .humayTextPrimary
    }
}

#Preview("Welcome Light") {
    WelcomeView {}
        .preferredColorScheme(.light)
}

#Preview("Welcome Dark") {
    WelcomeView {}
        .preferredColorScheme(.dark)
}
