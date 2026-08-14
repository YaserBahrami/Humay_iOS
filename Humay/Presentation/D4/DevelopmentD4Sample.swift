#if DEBUG
import Foundation

enum DevelopmentD4Sample {
    static let knownTimeReadiness = ChartReadiness(
        birthDate: .supplied(detail: "14 March 1994"),
        birthTime: .exact(detail: "Known-time fixture"),
        birthPlace: .supplied(detail: "Known-time fixture")
    )

    static let unknownTimeReadiness = ChartReadiness(
        birthDate: .supplied(detail: "14 March 1994"),
        birthTime: .unknown,
        birthPlace: .notProvided(detail: "A place was not provided")
    )

    static let knownTimeChart: ChartPayload = .western(
        ChartWesternModel(
            basis: ChartBasis(
                methodology: "Western",
                zodiac: "Tropical",
                date: "14 March 1994",
                time: "Known-time fixture",
                place: "Known-time fixture"
            ),
            wheel: ChartWheelModel(
                placements: knownPlacements.map {
                    ChartWheelPlacement(
                        point: $0.point,
                        position: $0.position,
                        house: $0.house,
                        reliability: $0.reliability
                    )
                },
                aspects: [
                    ChartWheelAspect(
                        firstPoint: .sun,
                        secondPoint: .moon,
                        kind: .trine,
                        orbDegrees: 7.73,
                        reliability: .reliable
                    ),
                    ChartWheelAspect(
                        firstPoint: .moon,
                        secondPoint: .venus,
                        kind: .square,
                        orbDegrees: 4.25,
                        reliability: .reliable
                    )
                ],
                houses: (1...12).compactMap { number in
                    guard let house = ChartHouse(rawValue: number) else { return nil }
                    return ChartWheelHouse(
                        number: house,
                        cuspLongitudeDegrees: Double(number - 1) * 30
                    )
                },
                selectedPoint: .moon
            ),
            placements: knownPlacements
        )
    )

    static let unknownTimeContext = ChartUnknownTimeContext(
        dateLabel: "14 March 1994",
        readiness: unknownTimeReadiness,
        knownFact: ChartPlacement(
            point: .sun,
            position: position(322.1833),
            house: nil,
            reliability: .reliable,
            interpretationTitle: "A date-valid starting point.",
            interpretationBody: "The Sun sign is shown because it is supported by the supplied date. Other precision-dependent facts stay withheld."
        ),
        withheldFacts: [.ascendant, .houses, .houseCusps],
        explanation: "No time or place was supplied. Humay does not substitute noon, midnight, sunrise, or another guessed time."
    )

    static func makeInput(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> D4FeatureInput {
        let state = argumentValue(named: "-HumayD4ChartState", arguments: arguments)?.lowercased()

        switch state {
        case "loading":
            return sample(.loading(ChartLoadingContext(
                title: "Preparing your sky map",
                detail: "Chart facts will appear when the calculation boundary is ready."
            )))
        case "locked":
            return sample(.precisionLocked(
                offer: ChartAccessOffer(
                    title: "Precision chart access",
                    detail: "A fuller chart is ready for the next access step."
                ),
                readiness: knownTimeReadiness
            ))
        case "available":
            return sample(.generationAvailable(
                offer: ChartAccessOffer(
                    title: "Your chart is ready to generate",
                    detail: "Your supplied birth details meet the current precision boundary."
                ),
                readiness: knownTimeReadiness
            ))
        case "loaded":
            return sample(.loaded(knownTimeChart))
        case "cached":
            return sample(.cached(knownTimeChart, savedAt: savedAt))
        case "offline":
            return sample(.offlineCached(knownTimeChart, savedAt: savedAt))
        case "offline-empty":
            return sample(.offlineNoCache(ChartOfflineContext(
                title: "No saved chart is available",
                detail: "Connect again when you are ready to create a chart. Nothing was guessed or queued."
            )))
        case "unsupported":
            return sample(.unsupportedMethodology(ChartUnsupportedMethodologyContext(
                title: "This chart method is not available yet",
                detail: "Humay is keeping the methodology boundary explicit while this path is reviewed."
            )))
        case "unknown-time":
            return sample(.insufficientBirthPrecision(
                context: .unknownTime(unknownTimeContext),
                missingInputs: [.birthTime, .birthPlace]
            ))
        case "failed":
            return sample(.failed(ChartFailure(
                title: "Chart unavailable right now",
                detail: "Try again later. Your supplied details were not changed."
            )))
        case "free", nil, "":
            return sample(.freePreview(knownTimeReadiness))
        default:
            return sample(.freePreview(knownTimeReadiness))
        }
    }

    private static let savedAt = Date(timeIntervalSince1970: 1_710_432_000)

    private static func sample(_ state: D4FeatureState) -> D4FeatureInput {
        D4FeatureInput(source: .developmentSample, chart: state)
    }

    private static func argumentValue(named name: String, arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private static func position(_ longitude: Double) -> WesternZodiacPosition {
        try! WesternZodiacPosition(longitudeDegrees: longitude)
    }

    private static func placement(
        _ point: ChartPoint,
        longitude: Double,
        house: ChartHouse?,
        interpretationTitle: String,
        interpretationBody: String
    ) -> ChartPlacement {
        ChartPlacement(
            point: point,
            position: position(longitude),
            house: house,
            reliability: .reliable,
            interpretationTitle: interpretationTitle,
            interpretationBody: interpretationBody
        )
    }

    private static let knownPlacements: [ChartPlacement] = [
        placement(
            .sun,
            longitude: 322.1833,
            house: .eleventh,
            interpretationTitle: "A clear center.",
            interpretationBody: "The Sun placement is a factual anchor in this development fixture. Interpretation remains separate from the supplied position."
        ),
        placement(
            .moon,
            longitude: 194.45,
            house: .fifth,
            interpretationTitle: "Room for response.",
            interpretationBody: "The Moon in Libra is presented as a reflective placement: notice balance, response, and the space between impulse and choice."
        ),
        placement(
            .mercury,
            longitude: 31.3,
            house: .tenth,
            interpretationTitle: "A practical voice.",
            interpretationBody: "This sample interpretation is editorial scaffolding only; the displayed degree remains the source fact."
        ),
        placement(
            .venus,
            longitude: 108.7,
            house: .eighth,
            interpretationTitle: "A warm value system.",
            interpretationBody: "This sample interpretation stays subordinate to the factual placement above."
        ),
        placement(
            .mars,
            longitude: 217.9167,
            house: .twelfth,
            interpretationTitle: "A focused current.",
            interpretationBody: "This sample interpretation is not a calculation result or a personal claim."
        ),
        placement(
            .jupiter,
            longitude: 282.15,
            house: .second,
            interpretationTitle: "A wider horizon.",
            interpretationBody: "This development fixture keeps meaning readable without presenting it as provider output."
        ),
        placement(
            .saturn,
            longitude: 356.2167,
            house: .sixth,
            interpretationTitle: "A patient structure.",
            interpretationBody: "Interpretation is intentionally restrained until production methodology is approved."
        ),
        placement(
            .ascendant,
            longitude: 63.0333,
            house: .first,
            interpretationTitle: "A first impression.",
            interpretationBody: "The Ascendant is included only inside this explicit known-time development fixture."
        )
    ]
}
#endif
