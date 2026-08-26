import Foundation

/// Canonical 366-day calendar key (MM-DD) used by the offline content pack.
///
/// The pack is intentionally not bound to a calendar year; one entry for `03-15`
/// serves every year's March 15. Non-leap years simply never request `02-29`.
/// `Date` still determines weekday/year/timeline position locally at runtime.
struct CanonicalDayKey: Sendable, Hashable, Codable, Comparable {
    /// Two-digit month "01"..."12".
    let month: Int
    /// Two-digit day "01"..."31" (validated against month).
    let day: Int

    /// Canonical string representation "MM-DD".
    var key: String {
        String(format: "%02d-%02d", month, day)
    }

    init(month: Int, day: Int) throws {
        guard (1...12).contains(month) else {
            throw ContentPackError.invalidDayKey("\(month)-\(day)")
        }
        let maxDay = Self.daysInMonth(month)
        guard (1...maxDay).contains(day) else {
            throw ContentPackError.invalidDayKey(String(format: "%02d-%02d", month, day))
        }
        self.month = month
        self.day = day
    }

    init(key: String) throws {
        let parts = key.split(separator: "-")
        guard parts.count == 2,
              let m = Int(parts[0]),
              let d = Int(parts[1])
        else {
            throw ContentPackError.invalidDayKey(key)
        }
        try self.init(month: m, day: d)
    }

    static func from(date: Date, calendar: Calendar = .current) -> CanonicalDayKey {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let comps = gregorian.dateComponents([.month, .day], from: date)
        // Force-unwrap is safe: Gregorian always yields month/day.
        // swiftlint:disable:next force_try
        return try! CanonicalDayKey(month: comps.month ?? 1, day: comps.day ?? 1)
    }

    /// All 366 canonical keys in calendar order (01-01 ... 12-31 including 02-29).
    static var all366: [CanonicalDayKey] {
        var result: [CanonicalDayKey] = []
        result.reserveCapacity(366)
        for month in 1...12 {
            let maxDay = daysInMonth(month)
            for day in 1...maxDay {
                // swiftlint:disable:next force_try
                result.append(try! CanonicalDayKey(month: month, day: day))
            }
        }
        return result
    }

    /// Rolling day offset → canonical key, handling year boundaries and leap day.
    static func key(forDayOffset offset: Int, anchor: ForecastAnchor, calendar: Calendar = .current) -> CanonicalDayKey? {
        guard let date = anchor.date(forDayOffset: offset, calendar: calendar) else { return nil }
        return from(date: date, calendar: calendar)
    }

    static func < (lhs: CanonicalDayKey, rhs: CanonicalDayKey) -> Bool {
        if lhs.month != rhs.month { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }

    // MARK: - Helpers

    private static func daysInMonth(_ month: Int) -> Int {
        switch month {
        case 2: 29 // include leap day
        case 4, 6, 9, 11: 30
        default: 31
        }
    }
}

// MARK: - Codable as "MM-DD" string

extension CanonicalDayKey {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let key = try container.decode(String.self)
        do {
            try self.init(key: key)
        } catch {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid day key: \(key)")
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(key)
    }
}
