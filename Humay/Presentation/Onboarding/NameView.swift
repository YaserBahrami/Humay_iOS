import SwiftUI

/// Onboarding name beat. Light touch: optional-feeling but genuinely useful for
/// personalization. Humay keeps it playful without blocking progress.
struct NameView: View {
    @Bindable var draft: OnboardingDraftState

    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingScreen { proxy in
            let compactHeight = proxy.size.height < 700

            VStack(alignment: .leading, spacing: compactHeight ? HumaySpacing.large : HumaySpacing.extraLarge) {
                OnboardingChrome(
                    stepLabel: "04 · Your name",
                    progressIndex: 4,
                    onBack: onBack
                )

                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    Text("What should Humay call you?")
                        .font(HumayTypography.heroTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text("Your roast needs a target.")
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                }

                HumaySurface(padding: HumaySpacing.large) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        TextField("Name", text: $draft.displayName)
                            .textContentType(.name)
                            .font(HumayTypography.cardTitle)
                            .submitLabel(.continue)
                            .onSubmit(onContinue)
                            .accessibilityIdentifier("onboarding.name.field")

                        Text("Optional. \"Anonymous Menace\" also works.")
                            .font(HumayTypography.caption)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
                .frame(maxWidth: 560)

                if proxy.size.width > proxy.size.height || proxy.size.height > 700 {
                    Text("Humay uses your name to make things feel personal. Everything stays on this device.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            OnboardingPrimaryAction(
                title: "Continue",
                identifier: "onboarding.name.continue",
                action: onContinue
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, HumaySpacing.large)
            .padding(.vertical, HumaySpacing.small)
            .background(Color.humayGround)
        }
    }
}

#Preview("Name Light") {
    NameView(draft: OnboardingDraftState(), onBack: {}, onContinue: {})
        .preferredColorScheme(.light)
}

#Preview("Name Dark") {
    NameView(draft: OnboardingDraftState(), onBack: {}, onContinue: {})
        .preferredColorScheme(.dark)
}
