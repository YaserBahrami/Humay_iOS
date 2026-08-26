import Foundation

// MARK: - BigThreeCalculationCore
//
// Single canonical calculation implementation for Big Three.
// Both DefaultBigThreeCalculator (async) and BigThreeSyncHelper delegate here.
// No duplicated Sun/Moon/Rising rules elsewhere.

enum BigThreeCalculationCore: Sendable {

    // MARK: - Cusp thresholds (measured accuracy + safety margin)
    //
    // Measured typical errors after GMST fix (see BIG_THREE_CALCULATION.md):
    //   Sun ~0.02°, Moon ~0.2°, Asc ~1.0°
    // Safety margins added to avoid false exactness near boundaries.
    // These are intentionally tight: goal is not to make many profiles ambiguous,
    // only genuine edge cases within verified uncertainty.
    static let sunCuspMarginDegrees: Double = 0.3   // 0.02 + 0.28 safety
    static let moonCuspMarginDegrees: Double = 1.0  // 0.2 + 0.8 safety
    static let ascCuspMarginDegrees: Double = 1.5   // 1.0 + 0.5 safety

    // MARK: - Entry

    static func calculate(birth: BirthDetails) throws -> BigThree {
        try validate(birth: birth)

        let fingerprint = BigThreeInputFingerprint.fingerprint(birth: birth, calculatorVersion: DefaultBigThreeCalculator.calculatorVersion)
        let metadata = BigThreeCalculationMetadata(
            calculatorVersion: DefaultBigThreeCalculator.calculatorVersion,
            astronomyEngineIdentifier: HumayAstronomyEngine.identifier,
            astronomyEngineVersion: HumayAstronomyEngine.version,
            zodiacSystem: .tropical,
            calculatedAt: .now,
            inputFingerprint: fingerprint
        )

        // Branch per §10 plus approximate handling
        switch (birth.time, birth.place) {
        case (.unknown, _), (_, .notProvided):
            return try calculateUnknownTime(birth: birth, metadata: metadata)
        case (.exact, .known), (.approximate, .known):
            return try calculateKnownTime(birth: birth, metadata: metadata)
        }
    }

    // MARK: - Known time (exact or approximate)

    private static func calculateKnownTime(birth: BirthDetails, metadata: BigThreeCalculationMetadata) throws -> BigThree {
        guard case .known(_, let lat, let lon, let tzID) = birth.place else {
            throw BigThreeCalculationError.invalidTimeZoneIdentifier
        }

        switch birth.time {
        case .exact(let minutes):
            return try calculateExactKnownTime(birth: birth, lat: lat, lon: lon, tzID: tzID, minutes: minutes, metadata: metadata)
        case .approximate(let minutes, let tolerance):
            return try calculateApproximateKnownTime(birth: birth, lat: lat, lon: lon, tzID: tzID, minutes: minutes, tolerance: tolerance, metadata: metadata)
        case .unknown:
            throw BigThreeCalculationError.invalidBirthTime
        }
    }

    private static func calculateExactKnownTime(
        birth: BirthDetails, lat: Double, lon: Double, tzID: String,
        minutes: Int, metadata: BigThreeCalculationMetadata
    ) throws -> BigThree {
        let resolution = BirthInstantResolver.resolve(year: birth.year, month: birth.month, day: birth.day,
                                                      minutesFromMidnight: minutes, timeZoneIdentifier: tzID)
        switch resolution {
        case .invalid:
            throw BigThreeCalculationError.invalidBirthTime
        case .nonexistent:
            // Spring-forward gap: wall time did not exist. Do not silently normalize.
            throw BigThreeCalculationError.historicalTimezoneUnavailable
        case .unique(let utc):
            return try evaluateSingleInstant(jdFor: utc, lat: lat, lon: lon, metadata: metadata)
        case .ambiguous(let first, let second):
            // Fall-back: evaluate both instants (each may already be cusp-ambiguous)
            let r1 = try evaluateSingleInstant(jdFor: first, lat: lat, lon: lon, metadata: metadata)
            let r2 = try evaluateSingleInstant(jdFor: second, lat: lat, lon: lon, metadata: metadata)
            // Helper to extract distinct signs from an availability (available or ambiguous)
            func signs(of avail: AstrologyAvailability<BigThreePosition>) -> Set<WesternZodiacSign> {
                switch avail {
                case .available(let p): return [p.sign]
                case .ambiguous(let opts): return Set(opts.map(\.sign))
                case .unavailable: return []
                }
            }
            func merge(_ a: AstrologyAvailability<BigThreePosition>, _ b: AstrologyAvailability<BigThreePosition>) -> AstrologyAvailability<BigThreePosition> {
                let combined = signs(of: a).union(signs(of: b))
                if combined.count == 1 {
                    // Both agree — safe to remain as r1 (if r1 was available, keep; if ambiguous but same sign set, keep r1)
                    // For cusp-ambiguous but identical sign set, we preserve ambiguity (honest)
                    if case .available = a, case .available = b { return a }
                    // If either is ambiguous, preserve ambiguity even if single distinct sign? Actually cusp ambiguity should remain
                    // Keep the more conservative (ambiguous) if either is ambiguous
                    if case .ambiguous = a { return a }
                    if case .ambiguous = b { return b }
                    return a
                } else {
                    // Distinct signs — synthesize ambiguous with one representative per distinct sign
                    var opts: [BigThreePosition] = []
                    var seen: Set<WesternZodiacSign> = []
                    for avail in [a, b] {
                        switch avail {
                        case .available(let p):
                            if seen.insert(p.sign).inserted { opts.append(p) }
                        case .ambiguous(let arr):
                            for p in arr where seen.insert(p.sign).inserted { opts.append(p) }
                        case .unavailable: break
                        }
                    }
                    return .ambiguous(options: Array(opts.prefix(2)))
                }
            }
            // If all limbs have single distinct sign (and not cusp-ambiguous differing), we could return r1, otherwise merge
            // Use merge for each limb individually
            let sun = merge(r1.sun, r2.sun)
            let moon = merge(r1.moon, r2.moon)
            let rising = merge(r1.rising, r2.rising)
            // If all three merges are available and original r1 was fully available, return r1 for efficiency
            // Otherwise return merged result
            if case .available = sun, case .available = moon, case .available = rising,
               case .available = r1.sun, case .available = r1.moon, case .available = r1.rising {
                return r1
            }
            return BigThree(sun: sun, moon: moon, rising: rising, metadata: metadata)
        }
    }

    private static func calculateApproximateKnownTime(
        birth: BirthDetails, lat: Double, lon: Double, tzID: String,
        minutes: Int, tolerance: Int,
        metadata: BigThreeCalculationMetadata
    ) throws -> BigThree {
        // Evaluate the full interval [central-tolerance, central+tolerance] clamped to day
        let lower = max(0, minutes - tolerance)
        let upper = min(1439, minutes + tolerance)

        var sunSigns: Set<WesternZodiacSign> = []
        var moonSigns: Set<WesternZodiacSign> = []
        var risingSigns: Set<WesternZodiacSign> = []
        var sunPositions: [BigThreePosition] = []
        var moonPositions: [BigThreePosition] = []
        var risingPositions: [BigThreePosition] = []
        var representativeSun: BigThreePosition?
        var representativeMoon: BigThreePosition?
        var representativeRising: BigThreePosition?

        // Central instant for representative longitude (if valid)
        if case .unique(let centralUTC) = BirthInstantResolver.resolve(year: birth.year, month: birth.month, day: birth.day,
                                                                       minutesFromMidnight: minutes, timeZoneIdentifier: tzID) {
            let jd = HumayAstronomyEngine.julianDay(from: centralUTC)
            representativeSun = try? BigThreePosition(longitudeDegrees: HumayAstronomyEngine.sunLongitude(julianDay: jd))
            representativeMoon = try? BigThreePosition(longitudeDegrees: HumayAstronomyEngine.moonLongitude(julianDay: jd))
            representativeRising = try? BigThreePosition(longitudeDegrees: HumayAstronomyEngine.ascendantLongitude(julianDay: jd, latitude: lat, longitude: lon))
        }

        // Evaluate every valid minute in the window (including both ambiguous instants)
        for m in lower...upper {
            let resolution = BirthInstantResolver.resolve(year: birth.year, month: birth.month, day: birth.day,
                                                          minutesFromMidnight: m, timeZoneIdentifier: tzID)
            let instants: [Date]
            switch resolution {
            case .unique(let d): instants = [d]
            case .ambiguous(let f, let s): instants = [f, s]
            case .nonexistent, .invalid: continue
            }
            for utc in instants {
                let jd = HumayAstronomyEngine.julianDay(from: utc)
                if let sunPos = try? BigThreePosition(longitudeDegrees: HumayAstronomyEngine.sunLongitude(julianDay: jd)) {
                    sunSigns.insert(sunPos.sign)
                    if sunPositions.count < 4 { sunPositions.append(sunPos) }
                }
                if let moonPos = try? BigThreePosition(longitudeDegrees: HumayAstronomyEngine.moonLongitude(julianDay: jd)) {
                    moonSigns.insert(moonPos.sign)
                    if moonPositions.count < 4 { moonPositions.append(moonPos) }
                }
                if let ascPos = try? BigThreePosition(longitudeDegrees: HumayAstronomyEngine.ascendantLongitude(julianDay: jd, latitude: lat, longitude: lon)) {
                    risingSigns.insert(ascPos.sign)
                    if risingPositions.count < 4 { risingPositions.append(ascPos) }
                }
            }
        }

        // If no valid instants (e.g., window entirely inside spring gap)
        if sunSigns.isEmpty && moonSigns.isEmpty && risingSigns.isEmpty {
            throw BigThreeCalculationError.historicalTimezoneUnavailable
        }

        // Build availabilities: if interval spans multiple signs -> ambiguous
        let sunAvail: AstrologyAvailability<BigThreePosition>
        if sunSigns.count > 1 {
            // Collect distinct sign positions
            var seen: Set<WesternZodiacSign> = []
            var opts: [BigThreePosition] = []
            for p in sunPositions where seen.insert(p.sign).inserted { opts.append(p) }
            // If we have only one position but multiple signs detected, synthesize neighbors
            if opts.count == 1 && sunSigns.count > 1 {
                // Add synthetic neighbor for honesty (should not happen with full scan)
                opts.append(contentsOf: sunPositions)
            }
            sunAvail = .ambiguous(options: Array(opts.prefix(2)))
        } else if let rep = representativeSun {
            // Check cusp margin
            if isNearCusp(rep, margin: sunCuspMarginDegrees) {
                // Need neighbor sign for ambiguity
                let neighbor = neighborSign(for: rep, jdForCentral: nil, lat: lat, lon: lon, isSun: true)
                sunAvail = .ambiguous(options: [rep, neighbor].compactMap { $0 })
            } else {
                sunAvail = .available(rep)
            }
        } else if let first = sunPositions.first {
            sunAvail = .available(first)
        } else {
            sunAvail = .unavailable(reason: .calculationUnavailable)
        }

        let moonAvail: AstrologyAvailability<BigThreePosition>
        if moonSigns.count > 1 {
            var seen: Set<WesternZodiacSign> = []
            var opts: [BigThreePosition] = []
            for p in moonPositions where seen.insert(p.sign).inserted { opts.append(p) }
            moonAvail = .ambiguous(options: Array(opts.prefix(2)))
        } else if let rep = representativeMoon {
            if isNearCusp(rep, margin: moonCuspMarginDegrees) {
                let neighbor = neighborSign(for: rep, jdForCentral: nil, lat: lat, lon: lon, isSun: false)
                moonAvail = .ambiguous(options: [rep, neighbor].compactMap { $0 })
            } else {
                moonAvail = .available(rep)
            }
        } else if let first = moonPositions.first {
            moonAvail = .available(first)
        } else {
            moonAvail = .unavailable(reason: .calculationUnavailable)
        }

        let risingAvail: AstrologyAvailability<BigThreePosition>
        if risingSigns.count > 1 {
            var seen: Set<WesternZodiacSign> = []
            var opts: [BigThreePosition] = []
            for p in risingPositions where seen.insert(p.sign).inserted { opts.append(p) }
            risingAvail = .ambiguous(options: Array(opts.prefix(2)))
        } else if let rep = representativeRising {
            if isNearCusp(rep, margin: ascCuspMarginDegrees) {
                let neighbor = neighborSign(for: rep, jdForCentral: nil, lat: lat, lon: lon, isSun: false)
                risingAvail = .ambiguous(options: [rep, neighbor].compactMap { $0 })
            } else {
                risingAvail = .available(rep)
            }
        } else if let first = risingPositions.first {
            risingAvail = .available(first)
        } else {
            risingAvail = .unavailable(reason: .calculationUnavailable)
        }

        return BigThree(sun: sunAvail, moon: moonAvail, rising: risingAvail, metadata: metadata)
    }

    private static func evaluateSingleInstant(jdFor utc: Date, lat: Double, lon: Double, metadata: BigThreeCalculationMetadata) throws -> BigThree {
        let jd = HumayAstronomyEngine.julianDay(from: utc)
        let sunLong = HumayAstronomyEngine.sunLongitude(julianDay: jd)
        let moonLong = HumayAstronomyEngine.moonLongitude(julianDay: jd)
        let ascLong = HumayAstronomyEngine.ascendantLongitude(julianDay: jd, latitude: lat, longitude: lon)

        var sunPos = try BigThreePosition(longitudeDegrees: sunLong)
        var moonPos = try BigThreePosition(longitudeDegrees: moonLong)
        var ascPos = try BigThreePosition(longitudeDegrees: ascLong)

        // Cusp honesty: if within margin of boundary, mark ambiguous
        let sunAvail: AstrologyAvailability<BigThreePosition>
        if isNearCusp(sunPos, margin: sunCuspMarginDegrees) {
            if let neighbor = neighborSign(for: sunPos, jdForCentral: jd, lat: lat, lon: lon, isSun: true) {
                sunAvail = .ambiguous(options: [sunPos, neighbor])
            } else {
                sunAvail = .available(sunPos)
            }
        } else {
            sunAvail = .available(sunPos)
        }

        let moonAvail: AstrologyAvailability<BigThreePosition>
        if isNearCusp(moonPos, margin: moonCuspMarginDegrees) {
            if let neighbor = neighborSign(for: moonPos, jdForCentral: jd, lat: lat, lon: lon, isSun: false) {
                moonAvail = .ambiguous(options: [moonPos, neighbor])
            } else {
                moonAvail = .available(moonPos)
            }
        } else {
            moonAvail = .available(moonPos)
        }

        let risingAvail: AstrologyAvailability<BigThreePosition>
        if isNearCusp(ascPos, margin: ascCuspMarginDegrees) {
            if let neighbor = neighborSign(for: ascPos, jdForCentral: jd, lat: lat, lon: lon, isSun: false) {
                risingAvail = .ambiguous(options: [ascPos, neighbor])
            } else {
                risingAvail = .available(ascPos)
            }
        } else {
            risingAvail = .available(ascPos)
        }

        // If any limb became ambiguous due to cusp, preserve it — do not assert exact sign
        return BigThree(sun: sunAvail, moon: moonAvail, rising: risingAvail, metadata: metadata)
    }

    // MARK: - Unknown time

    private static func calculateUnknownTime(birth: BirthDetails, metadata: BigThreeCalculationMetadata) throws -> BigThree {
        let rising: AstrologyAvailability<BigThreePosition> = .unavailable(reason: .missingBirthTime)

        guard case .known(_, _, _, let tzID) = birth.place else {
            let sun = try sunForUnknownTimeWithoutPlace(birth: birth)
            return BigThree(sun: sun, moon: .unavailable(reason: .missingBirthPlace), rising: rising, metadata: metadata)
        }

        let sunAvail = try sunForUnknownTimeWithPlace(birth: birth, tzID: tzID)
        let moonAvail = try moonForUnknownTime(birth: birth, tzID: tzID)

        return BigThree(sun: sunAvail, moon: moonAvail, rising: rising, metadata: metadata)
    }

    private static func sunForUnknownTimeWithPlace(birth: BirthDetails, tzID: String) throws -> AstrologyAvailability<BigThreePosition> {
        guard let bounds = BirthInstantResolver.dayBoundaryInstants(birth: birth) else {
            return .unavailable(reason: .missingBirthPlace)
        }
        let jdStart = HumayAstronomyEngine.julianDay(from: bounds.start)
        let jdEnd = HumayAstronomyEngine.julianDay(from: bounds.end)
        let longStart = HumayAstronomyEngine.sunLongitude(julianDay: jdStart)
        let longEnd = HumayAstronomyEngine.sunLongitude(julianDay: jdEnd)
        let signStart = try BigThreePosition(longitudeDegrees: longStart).sign
        let signEnd = try BigThreePosition(longitudeDegrees: longEnd).sign
        if signStart == signEnd {
            guard let noon = BirthInstantResolver.noonUTC(for: birth) else {
                return .unavailable(reason: .missingBirthPlace)
            }
            let noonLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon))
            let pos = try BigThreePosition(longitudeDegrees: noonLong)
            // Cusp check on representative
            if isNearCusp(pos, margin: sunCuspMarginDegrees) {
                // Even though start/end same sign, noon near cusp could still be uncertain
                // Treat as ambiguous with neighbor
                if let neighbor = neighborSign(for: pos, jdForCentral: HumayAstronomyEngine.julianDay(from: noon), lat: 0, lon: 0, isSun: true) {
                    return .ambiguous(options: [pos, neighbor])
                }
            }
            return .available(pos)
        } else {
            let p1 = try BigThreePosition(longitudeDegrees: longStart)
            let p2 = try BigThreePosition(longitudeDegrees: longEnd)
            return .ambiguous(options: [p1, p2])
        }
    }

    private static func sunForUnknownTimeWithoutPlace(birth: BirthDetails) throws -> AstrologyAvailability<BigThreePosition> {
        // Honest policy: without location we cannot know local civil day's UTC window.
        // The possible UTC instants for "birth date as local date somewhere on Earth"
        // span from UTC-14 earliest to UTC+12 latest (~50h window).
        // If Sun crosses sign in that window, we must mark ambiguous.
        var gmt = Calendar(identifier: .gregorian)
        gmt.timeZone = TimeZone(secondsFromGMT: 0)!

        // Earliest UTC that could be local 00:00 on birth date (UTC+14)
        // Latest UTC that could be local 23:59 on birth date (UTC-12)
        guard let baseMidnight = gmt.date(from: DateComponents(year: birth.year, month: birth.month, day: birth.day, hour: 0, minute: 0)),
              let baseNoon = gmt.date(from: DateComponents(year: birth.year, month: birth.month, day: birth.day, hour: 12, minute: 0)),
              let baseEnd = gmt.date(from: DateComponents(year: birth.year, month: birth.month, day: birth.day, hour: 23, minute: 59)) else {
            return .unavailable(reason: .missingBirthPlace)
        }
        let earliest = baseMidnight.addingTimeInterval(-14 * 3600)
        let latest = baseEnd.addingTimeInterval(12 * 3600)

        let sLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: earliest))
        let eLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: latest))
        let noonLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: baseNoon))
        let sSign = try BigThreePosition(longitudeDegrees: sLong).sign
        let eSign = try BigThreePosition(longitudeDegrees: eLong).sign
        let noonSign = try BigThreePosition(longitudeDegrees: noonLong).sign

        // If all three agree, day is well away from cusp -> available
        if sSign == eSign && eSign == noonSign {
            let pos = try BigThreePosition(longitudeDegrees: noonLong)
            // Still apply cusp margin check
            if isNearCusp(pos, margin: sunCuspMarginDegrees) {
                // Near cusp even with stable window -> ambiguous, need neighbor
                let pEarliest = try BigThreePosition(longitudeDegrees: sLong)
                let pLatest = try BigThreePosition(longitudeDegrees: eLong)
                // Distinct signs already checked stable, but near cusp extra safety: mark ambiguous with two options
                // Use earliest/latest as distinct if they differ, otherwise synthesize neighbor
                if pEarliest.sign != pos.sign {
                    return .ambiguous(options: [pos, pEarliest])
                } else if pLatest.sign != pos.sign {
                    return .ambiguous(options: [pos, pLatest])
                } else {
                    // Synthesize neighbor sign (adjacent)
                    if let neighbor = neighborSign(for: pos, jdForCentral: HumayAstronomyEngine.julianDay(from: baseNoon), lat: 0, lon: 0, isSun: true) {
                        return .ambiguous(options: [pos, neighbor])
                    }
                }
            }
            return .available(pos)
        } else {
            // Cusp spans worldwide window -> ambiguous
            // Return distinct options
            var seen: Set<WesternZodiacSign> = []
            var opts: [BigThreePosition] = []
            for long in [sLong, noonLong, eLong] {
                let p = try BigThreePosition(longitudeDegrees: long)
                if seen.insert(p.sign).inserted { opts.append(p) }
            }
            return .ambiguous(options: Array(opts.prefix(2)))
        }
    }

    private static func moonForUnknownTime(birth: BirthDetails, tzID: String) throws -> AstrologyAvailability<BigThreePosition> {
        let samples = BirthInstantResolver.sampledInstantsForUnknownTimeDay(birth: birth)
        guard !samples.isEmpty else { return .unavailable(reason: .missingBirthPlace) }
        let longs = samples.map { HumayAstronomyEngine.moonLongitude(julianDay: HumayAstronomyEngine.julianDay(from: $0)) }
        let signs = try longs.map { try BigThreePosition(longitudeDegrees: $0).sign }
        let distinct = Array(Set(signs))
        if distinct.count == 1 {
            guard let noon = BirthInstantResolver.noonUTC(for: birth) else {
                return .unavailable(reason: .missingBirthPlace)
            }
            let noonLong = HumayAstronomyEngine.moonLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon))
            let pos = try BigThreePosition(longitudeDegrees: noonLong)
            if isNearCusp(pos, margin: moonCuspMarginDegrees) {
                if let neighbor = neighborSign(for: pos, jdForCentral: HumayAstronomyEngine.julianDay(from: noon), lat: 0, lon: 0, isSun: false) {
                    return .ambiguous(options: [pos, neighbor])
                }
            }
            return .available(pos)
        } else {
            var seen: Set<WesternZodiacSign> = []
            var options: [BigThreePosition] = []
            for long in longs {
                let p = try BigThreePosition(longitudeDegrees: long)
                if seen.insert(p.sign).inserted { options.append(p) }
            }
            return .ambiguous(options: Array(options.prefix(2)))
        }
    }

    // MARK: - Helpers

    private static func isNearCusp(_ pos: BigThreePosition, margin: Double) -> Bool {
        let d = pos.degreeWithinSign
        return d < margin || d > (30.0 - margin)
    }

    private static func neighborSign(for pos: BigThreePosition, jdForCentral: Double?, lat: Double, lon: Double, isSun: Bool) -> BigThreePosition? {
        let d = pos.degreeWithinSign
        let delta: Double = d < 15 ? -(d + 0.5) : (30.0 - d + 0.5)
        let neighborLong = HumayAstronomyEngine.normalizeDegrees(pos.longitudeDegrees + delta)
        return try? BigThreePosition(longitudeDegrees: neighborLong)
    }

    // MARK: - Validation

    private static func validate(birth: BirthDetails) throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent
        var comps = DateComponents(); comps.year = birth.year; comps.month = birth.month; comps.day = birth.day
        comps.calendar = cal; comps.timeZone = cal.timeZone
        guard let cand = cal.date(from: comps) else { throw BigThreeCalculationError.invalidBirthDate }
        let res = cal.dateComponents([.year, .month, .day], from: cand)
        guard res.year == birth.year, res.month == birth.month, res.day == birth.day else {
            throw BigThreeCalculationError.invalidBirthDate
        }
        switch birth.time {
        case .exact(let m): guard (0...1439).contains(m) else { throw BigThreeCalculationError.invalidBirthTime }
        case .approximate(let m, let tol): guard (0...1439).contains(m), tol > 0 else { throw BigThreeCalculationError.invalidBirthTime }
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
