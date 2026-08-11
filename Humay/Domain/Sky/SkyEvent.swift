import Foundation

/// Which voice the Sky screen is speaking in.
///
/// This distinction is the whole idea of the screen. "In the sky" is what is happening,
/// impersonally, and would read identically for everyone alive. "For you" relates it to
/// a chart. Keeping them apart is how the application avoids implying that an eclipse
/// happened *at* someone.
enum SkyRegister: String, Sendable, CaseIterable, Identifiable {
    case inTheSky
    case forYou

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .inTheSky: "In the sky"
        case .forYou: "For you"
        }
    }
}

/// How much an event matters to this particular chart.
enum EventRelevance: String, Sendable, Hashable {
    case high
    case context

    var displayName: String {
        switch self {
        case .high: "High relevance"
        case .context: "Context"
        }
    }
}

/// When an event happens.
///
/// A clock time appears only when it is deterministically supported. `dayOnly` exists
/// so that "we know the day but not the minute" is representable rather than filled in.
enum EventTime: Sendable, Hashable {
    case exact(Date, timeZoneAbbreviation: String)
    case dayOnly

    var formatted: String? {
        guard case .exact(let date, let abbreviation) = self else { return nil }
        return "\(date.formatted(.dateTime.hour().minute())) \(abbreviation)"
    }
}

/// The Moon right now.
struct MoonPhase: Sendable, Hashable {
    let name: String
    /// Days since the new Moon.
    let ageDays: Double
    /// 0 to 1.
    let illuminatedFraction: Double
    /// The sign it is leaving and entering today, when it changes today.
    let ingress: MoonIngress?

    /// "3.4 DAYS OLD"
    var ageFormatted: String {
        "\(ageDays.formatted(.number.precision(.fractionLength(1)))) DAYS OLD"
    }

    /// "12% ILLUMINATED"
    var illuminationFormatted: String {
        "\(Int((illuminatedFraction * 100).rounded()))% ILLUMINATED"
    }
}

struct MoonIngress: Sendable, Hashable {
    let from: WesternSign
    let to: WesternSign
    let at: String

    /// "♍︎ → ♎︎ 15:42"
    var formatted: String { "\(from.glyph) → \(to.glyph) \(at)" }

    var spokenDescription: String {
        "Moon moves from \(from.spokenName) into \(to.spokenName) at \(at)"
    }
}

/// Something happening in the sky.
struct SkyEvent: Sendable, Hashable, Identifiable {
    let id: String
    let system: ChartSystem
    let title: String
    let date: DateComponents
    let time: EventTime
    let relevance: EventRelevance
    /// The impersonal account. Always present.
    let inTheSky: String
    /// The chart-relative account. Needs a chart, so it may be unavailable.
    let forYou: FactValue<String>
    /// Mono lines shown under the astrological basis heading.
    let basisFacts: [String]
    let provenance: ContentProvenance

    /// "22 AUG"
    var shortDateFormatted: String {
        var components = date
        components.calendar = Calendar(identifier: .gregorian)
        guard let resolved = components.date else { return "" }
        return resolved.formatted(.dateTime.day().month(.abbreviated)).uppercased()
    }
}

/// The sky as it stands, plus what is coming.
struct SkySnapshot: Sendable, Hashable {
    /// "Lisbon · 38°43′N", or a neutral label when no place is known.
    let locationLabel: String
    let moon: MoonPhase
    let moonInTheSky: String
    let moonForYou: FactValue<String>
    /// Where the visible bodies currently sit. Ordered as the interface shows them.
    let positions: [SkyPosition]
    let upcoming: [SkyEvent]
    let provenance: ContentProvenance
}

/// One body's current position, for the transits list.
struct SkyPosition: Sendable, Hashable, Identifiable {
    var id: String { planet.rawValue }
    let planet: Planet
    let position: Ecliptic
    let isRetrograde: Bool
    let note: String

    var spokenSummary: String {
        "\(planet.spokenName), \(position.spokenPosition)\(isRetrograde ? ", retrograde" : "")"
    }
}
