import Foundation

/// Deterministic two-person temporal comparison (§29).
///
/// Pure math over two forecasts sharing the same anchor. No AI involvement;
/// AI commentary later consumes these structured results (§31).
struct ForecastComparator: Sendable, Equatable {
    let first: YearlyForecast
    let second: YearlyForecast

    /// Day offsets covered by BOTH forecasts.
    var overlappingOffsets: Range<Int> {
        let lower = 0
        let upper = min(first.days.count, second.days.count)
        return lower..<max(lower, upper)
    }

    func firstValue(_ dimension: MoodDimension, at offset: Int) -> Int? {
        first.mood(atDayOffset: offset).map { $0.scores[dimension] }
    }

    func secondValue(_ dimension: MoodDimension, at offset: Int) -> Int? {
        second.mood(atDayOffset: offset).map { $0.scores[dimension] }
    }

    /// 0–100 alignment for one dimension on one day: 100 − |difference|.
    func dayAlignment(_ dimension: MoodDimension, at offset: Int) -> Int? {
        guard let a = firstValue(dimension, at: offset),
              let b = secondValue(dimension, at: offset) else { return nil }
        return 100 - abs(a - b)
    }

    func averageAlignment(_ dimension: MoodDimension, in offsets: Range<Int>) -> Double? {
        let values = offsets.compactMap { dayAlignment(dimension, at: $0) }
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    /// Overall alignment across all dimensions, overlapping range.
    func overallAlignment() -> Int {
        let offsets = overlappingOffsets
        guard !offsets.isEmpty else { return 0 }
        let perDimension = MoodDimension.allCases.compactMap { averageAlignment($0, in: offsets) }
        guard !perDimension.isEmpty else { return 0 }
        return Int((perDimension.reduce(0, +) / Double(perDimension.count)).rounded())
    }

    /// Highest-alignment windows for a dimension (best days to plan around).
    func bestAlignmentWindows(
        dimension: MoodDimension,
        windowLength: Int = 3,
        count: Int = 3
    ) -> [NotablePeriod] {
        rankedWindows(dimension: dimension, windowLength: windowLength, count: count)
    }

    /// Conflict candidates: days where combined chaos is high or combined
    /// patience is low — the "both of you said absolutely not" days.
    func conflictDays(limit: Int = 5) -> [(offset: Int, score: Int)] {
        let offsets = overlappingOffsets
        var scored: [(Int, Int)] = []
        for offset in offsets {
            guard let chaosA = firstValue(.chaos, at: offset),
                  let chaosB = secondValue(.chaos, at: offset),
                  let patienceA = firstValue(.patience, at: offset),
                  let patienceB = secondValue(.patience, at: offset) else { continue }
            let chaosPressure = (chaosA + chaosB) / 2
            let patienceDeficit = 100 - (patienceA + patienceB) / 2
            let combined = max(chaosPressure, patienceDeficit)
            if combined >= 65 {
                scored.append((offset, combined))
            }
        }
        return Array(scored.sorted { $0.1 > $1.1 }.prefix(limit))
    }

    /// Best joint romance days: both romance scores averaged, descending.
    func bestRomanceDays(limit: Int = 5) -> [(offset: Int, score: Int)] {
        topCombinedDays(dimension: .romance, limit: limit)
    }

    /// Calm joint windows: both patience high, both chaos low.
    func calmWindows(windowLength: Int = 3, count: Int = 3) -> [NotablePeriod] {
        let offsets = overlappingOffsets
        guard offsets.count >= windowLength else { return [] }

        func calmScore(_ offset: Int) -> Int {
            let patience = ((firstValue(.patience, at: offset) ?? 50) + (secondValue(.patience, at: offset) ?? 50)) / 2
            let chaos = ((firstValue(.chaos, at: offset) ?? 50) + (secondValue(.chaos, at: offset) ?? 50)) / 2
            return patience + (100 - chaos) - 100
        }

        var windows: [(start: Int, score: Int)] = []
        for start in offsets where start + windowLength <= offsets.upperBound {
            let window = start..<(start + windowLength)
            let average = Double(window.compactMap { calmScore($0) }.reduce(0, +)) / Double(windowLength)
            windows.append((start, Int(average)))
        }
        return windows.sorted { $0.score > $1.score }
            .prefix(count)
            .map { NotablePeriod(startDayOffset: $0.start, endDayOffset: $0.start + windowLength - 1, label: "Calm together", kind: .calm) }
    }

    /// Confidence collision: both confidence high — fun, not dangerous.
    func confidenceCollisions(limit: Int = 3) -> [(offset: Int, score: Int)] {
        let offsets = overlappingOffsets
        var scored: [(Int, Int)] = []
        for offset in offsets {
            guard let a = firstValue(.confidence, at: offset),
                  let b = secondValue(.confidence, at: offset) else { continue }
            let combined = min(a, b)
            if combined >= 75 {
                scored.append((offset, combined))
            }
        }
        return Array(scored.sorted { $0.1 > $1.1 }.prefix(limit))
    }

    // MARK: - Helpers

    private func topCombinedDays(dimension: MoodDimension, limit: Int) -> [(offset: Int, score: Int)] {
        let offsets = overlappingOffsets
        var scored: [(Int, Int)] = []
        for offset in offsets {
            guard let a = firstValue(dimension, at: offset),
                  let b = secondValue(dimension, at: offset) else { continue }
            scored.append((offset, (a + b) / 2))
        }
        return Array(scored.sorted { $0.1 > $1.1 }.prefix(limit))
    }

    private func rankedWindows(
        dimension: MoodDimension,
        windowLength: Int,
        count: Int
    ) -> [NotablePeriod] {
        let offsets = overlappingOffsets
        guard offsets.count >= windowLength else { return [] }

        var windows: [(start: Int, score: Int)] = []
        for start in offsets where start + windowLength <= offsets.upperBound {
            let window = start..<(start + windowLength)
            let scores = window.compactMap { dayAlignment(dimension, at: $0) }
            guard scores.count == windowLength else { continue }
            let average = scores.reduce(0, +) / windowLength
            windows.append((start, average))
        }
        return windows.sorted { $0.score > $1.score }
            .prefix(count)
            .map {
                NotablePeriod(
                    startDayOffset: $0.start,
                    endDayOffset: $0.start + windowLength - 1,
                    label: "Strong \(dimension.displayName.lowercased()) alignment",
                    kind: kind(for: dimension)
                )
            }
    }

    private func kind(for dimension: MoodDimension) -> NotablePeriod.Kind {
        switch dimension {
        case .overall: .calm
        case .romance: .romance
        case .social: .social
        case .career: .career
        case .energy, .confidence: .confidence
        case .patience, .chaos: .calm
        }
    }
}
