import Foundation
import Testing
@testable import Humay

@Suite("ASTRO-003 Western fact foundation")
struct WesternAstrologyFactsTests {
    @Test("Tropical longitude resolves to the expected sign and within-sign degree")
    func longitudeResolvesSign() throws {
        let aries = try WesternZodiacPosition(longitudeDegrees: 0)
        let taurus = try WesternZodiacPosition(longitudeDegrees: 30)
        let pisces = try WesternZodiacPosition(longitudeDegrees: 359.5)

        #expect(aries.sign == .aries)
        #expect(aries.degreeWithinSign == 0)
        #expect(taurus.sign == .taurus)
        #expect(taurus.degreeWithinSign == 0)
        #expect(pisces.sign == .pisces)
        #expect(pisces.degreeWithinSign == 29.5)
    }

    @Test("Longitude must be finite and inside one tropical circle")
    func longitudeValidation() {
        let invalidLongitudes: [Double] = [-0.0001, 360, .infinity, -.infinity, .nan]

        for value in invalidLongitudes {
            #expect(throws: WesternAstrologyFactValidationError.invalidLongitude) {
                try WesternZodiacPosition(longitudeDegrees: value)
            }
        }
    }

    @Test("Planetary position preserves fact reliability")
    func planetaryReliabilityIsPreserved() throws {
        let position = WesternPlanetaryPosition(
            planet: .moon,
            position: try WesternZodiacPosition(longitudeDegrees: 91.25),
            reliability: .uncertain(.approximateBirthTime)
        )

        let fact = WesternAstrologyFact.planetaryPosition(position)

        #expect(fact.reliability == .uncertain(.approximateBirthTime))
    }

    @Test("Aspect requires different bodies and a finite nonnegative orb")
    func aspectValidation() throws {
        #expect(throws: WesternAstrologyFactValidationError.identicalAspectBodies) {
            try WesternAspect(
                kind: .conjunction,
                firstPlanet: .sun,
                secondPlanet: .sun,
                orbDegrees: 0
            )
        }

        let invalidOrbs: [Double] = [-0.1, .infinity, .nan]
        for orb in invalidOrbs {
            #expect(throws: WesternAstrologyFactValidationError.invalidAspectOrb) {
                try WesternAspect(
                    kind: .trine,
                    firstPlanet: .sun,
                    secondPlanet: .moon,
                    orbDegrees: orb
                )
            }
        }

        let valid = try WesternAspect(
            kind: .square,
            firstPlanet: .sun,
            secondPlanet: .moon,
            orbDegrees: 1.75,
            reliability: .reliable
        )
        #expect(valid.orbDegrees == 1.75)
    }

    @Test("Western normalized result accepts unique planets and aspect pairs")
    func resultValidationAcceptsCoherentFacts() throws {
        let sun = WesternPlanetaryPosition(
            planet: .sun,
            position: try WesternZodiacPosition(longitudeDegrees: 17.2)
        )
        let moon = WesternPlanetaryPosition(
            planet: .moon,
            position: try WesternZodiacPosition(longitudeDegrees: 107.8)
        )
        let aspect = try WesternAspect(
            kind: .square,
            firstPlanet: .sun,
            secondPlanet: .moon,
            orbDegrees: 0.6
        )

        let result: AstrologyCalculationResult<WesternAstrologyFact> = AstrologyCalculationResult(
            tradition: .western,
            provenance: validProvenance(),
            calculatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            facts: [
                .planetaryPosition(sun),
                .planetaryPosition(moon),
                .aspect(aspect)
            ]
        )

        try WesternCalculationResultValidator.validate(result)
    }

    @Test("Western normalized result rejects duplicate planetary positions")
    func duplicatePlanetIsRejected() throws {
        let first = WesternPlanetaryPosition(
            planet: .sun,
            position: try WesternZodiacPosition(longitudeDegrees: 17.2)
        )
        let second = WesternPlanetaryPosition(
            planet: .sun,
            position: try WesternZodiacPosition(longitudeDegrees: 18.2)
        )
        let result: AstrologyCalculationResult<WesternAstrologyFact> = AstrologyCalculationResult(
            tradition: .western,
            provenance: validProvenance(),
            calculatedAt: .now,
            facts: [.planetaryPosition(first), .planetaryPosition(second)]
        )

        #expect(throws: AstrologyCalculationError.validationFailed) {
            try WesternCalculationResultValidator.validate(result)
        }
    }

    @Test("Western normalized result rejects duplicate aspect pairs regardless of order")
    func duplicateAspectPairIsRejected() throws {
        let first = try WesternAspect(
            kind: .square,
            firstPlanet: .sun,
            secondPlanet: .moon,
            orbDegrees: 1
        )
        let reversed = try WesternAspect(
            kind: .square,
            firstPlanet: .moon,
            secondPlanet: .sun,
            orbDegrees: 1
        )
        let result: AstrologyCalculationResult<WesternAstrologyFact> = AstrologyCalculationResult(
            tradition: .western,
            provenance: validProvenance(),
            calculatedAt: .now,
            facts: [.aspect(first), .aspect(reversed)]
        )

        #expect(throws: AstrologyCalculationError.validationFailed) {
            try WesternCalculationResultValidator.validate(result)
        }
    }

    @Test("Western result validator rejects wrong tradition and blank provenance")
    func resultBoundaryValidation() throws {
        let resultWithWrongTradition = AstrologyCalculationResult<WesternAstrologyFact>(
            tradition: .vedic,
            provenance: validProvenance(),
            calculatedAt: .now,
            facts: []
        )

        #expect(throws: AstrologyCalculationError.unsupportedMethodology) {
            try WesternCalculationResultValidator.validate(resultWithWrongTradition)
        }

        let blankProvenance = AstrologyCalculationProvenance(
            calculationContractVersion: " ",
            methodologyVersion: "western-tropical-v1",
            adapterIdentifier: "test-western"
        )
        let resultWithBlankProvenance = AstrologyCalculationResult<WesternAstrologyFact>(
            tradition: .western,
            provenance: blankProvenance,
            calculatedAt: .now,
            facts: []
        )

        #expect(throws: AstrologyCalculationError.validationFailed) {
            try WesternCalculationResultValidator.validate(resultWithBlankProvenance)
        }
    }

    private func validProvenance() -> AstrologyCalculationProvenance {
        AstrologyCalculationProvenance(
            calculationContractVersion: "1",
            methodologyVersion: "western-tropical-v1",
            adapterIdentifier: "test-western"
        )
    }
}
