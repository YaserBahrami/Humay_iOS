import Foundation

/// Typed validation failures for externally generated forecast content.
///
/// Invalid AI output must never reach Presentation. These errors carry enough
/// structure to log precisely and to drive recovery decisions.
enum ForecastValidationError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
    case scoreOutOfRange(dimension: MoodDimension?, value: Int, metricName: String)
    case missingDimension(MoodDimension)
    case emptyRequiredText(field: String)
    case textTooLong(field: String, length: Int, maximum: Int)
    case invalidMonthlyThemeCount(count: Int)
    case invalidMonthIndex(Int)
    case invalidPeriodRange(NotablePeriod)
    case duplicateDayOffset(Int)
    case dayOffsetOutOfRange(Int)
    case daysNotSorted
    case invalidSummaryLength(Int)
    case excessiveRepetition(detail: String)
    case invalidAnchorDate
    case missingDays(offsets: [Int], count: Int)
}

/// Centralized validation for normalized forecast content. Every externally
/// sourced day passes through here before it may enter a persisted document.
enum ForecastValidator {
    /// Maximum tolerated repetition inside one month of headlines. Normalized
    /// lowercase alphanumeric comparison; cheap, no semantic infrastructure.
    static let minimumUniqueHeadlineRatio = 0.6

    static func validate(days: [DailyMood], expectedOffsets: [Int]? = nil) throws {
        var seen = Set<Int>()
        var previousOffset = Int.min

        for day in days {
            guard !seen.contains(day.dayOffset) else {
                throw ForecastValidationError.duplicateDayOffset(day.dayOffset)
            }
            seen.insert(day.dayOffset)

            guard day.dayOffset >= 0, day.dayOffset < YearlyForecast.dayCount * 2 else {
                throw ForecastValidationError.dayOffsetOutOfRange(day.dayOffset)
            }
            guard day.dayOffset >= previousOffset else {
                throw ForecastValidationError.daysNotSorted
            }
            previousOffset = day.dayOffset

            if let summary = day.summary {
                guard (0...280).contains(summary.count) else {
                    throw ForecastValidationError.invalidSummaryLength(summary.count)
                }
            }
        }

        if let expectedOffsets {
            let present = Set(days.map(\.dayOffset))
            let missing = expectedOffsets.filter { !present.contains($0) }
            if !missing.isEmpty {
                throw ForecastValidationError.missingDays(offsets: Array(missing.prefix(5)), count: missing.count)
            }
        }
    }

    /// Soft QA check: flags suspiciously repetitive copy without failing hard.
    /// Returns nil when the sample is too small to judge.
    static func repetitionIssue(headlines: [String], label: String) -> ForecastValidationError? {
        guard headlines.count >= 8 else { return nil }
        let normalized = headlines.map { normalize($0) }
        let unique = Set(normalized).count
        let ratio = Double(unique) / Double(normalized.count)
        guard ratio < minimumUniqueHeadlineRatio else { return nil }
        return .excessiveRepetition(detail: "\(label): \(unique)/\(normalized.count) unique headlines")
    }

    static func normalize(_ text: String) -> String {
        text.lowercased()
            .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
            .split(separator: " ")
            .joined(separator: " ")
    }
}
