import Foundation

enum D4ContentSource: String, Sendable, Hashable {
    case productionUnavailable
    case developmentSample

    var isDevelopmentSample: Bool { self == .developmentSample }
}

enum ChartInputAvailability: Sendable, Hashable {
    case supplied(detail: String)
    case notProvided(detail: String)

    var isAvailable: Bool {
        if case .supplied = self { return true }
        return false
    }

    var label: String {
        switch self {
        case .supplied: "Supplied"
        case .notProvided: "Not provided"
        }
    }

    var detail: String {
        switch self {
        case .supplied(let detail), .notProvided(let detail): detail
        }
    }
}

enum ChartBirthTimeAvailability: Sendable, Hashable {
    case exact(detail: String)
    case approximate(detail: String)
    case unknown

    var label: String {
        switch self {
        case .exact: "Exact"
        case .approximate: "Approximate"
        case .unknown: "Unknown"
        }
    }

    var detail: String {
        switch self {
        case .exact(let detail), .approximate(let detail): detail
        case .unknown: "A clock time was not provided"
        }
    }
}

struct ChartReadiness: Sendable, Hashable {
    let birthDate: ChartInputAvailability
    let birthTime: ChartBirthTimeAvailability
    let birthPlace: ChartInputAvailability

    static let production = ChartReadiness(
        birthDate: .notProvided(detail: "Add a birth date to prepare a chart"),
        birthTime: .unknown,
        birthPlace: .notProvided(detail: "Add a birth place when precision needs it")
    )
}

enum ChartMissingInput: String, Sendable, Hashable {
    case birthDate
    case birthTime
    case birthPlace

    var label: String {
        switch self {
        case .birthDate: "Birth date"
        case .birthTime: "Birth time"
        case .birthPlace: "Birth place"
        }
    }
}

struct ChartAccessOffer: Sendable, Hashable {
    let title: String
    let detail: String
}

struct ChartLoadingContext: Sendable, Hashable {
    let title: String
    let detail: String
}

struct ChartOfflineContext: Sendable, Hashable {
    let title: String
    let detail: String
}

struct ChartUnsupportedMethodologyContext: Sendable, Hashable {
    let title: String
    let detail: String
}

struct ChartFailure: Sendable, Hashable {
    let title: String
    let detail: String
}

enum ChartPrecisionContext: Sendable, Hashable {
    case unknownTime(ChartUnknownTimeContext)
    case missingPlace(detail: String)
}

enum ChartWithheldFact: String, Sendable, Hashable, CaseIterable {
    case ascendant
    case houses
    case houseCusps

    var label: String {
        switch self {
        case .ascendant: "Ascendant"
        case .houses: "Houses"
        case .houseCusps: "House cusps"
        }
    }
}

struct ChartUnknownTimeContext: Sendable, Hashable {
    let dateLabel: String
    let readiness: ChartReadiness
    let knownFact: ChartPlacement
    let withheldFacts: [ChartWithheldFact]
    let explanation: String
}

enum ChartPoint: String, Sendable, Hashable, CaseIterable {
    case sun
    case moon
    case mercury
    case venus
    case mars
    case jupiter
    case saturn
    case ascendant

    var label: String {
        switch self {
        case .sun: "Sun"
        case .moon: "Moon"
        case .mercury: "Mercury"
        case .venus: "Venus"
        case .mars: "Mars"
        case .jupiter: "Jupiter"
        case .saturn: "Saturn"
        case .ascendant: "Ascendant"
        }
    }

    var symbol: String {
        switch self {
        case .sun: "sun.max.fill"
        case .moon: "moon.fill"
        case .mercury: "waveform.path.ecg"
        case .venus: "heart.fill"
        case .mars: "flame.fill"
        case .jupiter: "circle.dotted"
        case .saturn: "circle.dashed"
        case .ascendant: "arrow.up"
        }
    }
}

enum ChartHouse: Int, Sendable, Hashable, CaseIterable {
    case first = 1
    case second
    case third
    case fourth
    case fifth
    case sixth
    case seventh
    case eighth
    case ninth
    case tenth
    case eleventh
    case twelfth

    var label: String { "\(rawValue)\(rawValue == 1 ? "st" : rawValue == 2 ? "nd" : rawValue == 3 ? "rd" : "th") house" }
}

struct ChartPlacement: Identifiable, Sendable, Hashable {
    let point: ChartPoint
    let position: WesternZodiacPosition
    let house: ChartHouse?
    let reliability: AstrologyFactReliability
    let interpretationTitle: String
    let interpretationBody: String

    var id: ChartPoint { point }

    var degreeText: String { ChartDegreeFormatter.string(for: position.degreeWithinSign) }

    var factText: String {
        if let house {
            return "\(point.label) in \(position.sign.displayName) at \(degreeText), \(house.label)"
        }
        return "\(point.label) in \(position.sign.displayName) at \(degreeText)"
    }
}

struct ChartWheelPlacement: Identifiable, Sendable, Hashable {
    let point: ChartPoint
    let position: WesternZodiacPosition
    let house: ChartHouse?
    let reliability: AstrologyFactReliability

    var id: ChartPoint { point }
}

struct ChartWheelAspect: Identifiable, Sendable, Hashable {
    let firstPoint: ChartPoint
    let secondPoint: ChartPoint
    let kind: WesternAspectKind
    let orbDegrees: Double
    let reliability: AstrologyFactReliability

    var id: String { "\(firstPoint.rawValue)-\(secondPoint.rawValue)-\(kind.rawValue)" }
}

struct ChartWheelHouse: Identifiable, Sendable, Hashable {
    let number: ChartHouse
    let cuspLongitudeDegrees: Double

    var id: ChartHouse { number }
}

struct ChartWheelModel: Sendable, Hashable {
    let placements: [ChartWheelPlacement]
    let aspects: [ChartWheelAspect]
    let houses: [ChartWheelHouse]
    let selectedPoint: ChartPoint?

    var accessibilitySummary: String {
        let placementSummary = placements.map { placement in
            "\(placement.point.label) in \(placement.position.sign.displayName) at \(ChartDegreeFormatter.string(for: placement.position.degreeWithinSign))"
        }.joined(separator: ", ")
        let houseSummary = houses.isEmpty ? " Houses are not supplied." : " Houses are supplied for this known-time fixture."
        return "Western tropical chart wheel. \(placementSummary).\(houseSummary)"
    }
}

struct ChartBasis: Sendable, Hashable {
    let methodology: String
    let zodiac: String
    let date: String
    let time: String
    let place: String
}

struct ChartWesternModel: Sendable, Hashable {
    let basis: ChartBasis
    let wheel: ChartWheelModel
    let placements: [ChartPlacement]

    var bigThree: [ChartPlacement] {
        let wanted: [ChartPoint] = [.sun, .moon, .ascendant]
        return wanted.compactMap { point in placements.first(where: { $0.point == point }) }
    }

    func placement(for point: ChartPoint) -> ChartPlacement? {
        placements.first(where: { $0.point == point })
    }
}

enum ChartPayload: Sendable, Hashable {
    case western(ChartWesternModel)

    var western: ChartWesternModel? {
        if case .western(let model) = self { return model }
        return nil
    }
}

/// D4 presentation state. Calculation truth and access/cache state remain distinct.
enum D4FeatureState: Sendable, Hashable {
    case loading(ChartLoadingContext)
    case freePreview(ChartReadiness)
    case precisionLocked(offer: ChartAccessOffer, readiness: ChartReadiness)
    case generationAvailable(offer: ChartAccessOffer, readiness: ChartReadiness)
    case loaded(ChartPayload)
    case cached(ChartPayload, savedAt: Date)
    case offlineCached(ChartPayload, savedAt: Date)
    case offlineNoCache(ChartOfflineContext)
    case unsupportedMethodology(ChartUnsupportedMethodologyContext)
    case insufficientBirthPrecision(context: ChartPrecisionContext, missingInputs: [ChartMissingInput])
    case failed(ChartFailure)

    var payload: ChartPayload? {
        switch self {
        case .loaded(let payload), .cached(let payload, _), .offlineCached(let payload, _): payload
        case .loading, .freePreview, .precisionLocked, .generationAvailable,
             .offlineNoCache, .unsupportedMethodology, .insufficientBirthPrecision, .failed: nil
        }
    }
}

struct D4FeatureInput: Sendable, Hashable {
    let source: D4ContentSource
    let chart: D4FeatureState

    static let productionUnavailable = D4FeatureInput(
        source: .productionUnavailable,
        chart: .freePreview(.production)
    )
}

enum ChartProductCopy {
    static let freeTitle = "Your personal sky map"
    static let freeDescription = "A chart holds the details of your birth sky with care, context, and room for uncertainty."
    static let precisionTitle = "A more precise chart, when ready"
    static let precisionDescription = "Birth time and place help define the parts of a chart that cannot be responsibly guessed. Humay keeps those boundaries visible."
    static let freeBannerTitle = "Your chart starts with what you share"
    static let freeBannerDetail = "Add birth time and place to open more precise chart details. Until then, Humay keeps time-dependent facts open rather than guessing."
    static let loadedDescription = "Your chart is ready to explore."
}

enum ChartDegreeFormatter {
    static func string(for degree: Double) -> String {
        guard degree.isFinite else {
            return "00° 00′"
        }

        let clampedDegree = min(max(degree, 0), 30)
        let roundedMinutes = Int((clampedDegree * 60).rounded())
        let totalMinutes = min(max(roundedMinutes, 0), 1_799)
        let wholeDegrees = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d° %02d′", wholeDegrees, minutes)
    }
}

enum ChartReliabilityFormatter {
    static func string(for reliability: AstrologyFactReliability) -> String {
        switch reliability {
        case .reliable: "Reliable"
        case .uncertain(.approximateBirthTime): "Approximate birth time"
        case .uncertain(.boundarySensitive): "Boundary-sensitive"
        case .unavailable(.missingBirthTime): "Unavailable without birth time"
        case .unavailable(.missingBirthPlace): "Unavailable without birth place"
        case .unavailable(.insufficientBirthPrecision): "Insufficient birth precision"
        case .unavailable(.methodologyNotApproved): "Methodology not approved"
        case .unavailable(.unsupportedByCalculationBoundary): "Outside calculation boundary"
        }
    }
}
