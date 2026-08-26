import Foundation

/// Top-level generation phase for a personalized forecast.
enum ForecastGenerationPhase: String, Sendable, Hashable, Codable {
    case notGenerated
    case preparing
    case generating
    case partial
    case complete
    case stale
    case failed
    case invalid
}

/// Failure categories preserved across restarts so resume logic and error
/// surfaces can differentiate recovery paths.
enum GenerationFailureKind: String, Sendable, Hashable, Codable {
    case networkUnavailable
    case providerUnavailable
    case malformedOutput
    case authenticationFailed
    case rateLimited
    case serverError
    case validationFailed
    case cancelled
    case unknown
}

/// Status of one bounded generation chunk (one month by default).
enum GenerationChunkStatus: String, Sendable, Hashable, Codable {
    case pending
    case generating
    case complete
    case failed
}

struct GenerationChunkState: Sendable, Hashable, Codable {
    let monthIndex: Int
    var status: GenerationChunkStatus
    var attempts: Int
    var lastFailure: GenerationFailureKind?
    var completedAt: Date?

    init(monthIndex: Int, status: GenerationChunkStatus = .pending, attempts: Int = 0, lastFailure: GenerationFailureKind? = nil, completedAt: Date? = nil) {
        self.monthIndex = monthIndex
        self.status = status
        self.attempts = attempts
        self.lastFailure = lastFailure
        self.completedAt = completedAt
    }
}

/// Persisted generation bookkeeping. Enough to resume after termination without
/// discarding successful chunks.
struct GenerationStateRecord: Sendable, Hashable, Codable {
    var phase: ForecastGenerationPhase
    var chunks: [GenerationChunkState]
    var fingerprintAtGeneration: ProfileFingerprint
    var generatorVersion: String
    var startedAt: Date?
    var completedAt: Date?
    /// Cost/usage counters (§22): requests issued, retries consumed, provider
    /// usage units when the provider exposes them.
    var requestCount: Int
    var retryCount: Int
    var usageUnits: Int

    init(
        phase: ForecastGenerationPhase = .notGenerated,
        chunks: [GenerationChunkState] = [],
        fingerprintAtGeneration: ProfileFingerprint,
        generatorVersion: String,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        requestCount: Int = 0,
        retryCount: Int = 0,
        usageUnits: Int = 0
    ) {
        self.phase = phase
        self.chunks = chunks
        self.fingerprintAtGeneration = fingerprintAtGeneration
        self.generatorVersion = generatorVersion
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.requestCount = requestCount
        self.retryCount = retryCount
        self.usageUnits = usageUnits
    }

    func chunk(_ monthIndex: Int) -> GenerationChunkState {
        chunks.first { $0.monthIndex == monthIndex } ?? GenerationChunkState(monthIndex: monthIndex)
    }

    var completedChunkCount: Int {
        chunks.filter { $0.status == .complete }.count
    }

    var failedChunkIndexes: [Int] {
        chunks.filter { $0.status == .failed }.map(\.monthIndex)
    }

    var pendingChunkIndexes: [Int] {
        chunks.filter { $0.status == .pending || $0.status == .generating }.map(\.monthIndex)
    }

    /// The phase a consumer should observe given chunk outcomes.
    static func resolvedPhase(chunks: [GenerationChunkState], fingerprintMatches: Bool, generatorMatches: Bool) -> ForecastGenerationPhase {
        guard fingerprintMatches else { return .stale }
        guard generatorMatches else { return .stale }
        if chunks.allSatisfy({ $0.status == .complete }) { return .complete }
        if chunks.contains(where: { $0.status == .complete }) { return .partial }
        if chunks.contains(where: { $0.status == .failed }) { return .failed }
        return .notGenerated
    }
}
