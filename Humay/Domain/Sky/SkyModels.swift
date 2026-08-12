import Foundation

/// Stable Humay-owned identity for a sky event. Provider identifiers are translated
/// at a future Data boundary rather than crossing into Domain or Presentation.
struct SkyEventID: RawRepresentable, Identifiable, Sendable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        self.rawValue = normalized
    }

    var id: String { rawValue }
}

/// Civil date used to group events in Humay's calendar. This is not an instant and
/// does not imply an astrology methodology or hidden timezone.
struct SkyCalendarDate: Sendable, Hashable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day)

        guard let date = calendar.date(from: components) else {
            throw SkyContractValidationError.invalidCalendarDate
        }

        let resolved = calendar.dateComponents([.year, .month, .day], from: date)
        guard resolved.year == year,
              resolved.month == month,
              resolved.day == day else {
            throw SkyContractValidationError.invalidCalendarDate
        }

        self.year = year
        self.month = month
        self.day = day
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    fileprivate func adding(days: Int) -> Self? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components),
              let result = calendar.date(byAdding: .day, value: days, to: date) else {
            return nil
        }
        let resolved = calendar.dateComponents([.year, .month, .day], from: result)
        guard let year = resolved.year,
              let month = resolved.month,
              let day = resolved.day else {
            return nil
        }
        return try? Self(year: year, month: month, day: day)
    }
}

struct SkyCalendarMonthID: Sendable, Hashable {
    let year: Int
    let month: Int

    init(year: Int, month: Int) throws {
        guard (1...12).contains(month) else {
            throw SkyContractValidationError.invalidCalendarMonth
        }
        self.year = year
        self.month = month
    }
}

/// Context that can materially affect event grouping or timing. Location remains
/// absent unless a real feature supplies it; no default city or coordinates exist.
struct SkyObservationContext: Sendable, Hashable {
    let timeZoneIdentifier: String
    let locationName: String?

    init(timeZoneIdentifier: String, locationName: String? = nil) throws {
        guard TimeZone(identifier: timeZoneIdentifier) != nil else {
            throw SkyContractValidationError.invalidTimeZoneIdentifier
        }
        self.timeZoneIdentifier = timeZoneIdentifier
        self.locationName = locationName
    }
}

enum SkyEventType: Sendable, Hashable {
    case lunarPhase
    case planetaryIngress
    case planetaryAspect
    case planetaryStation
    case seasonalTransition
    case traditionSpecific(AstrologyTradition)
}

/// Whether an event is shared astronomical context or belongs to one astrology
/// tradition. This prevents a future provider from flattening every event into a
/// universal Western transit shape.
enum SkyEventSystem: Sendable, Hashable {
    case astronomical
    case astrological(AstrologyTradition)
}

enum SkyEventRelevance: Sendable, Hashable {
    case global
    case timeZone
    case location
}

enum SkyEventUncertainty: Sendable, Hashable {
    case roundedTiming
    case limitedSourcePrecision
}

/// Sample content uses `unverified`; only validated calculation/catalog work may
/// promote an event to `reliable` later.
enum SkyEventReliability: Sendable, Hashable {
    case reliable
    case approximate(SkyEventUncertainty)
    case unverified
}

enum SkyTimingUnavailability: Sendable, Hashable {
    case calculationUnavailable
    case methodologyNotApproved
    case timeZoneUnavailable
    case locationRequired
}

struct SkyEventInterval: Sendable, Hashable {
    let start: Date
    let end: Date

    init(start: Date, end: Date) throws {
        guard end > start else {
            throw SkyContractValidationError.invalidTimeInterval
        }
        self.start = start
        self.end = end
    }
}

/// Timing states are mutually exclusive. Unknown clock time is represented as a
/// date-only or unavailable value, never as a fabricated midnight/noon instant.
enum SkyEventTiming: Sendable, Hashable {
    case instant(Date)
    case interval(SkyEventInterval)
    case dateOnly(SkyCalendarDate)
    case unavailable(SkyTimingUnavailability)
}

/// Compact event information shared by Current Sky and calendar surfaces.
struct SkyEvent: Identifiable, Sendable, Hashable {
    let id: SkyEventID
    let type: SkyEventType
    let system: SkyEventSystem
    let title: String
    let summary: String?
    let timing: SkyEventTiming
    let relevance: SkyEventRelevance
    let reliability: SkyEventReliability
}

/// Detail keeps interpretation and factual basis separate. Neither is allowed to
/// substitute for the other when future providers are connected.
struct SkyEventDetail: Sendable, Hashable {
    let event: SkyEvent
    let meaning: String?
    let astrologicalBasis: String?
}

struct SkySnapshot: Sendable, Hashable {
    let observedAt: Date
    let context: SkyObservationContext
    let events: [SkyEvent]

    init(
        observedAt: Date,
        context: SkyObservationContext,
        events: [SkyEvent]
    ) throws {
        guard !events.isEmpty else {
            throw SkyContractValidationError.emptyLoadedContent
        }
        self.observedAt = observedAt
        self.context = context
        self.events = events
    }
}

struct SkyCalendarDay: Identifiable, Sendable, Hashable {
    let date: SkyCalendarDate
    let events: [SkyEvent]

    var id: SkyCalendarDate { date }
}

struct SkyCalendarMonth: Sendable, Hashable {
    let selection: SkyCalendarMonthID
    let context: SkyObservationContext
    let days: [SkyCalendarDay]

    init(
        selection: SkyCalendarMonthID,
        context: SkyObservationContext,
        days: [SkyCalendarDay]
    ) throws {
        guard days.contains(where: { !$0.events.isEmpty }) else {
            throw SkyContractValidationError.emptyLoadedContent
        }
        guard days.allSatisfy({
            $0.date.year == selection.year && $0.date.month == selection.month
        }) else {
            throw SkyContractValidationError.calendarDateOutsideSelection
        }
        guard Set(days.map(\.date)).count == days.count else {
            throw SkyContractValidationError.duplicateCalendarDate
        }
        guard days.map(\.date) == days.map(\.date).sorted() else {
            throw SkyContractValidationError.calendarDatesOutOfOrder
        }

        self.selection = selection
        self.context = context
        self.days = days
    }
}

struct SkyCalendarWeek: Sendable, Hashable {
    let startDate: SkyCalendarDate
    let context: SkyObservationContext
    let days: [SkyCalendarDay]

    init(
        startDate: SkyCalendarDate,
        context: SkyObservationContext,
        days: [SkyCalendarDay]
    ) throws {
        guard days.count == 7 else {
            throw SkyContractValidationError.invalidCalendarWeek
        }
        for offset in days.indices {
            guard startDate.adding(days: offset) == days[offset].date else {
                throw SkyContractValidationError.invalidCalendarWeek
            }
        }
        guard days.contains(where: { !$0.events.isEmpty }) else {
            throw SkyContractValidationError.emptyLoadedContent
        }

        self.startDate = startDate
        self.context = context
        self.days = days
    }
}

enum SkyContractValidationError: Error, Equatable, Sendable {
    case invalidCalendarDate
    case invalidCalendarMonth
    case invalidTimeZoneIdentifier
    case invalidTimeInterval
    case emptyLoadedContent
    case calendarDateOutsideSelection
    case duplicateCalendarDate
    case calendarDatesOutOfOrder
    case invalidCalendarWeek
}
