import Foundation

/// Domain-level structural validation for normalized Western calculation results.
///
/// This is intentionally narrower than astronomical validation. It verifies that a
/// normalized result is internally coherent before feature code can consume it. Golden
/// fixture accuracy remains ASTRO-006/provider-validation work.
enum WesternCalculationResultValidator {
    static func validate(
        _ result: AstrologyCalculationResult<WesternAstrologyFact>
    ) throws {
        guard result.tradition == .western else {
            throw AstrologyCalculationError.unsupportedMethodology
        }

        guard isNonblank(result.provenance.calculationContractVersion),
              isNonblank(result.provenance.methodologyVersion),
              isNonblank(result.provenance.adapterIdentifier) else {
            throw AstrologyCalculationError.validationFailed
        }

        var seenPlanets = Set<WesternPlanet>()
        var seenAspectPairs = Set<AspectPair>()

        for fact in result.facts {
            switch fact {
            case .planetaryPosition(let position):
                guard seenPlanets.insert(position.planet).inserted else {
                    throw AstrologyCalculationError.validationFailed
                }

            case .aspect(let aspect):
                let pair = AspectPair(aspect.firstPlanet, aspect.secondPlanet)
                guard seenAspectPairs.insert(pair).inserted else {
                    throw AstrologyCalculationError.validationFailed
                }
            }
        }
    }

    private static func isNonblank(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private struct AspectPair: Hashable {
        let first: WesternPlanet
        let second: WesternPlanet

        init(_ first: WesternPlanet, _ second: WesternPlanet) {
            if first.rawValue < second.rawValue {
                self.first = first
                self.second = second
            } else {
                self.first = second
                self.second = first
            }
        }
    }
}
