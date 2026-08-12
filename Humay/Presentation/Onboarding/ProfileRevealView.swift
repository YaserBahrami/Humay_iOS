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
            ProfileMedallion()
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
        colorScheme == .light ? .humayRaisedSurface : .humayRaisedSurface
    }
}

/// Decorative human-centered medallion from the approved Profile Reveal board.
/// It represents “you” without asserting any calculated astrological fact.
private struct ProfileMedallion: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Ellipse()
                .stroke(Color.humayLavender.opacity(colorScheme == .light ? 0.52 : 0.62), lineWidth: 1.4)
                .frame(width: 242, height: 156)
                .rotationEffect(.degrees(-6))

            Ellipse()
                .stroke(Color.humayCoral.opacity(colorScheme == .light ? 0.48 : 0.58), lineWidth: 1.4)
                .frame(width: 158, height: 232)
                .rotationEffect(.degrees(24))

            Circle()
                .fill(Color.humaySurface)
                .frame(width: 132, height: 132)
                .overlay {
                    Circle()
                        .stroke(Color.humayHairline, lineWidth: 1)
                }

            Circle()
                .fill(faceColor)
                .frame(width: 92, height: 92)

            ProfileHairShape()
                .fill(hairColor)
                .frame(width: 94, height: 62)
                .offset(y: -22)

            HStack(spacing: 24) {
                Circle()
                    .fill(faceInk)
                    .frame(width: 5, height: 5)
                Circle()
                    .fill(faceInk)
                    .frame(width: 5, height: 5)
            }
            .offset(y: 10)

            Canvas { context, size in
                var smile = Path()
                smile.move(to: CGPoint(x: 2, y: 2))
                smile.addQuadCurve(
                    to: CGPoint(x: size.width - 2, y: 2),
                    control: CGPoint(x: size.width / 2, y: size.height)
                )
                context.stroke(
                    smile,
                    with: .color(faceInk),
                    style: StrokeStyle(lineWidth: 1.7, lineCap: .round)
                )
            }
            .frame(width: 22, height: 10)
            .offset(y: 26)

            Circle()
                .fill(Color.humaySolarGold)
                .frame(width: 8, height: 8)
                .offset(x: 104, y: 16)

            Circle()
                .fill(Color.humayCelestialBlue)
                .frame(width: 7, height: 7)
                .offset(x: -88, y: -57)

            Image(systemName: "sparkle")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.humayCoral)
                .offset(x: 98, y: -78)

            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.humayLavender)
                .offset(x: -104, y: 62)
        }
        .frame(width: 270, height: 250)
    }

    private var faceColor: Color {
        Color(red: 0.957, green: 0.843, blue: 0.741)
    }

    private var hairColor: Color {
        Color(red: 0.545, green: 0.365, blue: 0.282)
    }

    private var faceInk: Color {
        colorScheme == .light ? .humayTextPrimary : .humayGround
    }
}

private struct ProfileHairShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY * 0.72))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.08),
            control1: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY + rect.height * 0.15),
            control2: CGPoint(x: rect.minX + rect.width * 0.36, y: rect.minY)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.maxY * 0.75),
            control1: CGPoint(x: rect.maxX - rect.width * 0.24, y: rect.minY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.04, y: rect.minY + rect.height * 0.30)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX + rect.width * 0.08, y: rect.minY + rect.height * 0.34),
            control1: CGPoint(x: rect.maxX - rect.width * 0.22, y: rect.maxY * 0.57),
            control2: CGPoint(x: rect.maxX - rect.width * 0.34, y: rect.minY + rect.height * 0.46)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY * 0.72),
            control1: CGPoint(x: rect.midX - rect.width * 0.15, y: rect.minY + rect.height * 0.52),
            control2: CGPoint(x: rect.minX + rect.width * 0.28, y: rect.maxY * 0.64)
        )
        path.closeSubpath()
        return path
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
