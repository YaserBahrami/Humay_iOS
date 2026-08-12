import Foundation

enum D2ContentSource: String, Sendable, Hashable {
    case productionUnavailable
    case developmentSample

    var isDevelopmentSample: Bool { self == .developmentSample }
}

enum TodayFeatureState: Sendable, Hashable {
    case loading
    case loaded(TodayContent)
    case cached(TodayContent, savedAt: Date)
    case offline(cached: TodayContent?)
    case failed(message: String)
}

enum DailyHoroscopeFeatureState: Sendable, Hashable {
    case loading(period: HoroscopePeriod)
    case free(DailyHoroscopeContent)
    case preciseLocked(freeReading: DailyHoroscopeContent)
    case preciseLoaded(DailyHoroscopeContent)
    case cached(DailyHoroscopeContent, savedAt: Date)
    case offline(cached: DailyHoroscopeContent?)
    case failed(period: HoroscopePeriod, message: String)

    var period: HoroscopePeriod {
        switch self {
        case .loading(let period), .failed(let period, _): period
        case .free(let reading),
             .preciseLocked(let reading),
             .preciseLoaded(let reading),
             .cached(let reading, _): reading.period
        case .offline(let reading): reading?.period ?? .today
        }
    }
}

enum CircleFeatureState: Sendable, Hashable {
    case loading
    case loaded([CirclePerson])
    case empty
    case offline(cached: [CirclePerson])
    case failed(message: String)

    var people: [CirclePerson] {
        switch self {
        case .loaded(let people), .offline(let people): people
        case .loading, .empty, .failed: []
        }
    }
}

enum CompatibilityFeatureState: Sendable, Hashable {
    case entry
    case loading(pair: CompatibilityPair)
    case freeLoaded(FreeCompatibilityResult)
    case preciseLocked(freeResult: FreeCompatibilityResult)
    case preciseLoaded(PreciseCompatibilityResult)
    case cached(PreciseCompatibilityResult, savedAt: Date)
    case offline(cached: PreciseCompatibilityResult?)
    case failed(pair: CompatibilityPair?, message: String)
}

/// Immutable feature input injected at the App-to-Presentation boundary.
struct D2FeatureInput: Sendable, Hashable {
    let source: D2ContentSource
    let today: TodayFeatureState
    let dailyHoroscope: [HoroscopePeriod: DailyHoroscopeFeatureState]
    let circle: CircleFeatureState
    let compatibility: CompatibilityFeatureState
    let preciseDailyPreview: DailyHoroscopeContent?
    let preciseCompatibilityPreview: PreciseCompatibilityResult?

    func dailyState(for period: HoroscopePeriod) -> DailyHoroscopeFeatureState {
        dailyHoroscope[period] ?? .failed(
            period: period,
            message: "This reading is not available yet."
        )
    }

    static let productionUnavailable = D2FeatureInput(
        source: .productionUnavailable,
        today: .failed(message: "Daily content is not connected yet."),
        dailyHoroscope: Dictionary(
            uniqueKeysWithValues: HoroscopePeriod.allCases.map {
                ($0, .failed(period: $0, message: "Daily content is not connected yet."))
            }
        ),
        circle: .empty,
        compatibility: .entry,
        preciseDailyPreview: nil,
        preciseCompatibilityPreview: nil
    )
}
