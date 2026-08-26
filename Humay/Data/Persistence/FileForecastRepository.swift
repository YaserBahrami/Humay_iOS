import Foundation

/// Storage failures for personalized forecast content (§34).
enum ForecastRepositoryError: Error, Equatable, Sendable {
    case readFailed
    case writeFailed
    case corruptedCache
    case unsupportedSchema(Int)
    case documentMissing
}

/// Durable boundary for persisted personalized forecasts (§25).
protocol ForecastRepository: Sendable {
    func load(subject: ForecastSubject) async throws -> PersonalizedForecastDocument?
    func save(_ document: PersonalizedForecastDocument) async throws
    /// Replaces exactly the month's day offsets with freshly generated days and
    /// persists immediately (§6 step 5) so successful chunks survive failures.
    func mergeMonth(
        subject: ForecastSubject,
        anchor: ForecastAnchor,
        monthIndex: Int,
        days: [DailyMood],
        chunkState: GenerationChunkState,
        usage: GenerationUsage
    ) async throws -> PersonalizedForecastDocument
    func remove(subject: ForecastSubject) async throws
    /// Debug/QA export of the normalized document (§26).
    func exportData(subject: ForecastSubject) async throws -> Data
}

/// File-backed repository: one JSON document per subject, atomic writes,
/// explicit corruption and schema handling.
actor FileForecastRepository: ForecastRepository {
    private let directoryURL: URL
    private let fileManager = FileManager.default

    init() throws {
        guard let applicationSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw ForecastRepositoryError.writeFailed
        }
        self.directoryURL = applicationSupport
            .appendingPathComponent("Humay", isDirectory: true)
            .appendingPathComponent("Forecasts", isDirectory: true)
    }

    /// Test/preview initializer with an isolated directory.
    init(directory: URL) {
        self.directoryURL = directory
    }

    private func fileURL(for profileID: UUID) -> URL {
        directoryURL
            .appendingPathComponent("\(profileID.uuidString)-forecast-v\(PersonalizedForecastDocument.schemaVersion).json")
    }

    func load(subject: ForecastSubject) async throws -> PersonalizedForecastDocument? {
        let url = fileURL(for: subject.id)
        guard fileManager.fileExists(atPath: url.path) else { return nil }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ForecastRepositoryError.readFailed
        }

        return try Self.decode(data)
    }

    func save(_ document: PersonalizedForecastDocument) async throws {
        let data: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            encoder.dateEncodingStrategy = .secondsSince1970
            data = try encoder.encode(document)
        } catch {
            throw ForecastRepositoryError.writeFailed
        }

        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try data.write(to: fileURL(for: document.subject.profileID), options: [.atomic])
        } catch {
            throw ForecastRepositoryError.writeFailed
        }
    }

    func mergeMonth(
        subject: ForecastSubject,
        anchor: ForecastAnchor,
        monthIndex: Int,
        days: [DailyMood],
        chunkState: GenerationChunkState,
        usage: GenerationUsage
    ) async throws -> PersonalizedForecastDocument {
        guard var document = try await load(subject: subject) else {
            throw ForecastRepositoryError.documentMissing
        }

        // Validate the chunk before it may touch the store (§11).
        let expectedOffsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)
        try ForecastValidator.validate(days: days, expectedOffsets: expectedOffsets)

        let replaced = Set(days.map(\.dayOffset))
        var merged = document.days.filter { !replaced.contains($0.dayOffset) }
        merged.append(contentsOf: days)
        merged.sort { $0.dayOffset < $1.dayOffset }
        document.forecast.days = merged

        // Update chunk bookkeeping and usage counters.
        var chunks = document.generationState.chunks
        if let index = chunks.firstIndex(where: { $0.monthIndex == monthIndex }) {
            chunks[index] = chunkState
        } else {
            chunks.append(chunkState)
        }
        chunks.sort { $0.monthIndex < $1.monthIndex }
        document.generationState.chunks = chunks
        document.generationState.requestCount += usage.requestCount
        document.generationState.retryCount += usage.retryCount
        document.generationState.usageUnits += usage.usageUnits
        if document.generationState.phase == .notGenerated || document.generationState.phase == .preparing {
            document.generationState.phase = .generating
        }

        try await save(document)
        return document
    }

    func remove(subject: ForecastSubject) async throws {
        let url = fileURL(for: subject.id)
        guard fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw ForecastRepositoryError.writeFailed
        }
    }

    func exportData(subject: ForecastSubject) async throws -> Data {
        let url = fileURL(for: subject.id)
        guard fileManager.fileExists(atPath: url.path) else {
            throw ForecastRepositoryError.documentMissing
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw ForecastRepositoryError.readFailed
        }
    }

    /// Shared decode path: schema detection, typed decoding, full validation.
    /// Anything suspicious is corruption — never partially trusted (§11, §25).
    static func decode(_ data: Data) throws -> PersonalizedForecastDocument {
        let envelope: SchemaEnvelope
        do {
            envelope = try JSONDecoder().decode(SchemaEnvelope.self, from: data)
        } catch {
            throw ForecastRepositoryError.corruptedCache
        }

        guard envelope.schemaVersion == PersonalizedForecastDocument.schemaVersion else {
            throw ForecastRepositoryError.unsupportedSchema(envelope.schemaVersion)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let document: PersonalizedForecastDocument
        do {
            document = try decoder.decode(PersonalizedForecastDocument.self, from: data)
        } catch {
            throw ForecastRepositoryError.corruptedCache
        }

        do {
            try ForecastValidator.validate(days: document.days)
            if let context = document.forecast.yearContext {
                _ = try YearContext(
                    yearTheme: context.yearTheme,
                    monthlyThemes: context.monthlyThemes,
                    notablePeriods: context.notablePeriods
                )
            }
        } catch {
            throw ForecastRepositoryError.corruptedCache
        }

        return document
    }

    private struct SchemaEnvelope: Decodable {
        let schemaVersion: Int
    }
}

/// In-memory repository for previews and tests.
actor InMemoryForecastRepository: ForecastRepository {
    private var documents: [UUID: PersonalizedForecastDocument] = [:]

    init() {}

    func load(subject: ForecastSubject) async throws -> PersonalizedForecastDocument? {
        documents[subject.id]
    }

    func save(_ document: PersonalizedForecastDocument) async throws {
        documents[document.subject.profileID] = document
    }


    func mergeMonth(
        subject: ForecastSubject,
        anchor: ForecastAnchor,
        monthIndex: Int,
        days: [DailyMood],
        chunkState: GenerationChunkState,
        usage: GenerationUsage
    ) async throws -> PersonalizedForecastDocument {
        guard var document = documents[subject.id] else {
            throw ForecastRepositoryError.documentMissing
        }

        let expectedOffsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: YearlyForecast.dayCount)
        try ForecastValidator.validate(days: days, expectedOffsets: expectedOffsets)

        let replaced = Set(days.map(\.dayOffset))
        var merged = document.days.filter { !replaced.contains($0.dayOffset) }
        merged.append(contentsOf: days)
        merged.sort { $0.dayOffset < $1.dayOffset }
        document.forecast.days = merged

        var chunks = document.generationState.chunks
        if let index = chunks.firstIndex(where: { $0.monthIndex == monthIndex }) {
            chunks[index] = chunkState
        } else {
            chunks.append(chunkState)
        }
        chunks.sort { $0.monthIndex < $1.monthIndex }
        document.generationState.chunks = chunks
        document.generationState.requestCount += usage.requestCount
        document.generationState.retryCount += usage.retryCount
        document.generationState.usageUnits += usage.usageUnits

        documents[subject.id] = document
        return document
    }

    func remove(subject: ForecastSubject) async throws {
        documents.removeValue(forKey: subject.id)
    }

    func exportData(subject: ForecastSubject) async throws -> Data {
        guard let document = documents[subject.id] else {
            throw ForecastRepositoryError.documentMissing
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .secondsSince1970
        return try encoder.encode(document)
    }
}
