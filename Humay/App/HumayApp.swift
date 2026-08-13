import SwiftUI

@main
struct HumayApp: App {
    @State private var environment: AppEnvironment
    @State private var navigation: AppNavigationState
    private let d2FeatureInput: D2FeatureInput
    private let d3FeatureInput: D3FeatureInput

    init() {
        let store: any UserStateStore
        do {
            store = try FileUserStateStore()
        } catch {
            HumayLog.application(.durableStorageUnavailable)
            store = UnavailableUserStateStore()
        }

        let environment = AppEnvironment(store: store)
        _environment = State(initialValue: environment)
        _navigation = State(initialValue: AppNavigationState(environment: environment))
#if DEBUG
        d2FeatureInput = AppFeatureComposition.makeD2Input()
        d3FeatureInput = AppFeatureComposition.makeD3Input()
#else
        d2FeatureInput = .productionUnavailable
        d3FeatureInput = .productionUnavailable
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                d2FeatureInput: d2FeatureInput,
                d3FeatureInput: d3FeatureInput
            )
                .environment(environment)
                .environment(navigation)
                .task {
                    await bootstrap(environment: environment)
                }
        }
    }

    @MainActor
    private func bootstrap(environment: AppEnvironment) async {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-HumayResetPersistence") {
            do {
                try await environment.resetForDevelopment()
            } catch {
                return
            }
        }
#endif

        await environment.restore()

#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-HumayD2Demo"),
           !environment.hasCompletedOnboarding {
            do {
                try await environment.completeOnboarding(
                    profile: DevelopmentD2Sample.profile,
                    tradition: .western
                )
            } catch {
                return
            }
        }
#endif
    }
}
