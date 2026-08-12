import Foundation

/// The user-owned profile/settings aggregate that the application must keep durable.
///
/// This is a domain boundary value, not a storage representation. Data owns the
/// Codable mapping and file format.
struct UserStateSnapshot: Sendable, Hashable {
    var profile: UserProfile?
    var settings: AppSettings
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

/// Stable operation-level failures exposed by persistence implementations.
enum UserStatePersistenceError: Error, Equatable, Sendable {
    case applicationSupportUnavailable
    case directoryCreationFailed
    case readFailed
    case writeFailed
    case clearFailed
    case malformedPayload
    case unsupportedSchema(version: Int)
    case invalidPayload
}
