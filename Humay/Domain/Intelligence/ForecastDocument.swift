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
    var provenance: ExtendedProvenance
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

    /// Deterministic astrology identity — now Sun/Moon/Rising from the offline
    /// Big Three calculator. AI never fills them (§3). Facts carry numeric
    /// longitude where available; formatting belongs to Presentation.
    struct AstrologyRecord: Sendable, Hashable, Codable {
        let sunSign: String?
        let sunLongitude: Double?
        let sunDegreeWithinSign: Double?
        let moonSign: String?
        let moonLongitude: Double?
        let moonDegreeWithinSign: Double?
        let moonAmbiguousOptions: [String]?
        let risingSign: String?
        let risingLongitude: Double?
        let risingDegreeWithinSign: Double?
        let calculationVersion: String
        let engineIdentifier: String?
        let zodiacSystem: String?
        let calculatedAt: Date?

        init(subject: ForecastSubject) {
            if let bigThree = subject.bigThree() {
                switch bigThree.sun {
                case .available(let pos):
                    sunSign = pos.sign.rawValue
                    sunLongitude = pos.longitudeDegrees
                    sunDegreeWithinSign = pos.degreeWithinSign
                case .ambiguous(let opts):
                    sunSign = opts.first?.sign.rawValue
                    sunLongitude = opts.first?.longitudeDegrees
                    sunDegreeWithinSign = opts.first?.degreeWithinSign
                case .unavailable:
                    sunSign = subject.sunSign?.rawValue
                    sunLongitude = nil
                    sunDegreeWithinSign = nil
                }
                switch bigThree.moon {
                case .available(let pos):
                    moonSign = pos.sign.rawValue
                    moonLongitude = pos.longitudeDegrees
                    moonDegreeWithinSign = pos.degreeWithinSign
                    moonAmbiguousOptions = nil
                case .ambiguous(let opts):
                    moonSign = nil
                    moonLongitude = nil
                    moonDegreeWithinSign = nil
                    moonAmbiguousOptions = opts.map(\.sign.rawValue)
                case .unavailable:
                    moonSign = nil
                    moonLongitude = nil
                    moonDegreeWithinSign = nil
                    moonAmbiguousOptions = nil
                }
                switch bigThree.rising {
                case .available(let pos):
                    risingSign = pos.sign.rawValue
                    risingLongitude = pos.longitudeDegrees
                    risingDegreeWithinSign = pos.degreeWithinSign
                case .ambiguous(let opts):
                    risingSign = opts.first?.sign.rawValue
                    risingLongitude = opts.first?.longitudeDegrees
                    risingDegreeWithinSign = opts.first?.degreeWithinSign
                case .unavailable:
                    risingSign = nil
                    risingLongitude = nil
                    risingDegreeWithinSign = nil
                }
                calculationVersion = bigThree.metadata.calculatorVersion
                engineIdentifier = bigThree.metadata.astronomyEngineIdentifier
                zodiacSystem = bigThree.metadata.zodiacSystem.rawValue
                calculatedAt = bigThree.metadata.calculatedAt
            } else {
                // Invalid input fallback — preserve date-table Sun if possible.
                sunSign = subject.sunSign?.rawValue
                sunLongitude = nil
                sunDegreeWithinSign = nil
                moonSign = nil
                moonLongitude = nil
                moonDegreeWithinSign = nil
                moonAmbiguousOptions = nil
                risingSign = nil
                risingLongitude = nil
                risingDegreeWithinSign = nil
                calculationVersion = IntelligenceVersions.astrologyCalculation
                engineIdentifier = nil
                zodiacSystem = ZodiacSystem.tropical.rawValue
                calculatedAt = nil
            }
        }

        enum CodingKeys: String, CodingKey {
            case sunSign, sunLongitude, sunDegreeWithinSign
            case moonSign, moonLongitude, moonDegreeWithinSign, moonAmbiguousOptions
            case risingSign, risingLongitude, risingDegreeWithinSign
            case calculationVersion, engineIdentifier, zodiacSystem, calculatedAt
        }

        init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            sunSign = try c.decodeIfPresent(String.self, forKey: .sunSign)
            sunLongitude = try c.decodeIfPresent(Double.self, forKey: .sunLongitude)
            sunDegreeWithinSign = try c.decodeIfPresent(Double.self, forKey: .sunDegreeWithinSign)
            moonSign = try c.decodeIfPresent(String.self, forKey: .moonSign)
            moonLongitude = try c.decodeIfPresent(Double.self, forKey: .moonLongitude)
            moonDegreeWithinSign = try c.decodeIfPresent(Double.self, forKey: .moonDegreeWithinSign)
            moonAmbiguousOptions = try c.decodeIfPresent([String].self, forKey: .moonAmbiguousOptions)
            risingSign = try c.decodeIfPresent(String.self, forKey: .risingSign)
            risingLongitude = try c.decodeIfPresent(Double.self, forKey: .risingLongitude)
            risingDegreeWithinSign = try c.decodeIfPresent(Double.self, forKey: .risingDegreeWithinSign)
            calculationVersion = try c.decodeIfPresent(String.self, forKey: .calculationVersion) ?? IntelligenceVersions.astrologyCalculation
            engineIdentifier = try c.decodeIfPresent(String.self, forKey: .engineIdentifier)
            zodiacSystem = try c.decodeIfPresent(String.self, forKey: .zodiacSystem)
            calculatedAt = try c.decodeIfPresent(Date.self, forKey: .calculatedAt)
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
    /// I.2.1 adds packVersion/contentCycleVersion for bundled lifecycle staleness (§40-42).
    struct ExtendedProvenance: Sendable, Hashable, Codable {
        let generatorVersion: String
        let promptCatalogVersion: String
        let providerIdentifier: String
        let modelIdentifier: String?
        let generatedAt: Date
        let basis: ContentBasis
        let usedFallback: Bool
        let packVersion: String?
        let contentCycleVersion: String?

        init(
            generatorVersion: String,
            promptCatalogVersion: String = IntelligenceVersions.promptCatalog,
            providerIdentifier: String,
            modelIdentifier: String? = nil,
            generatedAt: Date = .now,
            basis: ContentBasis,
            usedFallback: Bool = false,
            packVersion: String? = nil,
            contentCycleVersion: String? = nil
        ) {
            self.generatorVersion = generatorVersion
            self.promptCatalogVersion = promptCatalogVersion
            self.providerIdentifier = providerIdentifier
            self.modelIdentifier = modelIdentifier
            self.generatedAt = generatedAt
            self.basis = basis
            self.usedFallback = usedFallback
            self.packVersion = packVersion
            self.contentCycleVersion = contentCycleVersion
        }

        enum CodingKeys: String, CodingKey {
            case generatorVersion, promptCatalogVersion, providerIdentifier, modelIdentifier, generatedAt, basis, usedFallback, packVersion, contentCycleVersion
        }

        init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            generatorVersion = try c.decode(String.self, forKey: .generatorVersion)
            promptCatalogVersion = try c.decodeIfPresent(String.self, forKey: .promptCatalogVersion) ?? IntelligenceVersions.promptCatalog
            providerIdentifier = try c.decode(String.self, forKey: .providerIdentifier)
            modelIdentifier = try c.decodeIfPresent(String.self, forKey: .modelIdentifier)
            generatedAt = try c.decodeIfPresent(Date.self, forKey: .generatedAt) ?? Date.now
            basis = try c.decodeIfPresent(ContentBasis.self, forKey: .basis) ?? .entertainmentFixture
            usedFallback = try c.decodeIfPresent(Bool.self, forKey: .usedFallback) ?? false
            packVersion = try c.decodeIfPresent(String.self, forKey: .packVersion)
            contentCycleVersion = try c.decodeIfPresent(String.self, forKey: .contentCycleVersion)
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
    /// and the indicated generator. Anything else is stale by definition (§15).
    func isStale(for subject: ForecastSubject) -> Bool {
        isStale(for: subject, currentGeneratorVersion: nil)
    }

    func isStale(for subject: ForecastSubject, currentGeneratorVersion: String?) -> Bool {
        let effectiveGenerator = currentGeneratorVersion ?? provenance.generatorVersion
        let expected = ProfileFingerprint(subject: subject, generatorVersion: effectiveGenerator)
        // Fingerprint mismatch captures both birth-data and generator-version changes.
        // If caller supplied a currentGeneratorVersion that differs from the stored
        // provenance, the fingerprint will differ and the doc is stale.
        if fingerprint != expected { return true }
        // Also stale if stored provenance generator differs from current when supplied.
        if let current = currentGeneratorVersion, provenance.generatorVersion != current { return true }
        // Legacy check against static deterministic version only for deterministic docs.
        // Remote docs carry their own generatorVersion and are not compared to static.
        if provenance.providerIdentifier == PersonalizedContentProviderDescriptor.deterministicIdentifier
            || provenance.providerIdentifier == "pending" {
            if provenance.generatorVersion != Self.generatorVersion { return true }
        }
        return false
    }

    /// Bundled content-cycle staleness (§40-42): a persisted bundled or mixed document must become
    /// stale if originating cycle != currently installed active cycle, pack inactive, or pack unavailable.
    /// Pure deterministic docs are unaffected appropriately.
    func isStaleDueToContentCycle(currentContentCycleVersion: String?, currentPackVersion: String?, isBundledAvailable: Bool, isPackActive: Bool) -> Bool {
        // Only bundled/mixed docs (aiGenerated basis) are subject to pack lifecycle.
        guard case .aiGenerated = provenance.basis else { return false }
        // If current bundle unavailable or inactive, bundled content is stale (must fallback to deterministic)
        if !isBundledAvailable || !isPackActive { return true }
        // If we stored a cycle and it differs from current, stale
        if let stored = provenance.contentCycleVersion, let current = currentContentCycleVersion, stored != current { return true }
        // Pack version semantic incompatibility: if stored != current, consider stale (conservative)
        if let storedPack = provenance.packVersion, let currentPack = currentPackVersion, storedPack != currentPack {
            // Check major version change as incompatible; for now any mismatch is stale to avoid masquerading old content
            if storedPack != currentPack { return true }
        }
        return false
    }

    /// Combined staleness including both fingerprint and content-cycle (§41).
    func isStaleForCurrentState(subject: ForecastSubject, provider: any PersonalizedContentProviding, bundledRepository: BundledContentPackRepository) -> Bool {
        if isStale(for: subject, currentGeneratorVersion: provider.descriptor.generatorVersion) { return true }
        let manifest = bundledRepository.manifest
        let isAvailable = bundledRepository.isAvailable
        let isActive = manifest?.isActive(on: Date()) ?? false
        // Pilot bundles are always active; but Hybrid descriptor may be bundled-ai-v1 even if pilot. In pilot we don't enforce cycle staleness beyond fingerprint.
        if manifest?.coverage.isPilot == true { return false }
        return isStaleDueToContentCycle(currentContentCycleVersion: manifest?.contentCycleVersion, currentPackVersion: manifest?.packVersion, isBundledAvailable: isAvailable, isPackActive: isActive)
    }

    func resolvedPhase(for subject: ForecastSubject) -> ForecastGenerationPhase {
        if isStale(for: subject) { return .stale }
        return GenerationStateRecord.resolvedPhase(
            chunks: generationState.chunks,
            fingerprintMatches: true,
            generatorMatches: true
        )
    }

    func resolvedPhase(for subject: ForecastSubject, currentGeneratorVersion: String?) -> ForecastGenerationPhase {
        if isStale(for: subject, currentGeneratorVersion: currentGeneratorVersion) { return .stale }
        return GenerationStateRecord.resolvedPhase(
            chunks: generationState.chunks,
            fingerprintMatches: true,
            generatorMatches: true
        )
    }
}
