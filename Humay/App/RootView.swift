import SwiftUI

/// Root presenter for transient onboarding and the approved post-onboarding shell.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    @State private var onboardingDraft = OnboardingDraftState()
    @State private var saveFailed = false

    private let d2FeatureInput: D2FeatureInput
    private let d3FeatureInput: D3FeatureInput
    private let d4FeatureInput: D4FeatureInput

    init(
        d2FeatureInput: D2FeatureInput = .productionUnavailable,
        d3FeatureInput: D3FeatureInput = .productionUnavailable,
        d4FeatureInput: D4FeatureInput = .productionUnavailable
    ) {
        self.d2FeatureInput = d2FeatureInput
        self.d3FeatureInput = d3FeatureInput
        self.d4FeatureInput = d4FeatureInput
    }

    var body: some View {
        @Bindable var navigation = navigation

        Group {
            switch navigation.root {
            case .restoring:
                restorationSurface

            case .persistenceFailure:
                restorationFailureSurface

            case .onboarding:
                OnboardingFlowView(
                    route: $navigation.onboardingRoute,
                    draft: onboardingDraft,
                    onComplete: completeOnboarding
                )

            case .main:
                MainAppView(
                    d2FeatureInput: d2FeatureInput,
                    d3FeatureInput: d3FeatureInput,
                    d4FeatureInput: d4FeatureInput
                )
            }
        }
        .alert("Couldn't save your profile", isPresented: $saveFailed) {
            Button("Retry") {
                saveFailed = false
                completeOnboarding()
            }
            Button("Cancel", role: .cancel) {
                saveFailed = false
            }
        } message: {
            Text("Your entered details are still here. Retry to finish setup.")
        }
    }

    private func completeOnboarding() {
        guard let profile = onboardingDraft.makeProfile() else {
            navigation.onboardingRoute = .birthDate
            return
        }

        let tradition = onboardingDraft.selectedTradition
        Task { @MainActor in
            do {
                try await environment.completeOnboarding(
                    profile: profile,
                    tradition: tradition
                )
                saveFailed = false
                navigation.resetRoutes()
            } catch {
                saveFailed = true
            }
        }
    }

    private var restorationSurface: some View {
        Color(uiColor: .systemBackground)
            .ignoresSafeArea()
    }

    private var restorationFailureSurface: some View {
        restorationSurface
            .alert("Couldn't restore your profile", isPresented: .constant(true)) {
                Button("Retry") {
                    Task { @MainActor in
                        await environment.restore()
                    }
                }
            } message: {
                Text("Your saved profile was not changed. Retry to continue.")
            }
    }
}

#if DEBUG
#Preview("D2 Foundation") {
    let environment = AppEnvironment(
        store: UnavailableUserStateStore(),
        initialRestorationState: .ready
    )
    let navigation = AppNavigationState(environment: environment)

    RootView(
        d2FeatureInput: DevelopmentD2Sample.makeInput(arguments: []),
        d3FeatureInput: DevelopmentD3Sample.makeInput(arguments: []),
        d4FeatureInput: DevelopmentD4Sample.makeInput(arguments: [])
    )
        .environment(environment)
        .environment(navigation)
}
#endif
