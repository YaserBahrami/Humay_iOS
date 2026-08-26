import Foundation

/// The user-owned profile/settings/people aggregate that the application must keep
/// durable.
///
/// This is a domain boundary value, not a storage representation. Data owns the
/// Codable mapping and file format.
struct UserStateSnapshot: Sendable, Hashable {
    var profile: UserProfile?
    var settings: AppSettings
    var people: [ConnectionPerson]

    init(profile: UserProfile?, settings: AppSettings, people: [ConnectionPerson] = []) {
        self.profile = profile
        self.settings = settings
        self.people = people
    }
}

/// Durable ownership boundary for the local user-state aggregate.
///
/// A missing value means that no state has ever been persisted. Implementations must
/// throw for read, decode, write or clear failures rather than returning defaults.
protocol UserStateStore: Sendable {
    func load() async throws -> UserStateSnapshot?
    func save(_ state: UserStateSnapshot) async throws
    func clear() async throws
}

/// Stable, implementation-neutral failures exposed across the persistence boundary.
///
/// Concrete storage details such as Application Support paths or directory creation
/// remain Data-layer concerns and must not leak into Domain.
enum UserStatePersistenceError: Error, Equatable, Sendable {
    case unavailable
    case readFailed
    case writeFailed
    case clearFailed
    case malformedPayload
    case unsupportedSchema(version: Int)
    case invalidPayload
}
