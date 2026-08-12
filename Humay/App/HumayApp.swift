import SwiftUI

@main
struct HumayApp: App {
    @State private var environment: AppEnvironment
    @State private var navigation: AppNavigationState

    init() {
        let environment = AppEnvironment()
        _environment = State(initialValue: environment)
        _navigation = State(initialValue: AppNavigationState(environment: environment))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(navigation)
        }
    }
}
