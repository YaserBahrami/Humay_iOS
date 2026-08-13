import Foundation

/// Presentation-only names for Humay-owned Sky methodology values.
enum SkyMethodologyFormatter {
    static func label(for system: SkyEventSystem) -> String {
        switch system {
        case .astronomical:
            "Astronomical"
        case .astrological(let tradition):
            label(for: tradition)
        }
    }

    static func label(for tradition: AstrologyTradition) -> String {
        switch tradition {
        case .western:
            "Western"
        case .vedic:
            "Vedic"
        case .chinese:
            "Chinese"
        }
    }
}

enum SkyEventTypeFormatter {
    static func label(for type: SkyEventType) -> String {
        switch type {
        case .lunarPhase:
            "Lunar phase"
        case .planetaryIngress:
            "Planetary ingress"
        case .planetaryAspect:
            "Planetary aspect"
        case .planetaryStation:
            "Planetary station"
        case .seasonalTransition:
            "Seasonal transition"
        case .traditionSpecific:
            "Tradition-specific event"
        }
    }
}

/// Formats event timing from the observation context supplied by D3.
/// Device timezone is never used when a context is present.
enum SkyEventTimingFormatter {
    static func text(
        for timing: SkyEventTiming,
        context: SkyObservationContext,
        observedAt: Date? = nil
    ) -> String {
        switch timing {
        case .instant(let date):
            let day = isSameCivilDay(date, observedAt, context: context)
                ? "Today"
                : dateString(date, context: context, format: "EEE")
            return "Exact · \(day) \(timeString(date, context: context)) \(zoneString(for: date, context: context))"

        case .interval(let interval):
            let startDay = dateString(interval.start, context: context, format: "EEE")
            let endDay = dateString(interval.end, context: context, format: "EEE")
            let start = "\(startDay) \(timeString(interval.start, context: context))"
            let end = isSameCivilDay(interval.start, interval.end, context: context)
                ? timeString(interval.end, context: context)
                : "\(endDay) \(timeString(interval.end, context: context))"
            return "\(start) – \(end)"

        case .dateOnly(let date):
            return "Date only · \(dateOnlyString(date))"

        case .unavailable(let reason):
            return unavailableText(for: reason)
        }
    }

    static func accessibilityText(
        for timing: SkyEventTiming,
        context: SkyObservationContext,
        observedAt: Date? = nil
    ) -> String {
        switch timing {
        case .instant(let date):
            let day = isSameCivilDay(date, observedAt, context: context)
                ? "today"
                : dateString(date, context: context, format: "EEEE")
            return "Exact timing, \(day) at \(timeString(date, context: context)) \(zoneString(for: date, context: context))"

        case .interval(let interval):
            let startDay = dateString(interval.start, context: context, format: "EEEE")
            let endDay = dateString(interval.end, context: context, format: "EEEE")
            let start = "\(startDay) at \(timeString(interval.start, context: context))"
            let end = isSameCivilDay(interval.start, interval.end, context: context)
                ? timeString(interval.end, context: context)
                : "\(endDay) at \(timeString(interval.end, context: context))"
            return "From \(start) until \(end) \(zoneString(for: interval.start, context: context))"

        case .dateOnly(let date):
            return "Date only, \(dateOnlyString(date))"

        case .unavailable(let reason):
            return unavailableText(for: reason)
        }
    }

    static func observationText(
        for date: Date,
        context: SkyObservationContext
    ) -> String {
        "Observed \(timeString(date, context: context)) \(zoneString(for: date, context: context))"
    }

    static func contextText(for context: SkyObservationContext) -> String {
        context.locationName ?? context.timeZoneIdentifier
    }

    static func civilDateComponents(
        for timing: SkyEventTiming,
        context: SkyObservationContext
    ) -> (month: String, day: String)? {
        let date: Date?
        switch timing {
        case .instant(let value):
            date = value
        case .interval(let interval):
            date = interval.start
        case .dateOnly(let civilDate):
            return (
                month: monthString(civilDate),
                day: String(civilDate.day)
            )
        case .unavailable:
            date = nil
        }

        guard let date else { return nil }
        return (
            month: dateString(date, context: context, format: "MMM"),
            day: dateString(date, context: context, format: "d")
        )
    }

    private static func unavailableText(for reason: SkyTimingUnavailability) -> String {
        switch reason {
        case .calculationUnavailable:
            "Unavailable · timing not supplied"
        case .methodologyNotApproved:
            "Unavailable · methodology not approved"
        case .timeZoneUnavailable:
            "Unavailable · timezone not supplied"
        case .locationRequired:
            "Unavailable · location required"
        }
    }

    private static func dateOnlyString(_ date: SkyCalendarDate) -> String {
        let month = DateFormatter.monthName.string(
            from: DateComponents(
                calendar: Calendar(identifier: .gregorian),
                year: date.year,
                month: date.month,
                day: date.day
            ).date ?? .distantPast
        )
        return "\(date.day) \(month)"
    }

    private static func monthString(_ date: SkyCalendarDate) -> String {
        DateFormatter.monthShortName.string(
            from: DateComponents(
                calendar: Calendar(identifier: .gregorian),
                year: date.year,
                month: date.month,
                day: date.day
            ).date ?? .distantPast
        ).uppercased()
    }

    private static func dateString(
        _ date: Date,
        context: SkyObservationContext,
        format: String
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone(for: context)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private static func timeString(
        _ date: Date,
        context: SkyObservationContext
    ) -> String {
        dateString(date, context: context, format: "HH:mm")
    }

    private static func zoneString(
        for date: Date,
        context: SkyObservationContext
    ) -> String {
        let timeZone = timeZone(for: context)
        return timeZone.abbreviation(for: date) ?? context.timeZoneIdentifier
    }

    private static func isSameCivilDay(
        _ lhs: Date,
        _ rhs: Date?,
        context: SkyObservationContext
    ) -> Bool {
        guard let rhs else { return false }
        let calendar = calendar(for: context)
        return calendar.isDate(lhs, inSameDayAs: rhs)
    }

    private static func isSameCivilDay(
        _ lhs: Date,
        _ rhs: Date,
        context: SkyObservationContext
    ) -> Bool {
        calendar(for: context).isDate(lhs, inSameDayAs: rhs)
    }

    private static func calendar(for context: SkyObservationContext) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone(for: context)
        return calendar
    }

    private static func timeZone(for context: SkyObservationContext) -> TimeZone {
        TimeZone(identifier: context.timeZoneIdentifier) ?? .gmt
    }
}

private extension DateFormatter {
    static let monthName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .gmt
        formatter.dateFormat = "MMMM"
        return formatter
    }()

    static let monthShortName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .gmt
        formatter.dateFormat = "MMM"
        return formatter
    }()
}

private extension DateComponents {
    var date: Date? {
        Calendar(identifier: .gregorian).date(from: self)
    }
}
