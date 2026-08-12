#if DEBUG
import Foundation

/// Development-owned D3 composition. Values are deterministic UI/test samples,
/// excluded from Release, unverified, and never methodology evidence.
enum DevelopmentD3Sample {
    static let lunarEventID = requireID("development.sky.lunar")
    static let ingressEventID = requireID("development.sky.ingress")
    static let gatedEventID = requireID("development.sky.gated")

    static let selectedMonth = require {
        try SkyCalendarMonthID(year: 2026, month: 8)
    }

    static let selectedWeekStart = date(year: 2026, month: 8, day: 10)

    static let context = require {
        try SkyObservationContext(timeZoneIdentifier: "Europe/Istanbul")
    }

    static let lunarEvent = SkyEvent(
        id: lunarEventID,
        type: .lunarPhase,
        system: .astronomical,
        title: "Lunar phase",
        summary: "Deterministic sample copy for future layout testing.",
        timing: .instant(instant(day: 12, hour: 18)),
        relevance: .timeZone,
        reliability: .unverified
    )

    static let ingressEvent = SkyEvent(
        id: ingressEventID,
        type: .planetaryIngress,
        system: .astrological(.western),
        title: "Planetary ingress",
        summary: "Illustrative event content; no calculation is implied.",
        timing: .dateOnly(date(year: 2026, month: 8, day: 14)),
        relevance: .global,
        reliability: .unverified
    )

    static let gatedEvent = SkyEvent(
        id: gatedEventID,
        type: .traditionSpecific(.vedic),
        system: .astrological(.vedic),
        title: "Methodology-gated event",
        summary: nil,
        timing: .unavailable(.methodologyNotApproved),
        relevance: .location,
        reliability: .unverified
    )

    static let snapshot = require {
        try SkySnapshot(
            observedAt: instant(day: 12, hour: 9),
            context: context,
            events: [lunarEvent, ingressEvent, gatedEvent]
        )
    }

    static let month = require {
        try SkyCalendarMonth(
            selection: selectedMonth,
            context: context,
            days: [
                SkyCalendarDay(
                    date: date(year: 2026, month: 8, day: 12),
                    events: [lunarEvent]
                ),
                SkyCalendarDay(
                    date: date(year: 2026, month: 8, day: 14),
                    events: [ingressEvent, gatedEvent]
                )
            ]
        )
    }

    static let week = require {
        let days = (0..<7).map { offset in
            let day = 10 + offset
            let events: [SkyEvent] = switch day {
            case 12: [lunarEvent]
            case 14: [ingressEvent, gatedEvent]
            default: []
            }
            return SkyCalendarDay(
                date: date(year: 2026, month: 8, day: day),
                events: events
            )
        }
        return try SkyCalendarWeek(
            startDate: selectedWeekStart,
            context: context,
            days: days
        )
    }

    static let lunarDetail = SkyEventDetail(
        event: lunarEvent,
        meaning: "Sample meaning stays separate from the event fact.",
        astrologicalBasis: "No calculated basis is supplied by this development sample."
    )

    static func makeInput(arguments: [String] = ProcessInfo.processInfo.arguments) -> D3FeatureInput {
        D3FeatureInput(
            source: .developmentSample,
            currentSky: currentSkyState(
                named: argumentValue(after: "-HumayD3SkyState", in: arguments)
            ),
            calendarMonth: monthState(
                named: argumentValue(after: "-HumayD3MonthState", in: arguments)
            ),
            calendarWeek: weekState(
                named: argumentValue(after: "-HumayD3WeekState", in: arguments)
            ),
            eventDetails: [
                lunarEventID: detailState(
                    named: argumentValue(after: "-HumayD3DetailState", in: arguments)
                )
            ]
        )
    }

    private static func currentSkyState(named name: String?) -> CurrentSkyFeatureState {
        switch name {
        case "loading": .loading
        case "empty": .empty
        case "offline": .offline(cached: snapshot)
        case "offline-empty": .offline(cached: nil)
        case "unavailable": .unavailable(.dataSourceNotConnected)
        case "failed": .failed(.invalidContent)
        default: .loaded(snapshot)
        }
    }

    private static func monthState(named name: String?) -> SkyCalendarMonthFeatureState {
        switch name {
        case "loading": .loading(selectedMonth)
        case "empty": .empty(selectedMonth)
        case "offline": .offline(selection: selectedMonth, cached: month)
        case "offline-empty": .offline(selection: selectedMonth, cached: nil)
        case "unavailable": .unavailable(
            selection: selectedMonth,
            reason: .dataSourceNotConnected
        )
        case "failed": .failed(selection: selectedMonth, failure: .invalidContent)
        default: .loaded(month)
        }
    }

    private static func weekState(named name: String?) -> SkyCalendarWeekFeatureState {
        switch name {
        case "loading": .loading(startDate: selectedWeekStart)
        case "empty": .empty(startDate: selectedWeekStart)
        case "offline": .offline(startDate: selectedWeekStart, cached: week)
        case "offline-empty": .offline(startDate: selectedWeekStart, cached: nil)
        case "unavailable": .unavailable(
            startDate: selectedWeekStart,
            reason: .dataSourceNotConnected
        )
        case "failed": .failed(startDate: selectedWeekStart, failure: .invalidContent)
        default: .loaded(week)
        }
    }

    private static func detailState(named name: String?) -> SkyEventDetailFeatureState {
        switch name {
        case "loading": .loading(lunarEventID)
        case "offline": .offline(eventID: lunarEventID, cached: lunarDetail)
        case "offline-empty": .offline(eventID: lunarEventID, cached: nil)
        case "unavailable": .unavailable(
            eventID: lunarEventID,
            reason: .dataSourceNotConnected
        )
        case "failed": .failed(eventID: lunarEventID, failure: .invalidContent)
        default: .loaded(lunarDetail)
        }
    }

    private static func argumentValue(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private static func date(year: Int, month: Int, day: Int) -> SkyCalendarDate {
        require { try SkyCalendarDate(year: year, month: month, day: day) }
    }

    private static func instant(day: Int, hour: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(
            from: DateComponents(year: 2026, month: 8, day: day, hour: hour)
        )!
    }

    private static func requireID(_ rawValue: String) -> SkyEventID {
        guard let id = SkyEventID(rawValue: rawValue) else {
            preconditionFailure("Development sky event ID must not be empty")
        }
        return id
    }

    private static func require<Value>(_ make: () throws -> Value) -> Value {
        do {
            return try make()
        } catch {
            preconditionFailure("Invalid DevelopmentD3Sample value: \(error)")
        }
    }
}
#endif
