import SwiftUI

/// Root presenter for transient onboarding and the existing minimal main placeholder.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    @State private var onboardingDraft = OnboardingDraftState()

    var body: some View {
        @Bindable var navigation = navigation

        Group {
            switch navigation.root {
            case .onboarding:
                OnboardingFlowView(
                    route: $navigation.onboardingRoute,
                    draft: onboardingDraft,
                    onComplete: completeOnboarding
                )

            case .main:
                ZStack {
                    Color(uiColor: .systemBackground)
                        .ignoresSafeArea()

                    Text("Humay")
                        .font(.system(size: 44, weight: .regular, design: .serif))
                        .foregroundStyle(.primary)
                        .accessibilityIdentifier("humay.foundation.title")
                }
            }
        }
    }

    private func completeOnboarding() {
        guard let profile = onboardingDraft.makeProfile() else {
            navigation.onboardingRoute = .birthDate
            return
        }

        environment.completeOnboarding(
            profile: profile,
            tradition: onboardingDraft.selectedTradition
        )
        navigation.resetRoutes()
    }
}

#Preview("Foundation") {
    let environment = AppEnvironment()
    let navigation = AppNavigationState(environment: environment)

    RootView()
        .environment(environment)
        .environment(navigation)
}
