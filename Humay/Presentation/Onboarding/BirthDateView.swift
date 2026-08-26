import SwiftUI

struct BirthDateView: View {
    @Bindable var draft: OnboardingDraftState

    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var validationMessage: String?
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
        .onChange(of: draft.pickerDate) { _, _ in
            validationMessage = nil
        }
    }

    private func portraitLayout(
        compactHeight: Bool,
        sectionSpacing: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            OnboardingChrome(
                stepLabel: "01 · Birth date",
                progressIndex: 1,
                onBack: onBack
            )

            OnboardingTitleBlock(
                title: "When did you arrive?",
                supporting: "The universe allegedly had its reasons.",
                hero: false
            )

            datePickerSurface(compactHeight: compactHeight)

            explanatoryContent(compactHeight: compactHeight)
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func landscapeLayout(
        compactHeight: Bool,
        sectionSpacing: CGFloat
    ) -> some View {
        HStack(alignment: .top, spacing: compactHeight ? HumaySpacing.large : HumaySpacing.extraExtraLarge) {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                OnboardingChrome(
                    stepLabel: "01 · Birth date",
                    progressIndex: 1,
                    onBack: onBack
                )

                OnboardingTitleBlock(
                    title: "When did you arrive?",
                    supporting: "The universe allegedly had its reasons.",
                    hero: false
                )

                BirthDatePrecisionCard(compactHeight: compactHeight)
            }
            .frame(maxWidth: 420, alignment: .leading)

            VStack(alignment: .leading, spacing: sectionSpacing) {
                datePickerSurface(compactHeight: compactHeight)
                explanatoryContent(compactHeight: compactHeight)
            }
            .frame(maxWidth: 620, alignment: .leading)
        }
        .frame(maxWidth: 1120, alignment: .center)
    }

    private func datePickerSurface(compactHeight: Bool) -> some View {
        HumaySurface(
            level: .standard,
            padding: compactHeight ? HumaySpacing.small : HumaySpacing.medium
        ) {
            VStack(spacing: compactHeight ? 2 : HumaySpacing.small) {
                DatePicker(
                    "Birth date",
                    selection: $draft.pickerDate,
                    in: draft.earliestValidDate...draft.latestValidDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: compactHeight ? 170 : 205)
                .clipped()
                .accessibilityLabel("Birth date")
                .accessibilityValue(draft.pickerDateFormatted())
                .accessibilityHint("Choose your calendar birth date. Birth time and place are not collected here.")
                .accessibilityIdentifier("onboarding.birthDate.picker")

                BirthDateMotif(compactHeight: compactHeight)
                    .frame(height: compactHeight ? 54 : 86)
            }
        }
    }

    private func explanatoryContent(compactHeight: Bool) -> some View {
        VStack(alignment: .leading, spacing: compactHeight ? 7 : HumaySpacing.medium) {
            Text("Your date unlocks your Sun sign, your archetype and sign-to-sign chemistry. That's plenty to start.")
                .font(compactHeight ? HumayTypography.caption : HumayTypography.supporting)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .overlay(Color.humayHairline)

            Text("Birth time and place stay optional. Humay never fakes them — features that need them will ask honestly.")
                .font(compactHeight ? HumayTypography.caption : HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let validationMessage {
                Text(validationMessage)
                    .font(HumayTypography.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var primaryAction: some View {
        OnboardingPrimaryAction(
            title: "Continue",
            identifier: "onboarding.birthDate.continue"
        ) {
            if draft.confirmBirthDate() {
                onContinue()
            } else {
                validationMessage = "Choose a date between January 1, 1900 and today."
            }
        }
    }

    private func bounded(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }

    private struct BirthDatePrecisionCard: View {
        let compactHeight: Bool

        var body: some View {
            HumaySurface(padding: compactHeight ? HumaySpacing.medium : HumaySpacing.extraLarge) {
                VStack(alignment: .leading, spacing: compactHeight ? 4 : HumaySpacing.small) {
                    Text("Date first.\nPrecision later.")
                        .font(compactHeight ? HumayTypography.onboardingCardTitle : HumayTypography.editorialTitle)
                        .foregroundStyle(Color.humayTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Time and place stay optional.")
                        .font(compactHeight ? HumayTypography.caption : HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
        }
    }
}

private struct BirthDateMotif: View {
    let compactHeight: Bool

    var body: some View {
        HumayIllustration(name: "IllustrationCalendarCelestial")
            .frame(
                width: compactHeight ? 132 : 180,
                height: compactHeight ? 58 : 88
            )
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

#Preview("Birth Date Light") {
    BirthDateView(
        draft: OnboardingDraftState(),
        onBack: {},
        onContinue: {}
    )
    .preferredColorScheme(.light)
}

#Preview("Birth Date Dark") {
    BirthDateView(
        draft: OnboardingDraftState(),
        onBack: {},
        onContinue: {}
    )
    .preferredColorScheme(.dark)
}
