import SwiftUI

@main
struct HumayApp: App {
    @State private var environment: AppEnvironment
    @State private var navigation: AppNavigationState
    @State private var forecastStore: ForecastStore
    private let skyInput: D3FeatureInput

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

        // Personalized intelligence composition. The deterministic provider is
        // always available; the remote AI boundary activates only when a real
        // endpoint + transport are configured (§5, §36).
        let forecastRepository: any ForecastRepository
        do {
            forecastRepository = try FileForecastRepository()
        } catch {
            ForecastLog.repositoryIssue("durable forecast storage unavailable; using in-memory")
            forecastRepository = InMemoryForecastRepository()
        }
        let coordinator = ForecastGenerationCoordinator(
            provider: DeterministicContentProvider(),
            repository: forecastRepository
        )
        _forecastStore = State(initialValue: ForecastStore(
            repository: forecastRepository,
            coordinator: coordinator
        ))

#if DEBUG
        skyInput = DevelopmentD3Sample.makeInput()
#else
        skyInput = .productionUnavailable
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(skyInput: skyInput)
                .environment(environment)
                .environment(navigation)
                .environment(forecastStore)
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
        if ProcessInfo.processInfo.arguments.contains("-HumayDemo"),
           !environment.hasCompletedOnboarding {
            try? await environment.completeOnboarding(
                profile: DevelopmentSample.profile,
                tradition: .western
            )
            for person in DevelopmentSample.people {
                try? await environment.addPerson(person)
            }
        }
#endif
    }
}

#if DEBUG
/// Development-owned sample composition. Excluded from Release compilation.
enum DevelopmentSample {
    static let profile = UserProfile(
        id: UUID(uuidString: "77777777-7777-4777-8777-777777777777")!,
        displayName: "Yaser",
        birth: BirthDetails(year: 1993, month: 8, day: 7)
    )

    static let salma = ConnectionPerson(
        id: UUID(uuidString: "22222222-2222-4222-8222-222222222222")!,
        name: "Salma",
        relationshipKind: .crush,
        birth: BirthDetails(year: 1995, month: 6, day: 3)
    )

    static let mahtab = ConnectionPerson(
        id: UUID(uuidString: "33333333-3333-4333-8333-333333333333")!,
        name: "Mahtab",
        relationshipKind: .friend,
        birth: BirthDetails(year: 1994, month: 11, day: 21)
    )

    static let people = [salma, mahtab]
}
#endif
