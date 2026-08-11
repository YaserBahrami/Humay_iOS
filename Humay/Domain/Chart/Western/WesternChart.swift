import Foundation

/// The twelve tropical signs.
///
/// Deliberately **not** shared with `Rashi`. See the note on that type: they divide the
/// same circle, but making them one type is how Vedic quietly becomes a Western skin.
enum WesternSign: String, Sendable, CaseIterable, Identifiable, Codable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var id: String { rawValue }

    /// The spoken form. VoiceOver must say "Pisces", never the Unicode symbol name.
    var spokenName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var glyph: String {
        switch self {
        case .aries: "♈︎"
        case .taurus: "♉︎"
        case .gemini: "♊︎"
        case .cancer: "♋︎"
        case .leo: "♌︎"
        case .virgo: "♍︎"
        case .libra: "♎︎"
        case .scorpio: "♏︎"
        case .sagittarius: "♐︎"
        case .capricorn: "♑︎"
        case .aquarius: "♒︎"
        case .pisces: "♓︎"
        }
    }

    /// Ecliptic longitude at which this sign begins.
    var startLongitude: Double {
        Double(Self.allCases.firstIndex(of: self) ?? 0) * 30
    }

    /// The sign containing an ecliptic longitude.
    static func containing(longitude: Double) -> WesternSign {
        let normalised = longitude.truncatingRemainder(dividingBy: 360)
        let positive = normalised < 0 ? normalised + 360 : normalised
        return allCases[min(Int(positive / 30), 11)]
    }
}

/// The bodies a Western chart places.
enum Planet: String, Sendable, CaseIterable, Identifiable, Codable {
    case sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto

    var id: String { rawValue }

    var spokenName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    var glyph: String {
        switch self {
        case .sun: "☉"
        case .moon: "☽"
        case .mercury: "☿"
        case .venus: "♀"
        case .mars: "♂"
        case .jupiter: "♃"
        case .saturn: "♄"
        case .uranus: "♅"
        case .neptune: "♆"
        case .pluto: "♇"
        }
    }
}

/// A position on the ecliptic.
///
/// This is the single value a real ephemeris will populate. Everything downstream —
/// the sign, the formatted degree, the position on the wheel — is derived from it, so
/// replacing mock content with calculated content changes this number and nothing else.
struct Ecliptic: Sendable, Hashable {
    /// Degrees, 0 up to but not including 360.
    let longitudeDegrees: Double

    init(longitudeDegrees: Double) {
        let normalised = longitudeDegrees.truncatingRemainder(dividingBy: 360)
        self.longitudeDegrees = normalised < 0 ? normalised + 360 : normalised
    }

    var sign: WesternSign { .containing(longitude: longitudeDegrees) }

    /// Degree and arcminute are both taken from one rounded total.
    ///
    /// Deriving them separately lets floating-point error show up as 4°11′ for a value
    /// of 4.2, and lets a rounded arcminute reach 60 while the degree stays behind.
    private var totalArcminutes: Int { Int((longitudeDegrees * 60).rounded()) }

    var degreeInSign: Int { (totalArcminutes / 60) % 30 }

    var arcminuteInSign: Int { totalArcminutes % 60 }

    /// "4° 12′" — set in mono, with tabular figures.
    var degreeFormatted: String {
        String(format: "%d° %02d′", degreeInSign, arcminuteInSign)
    }

    /// "4° 12′ ♓︎"
    var formatted: String { "\(degreeFormatted) \(sign.glyph)" }

    /// "4 degrees 12 minutes Pisces" — for VoiceOver.
    var spokenPosition: String {
        "\(degreeInSign) degrees \(arcminuteInSign) minutes \(sign.spokenName)"
    }
}

/// A planet placed in the chart.
struct PlanetPlacement: Sendable, Hashable, Identifiable {
    var id: String { planet.rawValue }
    let planet: Planet
    let position: Ecliptic
    /// Houses need an exact birth time and a place, so this may be unavailable.
    let house: FactValue<Int>
    let isRetrograde: Bool
    /// What this placement is held to mean. Written per placement, not composed.
    let meaning: String

    var spokenSummary: String {
        var parts = ["\(planet.spokenName), \(position.spokenPosition)"]
        if let house = house.value { parts.append("house \(house)") }
        if isRetrograde { parts.append("retrograde") }
        return parts.joined(separator: ", ")
    }
}

enum AspectKind: String, Sendable, CaseIterable, Codable {
    case conjunction, sextile, square, trine, opposition

    var spokenName: String { rawValue }

    var glyph: String {
        switch self {
        case .conjunction: "☌"
        case .sextile: "⚹"
        case .square: "□"
        case .trine: "△"
        case .opposition: "☍"
        }
    }

    /// The angle this aspect is exact at.
    var exactAngle: Double {
        switch self {
        case .conjunction: 0
        case .sextile: 60
        case .square: 90
        case .trine: 120
        case .opposition: 180
        }
    }
}

/// A relationship between two placements. Western only — a yoga and a pillar
/// interaction are different ideas and get their own types.
struct Aspect: Sendable, Hashable, Identifiable {
    var id: String { "\(first.rawValue)-\(kind.rawValue)-\(second.rawValue)" }
    let first: Planet
    let second: Planet
    let kind: AspectKind
    /// Distance from exact, in degrees.
    let orbDegrees: Double
    let meaning: String

    /// "0° 08′"
    var orbFormatted: String {
        let degrees = Int(orbDegrees)
        let minutes = min(Int(((orbDegrees - Double(degrees)) * 60).rounded()), 59)
        return String(format: "%d° %02d′", degrees, minutes)
    }

    var spokenDescription: String {
        "\(first.spokenName) \(kind.spokenName) \(second.spokenName), orb \(orbDegrees.formatted(.number.precision(.fractionLength(1)))) degrees"
    }
}

/// A house cusp.
struct House: Sendable, Hashable, Identifiable {
    let id: Int
    let cusp: Ecliptic
    let title: String
    let summary: String

    var spokenDescription: String {
        "House \(id), cusp at \(cusp.spokenPosition). \(title)."
    }
}

/// A moving body's current relationship to the natal chart.
struct Transit: Sendable, Hashable, Identifiable {
    let id: String
    let planet: Planet
    let title: String
    let detail: String
    /// Which natal house it is moving through, when houses are calculable.
    let natalHouse: FactValue<Int>
    /// Present only when a clock time is deterministically supported.
    let exactAt: Date?
}

/// A Western natal chart.
///
/// Houses, aspects, transits and a rising sign exist here and nowhere else in the
/// domain.
struct WesternChart: Sendable, Hashable {
    let sun: PlanetPlacement
    /// The Moon's degree can become uncertain without a birth time, though its sign
    /// usually survives.
    let moon: FactValue<PlanetPlacement>
    /// Needs an exact time and a place. Never guessed.
    let rising: FactValue<PlanetPlacement>
    let placements: [PlanetPlacement]
    let houses: FactValue<[House]>
    let aspects: [Aspect]
    let headline: String
    let feature: ChartFeature
    let provenance: ContentProvenance

    var triad: ChartTriad {
        ChartTriad(entries: [
            .init(
                id: "sun",
                label: "Sun",
                value: sun.position.sign.spokenName,
                glyph: sun.position.sign.glyph,
                glyphSpokenName: sun.position.sign.spokenName
            ),
            .init(
                id: "moon",
                label: "Moon",
                value: moon.value.map { $0.position.sign.spokenName } ?? "—",
                glyph: moon.value.map { $0.position.sign.glyph } ?? ChartTriad.Entry.unavailableGlyph,
                glyphSpokenName: moon.value.map { $0.position.sign.spokenName } ?? "not available"
            ),
            .init(
                id: "rising",
                label: "Rising",
                value: rising.value.map { $0.position.sign.spokenName } ?? "—",
                glyph: rising.value.map { $0.position.sign.glyph } ?? ChartTriad.Entry.unavailableGlyph,
                glyphSpokenName: rising.value.map { $0.position.sign.spokenName } ?? "not available"
            ),
        ])
    }
}
