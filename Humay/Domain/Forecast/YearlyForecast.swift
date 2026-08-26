import Foundation

/// A dimension of the yearly entertainment forecast. These are Humay-original
/// playful axes (Category C), not astrological measurements.
enum MoodDimension: String, CaseIterable, Sendable, Hashable, Codable, Identifiable {
    case overall
    case romance
    case social
    case career
    case energy
    case confidence
    case patience
    case chaos

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .overall: "Overall"
        case .romance: "Romance"
        case .social: "Social"
        case .career: "Career"
        case .energy: "Energy"
        case .confidence: "Confidence"
        case .patience: "Patience"
        case .chaos: "Chaos"
        }
    }

    var symbol: String {
        switch self {
        case .overall: "sparkles"
        case .romance: "heart"
        case .social: "person.2"
        case .career: "briefcase"
        case .energy: "bolt"
        case .confidence: "crown"
        case .patience: "leaf"
        case .chaos: "tornado"
        }
    }
}

/// Validated 0–100 scores for one day across all dimensions.
struct MoodScores: Sendable, Hashable {
    fileprivate let storage: [MoodDimension: Int]

    init(_ values: [MoodDimension: Int]) {
        var validated: [MoodDimension: Int] = [:]
        for dimension in MoodDimension.allCases {
            let raw = values[dimension] ?? 50
            validated[dimension] = max(0, min(100, raw))
        }
        storage = validated
    }

    subscript(dimension: MoodDimension) -> Int {
        storage[dimension] ?? 50
    }
}

/// One day of the rolling year. `dayOffset` counts from the forecast start date;
/// converting to calendar dates happens at presentation with an explicit anchor.
struct DailyMood: Identifiable, Sendable, Hashable {
    let dayOffset: Int
    let scores: MoodScores
    /// Rare human notes ("your birthday", "maximum chaos Tuesday"). Empty most days.
    let note: String?

    var id: Int { dayOffset }
}

/// Where content came from and whether it can be trusted as current. This is the
/// seam future AI generation plugs into without touching presentation.
enum ContentBasis: Sendable, Hashable, Codable {
    /// Deterministic fixture generation shipped with the app.
    case entertainmentFixture
    /// Future AI-generated personalization.
    case aiGenerated(modelIdentifier: String)

    var isPersonalizedAI: Bool {
        if case .aiGenerated = self { return true }
        return false
    }
}

struct ContentProvenance: Sendable, Hashable, Codable {
    let generatorVersion: String
    let generatedAt: Date
    let basis: ContentBasis

    static func fixture(generatorVersion: String) -> ContentProvenance {
        ContentProvenance(
            generatorVersion: generatorVersion,
            generatedAt: .now,
            basis: .entertainmentFixture
        )
    }

    /// Whether stored content is compatible with this app build's expectations.
    func isCompatibleWith(currentGeneratorVersion: String) -> Bool {
        generatorVersion == currentGeneratorVersion
    }
}

/// Approximately one rolling year of daily entertainment mood data for a profile.
///
/// Generation is per-profile and cacheable (generate once → persist → reuse).
/// This type never claims astronomical truth; it is the entertainment dataset.
struct YearlyForecast: Sendable, Hashable {
    static let dayCount = 365
    /// Bumped when generation copy/shape changes meaningfully; stale caches can
    /// then be regenerated instead of silently mixed.
    static let currentGeneratorVersion = "humay-fixture-1"

    let profileID: UUID
    let days: [DailyMood]
    let provenance: ContentProvenance

    init(profileID: UUID, days: [DailyMood], provenance: ContentProvenance) {
        self.profileID = profileID
        self.days = days
        self.provenance = provenance
    }

    func mood(atDayOffset offset: Int) -> DailyMood? {
        guard days.indices.contains(offset) else { return nil }
        return days[offset]
    }

    func topDays(in dimension: MoodDimension, count: Int) -> [DailyMood] {
        days.sorted { $0.scores[dimension] > $1.scores[dimension] }.prefix(count).map(\.self)
    }

    func bottomDays(in dimension: MoodDimension, count: Int) -> [DailyMood] {
        days.sorted { $0.scores[dimension] < $1.scores[dimension] }.prefix(count).map(\.self)
    }

    func monthAverage(_ monthIndex: Int, anchor: ForecastAnchor, calendar: Calendar = .current) -> Double? {
        let offsets = anchor.dayOffsets(inMonthIndex: monthIndex, totalDays: days.count, calendar: calendar)
        guard !offsets.isEmpty else { return nil }
        let values = offsets.compactMap { mood(atDayOffset: $0) }.map { $0.scores[.overall] }
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
}

/// Converts between forecast day offsets and civil dates. The anchor owns the
/// timezone/calendar policy so Domain stays free of hidden instants.
struct ForecastAnchor: Sendable, Hashable {
    public let startYear: Int
    public let startMonth: Int
    public let startDay: Int

    public init(year: Int, month: Int, day: Int) {
        self.startYear = year
        self.startMonth = month
        self.startDay = day
    }

    public init(date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.startYear = components.year ?? 2026
        self.startMonth = components.month ?? 1
        self.startDay = components.day ?? 1
    }

    public func date(forDayOffset offset: Int, calendar: Calendar = .current) -> Date? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        guard let start = gregorian.date(from: DateComponents(year: startYear, month: startMonth, day: startDay)) else {
            return nil
        }
        return gregorian.date(byAdding: .day, value: offset, to: start)
    }

    public func dayOffset(for date: Date, calendar: Calendar = .current) -> Int? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        guard let start = gregorian.date(from: DateComponents(year: startYear, month: startMonth, day: startDay)) else {
            return nil
        }
        let days = gregorian.dateComponents([.day], from: gregorian.startOfDay(for: start), to: gregorian.startOfDay(for: date)).day
        return days
    }

    /// Day offsets belonging to the Nth month of the rolling year (0-based).
    public func dayOffsets(inMonthIndex index: Int, totalDays: Int, calendar: Calendar = .current) -> [Int] {
        guard index >= 0, index < 12 else { return [] }
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        guard let startDate = gregorian.date(from: DateComponents(year: startYear, month: startMonth, day: startDay)),
              let monthStart = gregorian.date(byAdding: .month, value: index, to: startDate),
              let nextMonthStart = gregorian.date(byAdding: .month, value: 1, to: monthStart)
        else { return [] }

        let lowerBound = gregorian.dateComponents([.day], from: startDate, to: monthStart).day ?? 0
        let upperBound = gregorian.dateComponents([.day], from: startDate, to: nextMonthStart).day ?? totalDays
        return Array(max(0, lowerBound)..<min(totalDays, max(0, upperBound)))
    }

    public func monthName(index: Int, calendar: Calendar = .current) -> String {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        guard let startDate = gregorian.date(from: DateComponents(year: startYear, month: startMonth, day: startDay)),
              let monthDate = gregorian.date(byAdding: .month, value: index, to: startDate)
        else { return "" }
        return monthDate.formatted(.dateTime.month(.wide).locale(calendar.locale ?? .current))
    }
}
