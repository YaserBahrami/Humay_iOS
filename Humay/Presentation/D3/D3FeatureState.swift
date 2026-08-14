import Foundation

enum D3ContentSource: String, Sendable, Hashable {
    case productionUnavailable
    case developmentSample

    var isDevelopmentSample: Bool { self == .developmentSample }
}

enum D3FeatureUnavailability: Sendable, Hashable {
    case dataSourceNotConnected
    case unsupportedMethodology
    case missingTimeZone
    case missingLocation
    case eventNotFound
}

enum D3FeatureFailure: Sendable, Hashable {
    case invalidContent
    case temporarilyUnavailable
    case unknown
}

enum CurrentSkyFeatureState: Sendable, Hashable {
    case loading
    case loaded(SkySnapshot)
    case empty
    case unavailable(D3FeatureUnavailability)
    case offline(cached: SkySnapshot?)
    case failed(D3FeatureFailure)
}

enum SkyCalendarMonthFeatureState: Sendable, Hashable {
    case loading(SkyCalendarMonthID)
    case loaded(SkyCalendarMonth)
    case empty(SkyCalendarMonthID)
    case unavailable(selection: SkyCalendarMonthID?, reason: D3FeatureUnavailability)
    case offline(selection: SkyCalendarMonthID, cached: SkyCalendarMonth?)
    case failed(selection: SkyCalendarMonthID?, failure: D3FeatureFailure)
}

enum SkyCalendarWeekFeatureState: Sendable, Hashable {
    case loading(startDate: SkyCalendarDate)
    case loaded(SkyCalendarWeek)
    case empty(startDate: SkyCalendarDate)
    case unavailable(startDate: SkyCalendarDate?, reason: D3FeatureUnavailability)
    case offline(startDate: SkyCalendarDate, cached: SkyCalendarWeek?)
    case failed(startDate: SkyCalendarDate?, failure: D3FeatureFailure)
}

enum SkyEventDetailFeatureState: Sendable, Hashable {
    case loading(SkyEventID)
    case loaded(SkyEventDetail)
    case unavailable(eventID: SkyEventID, reason: D3FeatureUnavailability)
    case offline(eventID: SkyEventID, cached: SkyEventDetail?)
    case failed(eventID: SkyEventID, failure: D3FeatureFailure)
}

/// Immutable D3 input shared by the approved Current Sky presentation and future
/// Calendar/Event Detail surfaces. Provider and persistence work stay outside it.
struct D3FeatureInput: Sendable, Hashable {
    let source: D3ContentSource
    let currentSky: CurrentSkyFeatureState
    let calendarMonth: SkyCalendarMonthFeatureState
    let calendarWeek: SkyCalendarWeekFeatureState
    let eventDetails: [SkyEventID: SkyEventDetailFeatureState]

    func eventDetailState(for eventID: SkyEventID) -> SkyEventDetailFeatureState {
        eventDetails[eventID] ?? .unavailable(
            eventID: eventID,
            reason: .eventNotFound
        )
    }

    static let productionUnavailable = D3FeatureInput(
        source: .productionUnavailable,
        currentSky: .unavailable(.dataSourceNotConnected),
        calendarMonth: .unavailable(
            selection: nil,
            reason: .dataSourceNotConnected
        ),
        calendarWeek: .unavailable(
            startDate: nil,
            reason: .dataSourceNotConnected
        ),
        eventDetails: [:]
    )
}
