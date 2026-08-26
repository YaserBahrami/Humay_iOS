import Foundation

// MARK: - Availability

/// Explicit availability of a deterministic astrology value.
///
/// Humay never represents "unknown time, rising guess" as `nil` or an optional
/// string — the reason is part of the result so UI and AI can branch honestly.
enum AstrologyAvailability<T: Sendable & Hashable & Codable>: Sendable, Hashable, Codable {
    case available(T)
    case unavailable(reason: AstrologyUnavailabilityReason)
    case ambiguous(options: [T])
}

enum AstrologyUnavailabilityReason: String, Sendable, Hashable, Codable {
    case missingBirthTime
    case missingBirthPlace
    case insufficientBirthPrecision
    case invalidInput
    case calculationUnavailable
}

extension AstrologyAvailability {
    var value: T? {
        if case .available(let v) = self { return v }
        return nil
    }

    var isAvailable: Bool {
        if case .available = self { return true }
        return false
    }
}

// MARK: - Position

/// A tropical ecliptic position used by the Big Three.
///
/// Longitude is absolute `[0, 360)`. Sign and degree are derived, stored
/// numerically (never as a preformatted string) so Presentation can format and
/// AI can include degree context without parsing.
struct BigThreePosition: Sendable, Hashable, Codable {
    let sign: WesternZodiacSign
    let longitudeDegrees: Double
    let degreeWithinSign: Double

    init(longitudeDegrees: Double) throws {
        guard longitudeDegrees.isFinite,
              longitudeDegrees >= 0,
              longitudeDegrees < 360 else {
            throw BigThreeCalculationError.invalidLongitude
        }
        self.longitudeDegrees = longitudeDegrees
        let idx = Int(longitudeDegrees / 30)
        self.sign = WesternZodiacSign.allCases[idx]
        self.degreeWithinSign = longitudeDegrees.truncatingRemainder(dividingBy: 30)
    }

    init(sign: WesternZodiacSign, longitudeDegrees: Double) {
        // Internal convenience when sign is already known to be correct.
        self.sign = sign
        self.longitudeDegrees = longitudeDegrees
        self.degreeWithinSign = longitudeDegrees.truncatingRemainder(dividingBy: 30)
    }
}

// MARK: - Zodiac system

enum ZodiacSystem: String, Sendable, Hashable, Codable {
    case tropical
}

// MARK: - Calculation metadata

struct BigThreeCalculationMetadata: Sendable, Hashable, Codable {
    let calculatorVersion: String
    let astronomyEngineIdentifier: String
    let astronomyEngineVersion: String
    let zodiacSystem: ZodiacSystem
    let calculatedAt: Date
    let inputFingerprint: String

    init(
        calculatorVersion: String,
        astronomyEngineIdentifier: String,
        astronomyEngineVersion: String,
        zodiacSystem: ZodiacSystem = .tropical,
        calculatedAt: Date = .now,
        inputFingerprint: String
    ) {
        self.calculatorVersion = calculatorVersion
        self.astronomyEngineIdentifier = astronomyEngineIdentifier
        self.astronomyEngineVersion = astronomyEngineVersion
        self.zodiacSystem = zodiacSystem
        self.calculatedAt = calculatedAt
        self.inputFingerprint = inputFingerprint
    }
}

// MARK: - BigThree

/// Deterministic Big Three result for one birth.
///
/// Each limb carries explicit availability — Presentation and AI can distinguish
/// "unavailable (needs time)" from "ambiguous (Moon crossed signs that day)".
struct BigThree: Sendable, Hashable, Codable {
    let sun: AstrologyAvailability<BigThreePosition>
    let moon: AstrologyAvailability<BigThreePosition>
    let rising: AstrologyAvailability<BigThreePosition>
    let metadata: BigThreeCalculationMetadata

    /// Convenience accessors for the common available case.
    var sunSign: WesternZodiacSign? { sun.value?.sign }
    var moonSign: WesternZodiacSign? { moon.value?.sign }
    var risingSign: WesternZodiacSign? { rising.value?.sign }

    /// Vendor-neutral input for AI prompt context.
    var astrologyContextForAI: [String: String] {
        var dict: [String: String] = [:]
        if let s = sun.value { dict["sun"] = s.sign.displayName }
        if let m = moon.value { dict["moon"] = m.sign.displayName }
        if let r = rising.value { dict["rising"] = r.sign.displayName }
        return dict
    }

    /// Optional richer context including degrees.
    var astrologyContextWithDegreesForAI: [String: String] {
        var dict: [String: String] = [:]
        if let s = sun.value {
            dict["sun"] = String(format: "%@ %.1f°", s.sign.displayName, s.degreeWithinSign)
        }
        if let m = moon.value {
            dict["moon"] = String(format: "%@ %.1f°", m.sign.displayName, m.degreeWithinSign)
        }
        if let r = rising.value {
            dict["rising"] = String(format: "%@ %.1f°", r.sign.displayName, r.degreeWithinSign)
        }
        return dict
    }
}

// MARK: - Errors

enum BigThreeCalculationError: Error, Sendable, Hashable, Equatable {
    case invalidBirthDate
    case invalidBirthTime
    case invalidLatitude
    case invalidLongitude
    case invalidTimeZoneIdentifier
    case invalidLongitudeValue
    case historicalTimezoneUnavailable
}

// MARK: - Input fingerprint

enum BigThreeInputFingerprint {
    /// Stable fingerprint over every input that can change Big Three facts.
    /// Changing displayName alone does not change this.
    static func fingerprint(birth: BirthDetails, calculatorVersion: String) -> String {
        var parts: [String] = [
            "calc=\(calculatorVersion)",
            "date=\(birth.year)-\(birth.month)-\(birth.day)"
        ]
        switch birth.time {
        case .exact(let m): parts.append("time=exact:\(m)")
        case .approximate(let m, let tol): parts.append("time=approx:\(m)+\(tol)")
        case .unknown: parts.append("time=unknown")
        }
        switch birth.place {
        case .known(let name, let lat, let lon, let tz):
            let rLat = (lat * 100).rounded() / 100
            let rLon = (lon * 100).rounded() / 100
            parts.append("place=\(name)|\(rLat)|\(rLon)|\(tz)")
        case .notProvided:
            parts.append("place=none")
        }
        let raw = parts.joined(separator: "|")
        var hash: UInt64 = 0xcbf29ce484222325
        for b in raw.utf8 {
            hash = (hash ^ UInt64(b)) &* 0x100000001b3
        }
        return String(format: "%016llx", hash)
    }
}
