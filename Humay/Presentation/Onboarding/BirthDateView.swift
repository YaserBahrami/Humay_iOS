import SwiftUI

struct BirthDateView: View {
    @Bindable var draft: OnboardingDraftState

    let onBack: () -> Void
    let onContinue: () -> Void

    @State private var validationMessage: String?

    var body: some View {
        OnboardingScreen { proxy in
            if proxy.size.width > proxy.size.height {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .onChange(of: draft.pickerDate) { _, _ in
            validationMessage = nil
        }
    }

    private var portraitLayout: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            OnboardingChrome(
                stepLabel: "01 · Birth date",
                progressIndex: 1,
                onBack: onBack
            )

            OnboardingTitleBlock(
                title: "When were you born?",
                supporting: "Your date is enough to start.",
                hero: false
            )

            datePickerSurface

            explanatoryContent

            primaryAction
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var landscapeLayout: some View {
        HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                OnboardingChrome(
                    stepLabel: "01 · Birth date",
                    progressIndex: 1,
                    onBack: onBack
                )

                OnboardingTitleBlock(
                    title: "When were you born?",
                    supporting: "Your date is enough to start.",
                    hero: false
                )

                BirthDatePrecisionCard()
            }
            .frame(maxWidth: 420, alignment: .leading)

            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                datePickerSurface
                explanatoryContent
                primaryAction
            }
            .frame(maxWidth: 620, alignment: .leading)
        }
        .frame(maxWidth: 1120, alignment: .center)
    }

    private var datePickerSurface: some View {
        HumaySurface(level: .standard, padding: HumaySpacing.medium) {
            VStack(spacing: HumaySpacing.small) {
                DatePicker(
                    "Birth date",
                    selection: $draft.pickerDate,
                    in: draft.earliestValidDate...draft.latestValidDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(minHeight: 220)
                .accessibilityLabel("Birth date")
                .accessibilityValue(draft.pickerDateFormatted())
                .accessibilityHint("Choose your calendar birth date. Birth time and place are not collected here.")
                .accessibilityIdentifier("onboarding.birthDate.picker")

                BirthDateMotif()
                    .frame(height: 84)
            }
        }
    }

    private var explanatoryContent: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            Text("This is all the general reading needs — your Sun sign, your Chinese year and sign-to-sign compatibility all follow from the date alone.")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .overlay(Color.humayHairline)

            Text("Birth time and place are not required now. You can add them later in Profile, and they unlock the parts of a chart that genuinely depend on them.")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let validationMessage {
                Text(validationMessage)
                    .font(HumayTypography.supporting)
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
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private struct BirthDatePrecisionCard: View {
        var body: some View {
            HumaySurface {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("Date first.\nPrecision later.")
                        .font(HumayTypography.editorialTitle)
                        .foregroundStyle(Color.humayTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Time and place stay optional.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
        }
    }
}

private struct BirthDateMotif: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: HumaySpacing.large) {
            Image(systemName: "calendar")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(colorScheme == .light ? Color.humayTextPrimary : Color.humaySolarGold)

            Image(systemName: colorScheme == .light ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Color.humaySolarGold)

            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.humayLavender)
        }
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
