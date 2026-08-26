import SwiftUI

/// Root presenter for transient onboarding and the main shell.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    @State private var onboardingDraft = OnboardingDraftState()
    @State private var saveFailed = false

    private let skyInput: D3FeatureInput

    init(skyInput: D3FeatureInput = .productionUnavailable) {
        self.skyInput = skyInput
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
                MainAppView(skyInput: skyInput)
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
#Preview("Root · Demo") {
    let environment = AppEnvironment(
        store: UnavailableUserStateStore(),
        initialRestorationState: .ready
    )
    let navigation = AppNavigationState(environment: environment)
    let inMemoryRepo = InMemoryForecastRepository()
    let store = ForecastStore(
        repository: inMemoryRepo,
        coordinator: ForecastGenerationCoordinator(
            provider: DeterministicContentProvider(),
            repository: inMemoryRepo
        )
    )

    return RootView(skyInput: DevelopmentD3Sample.makeInput())
        .environment(environment)
        .environment(navigation)
        .environment(store)
}
#endif
