import SwiftUI

/// Humay — application entry point.
///
/// The composition root (`AppEnvironment`) is built once here and injected into the
/// view hierarchy. No view constructs a service or a repository for itself.
@main
struct HumayApp: App {
    @State private var environment: AppEnvironment

    init() {
        HumayFontRegistrar.verifyAvailability()
        // Before any bar exists: UIAppearance only affects views created after it
        // is set, so doing this in onAppear leaves the first bar unstyled.
        HumayNavigationAppearance.apply()
        _environment = State(initialValue: AppEnvironment.live())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
        }
    }
}
