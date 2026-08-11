import OSLog

/// Application logging.
///
/// Birth data is personal, so nothing here interpolates it. `OSLog` redacts string
/// interpolations by default; that default is relied on rather than overridden.
enum HumayLog {
    private static let subsystem = "online.humay.ios"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let content = Logger(subsystem: subsystem, category: "content")
    static let navigation = Logger(subsystem: subsystem, category: "navigation")

    /// Call sites pass a plain `String` so they do not need to import `os` themselves,
    /// and so no personal value can be interpolated in by accident.
    static func persistenceFailure(_ summary: String) {
        persistence.error("\(summary, privacy: .public)")
    }

    static func contentFailure(_ summary: String) {
        content.error("\(summary, privacy: .public)")
    }
}

/// Build-time facts the interface may legitimately branch on.
enum HumayBuild {
    static var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    /// Whether to visibly mark content that came from a fixture.
    ///
    /// On in development so a screenshot cannot be mistaken for a real reading.
    static var showsSampleContentMarker: Bool { isDebug }
}
