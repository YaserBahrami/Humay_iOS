import Foundation

/// The twelve rashis.
///
/// This is **not** a typealias of `WesternSign`, and there is no bridging function
/// between them. They divide the same circle, and a reviewer will eventually want to
/// merge them — please do not. The moment one type serves both, someone writes
/// `chart.rashi.westernName` in a view and the Vedic reading becomes a Western reading
/// wearing Sanskrit labels. Sidereal and tropical also disagree by roughly 24 degrees,
/// so the same person's Sun is usually in a different division in each system; a shared
/// type invites treating those as the same value.
///
/// If a future Compare Systems screen genuinely needs to relate them, it gets its own
/// explicitly named type that owns that mapping, in its own file, with a comment saying
/// why it is allowed there and nowhere else.
enum Rashi: String, Sendable, CaseIterable, Identifiable, Codable {
    case mesha, vrishabha, mithuna, karka, simha, kanya
    case tula, vrishchika, dhanu, makara, kumbha, meena

    var id: String { rawValue }

    var spokenName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// The mark used in Vedic display. Shape is shared with the tropical zodiac
    /// notation, but the value it labels is a sidereal one.
    var glyph: String {
        switch self {
        case .mesha: "♈︎"
        case .vrishabha: "♉︎"
        case .mithuna: "♊︎"
        case .karka: "♋︎"
        case .simha: "♌︎"
        case .kanya: "♍︎"
        case .tula: "♎︎"
        case .vrishchika: "♏︎"
        case .dhanu: "♐︎"
        case .makara: "♑︎"
        case .kumbha: "♒︎"
        case .meena: "♓︎"
        }
    }
}

/// The nine grahas. Not "planets" — Rahu and Ketu are nodes, and the set is not the
/// Western one.
enum Graha: String, Sendable, CaseIterable, Identifiable, Codable {
    case surya, chandra, budha, shukra, mangala, guru, shani, rahu, ketu

    var id: String { rawValue }

    var spokenName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}

/// The twenty-seven lunar mansions.
enum Nakshatra: String, Sendable, CaseIterable, Identifiable, Codable {
    case ashwini, bharani, krittika, rohini, mrigashira, ardra, punarvasu, pushya, ashlesha
    case magha, purvaPhalguni, uttaraPhalguni, hasta, chitra, swati, vishakha, anuradha, jyeshtha
    case mula, purvaAshadha, uttaraAshadha, shravana, dhanishta, shatabhisha
    case purvaBhadrapada, uttaraBhadrapada, revati

    var id: String { rawValue }

    var spokenName: String {
        switch self {
        case .purvaPhalguni: "Purva Phalguni"
        case .uttaraPhalguni: "Uttara Phalguni"
        case .purvaAshadha: "Purva Ashadha"
        case .uttaraAshadha: "Uttara Ashadha"
        case .purvaBhadrapada: "Purva Bhadrapada"
        case .uttaraBhadrapada: "Uttara Bhadrapada"
        default: rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
    }
}

/// A bhava. Counted from the Lagna, so it needs a birth time.
struct Bhava: Sendable, Hashable, Identifiable {
    let id: Int
    let title: String
    let summary: String

    /// "B7" — the mono notation used on fact lines.
    var notation: String { "B\(id)" }

    var spokenDescription: String { "Bhava \(id), \(title)." }
}

/// A graha placed in the chart.
struct GrahaPlacement: Sendable, Hashable, Identifiable {
    var id: String { graha.rawValue }
    let graha: Graha
    let rashi: Rashi
    /// Degree within the rashi, when available.
    let degreeInRashi: FactValue<Double>
    let bhava: FactValue<Int>
    /// Needs the Moon to a useful precision, and therefore a birth time.
    let nakshatra: FactValue<Nakshatra>
    let meaning: String

    var degreeFormatted: String? {
        guard let degrees = degreeInRashi.value else { return nil }
        let whole = Int(degrees)
        let minutes = min(Int(((degrees - Double(whole)) * 60).rounded()), 59)
        return String(format: "%d° %02d′", whole, minutes)
    }

    var spokenSummary: String {
        var parts = ["\(graha.spokenName) in \(rashi.spokenName)"]
        if let bhava = bhava.value { parts.append("bhava \(bhava)") }
        if let nakshatra = nakshatra.value { parts.append("nakshatra \(nakshatra.spokenName)") }
        return parts.joined(separator: ", ")
    }
}

enum DashaLevel: String, Sendable, Codable {
    case maha, antara

    var displayName: String {
        switch self {
        case .maha: "Mahadasha"
        case .antara: "Antardasha"
        }
    }
}

/// A planetary period. Vedic timing has no Western counterpart — this is not a transit.
struct DashaPeriod: Sendable, Hashable, Identifiable {
    var id: String { "\(level.rawValue)-\(lord.rawValue)" }
    let lord: Graha
    let level: DashaLevel
    let startedAtAge: Int
    let endsAtAge: Int
    let summary: String

    var displayName: String { "\(lord.spokenName) \(level.displayName)" }
}

/// A Vedic natal chart.
///
/// There is no `houses` property, no `aspects` property and no `rising` property here.
/// Bhavas are not houses, and the aspect grammar is different; naming them the same
/// would be the first step toward treating them as the same.
struct VedicChart: Sendable, Hashable {
    let suryaRashi: Rashi
    let chandraRashi: Rashi
    /// Needs a birth time.
    let lagna: FactValue<Rashi>
    /// Needs the Moon's position to a useful precision.
    let nakshatra: FactValue<Nakshatra>
    let placements: [GrahaPlacement]
    let bhavas: FactValue<[Bhava]>
    let currentDasha: FactValue<DashaPeriod>
    /// The ayanamsa in force, stated because the choice changes every value above.
    let ayanamsaNote: String
    let headline: String
    let feature: ChartFeature
    let provenance: ContentProvenance

    var triad: ChartTriad {
        ChartTriad(entries: [
            .init(
                id: "chandra",
                label: "Chandra Rashi",
                value: chandraRashi.spokenName,
                glyph: chandraRashi.glyph,
                glyphSpokenName: chandraRashi.spokenName
            ),
            .init(
                id: "nakshatra",
                label: "Nakshatra",
                value: nakshatra.value?.spokenName ?? "—",
                glyph: "☽",
                glyphSpokenName: "Moon",
                glossaryTermID: "nakshatra"
            ),
            .init(
                id: "lagna",
                label: "Lagna",
                value: lagna.value?.spokenName ?? "—",
                glyph: lagna.value?.glyph ?? "·",
                glyphSpokenName: lagna.value?.spokenName ?? "not available",
                glossaryTermID: "lagna"
            ),
        ])
    }
}
