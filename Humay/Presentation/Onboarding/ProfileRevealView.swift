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
            Image("ProfileRevealConstellationPath")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
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
