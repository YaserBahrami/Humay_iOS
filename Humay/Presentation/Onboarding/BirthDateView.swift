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
                title: "When were you born?",
                supporting: "Your date is enough to start.",
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
                    title: "When were you born?",
                    supporting: "Your date is enough to start.",
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
                    .frame(height: compactHeight ? 52 : 82)
            }
        }
    }

    private func explanatoryContent(compactHeight: Bool) -> some View {
        VStack(alignment: .leading, spacing: compactHeight ? 7 : HumaySpacing.medium) {
            Text("This is all the general reading needs — your Sun sign, your Chinese year and sign-to-sign compatibility all follow from the date alone.")
                .font(compactHeight ? .caption : HumayTypography.supporting)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .overlay(Color.humayHairline)

            Text("Birth time and place are not required now. You can add them later in Profile, and they unlock the parts of a chart that genuinely depend on them.")
                .font(compactHeight ? .caption : HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption)
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
                        .font(compactHeight ? .caption : HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
        }
    }
}

private struct BirthDateMotif: View {
    let compactHeight: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            CalendarCompanion()
                .offset(x: -28, y: 7)

            Image(systemName: colorScheme == .light ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 29, weight: .regular))
                .foregroundStyle(Color.humaySolarGold)
                .offset(x: 47, y: -18)

            Image(systemName: "sparkle")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.humayLavender)
                .offset(x: 78, y: 31)

            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.humayCoral)
                .offset(x: -82, y: 5)

            Image(systemName: "sparkle")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color.humaySolarGold)
                .offset(x: 92, y: -39)
        }
        .scaleEffect(compactHeight ? 0.68 : 0.9)
        .frame(maxWidth: .infinity, minHeight: compactHeight ? 52 : 82)
        .accessibilityHidden(true)
    }

    private struct CalendarCompanion: View {
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.humaySurface)
                    .frame(width: 62, height: 56)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(calendarStroke, lineWidth: 2)
                    }

                Rectangle()
                    .fill(calendarStroke)
                    .frame(width: 60, height: 2)
                    .offset(y: -14)

                HStack(spacing: 6) {
                    ForEach(0..<6, id: \.self) { _ in
                        Capsule()
                            .fill(calendarStroke)
                            .frame(width: 2, height: 11)
                    }
                }
                .offset(y: -32)

                HStack(spacing: 17) {
                    Circle()
                        .fill(faceInk)
                        .frame(width: 4, height: 4)
                    Circle()
                        .fill(faceInk)
                        .frame(width: 4, height: 4)
                }
                .offset(y: 5)

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
                        style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
                    )
                }
                .frame(width: 20, height: 10)
                .offset(y: 16)

                Canvas { context, size in
                    var feet = Path()
                    feet.move(to: CGPoint(x: 15, y: 2))
                    feet.addLine(to: CGPoint(x: 11, y: 11))
                    feet.addLine(to: CGPoint(x: 22, y: 6))
                    feet.move(to: CGPoint(x: size.width - 15, y: 2))
                    feet.addLine(to: CGPoint(x: size.width - 11, y: 11))
                    feet.addLine(to: CGPoint(x: size.width - 22, y: 6))
                    context.stroke(
                        feet,
                        with: .color(calendarStroke),
                        style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)
                    )
                }
                .frame(width: 62, height: 13)
                .offset(y: 34)
            }
            .frame(width: 72, height: 78)
        }

        private var calendarStroke: Color {
            colorScheme == .light ? .humayTextPrimary : .humaySolarGold
        }

        private var faceInk: Color {
            .humayTextPrimary
        }
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
