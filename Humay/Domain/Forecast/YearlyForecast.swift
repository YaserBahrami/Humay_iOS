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
struct MoodScores: Sendable, Hashable, Codable {
    fileprivate let storage: [MoodDimension: Int]

    /// Clamping initializer for internally generated values.
    init(_ values: [MoodDimension: Int]) {
        var validated: [MoodDimension: Int] = [:]
        for dimension in MoodDimension.allCases {
            let raw = values[dimension] ?? 50
            validated[dimension] = max(0, min(100, raw))
        }
        storage = validated
    }

    /// Strict initializer for external (AI) values: out-of-range input is rejected,
    /// never silently clamped. Missing dimensions are rejected too.
    init(validating values: [MoodDimension: Int]) throws {
        var validated: [MoodDimension: Int] = [:]
        for dimension in MoodDimension.allCases {
            guard let raw = values[dimension] else {
                throw ForecastValidationError.missingDimension(dimension)
            }
            guard raw >= 0, raw <= 100 else {
                throw ForecastValidationError.scoreOutOfRange(dimension: dimension, value: raw, metricName: dimension.rawValue)
            }
            validated[dimension] = raw
        }
        storage = validated
    }

    subscript(dimension: MoodDimension) -> Int {
        storage[dimension] ?? 50
    }
}

/// Humay-original entertainment metrics for one day (Category C).
/// Chaos deliberately lives in `MoodDimension`; these are the extra play axes.
struct EntertainmentMetrics: Sendable, Hashable, Codable {
    let delusion: Int
    let mainCharacterEnergy: Int
    let dontTextThem: Int

    init(delusion: Int, mainCharacterEnergy: Int, dontTextThem: Int) throws {
        for (name, value) in [("delusion", delusion), ("mainCharacterEnergy", mainCharacterEnergy), ("dontTextThem", dontTextThem)] {
            guard value >= 0, value <= 100 else {
                throw ForecastValidationError.scoreOutOfRange(dimension: nil, value: value, metricName: name)
            }
        }
        self.delusion = delusion
        self.mainCharacterEnergy = mainCharacterEnergy
        self.dontTextThem = dontTextThem
    }
}

/// One semantic reading section with an explicit length bound.
struct DayReadingSection: Sendable, Hashable, Codable {
    static let maxLength = 600

    let category: ReadingCategory
    let text: String

    enum ReadingCategory: String, Sendable, Hashable, Codable, CaseIterable {
        case personal
        case love
        case career
        case money
        case social
    }

    init(category: ReadingCategory, text: String) throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ForecastValidationError.emptyRequiredText(field: "reading.\(category.rawValue)")
        }
        guard trimmed.count <= Self.maxLength else {
            throw ForecastValidationError.textTooLong(field: "reading.\(category.rawValue)", length: trimmed.count, maximum: Self.maxLength)
        }
        self.category = category
        self.text = trimmed
    }
}

/// The semantic (mode-neutral) reading for one day. Expression is applied locally
/// by personality modes; this record never changes when the user switches modes.
struct DayReading: Sendable, Hashable, Codable {
    static let headlineMaxLength = 120

    let headline: String
    let sections: [DayReadingSection]

    init(headline: String, sections: [DayReadingSection]) throws {
        let trimmed = headline.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ForecastValidationError.emptyRequiredText(field: "reading.headline")
        }
        guard trimmed.count <= Self.headlineMaxLength else {
            throw ForecastValidationError.textTooLong(field: "reading.headline", length: trimmed.count, maximum: Self.headlineMaxLength)
        }
        self.headline = trimmed
        self.sections = sections
    }
}

/// Paired flags for one day.
struct DayFlags: Sendable, Hashable, Codable {
    static let maxLength = 140

    let green: String
    let red: String

    init(green: String, red: String) throws {
        for (field, value) in [("green", green), ("red", red)] {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw ForecastValidationError.emptyRequiredText(field: "flags.\(field)")
            }
            guard trimmed.count <= Self.maxLength else {
                throw ForecastValidationError.textTooLong(field: "flags.\(field)", length: trimmed.count, maximum: Self.maxLength)
            }
        }
        self.green = green.trimmingCharacters(in: .whitespacesAndNewlines)
        self.red = red.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// One day of the rolling year. `dayOffset` counts from the forecast start date;
/// converting to calendar dates happens at presentation with an explicit anchor.
///
/// Personalized fields are optional so the deterministic engine and partial AI
/// datasets both produce valid days; consumers must treat absence honestly.
struct DailyMood: Identifiable, Sendable, Hashable, Codable {
    let dayOffset: Int
    let scores: MoodScores
    /// Rare human notes ("your birthday", "maximum chaos Tuesday"). Empty most days.
    let note: String?
    /// Semantic personalized reading, when a personalized dataset exists.
    let reading: DayReading?
    let entertainment: EntertainmentMetrics?
    let flags: DayFlags?
    /// One-line semantic summary (mode-neutral).
    let summary: String?

    init(
        dayOffset: Int,
        scores: MoodScores,
        note: String? = nil,
        reading: DayReading? = nil,
        entertainment: EntertainmentMetrics? = nil,
        flags: DayFlags? = nil,
        summary: String? = nil
    ) {
        self.dayOffset = dayOffset
        self.scores = scores
        self.note = note
        self.reading = reading
        self.entertainment = entertainment
        self.flags = flags
        self.summary = summary
    }

    var id: Int { dayOffset }
}

/// Month-level tendency from the canonical annual plan. Keeps monthly chunks
/// coherent with each other instead of generated in isolation.
struct MonthlyTheme: Sendable, Hashable, Codable {
    let monthIndex: Int
    let theme: String
    let tendency: String

    init(monthIndex: Int, theme: String, tendency: String) {
        self.monthIndex = monthIndex
        self.theme = theme
        self.tendency = tendency
    }
}

/// A highlighted window inside the year (e.g. "best romance stretch").
struct NotablePeriod: Sendable, Hashable, Codable {
    let startDayOffset: Int
    let endDayOffset: Int
    let label: String
    let kind: Kind

    enum Kind: String, Sendable, Hashable, Codable {
        case romance
        case chaos
        case career
        case social
        case calm
        case confidence
    }

    init(startDayOffset: Int, endDayOffset: Int, label: String, kind: Kind) {
        self.startDayOffset = startDayOffset
        self.endDayOffset = endDayOffset
        self.label = label
        self.kind = kind
    }
}

/// Canonical annual context generated before monthly chunks. Month generation
/// receives the relevant slice so the year reads as one story.
struct YearContext: Sendable, Hashable, Codable {
    static let themeMaxLength = 140

    let yearTheme: String
    let monthlyThemes: [MonthlyTheme]
    let notablePeriods: [NotablePeriod]

    init(yearTheme: String, monthlyThemes: [MonthlyTheme], notablePeriods: [NotablePeriod]) throws {
        let trimmed = yearTheme.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ForecastValidationError.emptyRequiredText(field: "yearContext.yearTheme")
        }
        guard trimmed.count <= Self.themeMaxLength else {
            throw ForecastValidationError.textTooLong(field: "yearContext.yearTheme", length: trimmed.count, maximum: Self.themeMaxLength)
        }
        guard monthlyThemes.count == 12 else {
            throw ForecastValidationError.invalidMonthlyThemeCount(count: monthlyThemes.count)
        }
        for theme in monthlyThemes {
            guard (0..<12).contains(theme.monthIndex) else {
                throw ForecastValidationError.invalidMonthIndex(theme.monthIndex)
            }
        }
        for period in notablePeriods {
            guard period.startDayOffset <= period.endDayOffset else {
                throw ForecastValidationError.invalidPeriodRange(period)
            }
        }
        self.yearTheme = trimmed
        self.monthlyThemes = monthlyThemes
        self.notablePeriods = notablePeriods
    }
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
    static let currentGeneratorVersion = "humay-deterministic-v2"

    let profileID: UUID
    let days: [DailyMood]
    let provenance: ContentProvenance
    let yearContext: YearContext?

    init(profileID: UUID, days: [DailyMood], provenance: ContentProvenance, yearContext: YearContext? = nil) {
        self.profileID = profileID
        self.days = days
        self.provenance = provenance
        self.yearContext = yearContext
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
struct ForecastAnchor: Sendable, Hashable, Codable {
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
