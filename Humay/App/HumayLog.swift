import OSLog

/// Finite application-level operational events.
///
/// Cases intentionally carry no associated values so call sites cannot attach user
/// or provider payloads to application diagnostics.
enum HumayApplicationLogEvent: CaseIterable, Equatable, Sendable {
    case durableStorageUnavailable
}

/// Finite persistence-level operational events.
///
/// Cases intentionally carry no associated values so persistence diagnostics remain
/// useful without exposing profile, birth or serialized storage data.
enum HumayPersistenceLogEvent: CaseIterable, Equatable, Sendable {
    case restoreFailed
    case saveFailed
    case clearFailed
    case unsupportedSchema
}

/// Central application logging.
enum HumayLog {
    private static let subsystem = "online.humay.ios"

    private static let applicationLogger = Logger(
        subsystem: subsystem,
        category: "application"
    )
    private static let persistenceLogger = Logger(
        subsystem: subsystem,
        category: "persistence"
    )

    static func application(_ event: HumayApplicationLogEvent) {
        switch event {
        case .durableStorageUnavailable:
            applicationLogger.error("Durable storage unavailable")
        }
    }

    static func persistence(_ event: HumayPersistenceLogEvent) {
        switch event {
        case .restoreFailed:
            persistenceLogger.error("User-state restore failed")
        case .saveFailed:
            persistenceLogger.error("User-state save failed")
        case .clearFailed:
            persistenceLogger.error("User-state clear failed")
        case .unsupportedSchema:
            persistenceLogger.error("Unsupported local persistence schema")
        }
    }
}
