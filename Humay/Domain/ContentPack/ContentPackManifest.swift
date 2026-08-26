import Foundation

/// Versioned manifest for the offline AI content pack.
///
/// Currency is declared at the pack boundary so a single `schemaVersion`
/// bump invalidates the entire bundled resource safely.
struct ContentPackManifest: Sendable, Hashable, Codable {
    static let currentSchemaVersion = 1
    static let currentCompilerVersion = "humay-pack-compiler-v1"

    let schemaVersion: Int
    let packVersion: String
    let language: String
    let contentCycleVersion: String
    let createdAt: Date
    let canonicalCalendar: String
    let coverage: Coverage
    let provenance: Provenance
    let compilerVersion: String
    let checksums: [String: String]?

    struct Coverage: Sendable, Hashable, Codable {
        /// Canonical start key inclusive, e.g. "03-01"
        let startDayKey: String?
        /// Canonical end key inclusive, e.g. "03-14"
        let endDayKey: String?
        /// Number of distinct day keys present (366 for full pack, 14 for pilot)
        let dayKeyCount: Int
        let isPilot: Bool
        let includesLeapDay: Bool
        /// Total Sun/day records present (366*12 for full, 14*12 for pilot)
        let sunRecordCount: Int
    }

    struct Provenance: Sendable, Hashable, Codable {
        let sourceModel: String
        let sourceModelVersion: String?
        let promptVersion: String
        let generatedAt: Date?
        let reviewedAt: Date?
        let contentLanguage: String
    }

    init(
        packVersion: String,
        language: String = "en",
        contentCycleVersion: String,
        createdAt: Date = .now,
        canonicalCalendar: String = "366-day",
        coverage: Coverage,
        provenance: Provenance,
        compilerVersion: String = currentCompilerVersion,
        checksums: [String: String]? = nil
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.packVersion = packVersion
        self.language = language
        self.contentCycleVersion = contentCycleVersion
        self.createdAt = createdAt
        self.canonicalCalendar = canonicalCalendar
        self.coverage = coverage
        self.provenance = provenance
        self.compilerVersion = compilerVersion
        self.checksums = checksums
    }

    func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw ContentPackError.unsupportedSchemaVersion(schemaVersion)
        }
        guard !packVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ContentPackError.malformedJSON("manifest.packVersion empty")
        }
    }
}
