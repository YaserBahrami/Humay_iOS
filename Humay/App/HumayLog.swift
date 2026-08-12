import OSLog

/// Central application logging.
///
/// Birth/profile values are personal and must not be logged. Call sites should log a
/// short operational summary rather than raw user/provider payloads.
enum HumayLog {
    private static let subsystem = "online.humay.ios"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let content = Logger(subsystem: subsystem, category: "content")
    static let navigation = Logger(subsystem: subsystem, category: "navigation")

    static func persistenceFailure(_ summary: String) {
        persistence.error("\(summary, privacy: .public)")
    }

    static func contentFailure(_ summary: String) {
        content.error("\(summary, privacy: .public)")
    }
}
