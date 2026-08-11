import Foundation

// MARK: - Repositories
//
// These are synchronous. The whole dataset is one profile, a handful of people and a
// few conversations — kilobytes — held in a store on the same device. Declaring them
// `async` would put `await` through every call site to describe work that does not
// happen, which is a cost pretending to be rigour.
//
// If a repository ever needs to do real background work, the protocol becomes `async`
// and gains a backing actor. Call sites already `try`, so that change is mechanical.

/// The person using the application. There is at most one.
@MainActor
protocol UserProfileRepository: AnyObject, Sendable {
    func load() throws -> UserProfile?
    func save(_ profile: UserProfile) throws
    func delete() throws
}

/// Preferences.
@MainActor
protocol AppSettingsRepository: AnyObject, Sendable {
    func load() throws -> AppSettings
    func save(_ settings: AppSettings) throws
}

/// People in the Circle.
@MainActor
protocol CirclePersonRepository: AnyObject, Sendable {
    func loadAll() throws -> [CirclePerson]
    func save(_ person: CirclePerson) throws
    func delete(id: UUID) throws
    func deleteAll() throws
}

/// Ask conversations.
@MainActor
protocol AskConversationRepository: AnyObject, Sendable {
    func loadAll() throws -> [AskConversation]
    func save(_ conversation: AskConversation) throws
    func delete(id: UUID) throws
    func deleteAll() throws
}
