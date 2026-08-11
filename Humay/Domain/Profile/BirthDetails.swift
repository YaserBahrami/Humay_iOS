import Foundation

/// A birth time, or the honest absence of one.
///
/// There is deliberately no initialiser that takes an optional and substitutes a
/// default. Constructing an unknown time requires writing `.unknown`, because the
/// product rule is that a missing birth time is never quietly replaced with noon or
/// midnight — the facts that depend on it are withheld instead.
enum BirthTime: Sendable, Hashable {
    case exact(minutesFromMidnight: Int)
    /// A remembered window rather than a clock reading — "some time in the afternoon".
    case approximate(minutesFromMidnight: Int, toleranceMinutes: Int)
    case unknown

    var isKnown: Bool {
        if case .unknown = self { return false }
        return true
    }

    var minutesFromMidnight: Int? {
        switch self {
        case .exact(let minutes), .approximate(let minutes, _): minutes
        case .unknown: nil
        }
    }

    /// Formatted for display, e.g. "7:42 AM" or "around 3:00 PM".
    func formatted(locale: Locale = .current) -> String? {
        guard let minutes = minutesFromMidnight else { return nil }
        var components = DateComponents()
        components.hour = minutes / 60
        components.minute = minutes % 60
        guard let date = Calendar(identifier: .gregorian).date(from: components) else { return nil }
        let text = date.formatted(.dateTime.hour().minute().locale(locale))
        if case .approximate = self { return "around \(text)" }
        return text
    }
}

/// A birth place, or the absence of one.
///
/// Longitude sets the houses and the time zone in force on the day sets almost
/// everything else, so a place is not interchangeable with a city name.
enum BirthPlace: Sendable, Hashable {
    case notProvided
    case known(name: String, latitude: Double, longitude: Double, timeZoneIdentifier: String)

    var isKnown: Bool {
        if case .notProvided = self { return false }
        return true
    }

    var name: String? {
        if case .known(let name, _, _, _) = self { return name }
        return nil
    }

    /// "38°43′N 9°08′W", for the mono fact lines.
    var coordinatesFormatted: String? {
        guard case .known(_, let latitude, let longitude, _) = self else { return nil }
        return "\(Self.format(latitude, positive: "N", negative: "S")) \(Self.format(longitude, positive: "E", negative: "W"))"
    }

    private static func format(_ value: Double, positive: String, negative: String) -> String {
        let hemisphere = value >= 0 ? positive : negative
        let magnitude = abs(value)
        let degrees = Int(magnitude)
        let minutes = Int(((magnitude - Double(degrees)) * 60).rounded())
        return String(format: "%d°%02d′%@", degrees, minutes, hemisphere)
    }
}

/// Everything the application knows about when and where someone was born.
///
/// The date is held as `DateComponents` rather than a `Date` because a birth date is a
/// calendar fact, not an instant. Turning it into an instant requires a time and a zone,
/// which is exactly the information that may be missing.
struct BirthDetails: Sendable, Hashable {
    var year: Int
    var month: Int
    var day: Int
    var time: BirthTime
    var place: BirthPlace

    init(year: Int, month: Int, day: Int, time: BirthTime = .unknown, place: BirthPlace = .notProvided) {
        self.year = year
        self.month = month
        self.day = day
        self.time = time
        self.place = place
    }

    var dateComponents: DateComponents {
        DateComponents(year: year, month: month, day: day)
    }

    /// True when a precise chart is calculable in principle — both a time and a place.
    var supportsPrecision: Bool {
        time.isKnown && place.isKnown
    }

    /// "14 March 1994"
    func dateFormatted(locale: Locale = .current) -> String {
        var components = dateComponents
        components.calendar = Calendar(identifier: .gregorian)
        guard let date = components.date else { return "\(day)/\(month)/\(year)" }
        return date.formatted(.dateTime.day().month(.wide).year().locale(locale))
    }
}
