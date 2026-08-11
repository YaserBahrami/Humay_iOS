import Foundation

/// Which system a piece of chart content belongs to.
///
/// This exists to *label* content, never to make content from different systems
/// interchangeable. There is no generic "placement" type and no protocol that a
/// Western, Vedic and Chinese chart all conform to, because the grammar of each — an
/// aspect, a yoga, a pillar interaction — is genuinely different content rather than a
/// different skin over the same idea.
enum ChartSystem: String, Sendable, CaseIterable, Identifiable, Codable {
    case western
    case vedic
    case chinese

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .western: "Western · Tropical"
        case .vedic: "Vedic · Sidereal"
        case .chinese: "Chinese · BaZi"
        }
    }

    var shortName: String {
        switch self {
        case .western: "Western"
        case .vedic: "Vedic"
        case .chinese: "Chinese"
        }
    }

    var tradition: AstrologyTradition {
        switch self {
        case .western: .western
        case .vedic: .vedic
        case .chinese: .chinese
        }
    }
}

extension AstrologyTradition {
    var chartSystem: ChartSystem {
        switch self {
        case .western: .western
        case .vedic: .vedic
        case .chinese: .chinese
        }
    }
}

/// A chart, in exactly one system.
///
/// A closed sum rather than a struct with optional Western, Vedic and Chinese sections,
/// so that "which system is this?" is answered once, at the point of use, and cannot be
/// left ambiguous.
enum SystemChart: Sendable, Hashable {
    case western(WesternChart)
    case vedic(VedicChart)
    case chinese(ChineseChart)

    var system: ChartSystem {
        switch self {
        case .western: .western
        case .vedic: .vedic
        case .chinese: .chinese
        }
    }

    var provenance: ContentProvenance {
        switch self {
        case .western(let chart): chart.provenance
        case .vedic(let chart): chart.provenance
        case .chinese(let chart): chart.provenance
        }
    }
}

/// The one thing a chart most wants to say about itself.
///
/// Western calls it the strongest aspect, Vedic the current dasha, Chinese the Day
/// Master. The *shape* is shared — a kicker, a headline, a paragraph — but the content
/// is written separately per system and never derived from a common source.
struct ChartFeature: Sendable, Hashable {
    let kicker: String
    let headline: String
    let body: String
}

/// The triad each system leads with. Three labelled values, in that system's own words.
struct ChartTriad: Sendable, Hashable {
    struct Entry: Sendable, Hashable, Identifiable {
        let id: String
        /// "Sun", "Chandra Rashi", "Day Master" — never translated across systems.
        let label: String
        /// "Pisces", "Vrishabha", "Wood".
        let value: String
        let glyph: String
        let glyphSpokenName: String
        /// A term in this entry that has a glossary definition, if any.
        let glossaryTermID: String?

        /// Stands in for a glyph that is not available, so a triad keeps its shape when
        /// one of its three values is withheld. Named rather than repeated as a literal
        /// so a view can tell a placeholder from a real mark and draw it accordingly.
        static let unavailableGlyph = "·"

        var hasGlyph: Bool { glyph != Self.unavailableGlyph }

        init(
            id: String,
            label: String,
            value: String,
            glyph: String,
            glyphSpokenName: String,
            glossaryTermID: String? = nil
        ) {
            self.id = id
            self.label = label
            self.value = value
            self.glyph = glyph
            self.glyphSpokenName = glyphSpokenName
            self.glossaryTermID = glossaryTermID
        }
    }

    let entries: [Entry]
}
