import Foundation

/// Optional topical context that can influence presentation modules without
/// touching canonical personalized data (§20).
///
/// Trends are replaceable campaign-style inputs: seasonal events, holidays,
/// dating-language moments. They must never rewrite the stored forecast —
/// changing a trend must not invalidate 365 days of cached content.
struct TrendContext: Sendable, Hashable, Codable, Identifiable {
    /// Stable campaign key, e.g. "valentines-2027".
    let id: String
    let title: String
    /// Day offsets (relative to the forecast anchor) the trend applies to.
    let applicableDayOffsets: ClosedRange<Int>
    /// Presentation hints; interpretation stays with the composition layer.
    let accentHint: String?

    init(id: String, title: String, applicableDayOffsets: ClosedRange<Int>, accentHint: String? = nil) {
        self.id = id
        self.title = title
        self.applicableDayOffsets = applicableDayOffsets
        self.accentHint = accentHint
    }

    func applies(toDayOffset offset: Int) -> Bool {
        applicableDayOffsets.contains(offset)
    }
}
