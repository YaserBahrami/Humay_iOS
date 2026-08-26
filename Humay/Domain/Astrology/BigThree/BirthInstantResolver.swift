import Foundation

// MARK: - BirthInstantResolver

/// Converts a local birth date + wall time + IANA zone into the correct
/// historical UTC instant, respecting the zone's daylight-saving rules on the
/// birth date rather than today's offset.
///
/// Foundation's `TimeZone` / `Calendar` already incorporate the IANA database
/// including historical `Asia/Tehran`, `Europe/Istanbul`, etc. This resolver
/// simply builds a calendar with that zone and lets it produce the instant.
enum BirthInstantResolver {
    /// UTC instant for an exact or approximate wall time.
    /// Returns `nil` for `.unknown`.
    static func utcInstant(
        year: Int, month: Int, day: Int,
        minutesFromMidnight: Int,
        timeZoneIdentifier: String
    ) -> Date? {
        guard let tz = TimeZone(identifier: timeZoneIdentifier) else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = minutesFromMidnight / 60
        comps.minute = minutesFromMidnight % 60
        comps.second = 0
        // `Calendar.date(from:)` with a specific TimeZone interprets the
        // components as wall time in that zone, yielding the correct absolute
        // instant including historical DST for that date.
        return calendar.date(from: comps)
    }

    /// Convenience resolving from `BirthDetails` when place and time are known.
    static func utcInstant(for birth: BirthDetails) -> Date? {
        guard let minutes = birth.time.minutesFromMidnight,
              case .known(_, _, _, let tzID) = birth.place else { return nil }
        return utcInstant(
            year: birth.year, month: birth.month, day: birth.day,
            minutesFromMidnight: minutes, timeZoneIdentifier: tzID
        )
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
    /// Used for unknown-time ambiguity detection (start/end ± tolerance).
    static func sampledInstantsForUnknownTimeDay(
        birth: BirthDetails
    ) -> [Date] {
        guard case .known(_, _, _, let tzID) = birth.place else { return [] }
        // Sample at 00:01, 06:00, 12:00, 18:00, 23:59 local to catch Moon
        // crossings that don't align exactly with midnight.
        let minutes = [1, 6 * 60, 12 * 60, 18 * 60, 23 * 60 + 59]
        return minutes.compactMap {
            utcInstant(year: birth.year, month: birth.month, day: birth.day,
                       minutesFromMidnight: $0, timeZoneIdentifier: tzID)
        }
    }

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
}
