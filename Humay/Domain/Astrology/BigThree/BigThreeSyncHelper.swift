import Foundation

/// Synchronous bridge for call-sites that cannot `await` (computed properties,
/// Document init). The deterministic engine is pure math + Foundation TimeZone,
/// so doing the same work synchronously is safe and identical to the async
/// `DefaultBigThreeCalculator`.
enum BigThreeSyncHelper {
    static func compute(birth: BirthDetails) -> BigThree? {
        // Inline the same validation + branching as DefaultBigThreeCalculator but sync.
        // Keep this in lockstep with the async implementation; tests cover both paths.
        do {
            try validate(birth: birth)
        } catch { return nil }

        let fingerprint = BigThreeInputFingerprint.fingerprint(birth: birth, calculatorVersion: DefaultBigThreeCalculator.calculatorVersion)
        let metadata = BigThreeCalculationMetadata(
            calculatorVersion: DefaultBigThreeCalculator.calculatorVersion,
            astronomyEngineIdentifier: HumayAstronomyEngine.identifier,
            astronomyEngineVersion: HumayAstronomyEngine.version,
            zodiacSystem: .tropical,
            calculatedAt: .now,
            inputFingerprint: fingerprint
        )

        switch (birth.time, birth.place) {
        case (.unknown, _), (_, .notProvided):
            return (try? calculateUnknownTime(birth: birth, metadata: metadata))
        case (.exact, .known), (.approximate, .known):
            return (try? calculateKnownTime(birth: birth, metadata: metadata))
        }
    }

    // MARK: - Duplicated logic (kept intentionally tiny; engine is the truth)

    private static func calculateKnownTime(birth: BirthDetails, metadata: BigThreeCalculationMetadata) throws -> BigThree {
        guard case .known(_, let lat, let lon, let tzID) = birth.place,
              let minutes = birth.time.minutesFromMidnight,
              let utc = BirthInstantResolver.utcInstant(
                year: birth.year, month: birth.month, day: birth.day,
                minutesFromMidnight: minutes, timeZoneIdentifier: tzID) else {
            throw BigThreeCalculationError.historicalTimezoneUnavailable
        }
        let jd = HumayAstronomyEngine.julianDay(from: utc)
        let sunPos = try BigThreePosition(longitudeDegrees: HumayAstronomyEngine.sunLongitude(julianDay: jd))
        let moonPos = try BigThreePosition(longitudeDegrees: HumayAstronomyEngine.moonLongitude(julianDay: jd))
        let ascPos = try BigThreePosition(longitudeDegrees: HumayAstronomyEngine.ascendantLongitude(julianDay: jd, latitude: lat, longitude: lon))
        return BigThree(sun: .available(sunPos), moon: .available(moonPos), rising: .available(ascPos), metadata: metadata)
    }

    private static func calculateUnknownTime(birth: BirthDetails, metadata: BigThreeCalculationMetadata) throws -> BigThree {
        let rising: AstrologyAvailability<BigThreePosition> = .unavailable(reason: .missingBirthTime)
        guard case .known = birth.place else {
            let sun = try sunForUnknownTimeWithoutPlace(birth: birth)
            return BigThree(sun: sun, moon: .unavailable(reason: .missingBirthPlace), rising: rising, metadata: metadata)
        }
        let sunAvail = try sunForUnknownTimeWithPlace(birth: birth)
        let moonAvail = try moonForUnknownTime(birth: birth)
        return BigThree(sun: sunAvail, moon: moonAvail, rising: rising, metadata: metadata)
    }

    private static func sunForUnknownTimeWithPlace(birth: BirthDetails) throws -> AstrologyAvailability<BigThreePosition> {
        guard let bounds = BirthInstantResolver.dayBoundaryInstants(birth: birth) else {
            return .unavailable(reason: .missingBirthPlace)
        }
        let sLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: bounds.start))
        let eLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: bounds.end))
        let sSign = try BigThreePosition(longitudeDegrees: sLong).sign
        let eSign = try BigThreePosition(longitudeDegrees: eLong).sign
        if sSign == eSign {
            guard let noon = BirthInstantResolver.noonUTC(for: birth) else { return .unavailable(reason: .missingBirthPlace) }
            let noonLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon))
            return .available(try BigThreePosition(longitudeDegrees: noonLong))
        } else {
            return .ambiguous(options: [try BigThreePosition(longitudeDegrees: sLong), try BigThreePosition(longitudeDegrees: eLong)])
        }
    }

    private static func sunForUnknownTimeWithoutPlace(birth: BirthDetails) throws -> AstrologyAvailability<BigThreePosition> {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let start = cal.date(from: DateComponents(year: birth.year, month: birth.month, day: birth.day, hour: 0, minute: 0)),
              let end = cal.date(from: DateComponents(year: birth.year, month: birth.month, day: birth.day, hour: 23, minute: 59)),
              let noon = cal.date(from: DateComponents(year: birth.year, month: birth.month, day: birth.day, hour: 12, minute: 0)) else {
            return .unavailable(reason: .missingBirthPlace)
        }
        let sLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: start))
        let eLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: end))
        let sSign = try BigThreePosition(longitudeDegrees: sLong).sign
        let eSign = try BigThreePosition(longitudeDegrees: eLong).sign
        if sSign == eSign {
            return .available(try BigThreePosition(longitudeDegrees: HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon))))
        } else {
            return .ambiguous(options: [try BigThreePosition(longitudeDegrees: sLong), try BigThreePosition(longitudeDegrees: eLong)])
        }
    }

    private static func moonForUnknownTime(birth: BirthDetails) throws -> AstrologyAvailability<BigThreePosition> {
        let samples = BirthInstantResolver.sampledInstantsForUnknownTimeDay(birth: birth)
        guard !samples.isEmpty else { return .unavailable(reason: .missingBirthPlace) }
        let longs = samples.map { HumayAstronomyEngine.moonLongitude(julianDay: HumayAstronomyEngine.julianDay(from: $0)) }
        let signs = try longs.map { try BigThreePosition(longitudeDegrees: $0).sign }
        if Set(signs).count == 1 {
            guard let noon = BirthInstantResolver.noonUTC(for: birth) else { return .unavailable(reason: .missingBirthPlace) }
            let noonLong = HumayAstronomyEngine.moonLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon))
            return .available(try BigThreePosition(longitudeDegrees: noonLong))
        } else {
            var seen: Set<WesternZodiacSign> = []
            var opts: [BigThreePosition] = []
            for l in longs {
                let p = try BigThreePosition(longitudeDegrees: l)
                if seen.insert(p.sign).inserted { opts.append(p) }
            }
            return .ambiguous(options: Array(opts.prefix(2)))
        }
    }

    private static func validate(birth: BirthDetails) throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent
        var comps = DateComponents(); comps.year = birth.year; comps.month = birth.month; comps.day = birth.day
        comps.calendar = cal; comps.timeZone = cal.timeZone
        guard let cand = cal.date(from: comps) else { throw BigThreeCalculationError.invalidBirthDate }
        let res = cal.dateComponents([.year, .month, .day], from: cand)
        guard res.year == birth.year, res.month == birth.month, res.day == birth.day else { throw BigThreeCalculationError.invalidBirthDate }
        switch birth.time {
        case .exact(let m): guard (0...1439).contains(m) else { throw BigThreeCalculationError.invalidBirthTime }
        case .approximate(let m, let t): guard (0...1439).contains(m), t > 0 else { throw BigThreeCalculationError.invalidBirthTime }
        case .unknown: break
        }
        if case .known(let name, let lat, let lon, let tzID) = birth.place {
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw BigThreeCalculationError.invalidBirthDate }
            guard lat.isFinite, (-90...90).contains(lat) else { throw BigThreeCalculationError.invalidLatitude }
            guard lon.isFinite, (-180...180).contains(lon) else { throw BigThreeCalculationError.invalidLongitude }
            guard TimeZone(identifier: tzID) != nil else { throw BigThreeCalculationError.invalidTimeZoneIdentifier }
        }
    }
}
