import Foundation
import Testing
@testable import Humay

@Suite("D3 Sky and Calendar contracts")
struct D3FeatureModelTests {
    @Test("Calendar dates and intervals reject invalid values")
    func invalidDateAndTimingAreRejected() throws {
        #expect(throws: SkyContractValidationError.invalidCalendarDate) {
            try SkyCalendarDate(year: 2026, month: 2, day: 30)
        }

        let instant = Date(timeIntervalSince1970: 1_786_464_000)
        #expect(throws: SkyContractValidationError.invalidTimeInterval) {
            try SkyEventInterval(start: instant, end: instant)
        }
        #expect(throws: SkyContractValidationError.invalidTimeInterval) {
            try SkyEventInterval(start: instant, end: instant.addingTimeInterval(-1))
        }
    }

    @Test("Unknown event time remains explicitly unavailable")
    func unavailableTimingIsExplicit() {
        let timing = SkyEventTiming.unavailable(.methodologyNotApproved)
        #expect(timing == .unavailable(.methodologyNotApproved))
    }

    @Test("Loaded contracts reject empty or structurally invalid content")
    func loadedContractValidation() throws {
        let context = try SkyObservationContext(timeZoneIdentifier: "Europe/Istanbul")
        let august = try SkyCalendarMonthID(year: 2026, month: 8)

        #expect(throws: SkyContractValidationError.emptyLoadedContent) {
            try SkySnapshot(
                observedAt: Date(timeIntervalSince1970: 1_786_464_000),
                context: context,
                events: []
            )
        }

        #expect(throws: SkyContractValidationError.emptyLoadedContent) {
            try SkyCalendarMonth(
                selection: august,
                context: context,
                days: []
            )
        }

        let start = try SkyCalendarDate(year: 2026, month: 8, day: 10)
        #expect(throws: SkyContractValidationError.invalidCalendarWeek) {
            try SkyCalendarWeek(startDate: start, context: context, days: [])
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
    }
#endif
}
