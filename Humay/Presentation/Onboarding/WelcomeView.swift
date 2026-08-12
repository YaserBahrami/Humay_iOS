import SwiftUI

struct WelcomeView: View {
    let onBegin: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var portraitSpacing: CGFloat {
        horizontalSizeClass == .compact ? HumaySpacing.large : HumaySpacing.extraLarge
    }

    var body: some View {
        OnboardingScreen { proxy in
            if proxy.size.width > proxy.size.height {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
    }

    private var portraitLayout: some View {
        VStack(alignment: .leading, spacing: portraitSpacing) {
            OnboardingChrome(
                stepLabel: nil,
                progressIndex: 0,
                onBack: nil
            )

            VStack(alignment: .leading, spacing: portraitSpacing) {
                OnboardingTitleBlock(
                    title: "Read the sky. Keep the fun.",
                    supporting: "Astrology that feels human — with the reasoning close enough to open whenever you want it.",
                    hero: true
                )
                .frame(maxWidth: horizontalSizeClass == .compact ? 300 : .infinity, alignment: .leading)

                WelcomeHeroCard()

                featureCues

                OnboardingPrimaryAction(
                    title: "Begin",
                    identifier: "onboarding.welcome.begin",
                    action: onBegin
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
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

                featureCues

                OnboardingPrimaryAction(
                    title: "Begin",
                    identifier: "onboarding.welcome.begin",
                    action: onBegin
                )
            }
            .frame(maxWidth: 420, alignment: .leading)

            WelcomeHeroCard()
                .frame(maxWidth: .infinity, minHeight: 360)
        }
        .frame(maxWidth: 1120, alignment: .center)
    }

    private var featureCues: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
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
}

private struct WelcomeHeroCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isCompact: Bool { horizontalSizeClass == .compact }

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

            HStack(alignment: .bottom, spacing: HumaySpacing.small) {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    Text("YOUR COSMIC COMPANION")
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humayCoral)
                        .tracking(1.2)

                    Text("Clear when it matters.\nPlayful when it can be.")
                        .font(HumayTypography.onboardingCardTitle)
                        .foregroundStyle(heroText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("A little perspective. Zero cosmic homework.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(heroText.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(
                    maxWidth: isCompact ? 225 : 520,
                    alignment: .leading
                )

                CelestialCompanionArt()
                    .frame(width: isCompact ? 95 : 170, height: isCompact ? 150 : 190)
                    .scaleEffect(isCompact ? 0.72 : 1)
            }
            .padding(isCompact ? HumaySpacing.medium : HumaySpacing.extraLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: isCompact ? 220 : 250)
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

private struct CelestialCompanionArt: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.humayLavender.opacity(colorScheme == .light ? 0.16 : 0.22))
                .frame(width: 144, height: 144)

            Ellipse()
                .fill(Color.humaySolarGold)
                .frame(width: 92, height: 22)
                .offset(y: 38)

            RoundedRectangle(cornerRadius: 34)
                .fill(companionColor)
                .frame(width: 86, height: 82)
                .offset(y: 34)

            HStack(spacing: 18) {
                Circle()
                    .fill(companionEyeColor)
                    .frame(width: 5, height: 5)
                Circle()
                    .fill(companionEyeColor)
                    .frame(width: 5, height: 5)
            }
            .offset(y: 43)

            Capsule()
                .stroke(companionEyeColor, lineWidth: 2)
                .frame(width: 18, height: 10)
                .offset(y: 56)

            Image(systemName: "sparkle")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.humaySolarGold)
                .offset(x: 56, y: -42)

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.humayCoral)
                .offset(x: -56, y: -58)
        }
        .frame(width: 190, height: 190)
        .accessibilityHidden(true)
    }

    private var companionColor: Color {
        colorScheme == .light ? .humayTextPrimary : .humayTextPrimary
    }

    private var companionEyeColor: Color {
        colorScheme == .light ? .humayGround : .humayGround
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
