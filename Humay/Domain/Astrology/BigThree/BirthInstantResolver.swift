import Foundation

// MARK: - BirthInstantResolution

/// Explicit resolution of a local wall-clock time in a historical timezone.
enum BirthInstantResolution: Sendable, Equatable, Hashable {
    /// One valid UTC instant.
    case unique(Date)
    /// The wall time occurs twice (fall-back). Both UTC instants are valid.
    case ambiguous(first: Date, second: Date)
    /// The wall time did not exist (spring-forward gap).
    case nonexistent
    /// Invalid inputs (bad zone, impossible date).
    case invalid
}

// MARK: - BirthInstantResolver

/// Converts a local birth date + wall time + IANA zone into the correct
/// historical UTC instant, respecting the zone's daylight-saving rules on the
/// birth date rather than today's offset.
///
/// Foundation's `TimeZone` / `Calendar` already incorporate the IANA database
/// including historical `Asia/Tehran`, `Europe/Istanbul`, etc. This resolver
/// builds a calendar with that zone and lets it produce the instant, but
/// explicitly detects DST gaps and folds rather than silently normalizing.
enum BirthInstantResolver {

    // MARK: - Core resolution

    /// Resolve a wall time to its UTC instant(s).
    static func resolve(
        year: Int, month: Int, day: Int,
        minutesFromMidnight: Int,
        timeZoneIdentifier: String
    ) -> BirthInstantResolution {
        guard let tz = TimeZone(identifier: timeZoneIdentifier) else { return .invalid }
        // Validate minutes range
        guard (0...1439).contains(minutesFromMidnight) else { return .invalid }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = minutesFromMidnight / 60
        comps.minute = minutesFromMidnight % 60
        comps.second = 0

        // Validate date itself (e.g., Feb 30)
        var validationCal = Calendar(identifier: .gregorian)
        validationCal.timeZone = tz
        guard let candidate = validationCal.date(from: comps) else { return .invalid }

        // Check if the produced date round-trips to the same wall components.
        // For a spring-forward gap, Calendar normalizes forward (02:30 -> 03:30),
        // so the round-trip will mismatch. That is the DST gap signal.
        let roundTrip = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: candidate)
        if roundTrip.year != year || roundTrip.month != month || roundTrip.day != day
            || roundTrip.hour != comps.hour || roundTrip.minute != comps.minute {
            // Distinguish invalid date (already nil) from gap: we have a candidate but mismatched wall time
            // Double-check by seeing if the day itself is valid (candidate exists)
            // If the mismatch is due to gap, return nonexistent.
            // For true invalid dates we already returned nil above, so this is gap.
            return .nonexistent
        }

        // Ambiguity detection: fall-back repeated hour.
        // The same wall time maps to two UTC instants 1 hour apart (typically).
        // Calendar.date(from:) returns the *first* occurrence. The second is + delta seconds
        // where delta is the DST offset change (usually 3600, sometimes 1800).
        // Test for repeated wall time at +3600 and +1800.
        let candidateOffset = tz.secondsFromGMT(for: candidate)

        // Check common DST shifts
        let deltas = [3600.0, 1800.0, 3600.0 * 0.5] // 1h, 30m
        // Also derive actual delta from nearby transition if available
        var testDeltas = deltas
        if let transitionDelta = dstDeltaOnDay(year: year, month: month, day: day, timeZone: tz, calendar: calendar) {
            if !testDeltas.contains(Double(transitionDelta)) {
                testDeltas.append(Double(transitionDelta))
            }
        }

        for delta in testDeltas {
            let secondCandidate = candidate.addingTimeInterval(delta)
            let secondComps = calendar.dateComponents([.hour, .minute], from: secondCandidate)
            if secondComps.hour == comps.hour && secondComps.minute == comps.minute {
                let offset2 = tz.secondsFromGMT(for: secondCandidate)
                if offset2 != candidateOffset {
                    // Ensure second candidate is still same civil day in that zone
                    let secondDay = calendar.dateComponents([.year, .month, .day], from: secondCandidate)
                    // For fall-back, same wall time but different UTC; both should be same civil date
                    // If secondCandidate slipped to next civil day due to offset weirdness, ignore
                    if secondDay.year == year && secondDay.month == month && secondDay.day == day {
                        return .ambiguous(first: candidate, second: secondCandidate)
                    }
                }
            }
        }

        return .unique(candidate)
    }

    /// Convenience resolving from `BirthDetails` when place and time are known.
    static func resolve(for birth: BirthDetails) -> BirthInstantResolution {
        guard let minutes = birth.time.minutesFromMidnight,
              case .known(_, _, _, let tzID) = birth.place else { return .invalid }
        return resolve(year: birth.year, month: birth.month, day: birth.day,
                       minutesFromMidnight: minutes, timeZoneIdentifier: tzID)
    }

    /// UTC instant for an exact or approximate wall time.
    /// Returns `nil` for unknown, nonexistent, ambiguous, or invalid.
    /// For ambiguous times, returns the *first* occurrence — callers needing
    /// explicit ambiguity handling should use `resolve(...)` directly.
    static func utcInstant(
        year: Int, month: Int, day: Int,
        minutesFromMidnight: Int,
        timeZoneIdentifier: String
    ) -> Date? {
        switch resolve(year: year, month: month, day: day,
                       minutesFromMidnight: minutesFromMidnight,
                       timeZoneIdentifier: timeZoneIdentifier) {
        case .unique(let d): return d
        case .ambiguous(let first, _): return first // legacy behavior: first occurrence
        case .nonexistent, .invalid: return nil
        }
    }

    /// Convenience resolving from `BirthDetails` when place and time are known.
    static func utcInstant(for birth: BirthDetails) -> Date? {
        guard let minutes = birth.time.minutesFromMidnight,
              case .known(_, _, _, let tzID) = birth.place else { return nil }
        return utcInstant(year: birth.year, month: birth.month, day: birth.day,
                          minutesFromMidnight: minutes, timeZoneIdentifier: tzID)
    }

    /// Validates a `BirthDetails` + time-zone combination early so callers can
    /// surface `invalidTimeZoneIdentifier` / `invalidLatitude` without waiting
    /// for ephemeris math. Returns the resolved IANA `TimeZone` on success.
    static func validateAndResolveTimeZone(_ identifier: String) throws -> TimeZone {
        guard let tz = TimeZone(identifier: identifier) else {
            throw BigThreeCalculationError.invalidTimeZoneIdentifier
        }
        return tz
    }

    /// Produces a UTC `Date` for midday local (12:00) — used as the representative
    /// instant when only the civil date is needed but an ephemeris call requires a
    /// full UTC moment. Callers must still do the day-range ambiguity check for
    /// Sun/Moon when birth time is unknown (never present the noon value as exact).
    static func noonUTC(for birth: BirthDetails) -> Date? {
        guard case .known(_, _, _, let tzID) = birth.place else { return nil }
        return utcInstant(
            year: birth.year, month: birth.month, day: birth.day,
            minutesFromMidnight: 12 * 60, timeZoneIdentifier: tzID
        )
    }

    /// Enumerates UTC instants for sampling across the local birth day.
    /// Used for unknown-time ambiguity detection.
    /// Samples at 00:00, 06:00, 12:00, 18:00, 23:59 local to catch Moon
    /// crossings that don't align exactly with midnight.
    /// Starts at 00:00 (not 00:01) to cover the full civil day.
    static func sampledInstantsForUnknownTimeDay(
        birth: BirthDetails
    ) -> [Date] {
        guard case .known(_, _, _, let tzID) = birth.place else { return [] }
        // Sample at 00:00, 06:00, 12:00, 18:00, 23:59 local.
        // Use exact 00:00 to catch transitions at start of day.
        let minutes = [0, 6 * 60, 12 * 60, 18 * 60, 23 * 60 + 59]
        return minutes.compactMap {
            utcInstant(year: birth.year, month: birth.month, day: birth.day,
                       minutesFromMidnight: $0, timeZoneIdentifier: tzID)
        }
    }

    /// All UTC instants for the local civil day, covering the full 00:00–23:59 interval.
    /// Returns nil if place is not known or day boundaries are invalid (DST gap at midnight is extremely rare).
    static func dayBoundaryInstants(
        birth: BirthDetails
    ) -> (start: Date, end: Date)? {
        guard case .known(_, _, _, let tzID) = birth.place else { return nil }
        guard let start = utcInstant(year: birth.year, month: birth.month, day: birth.day,
                                     minutesFromMidnight: 0, timeZoneIdentifier: tzID),
              let end = utcInstant(year: birth.year, month: birth.month, day: birth.day,
                                   minutesFromMidnight: 23 * 60 + 59, timeZoneIdentifier: tzID) else {
            return nil
        }
        return (start, end)
    }

    /// Enumerates every valid UTC instant for an approximate time window.
    /// Clamped to 0…1439. For nonexistent minutes inside the window (spring gap),
    /// those minutes are skipped (they contribute no valid instant).
    /// For ambiguous minutes (fall-back), the *first* occurrence is used for
    /// sign evaluation, but the full ambiguity check will catch if the second
    /// occurrence yields a different sign (caller handles).
    static func instantsForApproximateTime(birth: BirthDetails, toleranceMinutes: Int) -> [Date] {
        guard case .known(_, _, _, let tzID) = birth.place,
              let central = birth.time.minutesFromMidnight else { return [] }
        let lower = max(0, central - toleranceMinutes)
        let upper = min(1439, central + toleranceMinutes)
        var results: [Date] = []
        results.reserveCapacity(upper - lower + 1)
        for m in lower...upper {
            switch resolve(year: birth.year, month: birth.month, day: birth.day,
                           minutesFromMidnight: m, timeZoneIdentifier: tzID) {
            case .unique(let d):
                results.append(d)
            case .ambiguous(let first, _):
                // Both instants could matter for Rising; include both if they differ in sign
                // For now include first; caller will also evaluate second via resolve check
                // Include both to be exhaustive
                results.append(first)
                // Also append second occurrence for comprehensive sign check
                if case .ambiguous(_, let second) = resolve(year: birth.year, month: birth.month, day: birth.day,
                                                            minutesFromMidnight: m, timeZoneIdentifier: tzID) {
                    results.append(second)
                }
            case .nonexistent, .invalid:
                continue
            }
        }
        return results
    }

    /// Returns both UTC instants for an ambiguous wall time, or nil if not ambiguous.
    static func ambiguousInstants(
        year: Int, month: Int, day: Int,
        minutesFromMidnight: Int,
        timeZoneIdentifier: String
    ) -> (first: Date, second: Date)? {
        if case .ambiguous(let f, let s) = resolve(year: year, month: month, day: day,
                                                   minutesFromMidnight: minutesFromMidnight,
                                                   timeZoneIdentifier: timeZoneIdentifier) {
            return (f, s)
        }
        return nil
    }

    // MARK: - Helpers

    /// Attempts to find DST delta (seconds) for a transition occurring on the given civil day.
    private static func dstDeltaOnDay(year: Int, month: Int, day: Int, timeZone: TimeZone, calendar: Calendar) -> Int? {
        // Build start and end of civil day in that zone
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day; comps.hour = 0; comps.minute = 0; comps.second = 0
        guard let start = calendar.date(from: comps) else { return nil }
        // Look 26 hours ahead for any transition
        let end = start.addingTimeInterval(26 * 3600)
        var probe = start
        var lastOffset = timeZone.secondsFromGMT(for: probe)
        // Sample every 30 minutes to catch transition
        while probe < end {
            probe = probe.addingTimeInterval(1800)
            let offset = timeZone.secondsFromGMT(for: probe)
            if offset != lastOffset {
                return offset - lastOffset
            }
            lastOffset = offset
        }
        return nil
    }
}
