import Foundation

/// Orchestrates resumable year generation (§6, §13, §14).
///
/// Plan: load-or-create document → year outline → bounded month chunks, each
/// validated and persisted immediately. Failures are recorded per chunk and
/// never discard successful work. Safe to call again after termination,
/// network loss, or malformed provider output.
actor ForecastGenerationCoordinator {
    struct Configuration: Sendable {
        var maxAttemptsPerChunk: Int = 3
        var chunkCount: Int = 12

        init(maxAttemptsPerChunk: Int = 3, chunkCount: Int = 12) {
            self.maxAttemptsPerChunk = maxAttemptsPerChunk
            self.chunkCount = chunkCount
        }
    }

    enum Outcome: Sendable, Equatable {
        case cached(PersonalizedForecastDocument)
        case generated(PersonalizedForecastDocument)
        case partial(PersonalizedForecastDocument, failures: [GenerationFailureKind])
        case failed(GenerationFailureKind)
    }

    private let provider: any PersonalizedContentProviding
    private let repository: any ForecastRepository
    private let configuration: Configuration

    init(
        provider: any PersonalizedContentProviding,
        repository: any ForecastRepository,
        configuration: Configuration = Configuration()
    ) {
        self.provider = provider
        self.repository = repository
        self.configuration = configuration
    }

    // MARK: - Year generation

    func ensureForecast(
        subject: ForecastSubject,
        anchor: ForecastAnchor
    ) async throws -> Outcome {
        let existing = try await repository.load(subject: subject)

        // Fresh, complete document: pure cache hit (§22).
        if let existing,
           !existing.isStale(for: subject),
           existing.resolvedPhase(for: subject) == .complete {
            ForecastLog.cacheHit(profileID: subject.id)
            return .cached(existing)
        }

        if existing != nil {
            ForecastLog.resume(profileID: subject.id)
        } else {
            ForecastLog.generateStart(profileID: subject.id)
        }

        // Create or repair the document and its chunk plan.
        var document: PersonalizedForecastDocument
        if let existing, !existing.isStale(for: subject) {
            document = existing
            document.generationState.phase = .generating
            if document.generationState.chunks.count != configuration.chunkCount {
                document.generationState.chunks = Self.chunkPlan(count: configuration.chunkCount)
            }
        } else {
            document = Self.freshDocument(subject: subject, anchor: anchor, configuration: configuration)
        }
        try await repository.save(document)

        // Step 2: canonical annual context.
        if document.forecast.yearContext == nil {
            do {
                let outline = try await provider.generateYearOutline(subject: subject, anchor: anchor)
                document.forecast.yearContext = outline.context
                document.generationState.requestCount += outline.usage.requestCount
                document.generationState.usageUnits += outline.usage.usageUnits
                document.generationState.phase = .generating
                try await repository.save(document)
            } catch let error as GenerationError {
                try await recordFailure(error, on: document, subject: subject)
                return .failed(error.failureKind)
            } catch is CancellationError {
                try await persistInterrupted(document, subject: subject)
                throw CancellationError()
            }
        }

        // Step 3–6: bounded month chunks, validated + persisted immediately.
        var failures: [GenerationFailureKind] = []

        for monthIndex in 0..<configuration.chunkCount {
            try Task.checkCancellation()

            var chunk = document.generationState.chunk(monthIndex)
            guard chunk.status != .complete else { continue }
            guard chunk.attempts < configuration.maxAttemptsPerChunk else {
                failures.append(chunk.lastFailure ?? .unknown)
                continue
            }

            chunk.status = .generating
            chunk.attempts += 1
            document.generationState.chunks = upsert(document.generationState.chunks, chunk)
            try await repository.save(document)

            do {
                let generated = try await provider.generateMonthChunk(
                    subject: subject,
                    outline: document.forecast.yearContext!,
                    anchor: anchor,
                    monthIndex: monthIndex
                )

                let chunkState = GenerationChunkState(
                    monthIndex: monthIndex,
                    status: .complete,
                    attempts: chunk.attempts,
                    lastFailure: nil,
                    completedAt: .now
                )
                document = try await repository.mergeMonth(
                    subject: subject,
                    anchor: anchor,
                    monthIndex: monthIndex,
                    days: generated.days,
                    chunkState: chunkState,
                    usage: generated.usage
                )
                ForecastLog.chunkComplete(profileID: subject.id, monthIndex: monthIndex)
            } catch let error as GenerationError {
                failures.append(error.failureKind)
                if case .rateLimited = error {
                    // Cost discipline: stop the pass; resume later (§22).
                    try await recordChunkFailure(error, monthIndex: monthIndex, attempts: chunk.attempts, document: &document, subject: subject)
                    break
                }
                try await recordChunkFailure(error, monthIndex: monthIndex, attempts: chunk.attempts, document: &document, subject: subject)
            } catch is CancellationError {
                try await persistInterrupted(document, subject: subject)
                throw CancellationError()
            }
        }

        // Final phase resolution.
        document.generationState.phase = GenerationStateRecord.resolvedPhase(
            chunks: document.generationState.chunks,
            fingerprintMatches: true,
            generatorMatches: true
        )
        if document.generationState.phase == .complete {
            document.generationState.completedAt = .now
        }
        try await repository.save(document)

        switch document.generationState.phase {
        case .complete:
            ForecastLog.generateComplete(profileID: subject.id, days: document.days.count)
            return .generated(document)
        case .partial, .failed:
            ForecastLog.generateFailed(profileID: subject.id, failures: failures)
            return .partial(document, failures: failures)
        default:
            return .partial(document, failures: failures)
        }
    }

    // MARK: - Single day

    /// Targeted regeneration for one day (failed validation or explicit refresh).
    func regenerateDay(
        subject: ForecastSubject,
        dayOffset: Int
    ) async throws -> PersonalizedForecastDocument {
        guard var document = try await repository.load(subject: subject),
              let outline = document.forecast.yearContext else {
            throw ForecastRepositoryError.documentMissing
        }

        let day = try await provider.regenerateDay(
            subject: subject,
            outline: outline,
            anchor: document.anchor,
            dayOffset: dayOffset
        )

        try ForecastValidator.validate(days: [day], expectedOffsets: nil)

        var days = document.days.filter { $0.dayOffset != dayOffset }
        days.append(day)
        days.sort { $0.dayOffset < $1.dayOffset }
        document.forecast.days = days
        document.generationState.requestCount += 1

        try await repository.save(document)
        return document
    }

    // MARK: - Helpers

    private static func freshDocument(
        subject: ForecastSubject,
        anchor: ForecastAnchor,
        configuration: Configuration
    ) -> PersonalizedForecastDocument {
        let state = GenerationStateRecord(
            phase: .preparing,
            chunks: chunkPlan(count: configuration.chunkCount),
            fingerprintAtGeneration: ProfileFingerprint(
                subject: subject,
                generatorVersion: PersonalizedForecastDocument.generatorVersion
            ),
            generatorVersion: DeterministicContentProvider.generatorVersion,
            startedAt: .now
        )
        return PersonalizedForecastDocument(
            subject: subject,
            anchor: anchor,
            provenance: .init(
                generatorVersion: DeterministicContentProvider.generatorVersion,
                providerIdentifier: "pending",
                basis: .entertainmentFixture
            ),
            generationState: state
        )
    }

    private static func chunkPlan(count: Int) -> [GenerationChunkState] {
        (0..<count).map { GenerationChunkState(monthIndex: $0) }
    }

    private func upsert(
        _ chunks: [GenerationChunkState],
        _ chunk: GenerationChunkState
    ) -> [GenerationChunkState] {
        var result = chunks
        if let index = result.firstIndex(where: { $0.monthIndex == chunk.monthIndex }) {
            result[index] = chunk
        } else {
            result.append(chunk)
        }
        result.sort { $0.monthIndex < $1.monthIndex }
        return result
    }

    private func recordFailure(
        _ error: GenerationError,
        on document: PersonalizedForecastDocument,
        subject: ForecastSubject
    ) async throws {
        var updated = document
        updated.generationState.phase = .failed
        try await repository.save(updated)
        ForecastLog.generateFailed(profileID: subject.id, failures: [error.failureKind])
    }

    private func recordChunkFailure(
        _ error: GenerationError,
        monthIndex: Int,
        attempts: Int,
        document: inout PersonalizedForecastDocument,
        subject: ForecastSubject
    ) async throws {
        let chunk = GenerationChunkState(
            monthIndex: monthIndex,
            status: .failed,
            attempts: attempts,
            lastFailure: error.failureKind
        )
        document.generationState.chunks = upsert(document.generationState.chunks, chunk)
        document.generationState.retryCount += 1
        document.generationState.requestCount += 1
        try await repository.save(document)
        ForecastLog.validationOrChunkFailed(profileID: subject.id, monthIndex: monthIndex, kind: error.failureKind)
    }

    private func persistInterrupted(
        _ document: PersonalizedForecastDocument,
        subject: ForecastSubject
    ) async throws {
        var updated = document
        if updated.generationState.phase != .complete {
            updated.generationState.phase = document.generationState.completedChunkCount > 0 ? .partial : .generating
        }
        try await repository.save(updated)
    }
}
