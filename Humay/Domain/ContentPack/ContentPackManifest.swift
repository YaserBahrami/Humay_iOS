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
    // I.1 lifecycle — optional for pilot, required for production
    let activeFrom: Date?
    let activeThrough: Date?
    /// Top-level generation method (scripted-pilot, ai-batch-authored, human-curated, mixed)
    let generationMethod: String?
    /// Compact batch provenance summary (detailed provenance stays in source tooling)
    let batches: [BatchProvenance]?

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
        /// Generation method for this pack (scripted-pilot, ai-batch-authored, etc.)
        let generationMethod: String?
    }

    /// Batch-level provenance summary — compact, manifest-level
    struct BatchProvenance: Sendable, Hashable, Codable {
        let batchID: String
        let dayKeyRange: String? // e.g., "03-01_03-07"
        let signs: [String]? // subset of 12, nil means all
        let sourceModel: String
        let sourceModelVersion: String?
        let promptVersion: String?
        let generationMethod: String?
        let generatedAt: Date?
        let reviewedByModel: String?
        let reviewedAt: Date?
        let qaStatus: String? // generated, validated, reviewed, rejected, approved
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
        checksums: [String: String]? = nil,
        activeFrom: Date? = nil,
        activeThrough: Date? = nil,
        generationMethod: String? = nil,
        batches: [BatchProvenance]? = nil
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
        self.activeFrom = activeFrom
        self.activeThrough = activeThrough
        self.generationMethod = generationMethod
        self.batches = batches
    }

    func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw ContentPackError.unsupportedSchemaVersion(schemaVersion)
        }
        guard !packVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ContentPackError.malformedJSON("manifest.packVersion empty")
        }
        // Content cycle lifecycle: required for production, optional for pilot
        if !coverage.isPilot {
            guard !contentCycleVersion.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw ContentPackError.malformedJSON("contentCycleVersion required for production")
            }
            guard activeFrom != nil else {
                throw ContentPackError.malformedJSON("activeFrom required for production")
            }
            guard activeThrough != nil else {
                throw ContentPackError.malformedJSON("activeThrough required for production")
            }
            if let from = activeFrom, let through = activeThrough, from >= through {
                throw ContentPackError.malformedJSON("activeFrom must be before activeThrough")
            }
            // generationMethod recommended for production
            if let gm = generationMethod ?? provenance.generationMethod, gm.trimmingCharacters(in: .whitespaces).isEmpty {
                throw ContentPackError.malformedJSON("generationMethod empty")
            }
        }
    }
}
