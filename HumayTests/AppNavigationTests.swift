import Foundation
import Testing
@testable import Humay

@Suite("Application navigation boundary")
@MainActor
struct AppNavigationTests {
    @Test("Fresh app state resolves to onboarding")
    func freshAppStateResolvesToOnboarding() async {
        let environment = AppEnvironment(store: InMemoryUserStateStore())
        let navigation = AppNavigationState(environment: environment)

        #expect(navigation.root == .restoring)
        await environment.restore()

        #expect(AppRootState.resolve(from: environment) == .onboarding)
        #expect(navigation.root == .onboarding)
        #expect(navigation.onboardingRoute == .welcome)
    }

    @Test("Completed profile and settings resolve to main application")
    func completedProfileAndSettingsResolveToMain() async throws {
        let environment = try await completedEnvironment()
        let navigation = AppNavigationState(environment: environment)

        #expect(environment.hasCompletedOnboarding)
        #expect(navigation.root == .main)
        #expect(navigation.mainDestination == .today)
    }

    @Test("Onboarding route sequence is canonical")
    func onboardingRouteSequenceIsCanonical() {
        #expect(OnboardingRoute.canonicalSequence == [
            .welcome,
            .birthDate,
            .tradition,
            .profileReveal
        ])
        #expect(OnboardingRoute.allCases == OnboardingRoute.canonicalSequence)
    }

    @Test("Main destination order is canonical")
    func mainDestinationOrderIsCanonical() {
        #expect(MainDestination.canonicalOrder == [
            .today,
            .circle,
            .sky,
            .chart,
            .ask
        ])
        #expect(MainDestination.allCases == MainDestination.canonicalOrder)
    }

    @Test("Feature ownership stays under its primary destination")
    func featureOwnershipStaysUnderPrimaryDestination() {
        #expect(TodayRoute.dailyHoroscope.owningDestination == .today)
        #expect(CircleRoute.compatibility.owningDestination == .circle)
        #expect(SkyRoute.calendar.owningDestination == .sky)
        #expect(AppAuxiliaryRoute.allCases == [.profileSettings])
        #expect(MainDestination.allCases.count == 5)
    }

    @Test("Development reset returns root resolution to onboarding")
    func developmentResetReturnsRootResolutionToOnboarding() async throws {
        let environment = try await completedEnvironment()
        let navigation = AppNavigationState(environment: environment)
        #expect(navigation.root == .main)

        try await environment.resetForDevelopment()

        #expect(!environment.hasCompletedOnboarding)
        #expect(navigation.root == .onboarding)
    }

    private func completedEnvironment() async throws -> AppEnvironment {
        let environment = AppEnvironment(store: InMemoryUserStateStore())
        await environment.restore()
        let profile = UserProfile(
            displayName: "Humay User",
            birth: BirthDetails(year: 1994, month: 3, day: 14)
        )
        try await environment.completeOnboarding(profile: profile, tradition: .western)
        return environment
    }
}
