import Foundation
import SwiftData
import Testing
@testable import Humay

/// Persistence, over a fresh in-memory store per test.
///
/// Swift Testing creates a new suite instance for every test, so the container built in
/// `init` is never shared and cases cannot leak into one another.
@MainActor
@Suite("Persistence")
struct RepositoryTests {
    let container: ModelContainer

    init() throws {
        container = try HumayModelContainer.make(inMemory: true)
    }

    @Test("a profile round-trips")
    func profileRoundTrip() throws {
        let repository = SwiftDataUserProfileRepository(container: container)
        #expect(try repository.load() == nil)

        let profile = UserProfile(
            displayName: "Jordan",
            birth: BirthDetails(year: 1994, month: 3, day: 14)
        )
        try repository.save(profile)

        let loaded = try #require(try repository.load())
        #expect(loaded.id == profile.id)
        #expect(loaded.birth.year == 1994)
        #expect(loaded.birth.month == 3)
        #expect(loaded.birth.day == 14)
    }

    /// The rule the whole unknown-time design rests on: an absent birth time must come
    /// back absent, never as a stored midnight.
    @Test("an unknown birth time round-trips as unknown")
    func unknownBirthTimeSurvives() throws {
        let repository = SwiftDataUserProfileRepository(container: container)
        try repository.save(
            UserProfile(displayName: "A", birth: BirthDetails(year: 1990, month: 6, day: 1))
        )

        let loaded = try #require(try repository.load())
        #expect(loaded.birth.time == .unknown)
        #expect(loaded.birth.time.minutesFromMidnight == nil)
        #expect(loaded.birth.place == .notProvided)
    }

    /// Midnight is a legitimate birth time and must not be mistaken for "not set".
    @Test("midnight is distinguishable from unknown")
    func midnightIsNotUnknown() throws {
        let repository = SwiftDataUserProfileRepository(container: container)
        try repository.save(
            UserProfile(
                displayName: "A",
                birth: BirthDetails(year: 1990, month: 6, day: 1, time: .exact(minutesFromMidnight: 0))
            )
        )

        let loaded = try #require(try repository.load())
        #expect(loaded.birth.time == .exact(minutesFromMidnight: 0))
        #expect(loaded.birth.time.isKnown)
    }

    @Test("saving the same profile twice updates rather than duplicating")
    func profileIsSingular() throws {
        let repository = SwiftDataUserProfileRepository(container: container)
        var profile = UserProfile(displayName: "A", birth: BirthDetails(year: 1990, month: 6, day: 1))
        try repository.save(profile)
        profile.displayName = "B"
        try repository.save(profile)

        let context = ModelContext(container)
        #expect(try context.fetch(FetchDescriptor<UserProfileEntity>()).count == 1)
        #expect(try repository.load()?.displayName == "B")
    }

    @Test("people can be added, updated and removed")
    func circlePersonCRUD() throws {
        let repository = SwiftDataCirclePersonRepository(container: container)
        #expect(try repository.loadAll().isEmpty)

        var person = CirclePerson(
            name: "Sara",
            role: .partner,
            birth: BirthDetails(year: 1993, month: 8, day: 3)
        )
        try repository.save(person)
        #expect(try repository.loadAll().count == 1)

        person.name = "Sara M"
        try repository.save(person)
        let people = try repository.loadAll()
        #expect(people.count == 1)
        #expect(people.first?.name == "Sara M")
        #expect(people.first?.role == .partner)

        try repository.delete(id: person.id)
        #expect(try repository.loadAll().isEmpty)
    }

    @Test("settings round-trip and default when absent")
    func settingsRoundTrip() throws {
        let repository = SwiftDataAppSettingsRepository(container: container)
        #expect(try repository.load() == .default)

        var settings = AppSettings.default
        settings.tone = .roast
        settings.leadingTradition = .vedic
        settings.onboardingCompletedAt = .now
        try repository.save(settings)

        let loaded = try repository.load()
        #expect(loaded.tone == .roast)
        #expect(loaded.leadingTradition == .vedic)
        #expect(loaded.hasCompletedOnboarding)
    }

    @Test("deleting a conversation removes its messages")
    func conversationCascades() throws {
        let repository = SwiftDataAskConversationRepository(container: container)
        let conversation = AskConversation(messages: [
            AskMessage(role: .person, text: "Why?", provenance: .mockFixture(fixtureID: "t")),
            AskMessage(role: .humay, text: "Because.", provenance: .mockFixture(fixtureID: "t")),
        ])
        try repository.save(conversation)
        #expect(try repository.loadAll().first?.messages.count == 2)

        try repository.delete(id: conversation.id)
        #expect(try repository.loadAll().isEmpty)

        let context = ModelContext(container)
        #expect(try context.fetch(FetchDescriptor<AskMessageEntity>()).isEmpty)
    }

    @Test("deleting everything leaves an empty store")
    func deleteAllLeavesNothing() throws {
        let profiles = SwiftDataUserProfileRepository(container: container)
        let people = SwiftDataCirclePersonRepository(container: container)

        try profiles.save(UserProfile(displayName: "A", birth: BirthDetails(year: 1990, month: 1, day: 1)))
        try people.save(CirclePerson(name: "B", role: .friend, birth: BirthDetails(year: 1990, month: 1, day: 1)))

        try profiles.delete()
        try people.deleteAll()

        #expect(try profiles.load() == nil)
        #expect(try people.loadAll().isEmpty)
    }
}
