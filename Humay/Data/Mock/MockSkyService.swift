// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Moon phase, positions and event times here are illustrative. They are not
//  astronomy and must not be used as a test oracle.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// The sky, from fixtures.
///
/// The "for you" half of every value is a `FactValue`, so a person without a chart sees
/// the impersonal account and an explanation, rather than a chart-relative sentence
/// invented for them.
struct MockSkyService: SkyService, MockContentProvider {
    static let fixtureNamespace = "sky"

    let latency: MockLatency

    init(latency: MockLatency = .realistic) {
        self.latency = latency
    }

    func snapshot(for date: DateComponents, profile: UserProfile?) async throws -> SkySnapshot {
        await latency.wait()
        let personal = profile?.birth.supportsPrecision ?? false

        return SkySnapshot(
            locationLabel: locationLabel(for: profile),
            moon: SkyFixtures.moonPhase(for: date),
            moonInTheSky: SkyFixtures.moonInTheSky(for: date),
            moonForYou: personal
                ? .available("The Moon is in your eighth house for the whole day — trust, exposure, and what is shared rather than divided.")
                : .unavailable(reason: profile?.birth.time.isKnown == true ? .requiresBirthPlace : .requiresBirthTime),
            positions: SkyFixtures.positions(for: date),
            upcoming: SkyFixtures.events(personal: personal, provenance: Self.provenance("event")),
            provenance: Self.provenance("snapshot")
        )
    }

    func events(in month: DateComponents, profile: UserProfile?) async throws -> [SkyEvent] {
        await latency.wait()
        let personal = profile?.birth.supportsPrecision ?? false
        return SkyFixtures.monthEvents(
            month: month,
            personal: personal,
            provenance: Self.provenance("event")
        )
    }

    func event(id: String, profile: UserProfile?) async throws -> SkyEvent {
        await latency.wait()
        let personal = profile?.birth.supportsPrecision ?? false
        let all = SkyFixtures.events(personal: personal, provenance: Self.provenance("event"))
            + SkyFixtures.monthEvents(month: DateComponents(), personal: personal, provenance: Self.provenance("event"))
        guard let match = all.first(where: { $0.id == id }) else {
            throw HumayServiceError.contentUnavailable(id)
        }
        return match
    }

    private func locationLabel(for profile: UserProfile?) -> String {
        guard
            let profile,
            case .known(let name, _, _, _) = profile.birth.place,
            let coordinates = profile.birth.place.coordinatesFormatted
        else {
            return "Sky positions, geocentric"
        }
        return "\(name) · \(coordinates.split(separator: " ").first.map(String.init) ?? "")"
    }
}
