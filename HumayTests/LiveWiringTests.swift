import Foundation
import SwiftData
import Testing
@testable import Humay

/// The live wiring, over the real on-disk store.
///
/// These exist because the repositories originally kept only `container.mainContext`
/// and not the container. That works for as long as something else happens to hold the
/// container, so every isolated test passed while the application trapped inside
/// SwiftData on its first write. Exercising the composition root itself is what catches
/// an ownership mistake of that shape.
@MainActor
@Suite("Live wiring", .serialized)
struct LiveWiringTests {
    @Test("the live environment builds")
    func build() {
        _ = AppEnvironment.live()
    }

    @Test("completing onboarding persists a profile, settings and the seeded Circle")
    func completeOnboarding() {
        let environment = AppEnvironment.live()
        environment.deleteAllData()

        environment.completeOnboarding(
            profile: UserProfile(displayName: "", birth: BirthDetails(year: 1994, month: 3, day: 14)),
            tradition: .vedic
        )

        #expect(environment.profile != nil)
        #expect(environment.hasCompletedOnboarding)
        #expect(environment.settings.leadingTradition == .vedic)
        #expect(environment.people.count == SeedCircleFixtures.people.count)
    }

    @Test("state survives a rebuild of the environment")
    func survivesRelaunch() {
        let first = AppEnvironment.live()
        first.deleteAllData()
        first.completeOnboarding(
            profile: UserProfile(displayName: "", birth: BirthDetails(year: 1988, month: 11, day: 2)),
            tradition: .chinese
        )

        let second = AppEnvironment.live()
        #expect(second.hasCompletedOnboarding)
        #expect(second.profile?.birth.year == 1988)
        #expect(second.settings.leadingTradition == .chinese)
        #expect(second.people.count == SeedCircleFixtures.people.count)

        second.deleteAllData()
    }
}
