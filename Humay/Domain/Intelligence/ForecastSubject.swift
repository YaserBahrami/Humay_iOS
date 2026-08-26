import Foundation

/// The person a forecast is generated for. Unifies the app owner (`UserProfile`)
/// and saved connections (`ConnectionPerson`) behind one generation input.
struct ForecastSubject: Sendable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let birth: BirthDetails

    init(id: UUID, name: String, birth: BirthDetails) {
        self.id = id
        self.name = name
        self.birth = birth
    }

    var sunSign: WesternZodiacSign? {
        SunSignCalendar.westernSunSign(month: birth.month, day: birth.day)
    }
}

extension UserProfile {
    var forecastSubject: ForecastSubject {
        ForecastSubject(id: id, name: displayName, birth: birth)
    }
}

extension ConnectionPerson {
    var forecastSubject: ForecastSubject {
        ForecastSubject(id: id, name: name, birth: birth)
    }
}

/// Version inputs that materially change generated content. Bump these when the
/// calculation basis or output shape changes so stale caches can be detected.
enum IntelligenceVersions {
    /// Version of the deterministic astrology inputs feeding generation. Until a
    /// real engine exists, only the date-table Sun sign is available.
    static let astrologyCalculation = "astro-date-table-v1"
    /// Version of the persisted document schema.
    static let forecastSchema = 1
    /// Prompt catalog version recorded in provenance.
    static let promptCatalog = "prompts-v1"
}

/// Stable fingerprint over every material input of forecast generation.
///
/// If the fingerprint of a stored document differs from the subject's current
/// fingerprint, the document is stale and must not be presented as current.
struct ProfileFingerprint: Sendable, Hashable, RawRepresentable, Codable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(subject: ForecastSubject, generatorVersion: String) {
        var components: [String] = [
            "schema=\(IntelligenceVersions.forecastSchema)",
            "astro=\(IntelligenceVersions.astrologyCalculation)",
            "generator=\(generatorVersion)",
            "birth=\(subject.birth.year)-\(subject.birth.month)-\(subject.birth.day)"
        ]

        switch subject.birth.time {
        case .exact(let minutes):
            components.append("time=exact:\(minutes)")
        case .approximate(let minutes, let tolerance):
            components.append("time=approx:\(minutes)+\(tolerance)")
        case .unknown:
            components.append("time=unknown")
        }

        switch subject.birth.place {
        case .known(let name, let latitude, let longitude, let timeZone):
            // Coordinates rounded to ~1km so trivial GPS jitter does not
            // invalidate a year of content; name and zone stay exact.
            let roundedLat = (latitude * 100).rounded() / 100
            let roundedLon = (longitude * 100).rounded() / 100
            components.append("place=\(name)|\(roundedLat)|\(roundedLon)|\(timeZone)")
        case .notProvided:
            components.append("place=none")
        }

        let hash = HumayContentEngine.stableHash("fingerprint", components.joined(separator: "|"))
        self.rawValue = String(format: "%016llx", hash)
    }
}
