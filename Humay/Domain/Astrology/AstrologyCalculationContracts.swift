import Foundation

/// Confidence/availability state attached to a normalized Humay calculation fact.
///
/// Reliability is part of the deterministic result contract. Presentation may use it
/// to qualify or withhold a fact, but it must never replace an unavailable fact with a
/// guess.
enum AstrologyFactReliability: Sendable, Hashable {
    case reliable
    case uncertain(AstrologyFactUncertainty)
    case unavailable(AstrologyFactUnavailability)
}

/// Why a fact cannot be treated as fully reliable with the supplied inputs.
enum AstrologyFactUncertainty: Sendable, Hashable {
    case approximateBirthTime
    case boundarySensitive
}

/// Why a deterministic fact is not available to consumers.
enum AstrologyFactUnavailability: Sendable, Hashable {
    case missingBirthTime
    case missingBirthPlace
    case insufficientBirthPrecision
    case methodologyNotApproved
    case unsupportedByCalculationBoundary
}

/// Reproducibility metadata for a normalized Humay calculation result.
///
/// Values identify Humay-owned contract/methodology/adapter versions. They are not a
/// passthrough for vendor response payloads.
struct AstrologyCalculationProvenance: Sendable, Hashable {
    let calculationContractVersion: String
    let methodologyVersion: String
    let adapterIdentifier: String
    let engineVersion: String?
    let configurationVersion: String?

    init(
        calculationContractVersion: String,
        methodologyVersion: String,
        adapterIdentifier: String,
        engineVersion: String? = nil,
        configurationVersion: String? = nil
    ) {
        self.calculationContractVersion = calculationContractVersion
        self.methodologyVersion = methodologyVersion
        self.adapterIdentifier = adapterIdentifier
        self.engineVersion = engineVersion
        self.configurationVersion = configurationVersion
    }
}

/// Marker contract for a normalized Humay calculation fact.
///
/// Concrete Western/Vedic/BaZi fact shapes are introduced only by the owning
/// calculation tasks. This prevents ASTRO-002 from freezing a speculative universal
/// fact schema while still requiring every fact to expose reliability explicitly.
protocol AstrologyCalculationFact: Sendable, Hashable {
    var reliability: AstrologyFactReliability { get }
}

/// Provider-independent envelope returned by a calculation boundary.
///
/// The generic fact type keeps each methodology family strongly typed without leaking
/// provider-native response models into Domain or Presentation.
struct AstrologyCalculationResult<Fact: AstrologyCalculationFact>: Sendable, Hashable {
    let tradition: AstrologyTradition
    let provenance: AstrologyCalculationProvenance
    let calculatedAt: Date
    let facts: [Fact]

    init(
        tradition: AstrologyTradition,
        provenance: AstrologyCalculationProvenance,
        calculatedAt: Date,
        facts: [Fact]
    ) {
        self.tradition = tradition
        self.provenance = provenance
        self.calculatedAt = calculatedAt
        self.facts = facts
    }
}

/// Humay-owned calculation failures. Raw vendor/network errors do not cross this
/// boundary and sensitive input values are never carried by these cases.
enum AstrologyCalculationError: Error, Hashable, Sendable {
    case invalidInput
    case insufficientBirthPrecision
    case unsupportedMethodology
    case unavailable
    case requestRejected
    case malformedResponse
    case validationFailed
    case methodologyGateDisabled
}
