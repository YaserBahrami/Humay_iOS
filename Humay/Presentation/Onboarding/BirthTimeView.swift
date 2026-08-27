import SwiftUI

struct BirthTimeView: View {
    @Bindable var draft: OnboardingDraftState
    let onBack: () -> Void
    let onContinue: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        OnboardingScreen { proxy in
            let compactHeight = proxy.size.height < 700
            let sectionSpacing = bounded(proxy.size.height * (compactHeight ? 0.012 : 0.016), minimum: 8, maximum: 16)
            if proxy.size.width > proxy.size.height {
                landscapeLayout(compactHeight: compactHeight, sectionSpacing: sectionSpacing)
            } else {
                portraitLayout(compactHeight: compactHeight, sectionSpacing: sectionSpacing)
            }
        }
        .scrollDisabled(!dynamicTypeSize.isAccessibilitySize)
        .accessibilityIdentifier("onboarding.birthTime.screen")
    }

    private var continueTitle: String {
        switch draft.timeKind {
        case .unknown: "Continue without time"
        default: "Continue"
        }
    }

    private func portraitLayout(compactHeight: Bool, sectionSpacing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            OnboardingChrome(stepLabel: "02 · Birth time", progressIndex: 2, onBack: onBack)
            OnboardingTitleBlock(title: "What time did you arrive?", supporting: "Rising signs are dramatic about minutes.", hero: false)
            timeKindPicker(compactHeight: compactHeight)
            timeDetailSurface(compactHeight: compactHeight)
            OnboardingPrimaryAction(title: continueTitle, identifier: "onboarding.birthTime.continue", action: onContinue)
                .padding(.top, HumaySpacing.medium)
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func landscapeLayout(compactHeight: Bool, sectionSpacing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            HStack(alignment: .top, spacing: compactHeight ? HumaySpacing.large : HumaySpacing.extraExtraLarge) {
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    OnboardingChrome(stepLabel: "02 · Birth time", progressIndex: 2, onBack: onBack)
                    OnboardingTitleBlock(title: "What time did you arrive?", supporting: "Rising signs are dramatic about minutes.", hero: false)
                    copyCard(compactHeight: compactHeight)
                }
                .frame(maxWidth: 420, alignment: .leading)
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    timeKindPicker(compactHeight: compactHeight)
                    timeDetailSurface(compactHeight: compactHeight)
                }
                .frame(maxWidth: 620, alignment: .leading)
            }
            .frame(maxWidth: 1120, alignment: .center)
            OnboardingPrimaryAction(title: continueTitle, identifier: "onboarding.birthTime.continue", action: onContinue)
                .padding(.top, HumaySpacing.medium)
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func timeKindPicker(compactHeight: Bool) -> some View {
        VStack(spacing: HumaySpacing.small) {
            ForEach(OnboardingTimeKind.allCases, id: \.self) { kind in
                Button {
                    draft.timeKind = kind
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(kindLabel(kind))
                                .font(HumayTypography.bodyEmphasized)
                                .foregroundStyle(Color.humayTextPrimary)
                            Text(kindDetail(kind))
                                .font(HumayTypography.caption)
                                .foregroundStyle(Color.humayTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Image(systemName: draft.timeKind == kind ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(draft.timeKind == kind ? Color.humayCoral : Color.humayTextSecondary)
                    }
                    .padding(compactHeight ? 10 : HumaySpacing.medium)
                    .background(draft.timeKind == kind ? Color.humayCoral.opacity(0.10) : Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.compact))
                    .overlay { RoundedRectangle(cornerRadius: HumayRadius.compact).strokeBorder(draft.timeKind == kind ? Color.humayCoral : Color.humayHairline) }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(kindLabel(kind))
                .accessibilityAddTraits(draft.timeKind == kind ? .isSelected : [])
                .accessibilityIdentifier("onboarding.birthTime.kind.\(kind.rawValue)")
            }
        }
    }

    private func timeDetailSurface(compactHeight: Bool) -> some View {
        Group {
            switch draft.timeKind {
            case .exact:
                HumaySurface(level: .standard, padding: compactHeight ? HumaySpacing.small : HumaySpacing.medium) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("Exact time")
                            .font(HumayTypography.utility)
                            .foregroundStyle(Color.humayTextSecondary)
                        DatePicker("Birth time", selection: $draft.timePickerDate, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: compactHeight ? 140 : 160)
                            .clipped()
                            .accessibilityLabel("Exact birth time")
                            .accessibilityIdentifier("onboarding.birthTime.exactPicker")
                        Text("Local civil time — e.g. 17:05.")
                            .font(HumayTypography.caption)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
            case .approximate:
                HumaySurface(level: .standard, padding: compactHeight ? HumaySpacing.small : HumaySpacing.medium) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("Approximate time")
                            .font(HumayTypography.utility)
                            .foregroundStyle(Color.humayTextSecondary)
                        DatePicker("Approximate time", selection: $draft.timePickerDate, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: compactHeight ? 140 : 160)
                            .clipped()
                            .accessibilityIdentifier("onboarding.birthTime.approxPicker")
                        Picker("Uncertainty", selection: $draft.approximateToleranceMinutes) {
                            Text("±15 min").tag(15)
                            Text("±30 min").tag(30)
                            Text("±1 hour").tag(60)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("onboarding.birthTime.tolerance")
                        Text("Humay will only show a Rising or Moon sign when the full time range supports it.")
                            .font(HumayTypography.caption)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            case .unknown:
                HumaySurface(padding: compactHeight ? HumaySpacing.medium : HumaySpacing.extraLarge) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("No birth time? That's fine.")
                            .font(HumayTypography.bodyEmphasized)
                        Text("We won't make one up. Sun stays where safely determinable; Moon shows only when stable across the day; Rising stays unavailable until you add a time.")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func kindLabel(_ kind: OnboardingTimeKind) -> String {
        switch kind {
        case .exact: "Exact — I know the time"
        case .approximate: "Approximate"
        case .unknown: "I don't know"
        }
    }

    private func kindDetail(_ kind: OnboardingTimeKind) -> String {
        switch kind {
        case .exact: "17:05 exactly"
        case .approximate: "Around then, give or take"
        case .unknown: "We'll leave it blank honestly"
        }
    }

    private func bounded(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }

    private func copyCard(compactHeight: Bool) -> some View {
        HumaySurface(padding: compactHeight ? HumaySpacing.medium : HumaySpacing.extraLarge) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text("No idea? We'll leave it blank instead of making things up.")
                    .font(HumayTypography.bodyEmphasized)
                    .accessibilityIdentifier("onboarding.birthTime.copy")
                Text("Rising needs minutes. Moon needs stability. Sun is usually forgiving.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
    }
}

#Preview("Birth Time Light") {
    BirthTimeView(draft: OnboardingDraftState(), onBack: {}, onContinue: {})
        .preferredColorScheme(.light)
}
#Preview("Birth Time Dark") {
    BirthTimeView(draft: OnboardingDraftState(), onBack: {}, onContinue: {})
        .preferredColorScheme(.dark)
}
