import Foundation

/// Repositories backed by nothing but a dictionary.
///
/// Used by previews and by tests that are not about persistence. Keeping SwiftData out
/// of previews entirely makes them fast and removes a whole class of "the preview
/// crashed but the app is fine" confusion.
@MainActor
final class InMemoryUserProfileRepository: UserProfileRepository {
    private var stored: UserProfile?

    init(profile: UserProfile? = nil) {
        stored = profile
    }

    func load() throws -> UserProfile? { stored }
    func save(_ profile: UserProfile) throws { stored = profile }
    func delete() throws { stored = nil }
}

@MainActor
final class InMemoryAppSettingsRepository: AppSettingsRepository {
    private var stored: AppSettings

    init(settings: AppSettings = .default) {
        stored = settings
    }

    func load() throws -> AppSettings { stored }
    func save(_ settings: AppSettings) throws { stored = settings }
}

@MainActor
final class InMemoryCirclePersonRepository: CirclePersonRepository {
    private var stored: [UUID: CirclePerson]
    private var order: [UUID]

    init(people: [CirclePerson] = []) {
        stored = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
        order = people.map(\.id)
    }

    func loadAll() throws -> [CirclePerson] {
        order.compactMap { stored[$0] }
    }

    func save(_ person: CirclePerson) throws {
        if stored[person.id] == nil { order.append(person.id) }
        stored[person.id] = person
    }

    func delete(id: UUID) throws {
        stored[id] = nil
        order.removeAll { $0 == id }
    }

    func deleteAll() throws {
        stored.removeAll()
        order.removeAll()
    }
}

@MainActor
final class InMemoryAskConversationRepository: AskConversationRepository {
    private var stored: [UUID: AskConversation] = [:]

    func loadAll() throws -> [AskConversation] {
        stored.values.sorted { $0.startedAt > $1.startedAt }
    }

    func save(_ conversation: AskConversation) throws {
        stored[conversation.id] = conversation
    }

    func delete(id: UUID) throws {
        stored[id] = nil
    }

    func deleteAll() throws {
        stored.removeAll()
    }
}
