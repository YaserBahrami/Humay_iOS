import Foundation

/// Vendor-neutral boundary for personalized content generation (§4).
///
/// Implementations: deterministic fallback (shipped), development fixtures, and
/// the remote AI provider (contracts ready, transport injectable). Presentation
/// never knows which one produced the content.
///
/// All methods are chunk-scoped and resumable by design (§6): a year is generated
/// as one outline plus bounded month chunks, never one giant request.
protocol PersonalizedContentProviding: Sendable {
    /// Provider identity for provenance and stale detection.
    var descriptor: PersonalizedContentProviderDescriptor { get }

    /// Step 2 of the plan: lightweight annual structure (theme, monthly
    /// tendencies, notable periods) that later chunks must stay coherent with.
    func generateYearOutline(
        subject: ForecastSubject,
        anchor: ForecastAnchor
    ) async throws -> GeneratedOutline

    /// Step 3: one bounded month of structured days.
    func generateMonthChunk(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        monthIndex: Int
    ) async throws -> GeneratedMonth

    /// Targeted single-day regeneration (failed validation, user request).
    func regenerateDay(
        subject: ForecastSubject,
        outline: YearContext,
        anchor: ForecastAnchor,
        dayOffset: Int
    ) async throws -> DailyMood
}

/// Vendor-neutral provenance descriptor. Coordinator uses this to stamp
/// documents with the actual provider that generated the data.
struct PersonalizedContentProviderDescriptor: Sendable, Hashable {
    static let deterministicIdentifier = "deterministic"
    static let remoteIdentifier = "remote-ai"

    let providerIdentifier: String
    let generatorVersion: String
    let promptCatalogVersion: String
    let basis: ContentBasis
    let modelIdentifier: String?
}

/// Provider-reported usage for cost control (§22).
struct GenerationUsage: Sendable, Hashable {
    var requestCount: Int = 1
    var retryCount: Int = 0
    /// Provider-specific units (tokens or equivalents) when exposed.
    var usageUnits: Int = 0

    static let zero = GenerationUsage(requestCount: 0, retryCount: 0, usageUnits: 0)
}

struct GeneratedOutline: Sendable, Hashable {
    let context: YearContext
    let usage: GenerationUsage
    let modelIdentifier: String?
    /// Honest source of this generated outline — the actual provider that produced it, not the outer Hybrid descriptor.
    let sourceDescriptor: PersonalizedContentProviderDescriptor?
    var effectiveDescriptor: PersonalizedContentProviderDescriptor? { sourceDescriptor }
    let packVersion: String?
    let contentCycleVersion: String?

    init(context: YearContext, usage: GenerationUsage, modelIdentifier: String?, sourceDescriptor: PersonalizedContentProviderDescriptor? = nil, packVersion: String? = nil, contentCycleVersion: String? = nil) {
        self.context = context; self.usage = usage; self.modelIdentifier = modelIdentifier; self.sourceDescriptor = sourceDescriptor; self.packVersion = packVersion; self.contentCycleVersion = contentCycleVersion
    }
}

struct GeneratedMonth: Sendable, Hashable {
    let days: [DailyMood]
    let usage: GenerationUsage
    let modelIdentifier: String?
    let sourceDescriptor: PersonalizedContentProviderDescriptor?
    var effectiveDescriptor: PersonalizedContentProviderDescriptor? { sourceDescriptor }
    let packVersion: String?
    let contentCycleVersion: String?

    init(days: [DailyMood], usage: GenerationUsage, modelIdentifier: String?, sourceDescriptor: PersonalizedContentProviderDescriptor? = nil, packVersion: String? = nil, contentCycleVersion: String? = nil) {
        self.days = days; self.usage = usage; self.modelIdentifier = modelIdentifier; self.sourceDescriptor = sourceDescriptor; self.packVersion = packVersion; self.contentCycleVersion = contentCycleVersion
    }
}

/// Domain-level generation failures (§34). Presentation translates these into
/// Humay voice; the categories drive recovery decisions.
enum GenerationError: Error, Equatable, Sendable {
    case networkUnavailable
    case providerUnavailable
    case malformedOutput(detail: String)
    case authenticationFailed
    case rateLimited(retryAfterSeconds: Int?)
    case serverError(status: Int)
    case validationFailed(ForecastValidationError)
    case cancelled

    var failureKind: GenerationFailureKind {
        switch self {
        case .networkUnavailable: .networkUnavailable
        case .providerUnavailable: .providerUnavailable
        case .malformedOutput: .malformedOutput
        case .authenticationFailed: .authenticationFailed
        case .rateLimited: .rateLimited
        case .serverError: .serverError
        case .validationFailed: .validationFailed
        case .cancelled: .cancelled
        }
    }
}
