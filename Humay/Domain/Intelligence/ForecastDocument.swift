import Foundation

/// The persisted envelope for one person's personalized year.
///
/// Schema v1. Contains the normalized `YearlyForecast` plus identity, fingerprint
/// and generation bookkeeping. Everything here is validated on decode; a document
/// that fails validation is treated as corrupted, not partially trusted.
struct PersonalizedForecastDocument: Sendable, Hashable, Codable {
    static let schemaVersion = IntelligenceVersions.forecastSchema
    static let generatorVersion = YearlyForecast.currentGeneratorVersion

    let schemaVersion: Int
    let fingerprint: ProfileFingerprint
    let subject: SubjectRecord
    let astrology: AstrologyRecord
    let identity: IdentityRecord
    var forecast: ForecastRecord
    let provenance: ExtendedProvenance
    var generationState: GenerationStateRecord

    // MARK: - Records

    struct SubjectRecord: Sendable, Hashable, Codable {
        let profileID: UUID
        let displayName: String
        let birthYear: Int
        let birthMonth: Int
        let birthDay: Int
        let birthTimeKnown: Bool
        let birthPlaceName: String?

        init(subject: ForecastSubject) {
            profileID = subject.id
            displayName = subject.name
            birthYear = subject.birth.year
            birthMonth = subject.birth.month
            birthDay = subject.birth.day
            birthTimeKnown = subject.birth.time.isKnown
            birthPlaceName = subject.birth.place.name
        }

        var birth: BirthDetails {
            BirthDetails(year: birthYear, month: birthMonth, day: birthDay)
        }
    }

    /// Deterministic astrology identity only. Moon/Rising stay nil until a real
    /// calculation engine exists — AI never fills them (§3).
    struct AstrologyRecord: Sendable, Hashable, Codable {
        let sunSign: String?
        let moonSign: String?
        let risingSign: String?
        let calculationVersion: String

        init(subject: ForecastSubject) {
            sunSign = subject.sunSign?.rawValue
            moonSign = nil
            risingSign = nil
            calculationVersion = IntelligenceVersions.astrologyCalculation
        }
    }

    struct IdentityRecord: Sendable, Hashable, Codable {
        let humayArchetypeID: String

        init(subject: ForecastSubject) {
            humayArchetypeID = HumayContentEngine.archetype(profileID: subject.id).id
        }
    }

    struct ForecastRecord: Sendable, Hashable, Codable {
        let startYear: Int
        let startMonth: Int
        let startDay: Int
        var days: [DailyMood]
        var yearContext: YearContext?

        var anchor: ForecastAnchor {
            ForecastAnchor(year: startYear, month: startMonth, day: startDay)
        }
    }

    /// Provenance with generation-method detail beyond the base ContentProvenance.
    struct ExtendedProvenance: Sendable, Hashable, Codable {
        let generatorVersion: String
        let promptCatalogVersion: String
        let providerIdentifier: String
        let modelIdentifier: String?
        let generatedAt: Date
        let basis: ContentBasis
        let usedFallback: Bool

        init(
            generatorVersion: String,
            promptCatalogVersion: String = IntelligenceVersions.promptCatalog,
            providerIdentifier: String,
            modelIdentifier: String? = nil,
            generatedAt: Date = .now,
            basis: ContentBasis,
            usedFallback: Bool = false
        ) {
            self.generatorVersion = generatorVersion
            self.promptCatalogVersion = promptCatalogVersion
            self.providerIdentifier = providerIdentifier
            self.modelIdentifier = modelIdentifier
            self.generatedAt = generatedAt
            self.basis = basis
            self.usedFallback = usedFallback
        }
    }

    // MARK: - Lifecycle

    init(
        subject: ForecastSubject,
        anchor: ForecastAnchor,
        provenance: ExtendedProvenance,
        generationState: GenerationStateRecord,
        yearContext: YearContext? = nil,
        days: [DailyMood] = []
    ) {
        self.schemaVersion = Self.schemaVersion
        self.fingerprint = ProfileFingerprint(subject: subject, generatorVersion: provenance.generatorVersion)
        self.subject = SubjectRecord(subject: subject)
        self.astrology = AstrologyRecord(subject: subject)
        self.identity = IdentityRecord(subject: subject)
        self.forecast = ForecastRecord(
            startYear: anchor.startYear,
            startMonth: anchor.startMonth,
            startDay: anchor.startDay,
            days: days,
            yearContext: yearContext
        )
        self.provenance = provenance
        self.generationState = generationState
    }

    var anchor: ForecastAnchor { forecast.anchor }
    var days: [DailyMood] { forecast.days }

    func day(atOffset offset: Int) -> DailyMood? {
        forecast.days.first { $0.dayOffset == offset }
    }

    /// Whether this document was generated for the subject's current birth data
    /// and the current generator. Anything else is stale by definition (§15).
    func isStale(for subject: ForecastSubject) -> Bool {
        let expected = ProfileFingerprint(subject: subject, generatorVersion: provenance.generatorVersion)
        return fingerprint != expected
            || provenance.generatorVersion != Self.generatorVersion
    }

    func resolvedPhase(for subject: ForecastSubject) -> ForecastGenerationPhase {
        if isStale(for: subject) { return .stale }
        return GenerationStateRecord.resolvedPhase(
            chunks: generationState.chunks,
            fingerprintMatches: true,
            generatorMatches: true
        )
    }
}
