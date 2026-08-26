import Foundation

/// The person using the application.
///
/// This is a local profile on one device. There is no sign-in, no server record and no
/// identity beyond what is stored here.
struct UserProfile: Sendable, Hashable, Identifiable {
    let id: UUID
    var displayName: String
    var birth: BirthDetails

    init(id: UUID = UUID(), displayName: String, birth: BirthDetails) {
        self.id = id
        self.displayName = displayName
        self.birth = birth
    }
}

/// Which tradition leads the experience.
///
/// All three remain available at all times. This sets the vocabulary of the daily
/// reading and the default view of the chart — it is not a filter, and it does not
/// make the other traditions unavailable.
enum AstrologyTradition: String, Sendable, CaseIterable, Identifiable, Codable {
    case western
    case vedic
    case chinese

    var id: String { rawValue }

    /// The name as it should appear, in its own terms.
    var displayName: String {
        switch self {
        case .western: "Western · Tropical"
        case .vedic: "Vedic · Sidereal"
        case .chinese: "Chinese · Four Pillars"
        }
    }

    var shortName: String {
        switch self {
        case .western: "Western"
        case .vedic: "Vedic"
        case .chinese: "Chinese"
        }
    }

    /// A single mark standing for the tradition. Not a zodiac glyph.
    var mark: String {
        switch self {
        case .western: "☉"
        case .vedic: "☽"
        case .chinese: "氣"
        }
    }

    var markSpokenName: String {
        switch self {
        case .western: "Sun"
        case .vedic: "Moon"
        case .chinese: "Qi"
        }
    }

    /// What this tradition reads the sky against.
    var premise: String {
        switch self {
        case .western: "Reads the sky against the seasons."
        case .vedic: "Reads the sky against the fixed stars, Moon-first."
        case .chinese: "Reads five elements across the pillars of your birth."
        }
    }

    /// The concepts that belong to this tradition and to no other.
    var concepts: [String] {
        switch self {
        case .western: ["Planets", "Signs", "Houses", "Aspects", "Transits"]
        case .vedic: ["Grahas", "Rashis", "Bhavas", "Nakshatras", "Dashas"]
        case .chinese: ["Pillars", "Stems", "Branches", "Elements", "Cycles"]
        }
    }
}
