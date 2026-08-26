import Foundation
import Testing
@testable import Humay

@Suite("D3 Sky and Calendar contracts")
struct D3FeatureModelTests {
    @Test("Calendar dates and month selections reject months 0 and 13")
    func calendarMonthBoundsAreValidated() {
        for invalidMonth in [0, 13] {
            #expect(throws: SkyContractValidationError.invalidCalendarMonth) {
                try SkyCalendarMonthID(year: 2026, month: invalidMonth)
            }
            #expect(throws: SkyContractValidationError.invalidCalendarDate) {
                try SkyCalendarDate(year: 2026, month: invalidMonth, day: 1)
            }
        }
    }

    @Test("Calendar dates reject invalid civil dates")
    func invalidCivilDatesAreRejected() {
        #expect(throws: SkyContractValidationError.invalidCalendarDate) {
            try SkyCalendarDate(year: 2026, month: 2, day: 30)
        }
        #expect(throws: SkyContractValidationError.invalidCalendarDate) {
            try SkyCalendarDate(year: 2026, month: 4, day: 31)
        }
    }

    @Test("Observation context validates timezone identifiers")
    func observationTimeZonesAreValidated() throws {
        #expect(throws: SkyContractValidationError.invalidTimeZoneIdentifier) {
            try SkyObservationContext(timeZoneIdentifier: "Mars/Olympus_Mons")
        }

        let context = try SkyObservationContext(
            timeZoneIdentifier: "Europe/Istanbul",
            locationName: "Istanbul"
        )
        #expect(context.timeZoneIdentifier == "Europe/Istanbul")
        #expect(context.locationName == "Istanbul")
    }

    @Test("Calendar month rejects dates outside its selection")
    func monthRejectsDateOutsideSelection() throws {
        let context = try testContext()
        let selection = try SkyCalendarMonthID(year: 2026, month: 8)
        let outsideDay = SkyCalendarDay(
            date: try testDate(year: 2026, month: 9, day: 1),
            events: [try testEvent()]
        )

        #expect(throws: SkyContractValidationError.calendarDateOutsideSelection) {
            try SkyCalendarMonth(
                selection: selection,
                context: context,
                days: [outsideDay]
            )
        }
    }

    @Test("Calendar month rejects duplicate and out-of-order dates")
    func monthRejectsDuplicateAndOutOfOrderDates() throws {
        let context = try testContext()
        let selection = try SkyCalendarMonthID(year: 2026, month: 8)
        let event = try testEvent()
        let day12 = SkyCalendarDay(
            date: try testDate(year: 2026, month: 8, day: 12),
            events: [event]
        )
        let day14 = SkyCalendarDay(
            date: try testDate(year: 2026, month: 8, day: 14),
            events: []
        )

        #expect(throws: SkyContractValidationError.duplicateCalendarDate) {
            try SkyCalendarMonth(
                selection: selection,
                context: context,
                days: [day12, day12]
            )
        }
        #expect(throws: SkyContractValidationError.calendarDatesOutOfOrder) {
            try SkyCalendarMonth(
                selection: selection,
                context: context,
                days: [day14, day12]
            )
        }
    }

    @Test("Loaded calendar month requires an event-bearing day")
    func monthRejectsNoEventBearingDay() throws {
        let context = try testContext()
        let selection = try SkyCalendarMonthID(year: 2026, month: 8)
        let emptyDay = SkyCalendarDay(
            date: try testDate(year: 2026, month: 8, day: 12),
            events: []
        )

        #expect(throws: SkyContractValidationError.emptyLoadedContent) {
            try SkyCalendarMonth(
                selection: selection,
                context: context,
                days: [emptyDay]
            )
        }
    }

    @Test("Valid calendar month succeeds")
    func validMonthSucceeds() throws {
        let context = try testContext()
        let selection = try SkyCalendarMonthID(year: 2026, month: 8)
        let days = [
            SkyCalendarDay(
                date: try testDate(year: 2026, month: 8, day: 12),
                events: [try testEvent()]
            ),
            SkyCalendarDay(
                date: try testDate(year: 2026, month: 8, day: 14),
                events: []
            )
        ]

        let month = try SkyCalendarMonth(
            selection: selection,
            context: context,
            days: days
        )
        #expect(month.selection == selection)
        #expect(month.days == days)
    }

    @Test("Calendar week requires exactly seven days")
    func weekRequiresSevenDays() throws {
        let context = try testContext()
        let start = try testDate(year: 2026, month: 8, day: 10)
        let event = try testEvent()

        #expect(throws: SkyContractValidationError.invalidCalendarWeek) {
            try SkyCalendarWeek(
                startDate: start,
                context: context,
                days: try weekDays(start: start, count: 6, event: event)
            )
        }
        #expect(throws: SkyContractValidationError.invalidCalendarWeek) {
            try SkyCalendarWeek(
                startDate: start,
                context: context,
                days: try weekDays(start: start, count: 8, event: event)
            )
        }
    }

    @Test("Calendar week rejects non-contiguous dates and incorrect start date")
    func weekValidatesSequenceAndStart() throws {
        let context = try testContext()
        let start = try testDate(year: 2026, month: 8, day: 10)
        let event = try testEvent()
        var nonContiguous = try weekDays(start: start, count: 7, event: event)
        nonContiguous[3] = SkyCalendarDay(
            date: try testDate(year: 2026, month: 8, day: 14),
            events: []
        )

        #expect(throws: SkyContractValidationError.invalidCalendarWeek) {
            try SkyCalendarWeek(
                startDate: start,
                context: context,
                days: nonContiguous
            )
        }

        let wrongDays = try weekDays(
            start: try testDate(year: 2026, month: 8, day: 11),
            count: 7,
            event: event
        )
        #expect(throws: SkyContractValidationError.invalidCalendarWeek) {
            try SkyCalendarWeek(
                startDate: start,
                context: context,
                days: wrongDays
            )
        }
    }

    @Test("Valid calendar week can cross a month boundary")
    func validWeekCrossesMonthBoundary() throws {
        let context = try testContext()
        let start = try testDate(year: 2026, month: 8, day: 29)
        let days = try weekDays(start: start, count: 7, event: try testEvent())

        let week = try SkyCalendarWeek(
            startDate: start,
            context: context,
            days: days
        )
        let expectedEnd = try testDate(year: 2026, month: 9, day: 4)
        #expect(week.days.first?.date == start)
        #expect(week.days.last?.date == expectedEnd)
    }

    @Test("Loaded seven-day week requires an event-bearing day")
    func weekRejectsNoEventBearingDay() throws {
        let context = try testContext()
        let start = try testDate(year: 2026, month: 8, day: 10)

        #expect(throws: SkyContractValidationError.emptyLoadedContent) {
            try SkyCalendarWeek(
                startDate: start,
                context: context,
                days: try weekDays(start: start, count: 7, event: nil)
            )
        }
    }

    @Test("Sky events validate tradition and system ownership")
    func eventSystemOwnershipIsValidated() throws {
        let astronomical = try testEvent(
            type: .lunarPhase,
            system: .astronomical
        )
        #expect(astronomical.system == .astronomical)

        let vedic = try testEvent(
            type: .traditionSpecific(.vedic),
            system: .astrological(.vedic)
        )
        #expect(vedic.type == .traditionSpecific(.vedic))
        #expect(vedic.system == .astrological(.vedic))

        #expect(throws: SkyContractValidationError.incompatibleEventSystem) {
            try testEvent(
                type: .traditionSpecific(.vedic),
                system: .astrological(.western)
            )
        }
        #expect(throws: SkyContractValidationError.incompatibleEventSystem) {
            try testEvent(
                type: .traditionSpecific(.vedic),
                system: .astronomical
            )
        }
    }

    @Test("Event timing keeps interval date-only instant and unavailable states distinct")
    func eventTimingIsValidatedAndExplicit() throws {
        let instant = Date(timeIntervalSince1970: 1_786_464_000)
        #expect(throws: SkyContractValidationError.invalidTimeInterval) {
            try SkyEventInterval(start: instant, end: instant)
        }
        #expect(throws: SkyContractValidationError.invalidTimeInterval) {
            try SkyEventInterval(start: instant, end: instant.addingTimeInterval(-1))
        }

        let interval = try SkyEventInterval(
            start: instant,
            end: instant.addingTimeInterval(60)
        )
        #expect(interval.start == instant)
        #expect(interval.end == instant.addingTimeInterval(60))

        let civilDate = try testDate(year: 2026, month: 8, day: 12)
        let dateOnly = SkyEventTiming.dateOnly(civilDate)
        let exactInstant = SkyEventTiming.instant(instant)
        #expect(dateOnly != exactInstant)
        #expect(SkyEventTiming.unavailable(.methodologyNotApproved) == .unavailable(
            .methodologyNotApproved
        ))
    }

    @Test("Loaded snapshot rejects empty content")
    func loadedSnapshotRejectsEmptyContent() throws {
        let context = try testContext()

        #expect(throws: SkyContractValidationError.emptyLoadedContent) {
            try SkySnapshot(
                observedAt: Date(timeIntervalSince1970: 1_786_464_000),
                context: context,
                events: []
            )
        }
    }

    @Test("Release composition exposes no sample sky content")
    func releaseCompositionIsUnavailable() throws {
        let input = D3FeatureInput.productionUnavailable

        #expect(input.source == .productionUnavailable)
        #expect(!input.source.isDevelopmentSample)
        #expect(input.currentSky == .unavailable(.dataSourceNotConnected))
        #expect(input.calendarMonth == .unavailable(
            selection: nil,
            reason: .dataSourceNotConnected
        ))
        #expect(input.calendarWeek == .unavailable(
            startDate: nil,
            reason: .dataSourceNotConnected
        ))
        #expect(input.eventDetails.isEmpty)

        let unknownID = try #require(SkyEventID(rawValue: "unknown"))
        #expect(input.eventDetailState(for: unknownID) == .unavailable(
            eventID: unknownID,
            reason: .eventNotFound
        ))
    }

    @Test("Sky methodology formatter preserves system ownership")
    func methodologyLabelsRemainDistinct() {
        #expect(SkyMethodologyFormatter.label(for: .astronomical) == "Astronomical")
        #expect(SkyMethodologyFormatter.label(for: .astrological(.western)) == "Western")
        #expect(SkyMethodologyFormatter.label(for: .astrological(.vedic)) == "Vedic")
        #expect(SkyMethodologyFormatter.label(for: .astrological(.chinese)) == "Chinese")
    }

    @Test("Sky timing formatter never adds a clock to date-only timing")
    func timingFormatterDoesNotFabricateDateTime() throws {
        let context = try testContext()
        let date = try testDate(year: 2026, month: 8, day: 14)

        let dateOnly = SkyEventTimingFormatter.text(
            for: .dateOnly(date),
            context: context
        )
        let unavailable = SkyEventTimingFormatter.text(
            for: .unavailable(.calculationUnavailable),
            context: context
        )

        #expect(dateOnly == "Date only · 14 August")
        #expect(!dateOnly.contains(":"))
        #expect(unavailable == "Unavailable · timing not supplied")
    }

    @Test("Sky timing formatter uses supplied observation timezone")
    func timingFormatterUsesSuppliedTimezone() throws {
        let context = try SkyObservationContext(timeZoneIdentifier: "Europe/Istanbul")
        let instant = Date(timeIntervalSince1970: 1_786_464_000)

        let formatted = SkyEventTimingFormatter.text(
            for: .instant(instant),
            context: context
        )

        #expect(formatted.contains("TRT") || formatted.contains("GMT+3"))
    }

    @Test("App composition keeps D3 input at the application boundary")
    func appCompositionKeepsD3AtBoundary() {
        let production = D3FeatureInput.productionUnavailable
        #expect(production.source == .productionUnavailable)

#if DEBUG
        let development = DevelopmentD3Sample.makeInput(arguments: [])
        #expect(development.source == .developmentSample)
        #expect(development.currentSky == .loaded(DevelopmentD3Sample.snapshot))
#endif
    }

#if DEBUG
    @Test("Development composition is deterministic and fully typed")
    func developmentCompositionIsDeterministic() {
        let first = DevelopmentD3Sample.makeInput(arguments: [])
        let second = DevelopmentD3Sample.makeInput(arguments: [])

        #expect(first == second)
        #expect(first.source == .developmentSample)
        #expect(first.source.isDevelopmentSample)
        #expect(first.currentSky == .loaded(DevelopmentD3Sample.snapshot))
        #expect(first.calendarMonth == .loaded(DevelopmentD3Sample.month))
        #expect(first.calendarWeek == .loaded(DevelopmentD3Sample.week))
        #expect(DevelopmentD3Sample.referenceToday == testDateUnchecked(year: 2026, month: 8, day: 13))
        #expect(DevelopmentD3Sample.month.days.first(where: { $0.date.day == 14 })?.events.count == 3)
        #expect(DevelopmentD3Sample.week.days.first(where: { $0.date.day == 14 })?.events.count == 3)
        #expect(DevelopmentD3Sample.snapshot.events.allSatisfy {
            $0.reliability == .unverified
        })
        #expect(first.eventDetailState(for: DevelopmentD3Sample.lunarEventID) == .loaded(
            DevelopmentD3Sample.lunarDetail
        ))
    }

    @Test("Development arguments expose loading empty unavailable offline and error states")
    func developmentStateSemantics() {
        let loading = DevelopmentD3Sample.makeInput(arguments: [
            "-HumayD3SkyState", "loading",
            "-HumayD3MonthState", "loading",
            "-HumayD3WeekState", "loading",
            "-HumayD3DetailState", "loading"
        ])
        #expect(loading.currentSky == .loading)
        #expect(loading.calendarMonth == .loading(DevelopmentD3Sample.selectedMonth))
        #expect(loading.calendarWeek == .loading(
            startDate: DevelopmentD3Sample.selectedWeekStart
        ))

        let emptyAndUnavailable = DevelopmentD3Sample.makeInput(arguments: [
            "-HumayD3SkyState", "empty",
            "-HumayD3MonthState", "empty",
            "-HumayD3WeekState", "unavailable",
            "-HumayD3DetailState", "unavailable"
        ])
        #expect(emptyAndUnavailable.currentSky == .empty)
        #expect(emptyAndUnavailable.calendarMonth == .empty(
            DevelopmentD3Sample.selectedMonth
        ))
        #expect(emptyAndUnavailable.calendarWeek == .unavailable(
            startDate: DevelopmentD3Sample.selectedWeekStart,
            reason: .dataSourceNotConnected
        ))

        let offlineAndFailed = DevelopmentD3Sample.makeInput(arguments: [
            "-HumayD3SkyState", "offline",
            "-HumayD3MonthState", "offline-empty",
            "-HumayD3WeekState", "failed",
            "-HumayD3DetailState", "failed"
        ])
        #expect(offlineAndFailed.currentSky == .offline(
            cached: DevelopmentD3Sample.snapshot
        ))
        #expect(offlineAndFailed.calendarMonth == .offline(
            selection: DevelopmentD3Sample.selectedMonth,
            cached: nil
        ))
        #expect(offlineAndFailed.calendarWeek == .failed(
            startDate: DevelopmentD3Sample.selectedWeekStart,
            failure: .invalidContent
        ))
        #expect(offlineAndFailed.eventDetailState(
            for: DevelopmentD3Sample.lunarEventID
        ) == .failed(
            eventID: DevelopmentD3Sample.lunarEventID,
            failure: .invalidContent
        ))

        let cached = DevelopmentD3Sample.makeInput(arguments: [
            "-HumayD3MonthState", "offline",
            "-HumayD3WeekState", "offline"
        ])
        #expect(cached.calendarMonth == .offline(
            selection: DevelopmentD3Sample.selectedMonth,
            cached: DevelopmentD3Sample.month
        ))
        #expect(cached.calendarWeek == .offline(
            startDate: DevelopmentD3Sample.selectedWeekStart,
            cached: DevelopmentD3Sample.week
        ))

        let detailStates = DevelopmentD3Sample.makeInput()
        #expect(detailStates.eventDetailState(for: DevelopmentD3Sample.ingressEventID) == .loaded(
            DevelopmentD3Sample.ingressDetail
        ))
        #expect(detailStates.eventDetailState(for: DevelopmentD3Sample.aspectEventID) == .loaded(
            DevelopmentD3Sample.aspectDetail
        ))
        #expect(detailStates.eventDetailState(for: DevelopmentD3Sample.gatedEventID) == .unavailable(
            eventID: DevelopmentD3Sample.gatedEventID,
            reason: .unsupportedMethodology
        ))
        #expect(detailStates.eventDetailState(for: DevelopmentD3Sample.seasonalEventID) == .unavailable(
            eventID: DevelopmentD3Sample.seasonalEventID,
            reason: .eventNotFound
        ))
    }
#endif

    @Test("Event detail presentation labels keep facts and availability user-facing")
    func eventDetailPresentationLabels() {
        #expect(SkyEventRelevanceFormatter.label(for: .global) == "Global")
        #expect(SkyEventRelevanceFormatter.label(for: .timeZone) == "Observation timezone")
        #expect(SkyEventReliabilityFormatter.label(for: .unverified) == "Unverified sample")
        #expect(SkyEventReliabilityFormatter.label(for: .approximate(.roundedTiming)) == "Approximate · rounded timing")

        let notFound = SkyEventDetailStateFormatter.unavailableCopy(for: .eventNotFound)
        #expect(notFound.title == "Event not found")
        #expect(notFound.detail == "This event is no longer available.")

        let failed = SkyEventDetailStateFormatter.failureCopy(for: .invalidContent)
        #expect(failed.title == "Event detail unavailable")
        #expect(failed.detail == "The supplied event facts could not be loaded.")
    }

    @Test("Calendar reference grid stays Monday-first and supports six rows")
    func calendarReferenceGridIsMondayFirst() throws {
        let august = try SkyCalendarMonthID(year: 2026, month: 8)
        let dates = SkyCalendarSupport.monthGridDates(for: august)
        let july27 = try SkyCalendarDate(year: 2026, month: 7, day: 27)
        let august1 = try SkyCalendarDate(year: 2026, month: 8, day: 1)
        let august2 = try SkyCalendarDate(year: 2026, month: 8, day: 2)
        let september6 = try SkyCalendarDate(year: 2026, month: 9, day: 6)

        #expect(dates.count == 42)
        #expect(dates.first == july27)
        #expect(dates[5] == august1)
        #expect(dates[6] == august2)
        #expect(dates.last == september6)
    }

    @Test("Calendar preserves quiet-day distinction in supplied fixture")
    func calendarQuietDayIsNotProviderFailure() throws {
        let quietDate = try SkyCalendarDate(year: 2026, month: 8, day: 16)
        let monthDays = Dictionary(uniqueKeysWithValues: DevelopmentD3Sample.month.days.map { ($0.date, $0.events) })

        #expect(monthDays[quietDate] == nil)
        #expect(!monthDays.keys.contains(quietDate))
    }

    @Test("Calendar timing presentation keeps exact, range, date-only and unavailable forms")
    func calendarTimingPresentationUsesCentralFormatter() throws {
        let context = try testContext()
        let exact = DevelopmentD3Sample.lunarEvent.timing
        let dateOnly = SkyEventTiming.dateOnly(try testDate(year: 2026, month: 8, day: 14))
        let interval = SkyEventTiming.interval(try SkyEventInterval(
            start: Date(timeIntervalSince1970: 1_786_464_000),
            end: Date(timeIntervalSince1970: 1_786_496_400)
        ))

        #expect(SkyEventTimingFormatter.calendarText(for: exact, context: context) == "Exact · 18:00 TRT")
        #expect(SkyEventTimingFormatter.calendarText(for: dateOnly, context: context) == "Date only · 14 August")
        #expect(SkyEventTimingFormatter.calendarText(for: interval, context: context).contains("–"))
        #expect(SkyEventTimingFormatter.calendarText(
            for: .unavailable(.methodologyNotApproved),
            context: context
        ) == "Timing unavailable")
    }

    private func testContext() throws -> SkyObservationContext {
        try SkyObservationContext(timeZoneIdentifier: "Europe/Istanbul")
    }

#if DEBUG
    private func testDateUnchecked(year: Int, month: Int, day: Int) -> SkyCalendarDate {
        do {
            return try SkyCalendarDate(year: year, month: month, day: day)
        } catch {
            preconditionFailure("Test date must be valid")
        }
    }
#endif

    private func testDate(year: Int, month: Int, day: Int) throws -> SkyCalendarDate {
        try SkyCalendarDate(year: year, month: month, day: day)
    }

    private func testEvent(
        type: SkyEventType = .lunarPhase,
        system: SkyEventSystem = .astronomical
    ) throws -> SkyEvent {
        let id = try #require(SkyEventID(rawValue: "test.sky.event"))
        return try SkyEvent(
            id: id,
            type: type,
            system: system,
            title: "Test event",
            summary: nil,
            timing: .unavailable(.calculationUnavailable),
            relevance: .global,
            reliability: .unverified
        )
    }

    private func weekDays(
        start: SkyCalendarDate,
        count: Int,
        event: SkyEvent?
    ) throws -> [SkyCalendarDay] {
        try (0..<count).map { offset in
            SkyCalendarDay(
                date: try adding(days: offset, to: start),
                events: offset == 0 ? event.map { [$0] } ?? [] : []
            )
        }
    }

    private func adding(days: Int, to date: SkyCalendarDate) throws -> SkyCalendarDate {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let foundationDate = try #require(calendar.date(from: DateComponents(
            year: date.year,
            month: date.month,
            day: date.day
        )))
        let shiftedDate = try #require(
            calendar.date(byAdding: .day, value: days, to: foundationDate)
        )
        let components = calendar.dateComponents([.year, .month, .day], from: shiftedDate)
        return try SkyCalendarDate(
            year: try #require(components.year),
            month: try #require(components.month),
            day: try #require(components.day)
        )
    }
}
