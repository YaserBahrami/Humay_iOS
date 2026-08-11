import Foundation

/// What each tradition can say from a birth date alone.
///
/// This is the general profile: a Sun sign, a sidereal Sun rashi and a year pillar.
/// It is not a chart, and the interface says so — Moon, Rising, houses, bhavas and the
/// hour pillar all need a birth time and place.
struct SignProfile: Sendable, Hashable {
    struct Entry: Sendable, Hashable, Identifiable {
        let id: String
        let system: ChartSystem
        /// The label in that system's own words: "Sun", "Surya Rashi", "Year".
        let label: String
        let value: String
        let glyph: String
        let glyphSpokenName: String
    }

    let westernSun: WesternSign
    let vedicSuryaRashi: Rashi
    let chineseYearPillar: Pillar
    let headline: String
    let body: String
    /// States the limits of a date-only reading, in plain words.
    let basisNote: String
    let provenance: ContentProvenance

    var entries: [Entry] {
        [
            Entry(
                id: "western",
                system: .western,
                label: "Sun",
                value: westernSun.spokenName,
                glyph: westernSun.glyph,
                glyphSpokenName: westernSun.spokenName
            ),
            Entry(
                id: "vedic",
                system: .vedic,
                label: "Surya Rashi",
                value: vedicSuryaRashi.spokenName,
                glyph: vedicSuryaRashi.glyph,
                glyphSpokenName: vedicSuryaRashi.spokenName
            ),
            Entry(
                id: "chinese",
                system: .chinese,
                label: "Year",
                value: "\(chineseYearPillar.stem.spokenName) \(chineseYearPillar.branch.animalSpokenName)",
                glyph: chineseYearPillar.branch.animalHan,
                glyphSpokenName: chineseYearPillar.spokenDescription
            ),
        ]
    }
}

/// A term that needs explaining, scoped to the system it belongs to.
///
/// `system` is non-optional so a glossary entry can never be system-agnostic. A
/// Nakshatra definition must not be reachable from a Western screen.
struct GlossaryTerm: Sendable, Hashable, Identifiable {
    let id: String
    let system: ChartSystem
    let term: String
    let definition: String
    /// What this term additionally requires, when it is not calculable from a date.
    let requirement: String?
}

/// One placement, opened on its own.
struct PlacementDetail: Sendable, Hashable, Identifiable {
    struct Section: Sendable, Hashable, Identifiable {
        let id: String
        let title: String
        let body: String
        /// Mono fact lines shown beneath the prose.
        let facts: [String]
    }

    let id: String
    let system: ChartSystem
    /// "Sun"
    let title: String
    /// "Pisces"
    let subtitle: String
    /// "4° 12′"
    let precision: String?
    let glyph: String
    let glyphSpokenName: String
    let sections: [Section]
    let provenance: ContentProvenance
}
