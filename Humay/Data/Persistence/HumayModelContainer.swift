import Foundation
import SwiftData

/// Builds the store.
///
/// The container is a private detail of the data layer. The application deliberately
/// does not call `.modelContainer(_:)` on the scene and no view uses `@Query` — either
/// would put SwiftData into the view layer and dissolve the boundary that keeps the
/// interface depending on protocols.
enum HumayModelContainer {
    /// Where the store lives.
    ///
    /// Application Support rather than Documents, because this is app state the person
    /// never browses. The directory does not exist in a fresh container and SwiftData
    /// does not create it — without this, the container is built happily and then traps
    /// on the first write, which reads as a SwiftData bug rather than a missing folder.
    static func storeURL() throws -> URL {
        let fileManager = FileManager.default
        let directory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        if !fileManager.fileExists(atPath: directory.path(percentEncoded: false)) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory.appending(path: "Humay.store")
    }

    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: HumaySchemaV1.self)
        let configuration: ModelConfiguration = if inMemory {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            ModelConfiguration(schema: schema, url: try storeURL())
        }
        return try ModelContainer(
            for: schema,
            migrationPlan: HumayMigrationPlan.self,
            configurations: [configuration]
        )
    }

    /// Falls back to an in-memory store when the on-disk one cannot be opened.
    ///
    /// A store that will not open should not be a launch failure the person cannot get
    /// past. They lose persistence for the session, which is visible and recoverable; a
    /// crash loop is neither.
    static func makeWithFallback() -> ModelContainer {
        do {
            return try make()
        } catch {
            HumayLog.persistenceFailure("On-disk store unavailable, falling back to memory: \(error)")
            do {
                return try make(inMemory: true)
            } catch {
                fatalError("Could not create an in-memory store: \(error)")
            }
        }
    }
}
