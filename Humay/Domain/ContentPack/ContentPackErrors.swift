import Foundation

enum ContentPackError: Error, Equatable, Sendable {
    case invalidDayKey(String)
    case duplicateRecord(String)
    case missingRecord(String)
    case invalidScore(dimension: String, value: Int)
    case invalidTextLength(field: String, length: Int, max: Int)
    case unsupportedSchemaVersion(Int)
    case missingFile(String)
    case malformedJSON(String)
    case invalidReference(String)
    case checksumMismatch(String)
    case bundleNotFound
    case packCorrupted(String)
}
