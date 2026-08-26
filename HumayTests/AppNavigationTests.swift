import Testing
@testable import Humay

@Suite("Application navigation")
@MainActor
struct AppNavigationTests {
    @Test("Fresh app state resolves to onboarding")
    func freshAppStateResolvesToOnboarding() async {
        let environment = AppEnvironment(store: InMemoryUserStateStore())
        await environment.restore()
        let navigation = AppNavigationState(environment: environment)

        #expect(navigation.root == .onboarding)
    }

    @Test("Completed profile and settings resolve to main application")
    func completedStateResolvesToMain() async throws {
        let store = InMemoryUserStateStore()
        let firstEnvironment = AppEnvironment(store: store)
        await firstEnvironment.restore()

        let profile = UserProfile(
            displayName: "Yaser",
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )
        try await firstEnvironment.completeOnboarding(profile: profile, tradition: .western)

        let navigation = AppNavigationState(environment: firstEnvironment)

        #expect(navigation.root == .main)
    }

    @Test("Onboarding route sequence is canonical")
    func onboardingRouteSequenceIsCanonical() {
        #expect(OnboardingRoute.canonicalSequence == [
            .welcome, .birthDate, .name, .tradition, .profileReveal
        ])
        #expect(OnboardingRoute.welcome.next == .birthDate)
        #expect(OnboardingRoute.name.previous == .birthDate)
        #expect(OnboardingRoute.tradition.next == .profileReveal)
        #expect(OnboardingRoute.profileReveal.next == nil)
    }

    @Test("Main destination order is canonical")
    func mainDestinationOrderIsCanonical() {
        #expect(MainDestination.canonicalOrder == [
            .today,
            .chemistry,
            .you,
            .sky
        ])
        #expect(MainDestination.allCases == MainDestination.canonicalOrder)
    }

    @Test("Development reset returns root resolution to onboarding")
    func developmentResetReturnsToOnboarding() async throws {
        let store = InMemoryUserStateStore()
        let environment = AppEnvironment(store: store)
        await environment.restore()
        let profile = UserProfile(
            displayName: "Yaser",
            birth: BirthDetails(year: 1993, month: 8, day: 7)
        )
        try await environment.completeOnboarding(profile: profile, tradition: .western)

        try await environment.resetForDevelopment()
        let navigation = AppNavigationState(environment: environment)

        #expect(navigation.root == .onboarding)
        #expect(environment.people.isEmpty)
    }
}
