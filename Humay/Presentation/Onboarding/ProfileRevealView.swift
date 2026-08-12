import SwiftUI

struct ProfileRevealView: View {
    let birthDate: OnboardingBirthDate
    let tradition: AstrologyTradition
    let onBack: () -> Void
    let onEnterHumay: () -> Void

    var body: some View {
        OnboardingScreen { _ in
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                OnboardingChrome(
                    stepLabel: "03 · Your profile",
                    progressIndex: 3,
                    onBack: onBack
                )

                OnboardingTitleBlock(
                    title: "Your starting profile is ready",
                    supporting: "A simple beginning — no fake precision.",
                    hero: false
                )

                ViewThatFits(in: .horizontal) {
                    twoRegionContent
                    compactContent
                }
            }
        }
    }

    private var twoRegionContent: some View {
        HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
            ProfileRevealHero()
                .frame(minWidth: 300, maxWidth: 420)

            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                profileFacts
                primaryAction
            }
            .frame(minWidth: 360, maxWidth: 620, alignment: .leading)
        }
        .frame(maxWidth: 1120, alignment: .center)
    }

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            ProfileRevealHero()
            profileFacts
            primaryAction
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var profileFacts: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                Text("YOUR STARTING PROFILE")
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayCoral)
                    .tracking(1.2)

                Text("You gave Humay just enough to begin.")
                    .font(HumayTypography.editorialTitle)
                    .foregroundStyle(Color.humayTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    ProfileFactRow(
                        label: "Birth date",
                        value: birthDate.formatted()
                    )

                    ProfileFactRow(
                        label: "Starting tradition",
                        value: tradition.shortName
                    )
                }

                Divider()
                    .overlay(Color.humayHairline)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("Precision stays optional")
                        .font(HumayTypography.bodyEmphasized)
                        .foregroundStyle(Color.humayTextPrimary)

                    Text("Add birth time and place later only when a feature genuinely needs them.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("onboarding.profileReveal.summary")
    }

    private var primaryAction: some View {
        OnboardingPrimaryAction(
            title: "Enter Humay",
            identifier: "onboarding.profileReveal.enter",
            action: onEnterHumay
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct ProfileFactRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            Text(label)
                .font(HumayTypography.utility)
                .foregroundStyle(Color.humayTextSecondary)

            Text(value)
                .font(HumayTypography.bodyEmphasized)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileRevealHero: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: HumaySpacing.large) {
            HumaProfileMark()
                .frame(height: 250)
                .accessibilityHidden(true)

            Text("Ready to meet your sky?")
                .font(HumayTypography.editorialTitle)
                .foregroundStyle(Color.humayTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(HumaySpacing.extraLarge)
        .background(heroSurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("onboarding.profileReveal.hero")
    }

    private var heroSurface: Color {
        .humayRaisedSurface
    }
}

/// A decorative Huma-inspired celestial mark for the emotional close of onboarding.
/// The bird is symbolic brand language only; it intentionally communicates no chart fact.
private struct HumaProfileMark: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Ellipse()
                .stroke(
                    Color.humayLavender.opacity(colorScheme == .light ? 0.48 : 0.62),
                    style: StrokeStyle(lineWidth: 1.35, lineCap: .round)
                )
                .frame(width: 252, height: 150)
                .rotationEffect(.degrees(11))

            Ellipse()
                .stroke(
                    Color.humayCoral.opacity(colorScheme == .light ? 0.46 : 0.60),
                    style: StrokeStyle(lineWidth: 1.35, lineCap: .round)
                )
                .frame(width: 226, height: 168)
                .rotationEffect(.degrees(-19))

            HumaBirdLineArt()
                .frame(width: 205, height: 170)
                .offset(y: -4)

            HumaSunGlyph()
                .frame(width: 34, height: 34)
                .offset(x: -105, y: 68)

            Image(systemName: "moon.fill")
                .font(.system(size: 19, weight: .light))
                .foregroundStyle(Color.humayLavender.opacity(colorScheme == .light ? 0.78 : 0.90))
                .offset(x: 111, y: 55)

            Circle()
                .fill(Color.humayCoral)
                .frame(width: 7, height: 7)
                .offset(x: 80, y: -77)

            Circle()
                .fill(Color.humayLavender)
                .frame(width: 7, height: 7)
                .offset(x: -96, y: -59)

            Circle()
                .fill(Color.humaySolarGold)
                .frame(width: 6, height: 6)
                .offset(x: 78, y: 72)

            Image(systemName: "sparkle")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.humaySolarGold)
                .offset(x: 118, y: -47)

            Image(systemName: "sparkle")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.humayCoral)
                .offset(x: -120, y: -28)

            Image(systemName: "sparkle")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color.humayLavender)
                .offset(x: -72, y: 82)
        }
        .frame(width: 300, height: 250)
    }
}

private struct HumaBirdLineArt: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let line = Color.humaySolarGold.opacity(colorScheme == .light ? 0.90 : 0.96)
            let softLine = Color.humaySolarGold.opacity(colorScheme == .light ? 0.48 : 0.62)
            let wash = Color.humaySolarGold.opacity(colorScheme == .light ? 0.055 : 0.07)

            var body = Path()
            body.move(to: CGPoint(x: w * 0.57, y: h * 0.32))
            body.addQuadCurve(
                to: CGPoint(x: w * 0.69, y: h * 0.27),
                control: CGPoint(x: w * 0.63, y: h * 0.27)
            )
            body.addLine(to: CGPoint(x: w * 0.64, y: h * 0.34))
            body.addCurve(
                to: CGPoint(x: w * 0.61, y: h * 0.58),
                control1: CGPoint(x: w * 0.61, y: h * 0.39),
                control2: CGPoint(x: w * 0.66, y: h * 0.50)
            )
            body.addCurve(
                to: CGPoint(x: w * 0.47, y: h * 0.69),
                control1: CGPoint(x: w * 0.58, y: h * 0.64),
                control2: CGPoint(x: w * 0.53, y: h * 0.68)
            )
            body.addCurve(
                to: CGPoint(x: w * 0.36, y: h * 0.62),
                control1: CGPoint(x: w * 0.42, y: h * 0.69),
                control2: CGPoint(x: w * 0.38, y: h * 0.66)
            )
            body.addCurve(
                to: CGPoint(x: w * 0.52, y: h * 0.47),
                control1: CGPoint(x: w * 0.42, y: h * 0.59),
                control2: CGPoint(x: w * 0.49, y: h * 0.54)
            )
            body.addCurve(
                to: CGPoint(x: w * 0.57, y: h * 0.32),
                control1: CGPoint(x: w * 0.53, y: h * 0.40),
                control2: CGPoint(x: w * 0.54, y: h * 0.35)
            )
            body.closeSubpath()
            context.fill(body, with: .color(wash))
            context.stroke(
                body,
                with: .color(line),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
            )

            var leftWing = Path()
            leftWing.move(to: CGPoint(x: w * 0.49, y: h * 0.55))
            leftWing.addCurve(
                to: CGPoint(x: w * 0.31, y: h * 0.11),
                control1: CGPoint(x: w * 0.38, y: h * 0.40),
                control2: CGPoint(x: w * 0.32, y: h * 0.23)
            )
            leftWing.addCurve(
                to: CGPoint(x: w * 0.56, y: h * 0.48),
                control1: CGPoint(x: w * 0.43, y: h * 0.23),
                control2: CGPoint(x: w * 0.51, y: h * 0.35)
            )
            context.stroke(
                leftWing,
                with: .color(line),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
            )

            var rightWing = Path()
            rightWing.move(to: CGPoint(x: w * 0.58, y: h * 0.51))
            rightWing.addCurve(
                to: CGPoint(x: w * 0.88, y: h * 0.32),
                control1: CGPoint(x: w * 0.68, y: h * 0.48),
                control2: CGPoint(x: w * 0.80, y: h * 0.38)
            )
            rightWing.addCurve(
                to: CGPoint(x: w * 0.62, y: h * 0.66),
                control1: CGPoint(x: w * 0.82, y: h * 0.54),
                control2: CGPoint(x: w * 0.70, y: h * 0.62)
            )
            context.stroke(
                rightWing,
                with: .color(line),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
            )

            for index in 0..<6 {
                let inset = CGFloat(index) * w * 0.018
                var feather = Path()
                feather.move(to: CGPoint(x: w * 0.48 - inset * 0.20, y: h * 0.52 - inset * 0.12))
                feather.addQuadCurve(
                    to: CGPoint(x: w * (0.29 + CGFloat(index) * 0.035), y: h * (0.17 + CGFloat(index) * 0.052)),
                    control: CGPoint(x: w * (0.36 + CGFloat(index) * 0.025), y: h * (0.34 + CGFloat(index) * 0.018))
                )
                context.stroke(
                    feather,
                    with: .color(softLine),
                    style: StrokeStyle(lineWidth: 1.05, lineCap: .round)
                )
            }

            for index in 0..<5 {
                var feather = Path()
                feather.move(to: CGPoint(x: w * 0.61, y: h * (0.53 + CGFloat(index) * 0.018)))
                feather.addQuadCurve(
                    to: CGPoint(x: w * (0.84 - CGFloat(index) * 0.032), y: h * (0.37 + CGFloat(index) * 0.050)),
                    control: CGPoint(x: w * (0.72 + CGFloat(index) * 0.018), y: h * (0.48 + CGFloat(index) * 0.018))
                )
                context.stroke(
                    feather,
                    with: .color(softLine),
                    style: StrokeStyle(lineWidth: 1.05, lineCap: .round)
                )
            }

            for index in 0..<3 {
                var tail = Path()
                tail.move(to: CGPoint(x: w * (0.47 + CGFloat(index) * 0.035), y: h * 0.67))
                tail.addQuadCurve(
                    to: CGPoint(x: w * (0.23 + CGFloat(index) * 0.07), y: h * (0.92 - CGFloat(index) * 0.018)),
                    control: CGPoint(x: w * (0.37 + CGFloat(index) * 0.025), y: h * 0.82)
                )
                context.stroke(
                    tail,
                    with: .color(line),
                    style: StrokeStyle(lineWidth: 1.35, lineCap: .round)
                )
            }

            var chest = Path()
            chest.move(to: CGPoint(x: w * 0.55, y: h * 0.39))
            chest.addQuadCurve(
                to: CGPoint(x: w * 0.53, y: h * 0.64),
                control: CGPoint(x: w * 0.48, y: h * 0.53)
            )
            context.stroke(
                chest,
                with: .color(softLine),
                style: StrokeStyle(lineWidth: 1.1, lineCap: .round)
            )

            let eyeRect = CGRect(
                x: w * 0.605,
                y: h * 0.305,
                width: 3.2,
                height: 3.2
            )
            context.fill(Path(ellipseIn: eyeRect), with: .color(line))
        }
    }
}

private struct HumaSunGlyph: View {
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(Color.humaySolarGold)
                    .frame(width: 1.4, height: 7)
                    .offset(y: -14)
                    .rotationEffect(.degrees(Double(index) * 45))
            }

            Circle()
                .fill(Color.humaySolarGold.opacity(0.18))
                .frame(width: 22, height: 22)

            Circle()
                .stroke(Color.humaySolarGold, lineWidth: 1.5)
                .frame(width: 18, height: 18)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Profile Reveal Light") {
    ProfileRevealView(
        birthDate: OnboardingBirthDate(year: 1994, month: 3, day: 14),
        tradition: .western,
        onBack: {},
        onEnterHumay: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Profile Reveal Dark") {
    ProfileRevealView(
        birthDate: OnboardingBirthDate(year: 1994, month: 3, day: 14),
        tradition: .western,
        onBack: {},
        onEnterHumay: {}
    )
    .preferredColorScheme(.dark)
}
