import Foundation

/// The only file in the application that names concrete implementations.
///
/// When real services arrive, this file changes and nothing else does.
extension AppEnvironment {
    /// Wipes stored state at launch. UI tests pass this so an onboarding run starts
    /// from a known state without reinstalling the application between cases.
    static let resetLaunchArgument = "-humay-reset-state"

    static func live() -> AppEnvironment {
        let container = HumayModelContainer.makeWithFallback()
        let latency = MockLatency.realistic

        let environment = AppEnvironment(
            contentMode: .mock,
            profileRepository: SwiftDataUserProfileRepository(container: container),
            settingsRepository: SwiftDataAppSettingsRepository(container: container),
            personRepository: SwiftDataCirclePersonRepository(container: container),
            askRepository: SwiftDataAskConversationRepository(container: container),
            horoscopeService: MockHoroscopeService(latency: latency),
            chartService: MockChartCalculationService(latency: latency),
            compatibilityService: MockCompatibilityService(latency: latency),
            skyService: MockSkyService(latency: latency),
            assistantService: MockAstrologyAssistantService(latency: latency),
            glossaryService: MockGlossaryService(latency: latency)
        )

        if ProcessInfo.processInfo.arguments.contains(resetLaunchArgument) {
            environment.deleteAllData()
        }
        return environment
    }
}

#if DEBUG
extension AppEnvironment {
    /// For previews and fast tests.
    ///
    /// Backed by in-memory repositories with no latency, so previews never touch
    /// SwiftData and never wait. A preview that crashes is then a real signal about the
    /// view rather than about the store.
    static func preview(
        profile: UserProfile? = .previewProfile,
        settings: AppSettings = .previewCompleted,
        people: [CirclePerson] = SeedCircleFixtures.people
    ) -> AppEnvironment {
        AppEnvironment(
            contentMode: .mock,
            profileRepository: InMemoryUserProfileRepository(profile: profile),
            settingsRepository: InMemoryAppSettingsRepository(settings: settings),
            personRepository: InMemoryCirclePersonRepository(people: people),
            askRepository: InMemoryAskConversationRepository(),
            horoscopeService: MockHoroscopeService(latency: .instant),
            chartService: MockChartCalculationService(latency: .instant),
            compatibilityService: MockCompatibilityService(latency: .instant),
            skyService: MockSkyService(latency: .instant),
            assistantService: MockAstrologyAssistantService(latency: .instant),
            glossaryService: MockGlossaryService(latency: .instant)
        )
    }
}

extension UserProfile {
    static let previewProfile = UserProfile(
        displayName: "Jordan",
        birth: BirthDetails(
            year: 1994,
            month: 3,
            day: 14,
            time: .exact(minutesFromMidnight: 7 * 60 + 42),
            place: .known(
                name: "Lisbon, Portugal",
                latitude: 38.7167,
                longitude: -9.1333,
                timeZoneIdentifier: "Europe/Lisbon"
            )
        )
    )

    /// The same person, without the birth time — for exercising the withheld states.
    static let previewProfileDateOnly = UserProfile(
        displayName: "Jordan",
        birth: BirthDetails(year: 1994, month: 3, day: 14)
    )
}

extension AppSettings {
    static let previewCompleted = AppSettings(
        leadingTradition: .western,
        tone: .normal,
        onboardingCompletedAt: .now,
        notifications: .default
    )
}
#endif
