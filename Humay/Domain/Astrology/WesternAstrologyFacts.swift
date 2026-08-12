import Foundation

/// The initial Western bodies Humay normalizes for the production baseline.
///
/// Additional points (nodes, Chiron, asteroids, etc.) are intentionally excluded until
/// a feature and methodology decision require them.
enum WesternPlanet: String, CaseIterable, Sendable, Hashable {
    case sun
    case moon
    case mercury
    case venus
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
    case pluto
}

/// Tropical zodiac signs in ecliptic-longitude order.
enum WesternZodiacSign: String, CaseIterable, Sendable, Hashable {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces
}

/// A normalized tropical ecliptic position.
///
/// The calculation adapter is responsible for normalizing provider values into
/// `[0, 360)`. Domain rejects non-finite and out-of-range longitudes rather than
/// silently wrapping malformed provider output.
struct WesternZodiacPosition: Sendable, Hashable {
    let longitudeDegrees: Double

    init(longitudeDegrees: Double) throws {
        guard longitudeDegrees.isFinite,
              longitudeDegrees >= 0,
              longitudeDegrees < 360 else {
            throw WesternAstrologyFactValidationError.invalidLongitude
        }

        self.longitudeDegrees = longitudeDegrees
    }

    var sign: WesternZodiacSign {
        WesternZodiacSign.allCases[Int(longitudeDegrees / 30)]
    }

    var degreeWithinSign: Double {
        longitudeDegrees.truncatingRemainder(dividingBy: 30)
    }
}

struct WesternPlanetaryPosition: Sendable, Hashable {
    let planet: WesternPlanet
    let position: WesternZodiacPosition
    let reliability: AstrologyFactReliability

    init(
        planet: WesternPlanet,
        position: WesternZodiacPosition,
        reliability: AstrologyFactReliability = .reliable
    ) {
        self.planet = planet
        self.position = position
        self.reliability = reliability
    }
}

/// Initial major-aspect vocabulary for the Western baseline.
///
/// This defines normalized result vocabulary only. It deliberately does not define
/// orb thresholds or decide which aspects an engine should emit; those are methodology
/// and validation concerns rather than vendor defaults.
enum WesternAspectKind: String, CaseIterable, Sendable, Hashable {
    case conjunction
    case opposition
    case trine
    case square
    case sextile
}

struct WesternAspect: Sendable, Hashable {
    let kind: WesternAspectKind
    let firstPlanet: WesternPlanet
    let secondPlanet: WesternPlanet
    let orbDegrees: Double
    let reliability: AstrologyFactReliability

    init(
        kind: WesternAspectKind,
        firstPlanet: WesternPlanet,
        secondPlanet: WesternPlanet,
        orbDegrees: Double,
        reliability: AstrologyFactReliability = .reliable
    ) throws {
        guard firstPlanet != secondPlanet else {
            throw WesternAstrologyFactValidationError.identicalAspectBodies
        }
        guard orbDegrees.isFinite, orbDegrees >= 0 else {
            throw WesternAstrologyFactValidationError.invalidAspectOrb
        }

        self.kind = kind
        self.firstPlanet = firstPlanet
        self.secondPlanet = secondPlanet
        self.orbDegrees = orbDegrees
        self.reliability = reliability
    }
}

/// Concrete Western facts available before house-system methodology is signed off.
///
/// Ascendant and house-cusp facts are intentionally not added yet: METHOD-001 remains
/// open, so ASTRO-003 must not freeze or imply a production house-system decision.
enum WesternAstrologyFact: AstrologyCalculationFact {
    case planetaryPosition(WesternPlanetaryPosition)
    case aspect(WesternAspect)

    var reliability: AstrologyFactReliability {
        switch self {
        case .planetaryPosition(let fact): fact.reliability
        case .aspect(let fact): fact.reliability
        }
    }
}

enum WesternAstrologyFactValidationError: Error, Equatable, Sendable {
    case invalidLongitude
    case identicalAspectBodies
    case invalidAspectOrb
}
