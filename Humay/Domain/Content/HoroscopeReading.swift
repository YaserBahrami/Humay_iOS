import Foundation

/// How specific a piece of content is entitled to be.
///
/// The distinction is a claim about what the content was derived from, so it travels
/// with the content rather than being decided by the screen showing it.
enum PrecisionTier: String, Sendable, Hashable {
    /// Derived from a coarse bucket — a Sun sign, a year pillar. True of a great many
    /// people at once, and labelled as such.
    case general
    /// Derived from a calculated chart and the current sky.
    case precise

    var badgeLabel: String {
        switch self {
        case .general: "General"
        case .precise: "Precise"
        }
    }
}

/// The four areas a daily reading is broken into.
enum ReadingCategory: String, Sendable, CaseIterable, Identifiable, Codable {
    case love, career, finance, health

    var id: String { rawValue }

    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

/// A factor a reading rests on.
///
/// Shown behind the astrological basis disclosure. Every reading in the application can
/// produce these, because the product promise is that a reading opens to show its
/// reasoning rather than asserting.
struct BasisFactor: Sendable, Hashable, Identifiable {
    let id: String
    let system: ChartSystem
    /// "Moon → H8"
    let label: String
    /// "15:42"
    let detail: String
}

/// Why a reading says what it says.
///
/// The basis belongs to the *reading*, not to the register it is written in. Normal and
/// Roast share one basis; a unit test asserts it.
struct ReadingBasis: Sendable, Hashable {
    /// One sentence stating what this reading was derived from, and what it was not.
    let summary: String
    let factors: [BasisFactor]

    static let none = ReadingBasis(summary: "", factors: [])
}

/// A daily reading.
struct HoroscopeReading: Sendable, Hashable, Identifiable {
    let id: String
    let date: DateComponents
    let tier: PrecisionTier
    let tone: Tone
    /// Who or what the reading is about: "Pisces", "Your chart", "You and Sara".
    let subjectLabel: String
    let headline: String
    /// The reading itself. Absent for the compact per-category form.
    let overview: String?
    let categories: [ReadingCategory: String]
    let basis: ReadingBasis
    let provenance: ContentProvenance

    func text(for category: ReadingCategory) -> String? {
        categories[category]
    }
}
