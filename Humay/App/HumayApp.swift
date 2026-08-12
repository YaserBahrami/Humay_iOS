import SwiftUI

@main
struct HumayApp: App {
    @State private var environment: AppEnvironment
    @State private var navigation: AppNavigationState

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
    }

    var body: some Scene {
        WindowGroup {
            RootView()
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
    }
}
