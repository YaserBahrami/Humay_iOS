import SwiftUI

@main
struct HumayApp: App {
    @State private var environment: AppEnvironment
    @State private var navigation: AppNavigationState
    private let d2FeatureInput: D2FeatureInput
    private let d3FeatureInput: D3FeatureInput
    private let d4FeatureInput: D4FeatureInput
    private let d5FeatureInput: D5FeatureInput

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
        d4FeatureInput = AppFeatureComposition.makeD4Input()
        d5FeatureInput = AppFeatureComposition.makeD5Input()
#else
        d2FeatureInput = .productionUnavailable
        d3FeatureInput = .productionUnavailable
        d4FeatureInput = .productionUnavailable
        d5FeatureInput = .productionUnavailable
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                d2FeatureInput: d2FeatureInput,
                d3FeatureInput: d3FeatureInput,
                d4FeatureInput: d4FeatureInput,
                d5FeatureInput: d5FeatureInput
            )
                .environment(environment)
                .environment(navigation)
                .preferredColorScheme(developmentColorScheme)
                .task {
                    await bootstrap(environment: environment)
                }
        }
    }

    private var developmentColorScheme: ColorScheme? {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        guard let keyIndex = arguments.firstIndex(of: "-HumayInterfaceStyle"),
              arguments.indices.contains(keyIndex + 1) else {
            return nil
        }

        switch arguments[keyIndex + 1].lowercased() {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
#else
        nil
#endif
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

        if ProcessInfo.processInfo.arguments.contains("-HumayD4Demo") {
            navigation.mainDestination = .chart
        }

        if ProcessInfo.processInfo.arguments.contains("-HumayWesternChartDemo")
            || ProcessInfo.processInfo.arguments.contains("-HumayPlacementDetailDemo") {
            navigation.mainDestination = .chart
        }

        if ProcessInfo.processInfo.arguments.contains("-HumayExploreDemo") {
            navigation.mainDestination = .explore
        }

        if ProcessInfo.processInfo.arguments.contains("-HumayConnectionsDemo") {
            navigation.mainDestination = .connections
        }

        if ProcessInfo.processInfo.arguments.contains("-HumayCompatibilityDemo") {
            navigation.mainDestination = .connections
        }

        if ProcessInfo.processInfo.arguments.contains("-HumayYouDemo") {
            navigation.mainDestination = .you
        }

        if d5FeatureInput.source.isDevelopmentSample,
           d5FeatureInput.state != .empty {
            navigation.mainDestination = .explore
        }
#endif
    }
}
