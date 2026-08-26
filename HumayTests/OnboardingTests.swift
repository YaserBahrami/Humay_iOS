import Foundation
import Testing
@testable import Humay

@Suite("Onboarding production flow")
@MainActor
struct OnboardingTests {
    @Test("Onboarding route transitions are deterministic")
    func routeTransitions() {
        #expect(OnboardingRoute.welcome.next == .birthDate)
        #expect(OnboardingRoute.birthDate.previous == .welcome)
        #expect(OnboardingRoute.birthDate.next == .name)
        #expect(OnboardingRoute.name.previous == .birthDate)
        #expect(OnboardingRoute.name.next == .tradition)
        #expect(OnboardingRoute.tradition.previous == .name)
        #expect(OnboardingRoute.tradition.next == .profileReveal)
        #expect(OnboardingRoute.profileReveal.previous == .tradition)
        #expect(OnboardingRoute.profileReveal.next == nil)
    }

    @Test("Fresh onboarding draft starts at a valid date cursor without a confirmed profile date")
    func freshDraftStartsUnconfirmed() {
        let draft = OnboardingDraftState(now: fixedNow, calendar: fixedCalendar)

        #expect(draft.pickerDate == draft.latestValidDate)
        #expect(draft.confirmedBirthDate == nil)
        #expect(draft.selectedTradition == .western)
        #expect(draft.makeProfile() == nil)
    }

    @Test("Confirmed date preserves year, month and day semantics")
    func confirmedDatePreservesCalendarComponents() throws {
        let draft = OnboardingDraftState(now: fixedNow, calendar: fixedCalendar)
        draft.pickerDate = try #require(
            fixedCalendar.date(from: DateComponents(year: 1994, month: 3, day: 14))
        )

        #expect(draft.confirmBirthDate())
        #expect(draft.confirmedBirthDate == OnboardingBirthDate(year: 1994, month: 3, day: 14))

        let profile = try #require(draft.makeProfile())
        #expect(profile.birth.year == 1994)
        #expect(profile.birth.month == 3)
        #expect(profile.birth.day == 14)
    }

    @Test("Birth date cannot precede January 1, 1900")
    func birthDateHasEarliestBound() throws {
        let draft = OnboardingDraftState(now: fixedNow, calendar: fixedCalendar)
        draft.pickerDate = try #require(
            fixedCalendar.date(from: DateComponents(year: 1899, month: 12, day: 31))
        )

        #expect(!draft.confirmBirthDate())
        #expect(draft.confirmedBirthDate == nil)
    }

    @Test("Birth date cannot exceed today")
    func birthDateHasLatestBound() throws {
        let draft = OnboardingDraftState(now: fixedNow, calendar: fixedCalendar)
        draft.pickerDate = try #require(
            fixedCalendar.date(from: DateComponents(year: 2026, month: 8, day: 13))
        )

        #expect(!draft.confirmBirthDate())
        #expect(draft.confirmedBirthDate == nil)
    }

    @Test("Tradition selection persists inside active onboarding state")
    func traditionSelectionPersists() {
        let draft = OnboardingDraftState(now: fixedNow, calendar: fixedCalendar)

        draft.selectedTradition = .vedic

        #expect(draft.selectedTradition == .vedic)
    }

    @Test("Draft inputs survive route changes")
    func draftInputsSurviveRouteChanges() throws {
        let draft = OnboardingDraftState(now: fixedNow, calendar: fixedCalendar)
        draft.pickerDate = try #require(
            fixedCalendar.date(from: DateComponents(year: 1994, month: 3, day: 14))
        )
        #expect(draft.confirmBirthDate())
        draft.selectedTradition = .chinese

        var route = OnboardingRoute.welcome
        route = try #require(route.next)
        route = try #require(route.next)
        route = try #require(route.next)
        route = try #require(route.previous)
        route = try #require(route.previous)

        #expect(route == .birthDate)
        #expect(draft.confirmedBirthDate == OnboardingBirthDate(year: 1994, month: 3, day: 14))
        #expect(draft.selectedTradition == .chinese)
    }

    @Test("Completion creates a date-only profile with selected tradition and main root")
    func completionCreatesDomainProfile() async throws {
        let draft = OnboardingDraftState(now: fixedNow, calendar: fixedCalendar)
        draft.pickerDate = try #require(
            fixedCalendar.date(from: DateComponents(year: 1994, month: 3, day: 14))
        )
        #expect(draft.confirmBirthDate())
        draft.selectedTradition = .chinese

        let environment = AppEnvironment(store: InMemoryUserStateStore())
        await environment.restore()
        let profile = try #require(draft.makeProfile())
        try await environment.completeOnboarding(
            profile: profile,
            tradition: draft.selectedTradition
        )
        let navigation = AppNavigationState(environment: environment)

        #expect(profile.displayName.isEmpty)
        #expect(profile.birth.time == .unknown)
        #expect(profile.birth.place == .notProvided)
        #expect(environment.settings.leadingTradition == .chinese)
        #expect(environment.hasCompletedOnboarding)
        #expect(navigation.root == .main)
    }

    @Test("Completed profile restores into a newly constructed environment")
    func completionRestoresIntoNewEnvironment() async throws {
        let store = InMemoryUserStateStore()
        let firstEnvironment = AppEnvironment(store: store)
        await firstEnvironment.restore()
        let profile = UserProfile(
            displayName: "",
            birth: BirthDetails(year: 1994, month: 3, day: 14)
        )
        try await firstEnvironment.completeOnboarding(
            profile: profile,
            tradition: .western,
            completedAt: fixedNow
        )

        let newEnvironment = AppEnvironment(store: store)
        await newEnvironment.restore()

        #expect(firstEnvironment.hasCompletedOnboarding)
        #expect(newEnvironment.hasCompletedOnboarding)
        #expect(newEnvironment.profile == profile)
        #expect(newEnvironment.settings.onboardingCompletedAt == fixedNow)
    }

    private var fixedCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private var fixedNow: Date {
        fixedCalendar.date(from: DateComponents(year: 2026, month: 8, day: 12))!
    }
}
