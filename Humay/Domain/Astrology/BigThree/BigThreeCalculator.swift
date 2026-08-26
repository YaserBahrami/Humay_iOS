import Foundation

// MARK: - Protocol

protocol BigThreeCalculating: Sendable {
    func calculate(birth: BirthDetails) async throws -> BigThree
}

// MARK: - Errors

extension BigThreeCalculationError {
    static let version = "bigthree-v1"

    var asAvailabilityReason: AstrologyUnavailabilityReason {
        switch self {
        case .invalidBirthDate, .invalidBirthTime: .invalidInput
        case .invalidLatitude, .invalidLongitude: .invalidInput
        case .invalidTimeZoneIdentifier: .invalidInput
        case .invalidLongitudeValue: .invalidInput
        case .historicalTimezoneUnavailable: .calculationUnavailable
        }
    }
}

// MARK: - DefaultBigThreeCalculator

/// Deterministic, offline, vendor-neutral Big Three calculator.
///
/// No networking, no API key, no Swiss Ephemeris, no AI. Pure Meeus-lite math
/// behind `HumayAstronomyEngine` plus Foundation's historical TimeZone DB.
struct DefaultBigThreeCalculator: BigThreeCalculating, Sendable {
    static let calculatorVersion = "bigthree-v1"
    static let engineIdentifier = HumayAstronomyEngine.identifier
    static let engineVersion = HumayAstronomyEngine.version

    func calculate(birth: BirthDetails) async throws -> BigThree {
        try validate(birth: birth)

        let fingerprint = BigThreeInputFingerprint.fingerprint(birth: birth, calculatorVersion: Self.calculatorVersion)
        let metadata = BigThreeCalculationMetadata(
            calculatorVersion: Self.calculatorVersion,
            astronomyEngineIdentifier: Self.engineIdentifier,
            astronomyEngineVersion: Self.engineVersion,
            zodiacSystem: .tropical,
            calculatedAt: .now,
            inputFingerprint: fingerprint
        )

        // Branch on time/place availability per §10.
        switch (birth.time, birth.place) {
        case (.unknown, _), (_, .notProvided):
            return try calculateUnknownTime(birth: birth, metadata: metadata)
        case (.exact, .known), (.approximate, .known):
            return try calculateKnownTime(birth: birth, metadata: metadata)
        }
    }

    // MARK: Known time

    private func calculateKnownTime(birth: BirthDetails, metadata: BigThreeCalculationMetadata) throws -> BigThree {
        guard case .known(_, let lat, let lon, let tzID) = birth.place else {
            throw BigThreeCalculationError.invalidTimeZoneIdentifier
        }
        guard let minutes = birth.time.minutesFromMidnight else {
            throw BigThreeCalculationError.invalidBirthTime
        }
        // Historical UTC instant
        guard let utc = BirthInstantResolver.utcInstant(
            year: birth.year, month: birth.month, day: birth.day,
            minutesFromMidnight: expandedMinutes(minutes: minutes, time: birth.time),
            timeZoneIdentifier: tzID
        ) else {
            throw BigThreeCalculationError.historicalTimezoneUnavailable
        }
        let jd = HumayAstronomyEngine.julianDay(from: utc)

        let sunLong = HumayAstronomyEngine.sunLongitude(julianDay: jd)
        let moonLong = HumayAstronomyEngine.moonLongitude(julianDay: jd)
        let ascLong = HumayAstronomyEngine.ascendantLongitude(julianDay: jd, latitude: lat, longitude: lon)

        let sunPos = try BigThreePosition(longitudeDegrees: sunLong)
        let moonPos = try BigThreePosition(longitudeDegrees: moonLong)
        let ascPos = try BigThreePosition(longitudeDegrees: ascLong)

        // Approximate time: mark reliability as uncertain if near cusp.
        // For v1 we still return available but could expose uncertainty via
        // reliability flag later. Keep available now; the tolerance broadens
        // future ambiguity checks if needed.
        if case .approximate = birth.time {
            // If within tolerance the Moon could have crossed, we could flag
            // ambiguous. For known approximate time, we keep available as per
            // spec ("approximate" still isKnown). The undecided case is handled
            // only for `.unknown` per §10. Exact behaviour for approximate stays
            // available — no silent noon substitution.
            _ = () // placeholder for future uncertainty attachment
        }

        return BigThree(
            sun: .available(sunPos),
            moon: .available(moonPos),
            rising: .available(ascPos),
            metadata: metadata
        )
    }

    // MARK: Unknown time

    private func calculateUnknownTime(birth: BirthDetails, metadata: BigThreeCalculationMetadata) throws -> BigThree {
        // Rising is always unavailable without time+place.
        let rising: AstrologyAvailability<BigThreePosition> = .unavailable(reason: .missingBirthTime)

        // Without a place we cannot produce any longitude-based sign; fall back
        // to date-table Sun if determinable, otherwise invalid.
        guard case .known(_, let lat, let lon, let tzID) = birth.place else {
            // No place at all: we can still provide Sun from longitude math using
            // noon UTC at GMT as a coarse fallback ONLY if day-range is stable.
            // Prefer the canonical tropical date table as the honest fallback,
            // but to keep longitude semantics we approximate via noon GMT.
            let sun = try sunForUnknownTimeWithoutPlace(birth: birth)
            return BigThree(sun: sun, moon: .unavailable(reason: .missingBirthPlace), rising: rising, metadata: metadata)
        }

        // With place but unknown time: sample the whole local day in UTC.
        // Sun: safe if same sign all day.
        // Moon: safe if same sign all sampled points.
        let sunAvail = try sunForUnknownTimeWithPlace(birth: birth, tzID: tzID)
        let moonAvail = try moonForUnknownTime(birth: birth, tzID: tzID)

        // Even though Rising is structurally unavailable, also consider missing
        // time vs missing place distinction for metadata.
        _ = (lat, lon) // validated above, kept to show place was required

        return BigThree(sun: sunAvail, moon: moonAvail, rising: rising, metadata: metadata)
    }

    private func sunForUnknownTimeWithPlace(birth: BirthDetails, tzID: String) throws -> AstrologyAvailability<BigThreePosition> {
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
            // Representative longitude = noon value (midpoint) — still deterministic
            // and inside the same sign; safe to present.
            guard let noon = BirthInstantResolver.noonUTC(for: birth) else {
                return .unavailable(reason: .missingBirthPlace)
            }
            let noonLong = HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon))
            let pos = try BigThreePosition(longitudeDegrees: noonLong)
            return .available(pos)
        } else {
            // Sun cusp day — ambiguous without time.
            let p1 = try BigThreePosition(longitudeDegrees: longStart)
            let p2 = try BigThreePosition(longitudeDegrees: longEnd)
            return .ambiguous(options: [p1, p2])
        }
    }

    private func sunForUnknownTimeWithoutPlace(birth: BirthDetails) throws -> AstrologyAvailability<BigThreePosition> {
        // Use noon GMT as a neutral anchor and check day-range via GMT.
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
            let pos = try BigThreePosition(longitudeDegrees: HumayAstronomyEngine.sunLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon)))
            return .available(pos)
        } else {
            return .ambiguous(options: [try BigThreePosition(longitudeDegrees: sLong), try BigThreePosition(longitudeDegrees: eLong)])
        }
    }

    private func moonForUnknownTime(birth: BirthDetails, tzID: String) throws -> AstrologyAvailability<BigThreePosition> {
        let samples = BirthInstantResolver.sampledInstantsForUnknownTimeDay(birth: birth)
        guard !samples.isEmpty else { return .unavailable(reason: .missingBirthPlace) }
        let longs = samples.map { HumayAstronomyEngine.moonLongitude(julianDay: HumayAstronomyEngine.julianDay(from: $0)) }
        let signs = try longs.map { try BigThreePosition(longitudeDegrees: $0).sign }
        let distinct = Array(Set(signs))
        if distinct.count == 1 {
            // Stable all day — produce noon value as representative.
            guard let noon = BirthInstantResolver.noonUTC(for: birth) else {
                return .unavailable(reason: .missingBirthPlace)
            }
            let noonLong = HumayAstronomyEngine.moonLongitude(julianDay: HumayAstronomyEngine.julianDay(from: noon))
            let pos = try BigThreePosition(longitudeDegrees: noonLong)
            return .available(pos)
        } else {
            // Could be 2 signs if it crossed once during the day. Return
            // ambiguous with the distinct sign options (deduped positions).
            var seen: Set<WesternZodiacSign> = []
            var options: [BigThreePosition] = []
            for long in longs {
                let p = try BigThreePosition(longitudeDegrees: long)
                if seen.insert(p.sign).inserted {
                    options.append(p)
                }
            }
            // Cap to 2 most relevant; lunar day never spans >2 signs (13°/day).
            return .ambiguous(options: Array(options.prefix(2)))
        }
    }

    // MARK: Validation

    private func validate(birth: BirthDetails) throws {
        // Birth date 1900...today already validated by BirthCalculationInput,
        // but calculator is also used directly from Profile — re-validate lightly.
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent
        var comps = DateComponents(); comps.year = birth.year; comps.month = birth.month; comps.day = birth.day
        comps.calendar = cal; comps.timeZone = cal.timeZone
        guard let cand = cal.date(from: comps) else { throw BigThreeCalculationError.invalidBirthDate }
        let res = cal.dateComponents([.year, .month, .day], from: cand)
        guard res.year == birth.year, res.month == birth.month, res.day == birth.day else {
            throw BigThreeCalculationError.invalidBirthDate
        }
        // Time
        switch birth.time {
        case .exact(let m): guard (0...1439).contains(m) else { throw BigThreeCalculationError.invalidBirthTime }
        case .approximate(let m, let tol): guard (0...1439).contains(m), tol > 0 else { throw BigThreeCalculationError.invalidBirthTime }
        case .unknown: break
        }
        // Place / timezone / coordinates
        if case .known(let name, let lat, let lon, let tzID) = birth.place {
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw BigThreeCalculationError.invalidBirthDate }
            guard lat.isFinite, (-90...90).contains(lat) else { throw BigThreeCalculationError.invalidLatitude }
            guard lon.isFinite, (-180...180).contains(lon) else { throw BigThreeCalculationError.invalidLongitude }
            guard TimeZone(identifier: tzID) != nil else { throw BigThreeCalculationError.invalidTimeZoneIdentifier }
        }
    }

    private func expandedMinutes(minutes: Int, time: BirthTime) -> Int {
        // For .approximate we still calculate at the central minute; ambiguity
        // could be assessed over the window in a future reliability layer.
        minutes
    }
}


