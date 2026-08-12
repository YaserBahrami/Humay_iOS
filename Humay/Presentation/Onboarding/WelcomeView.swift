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

                CosmicCupCompanion()
                    .frame(
                        width: compactHeight ? 78 : (isCompactWidth ? 108 : 180),
                        height: compactHeight ? 96 : (isCompactWidth ? 146 : 190)
                    )
                    .scaleEffect(compactHeight ? 0.52 : (isCompactWidth ? 0.78 : 1))
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

private struct CosmicCupCompanion: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.humayLavender.opacity(colorScheme == .light ? 0.14 : 0.20))
                .frame(width: 148, height: 148)

            Circle()
                .stroke(Color.humayLavender.opacity(0.28), lineWidth: 1)
                .frame(width: 126, height: 126)

            steam
                .offset(y: -54)

            Circle()
                .stroke(cupColor, lineWidth: 8)
                .frame(width: 42, height: 42)
                .offset(x: 48, y: 31)

            Capsule()
                .fill(Color.humaySolarGold.opacity(0.20))
                .frame(width: 108, height: 8)
                .offset(y: 75)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cupColor)
                .frame(width: 96, height: 74)
                .offset(y: 30)

            Ellipse()
                .fill(Color.humaySolarGold)
                .frame(width: 98, height: 23)
                .offset(y: -5)

            Ellipse()
                .fill(coffeeColor)
                .frame(width: 82, height: 14)
                .offset(y: -5)

            HStack(spacing: 20) {
                Circle()
                    .fill(faceInk)
                    .frame(width: 5, height: 5)
                Circle()
                    .fill(faceInk)
                    .frame(width: 5, height: 5)
            }
            .offset(y: 35)

            smile
                .offset(y: 50)

            Image(systemName: "sparkle")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.humaySolarGold)
                .offset(x: 61, y: -48)

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.humayCoral)
                .offset(x: -59, y: -63)
        }
        .frame(width: 190, height: 190)
        .accessibilityHidden(true)
    }

    private var cupColor: Color {
        colorScheme == .light ? .humayRaisedSurface : .humayTextPrimary
    }

    private var faceInk: Color {
        colorScheme == .light ? .humayTextPrimary : .humayGround
    }

    private var coffeeColor: Color {
        .humayCosmicCoffee
    }

    private var steam: some View {
        Canvas { context, size in
            var lavender = Path()
            lavender.move(to: CGPoint(x: size.width * 0.34, y: size.height))
            lavender.addCurve(
                to: CGPoint(x: size.width * 0.36, y: 0),
                control1: CGPoint(x: size.width * 0.12, y: size.height * 0.64),
                control2: CGPoint(x: size.width * 0.58, y: size.height * 0.38)
            )
            context.stroke(
                lavender,
                with: .color(Color.humayLavender),
                style: StrokeStyle(lineWidth: 2.2, lineCap: .round)
            )

            var coral = Path()
            coral.move(to: CGPoint(x: size.width * 0.66, y: size.height))
            coral.addCurve(
                to: CGPoint(x: size.width * 0.70, y: size.height * 0.10),
                control1: CGPoint(x: size.width * 0.45, y: size.height * 0.68),
                control2: CGPoint(x: size.width * 0.86, y: size.height * 0.48)
            )
            context.stroke(
                coral,
                with: .color(Color.humayCoral),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
            )
        }
        .frame(width: 54, height: 44)
    }

    private var smile: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: 2, y: 2))
            path.addQuadCurve(
                to: CGPoint(x: size.width - 2, y: 2),
                control: CGPoint(x: size.width / 2, y: size.height)
            )
            context.stroke(
                path,
                with: .color(faceInk),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
            )
        }
        .frame(width: 20, height: 10)
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
