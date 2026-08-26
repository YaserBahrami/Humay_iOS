import Foundation
import OSLog

/// Structured forecast-pipeline diagnostics (§40).
///
/// Privacy rules: profile IDs are opaque UUIDs (already non-identifying outside
/// this device); birth details, names and generated copy are never logged.
/// Counts and categories only.
enum ForecastLog {
    private static let logger = Logger(subsystem: "online.humay.ios", category: "forecast")

    static func load(profileID: UUID) {
        logger.debug("forecast.load profile=\(profileID.uuidString, privacy: .private(mask: .hash))")
    }

    static func cacheHit(profileID: UUID) {
        logger.debug("forecast.cacheHit profile=\(profileID.uuidString, privacy: .private(mask: .hash))")
    }

    static func stale(profileID: UUID) {
        logger.info("forecast.stale profile=\(profileID.uuidString, privacy: .private(mask: .hash))")
    }

    static func generateStart(profileID: UUID) {
        logger.info("forecast.generate.start profile=\(profileID.uuidString, privacy: .private(mask: .hash))")
    }

    static func chunkComplete(profileID: UUID, monthIndex: Int) {
        logger.info("forecast.generate.chunk profile=\(profileID.uuidString, privacy: .private(mask: .hash)) month=\(monthIndex)")
    }

    static func generateComplete(profileID: UUID, days: Int) {
        logger.info("forecast.generate.complete profile=\(profileID.uuidString, privacy: .private(mask: .hash)) days=\(days)")
    }

    static func generateFailed(profileID: UUID, failures: [GenerationFailureKind]) {
        let kinds = failures.map(\.rawValue).joined(separator: ",")
        logger.error("forecast.generate.failed profile=\(profileID.uuidString, privacy: .private(mask: .hash)) kinds=\(kinds, privacy: .public)")
    }

    static func resume(profileID: UUID) {
        logger.info("forecast.resume profile=\(profileID.uuidString, privacy: .private(mask: .hash))")
    }

    static func validationOrChunkFailed(profileID: UUID, monthIndex: Int, kind: GenerationFailureKind) {
        logger.error("forecast.validation.failed profile=\(profileID.uuidString, privacy: .private(mask: .hash)) month=\(monthIndex) kind=\(kind.rawValue, privacy: .public)")
    }

    static func repositoryIssue(_ issue: String) {
        logger.error("forecast.repository issue=\(issue, privacy: .public)")
    }
}
