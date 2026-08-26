import Foundation

#if DEBUG
/// DEBUG-only inspection/export for Big Three calculation.
/// No Release surface.

struct BigThreeDebugPayload: Codable, Sendable {
    /// The actual UTC instant of birth (nil if unknown/nonexistent/invalid).
    let birthUTC: String?
    /// Local wall time description.
    let birthLocal: String
    let sun: PositionPayload?
    let moon: PositionPayload?
    let rising: PositionPayload?
    let calculator: CalculatorPayload
    let unavailableReasons: [String: String]
    let ambiguousOptions: [String: [String]]
    /// Explicit DST resolution state: unique/nonexistent/ambiguous/invalid/unknown.
    let birthResolution: String
    /// When birth time is approximate, the inspected interval (e.g., "17:05 ±30").
    let approximateInterval: String?
    /// For ambiguous wall times, both UTC instants.
    let ambiguousInstantsUTC: [String]?

    struct PositionPayload: Codable, Sendable {
        let longitude: Double
        let sign: String
        let degreeWithinSign: Double
    }
    struct CalculatorPayload: Codable, Sendable {
        let engine: String
        let version: String
        let calculatorVersion: String
        let zodiacSystem: String
        /// Timestamp when calculation was performed (not birth UTC).
        let calculatedAt: String
        let inputFingerprint: String
    }
}

enum BigThreeDebug {
    static func payload(for birth: BirthDetails, bigThree: BigThree) -> BigThreeDebugPayload {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]

        // Correct semantics: birthUTC is the birth instant in UTC; calculatedAt is in CalculatorPayload.
        let birthUTC: String? = {
            guard let utc = BirthInstantResolver.utcInstant(for: birth) else { return nil }
            return iso.string(from: utc)
        }()

        let local = "\(birth.year)-\(String(format: "%02d", birth.month))-\(String(format: "%02d", birth.day)) \(birth.time.minutesFromMidnight.map { String(format: "%02d:%02d", $0/60, $0%60) } ?? "unknown") \(birth.place.name ?? "no-place")"

        // Resolution description
        let resolutionString: String = {
            guard let minutes = birth.time.minutesFromMidnight,
                  case .known(_, _, _, let tzID) = birth.place else {
                if case .unknown = birth.time { return "unknown-time" }
                if case .notProvided = birth.place { return "no-place" }
                return "n/a"
            }
            switch BirthInstantResolver.resolve(year: birth.year, month: birth.month, day: birth.day,
                                               minutesFromMidnight: minutes, timeZoneIdentifier: tzID) {
            case .unique: return "unique"
            case .ambiguous: return "ambiguous (fall-back repeated hour)"
            case .nonexistent: return "nonexistent (spring-forward gap)"
            case .invalid: return "invalid"
            }
        }()

        let approximateInterval: String? = {
            if case .approximate(let m, let tol) = birth.time {
                let h = m/60; let mi = m%60
                return String(format: "%02d:%02d ±%d min", h, mi, tol)
            }
            return nil
        }()

        let ambiguousInstantsUTC: [String]? = {
            guard let minutes = birth.time.minutesFromMidnight,
                  case .known(_, _, _, let tzID) = birth.place,
                  let pair = BirthInstantResolver.ambiguousInstants(year: birth.year, month: birth.month, day: birth.day,
                                                                    minutesFromMidnight: minutes, timeZoneIdentifier: tzID) else { return nil }
            return [iso.string(from: pair.first), iso.string(from: pair.second)]
        }()

        func posPayload(_ availability: AstrologyAvailability<BigThreePosition>) -> BigThreeDebugPayload.PositionPayload? {
            if case .available(let p) = availability {
                return .init(longitude: p.longitudeDegrees, sign: p.sign.displayName, degreeWithinSign: p.degreeWithinSign)
            }
            return nil
        }

        var reasons: [String: String] = [:]
        var ambiguous: [String: [String]] = [:]

        switch bigThree.sun {
        case .unavailable(let r): reasons["sun"] = r.rawValue
        case .ambiguous(let opts): ambiguous["sun"] = opts.map { $0.sign.displayName }
        case .available: break
        }
        switch bigThree.moon {
        case .unavailable(let r): reasons["moon"] = r.rawValue
        case .ambiguous(let opts): ambiguous["moon"] = opts.map { $0.sign.displayName }
        case .available: break
        }
        switch bigThree.rising {
        case .unavailable(let r): reasons["rising"] = r.rawValue
        case .ambiguous(let opts): ambiguous["rising"] = opts.map { $0.sign.displayName }
        case .available: break
        }

        return BigThreeDebugPayload(
            birthUTC: birthUTC,
            birthLocal: local,
            sun: posPayload(bigThree.sun),
            moon: posPayload(bigThree.moon),
            rising: posPayload(bigThree.rising),
            calculator: .init(
                engine: bigThree.metadata.astronomyEngineIdentifier,
                version: bigThree.metadata.astronomyEngineVersion,
                calculatorVersion: bigThree.metadata.calculatorVersion,
                zodiacSystem: bigThree.metadata.zodiacSystem.rawValue,
                calculatedAt: iso.string(from: bigThree.metadata.calculatedAt),
                inputFingerprint: bigThree.metadata.inputFingerprint
            ),
            unavailableReasons: reasons,
            ambiguousOptions: ambiguous,
            birthResolution: resolutionString,
            approximateInterval: approximateInterval,
            ambiguousInstantsUTC: ambiguousInstantsUTC
        )
    }

    static func jsonString(from payload: BigThreeDebugPayload) -> String? {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? enc.encode(payload) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func json(for birth: BirthDetails) -> String? {
        guard let bt = BigThreeSyncHelper.compute(birth: birth) else { return nil }
        let payload = payload(for: birth, bigThree: bt)
        return jsonString(from: payload)
    }
}
#endif
