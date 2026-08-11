// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//
//  The positions below are a toy model, not astronomy. They ignore orbital
//  eccentricity, inclination, the observer's location and everything else that
//  makes an ephemeris an ephemeris; they are accurate to no better than a few
//  degrees and are wrong in ways that matter.
//
//  They are computed rather than hard-coded for one reason: a screen that says
//  "waxing gibbous, 88% illuminated" beside a sentence about a new moon is not
//  merely placeholder content, it is visibly incoherent, and incoherence in a
//  product whose whole promise is showing its reasoning reads as carelessness
//  rather than as a placeholder. Deriving everything from one date keeps the
//  screen internally consistent while still being openly fake.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

enum SkyFixtures {
    /// Days from the start of the year, used as the single input everything derives from.
    private static func dayOfYear(_ date: DateComponents) -> Double {
        var components = date
        components.calendar = Calendar(identifier: .gregorian)
        guard
            let resolved = components.date,
            let day = Calendar(identifier: .gregorian).ordinality(of: .day, in: .year, for: resolved)
        else { return 1 }
        return Double(day)
    }

    /// The Sun's approximate ecliptic longitude.
    ///
    /// Zero degrees is the March equinox, around day 79. A circular orbit at a constant
    /// rate — the real thing varies by up to about two degrees over the year.
    private static func sunLongitude(_ date: DateComponents) -> Double {
        (dayOfYear(date) - 79) * (360 / 365.25)
    }

    /// The Moon's approximate longitude, at its mean rate from an arbitrary epoch.
    private static func moonLongitude(_ date: DateComponents) -> Double {
        let year = Double(date.year ?? 2026)
        return (dayOfYear(date) * 13.176 + year * 129.4).truncatingRemainder(dividingBy: 360)
    }

    static func moonPhase(for date: DateComponents) -> MoonPhase {
        // Phase follows from the Sun–Moon elongation, so the name, the age and the
        // illumination can never disagree with each other.
        let elongation = normalised(moonLongitude(date) - sunLongitude(date))
        let synodicMonth = 29.53
        let age = elongation / 360 * synodicMonth
        let illumination = (1 - cos(elongation * .pi / 180)) / 2

        let moonSign = WesternSign.containing(longitude: moonLongitude(date))
        let nextSign = WesternSign.allCases[
            ((WesternSign.allCases.firstIndex(of: moonSign) ?? 0) + 1) % 12
        ]

        return MoonPhase(
            name: phaseName(forElongation: elongation),
            ageDays: age,
            illuminatedFraction: illumination,
            ingress: MoonIngress(from: moonSign, to: nextSign, at: "15:42")
        )
    }

    private static func phaseName(forElongation elongation: Double) -> String {
        switch elongation {
        case ..<22.5: "New Moon"
        case ..<67.5: "Waxing crescent"
        case ..<112.5: "First quarter"
        case ..<157.5: "Waxing gibbous"
        case ..<202.5: "Full Moon"
        case ..<247.5: "Waning gibbous"
        case ..<292.5: "Last quarter"
        case ..<337.5: "Waning crescent"
        default: "New Moon"
        }
    }

    /// The impersonal account of the Moon, written from the phase rather than fixed.
    static func moonInTheSky(for date: DateComponents) -> String {
        let phase = moonPhase(for: date)
        let age = phase.ageDays.formatted(.number.precision(.fractionLength(1)))
        let visibility: String = switch phase.name {
        case "New Moon":
            "too close to the Sun to be seen"
        case "Waxing crescent":
            "low in the west shortly after sunset"
        case "First quarter":
            "high in the south at sunset, setting around midnight"
        case "Waxing gibbous":
            "rising in the afternoon and up for most of the night"
        case "Full Moon":
            "rising as the Sun sets and up all night"
        case "Waning gibbous":
            "rising later each evening and still up at dawn"
        case "Last quarter":
            "rising around midnight, high in the south at sunrise"
        default:
            "low in the east before dawn"
        }
        return "\(age) days past the New Moon, \(visibility). This is what the sky is doing — it reads the same for everyone looking up tonight."
    }

    static func positions(for date: DateComponents) -> [SkyPosition] {
        let sun = sunLongitude(date)
        let day = dayOfYear(date)

        // Each body moves at roughly its own rate from the Sun's position. Mercury and
        // Venus stay near the Sun, which is at least the right shape of wrong.
        let longitudes: [Planet: Double] = [
            .sun: sun,
            .moon: moonLongitude(date),
            .mercury: sun + 18 * sin(day / 88 * 2 * .pi),
            .venus: sun + 44 * sin(day / 225 * 2 * .pi),
            .mars: sun * 0.53 + 120,
        ]

        return [Planet.sun, .moon, .mercury, .venus, .mars].map { planet in
            SkyPosition(
                planet: planet,
                position: Ecliptic(longitudeDegrees: normalised(longitudes[planet] ?? 0)),
                isRetrograde: planet == .mercury && Int(day) % 29 < 6,
                note: positionNotes[planet] ?? ""
            )
        }
    }

    private static func normalised(_ degrees: Double) -> Double {
        let value = degrees.truncatingRemainder(dividingBy: 360)
        return value < 0 ? value + 360 : value
    }

    private static let positionNotes: [Planet: String] = [
        .sun: "Where the season sits. Everything else is read against it.",
        .moon: "Moves about thirteen degrees a day, which is why it is the fastest thing on this screen.",
        .mercury: "Out of its retrograde shadow this morning. Anything postponed in the last three weeks can be picked back up.",
        .venus: "Approaching one of the two signs it rules. Not an event so much as a return to easier ground.",
        .mars: "Slowing before its station. Effort meets more resistance than usual for the next fortnight.",
    ]

    static func events(personal: Bool, provenance: ContentProvenance) -> [SkyEvent] {
        [
            SkyEvent(
                id: "venus-enters-libra",
                system: .western,
                title: "Venus enters Libra",
                date: DateComponents(year: 2026, month: 8, day: 22),
                time: .exact(referenceDate(day: 22, hour: 4, minute: 16), timeZoneAbbreviation: "WEST"),
                relevance: .context,
                inTheSky: "Venus returns to one of the two signs it rules. This happens for everyone alive, once a year, and takes about four weeks to cross.",
                forYou: personal
                    ? .available("It moves into your eighth house — trust, and the things you share rather than divide. Nothing sits there natally, so this is a passing emphasis rather than a permanent theme being lit up.")
                    : .unavailable(reason: .requiresBirthTime),
                basisFacts: [
                    "♀  00°00′ ♎︎  ·  22 AUG 04:16",
                    "ENTERS H8 AT 23°44′ ♎︎",
                    "NATAL H8 EMPTY BY PLACEMENT",
                ],
                provenance: provenance
            ),
            SkyEvent(
                id: "full-moon-aquarius",
                system: .western,
                title: "Full Moon in Aquarius",
                date: DateComponents(year: 2026, month: 8, day: 20),
                time: .exact(referenceDate(day: 20, hour: 2, minute: 26), timeZoneAbbreviation: "WEST"),
                relevance: .high,
                inTheSky: "The Moon reaches opposition with the Sun at 27°42′ Aquarius. Fully lit, rising as the Sun sets.",
                forYou: personal
                    ? .available("A degree and a half from your Ascendant, which is close enough to be about you specifically rather than about the month.")
                    : .unavailable(reason: .requiresBirthTime),
                basisFacts: [
                    "☽  27°42′ ♒︎  ☍  ☉  27°42′ ♌︎",
                    "20 AUG 02:26 WEST",
                    "ORB TO NATAL ASC  1°32′",
                ],
                provenance: provenance
            ),
            SkyEvent(
                id: "mercury-shadow-out",
                system: .western,
                title: "Mercury clears its retrograde shadow",
                date: DateComponents(year: 2026, month: 8, day: 11),
                time: .exact(referenceDate(day: 11, hour: 6, minute: 12), timeZoneAbbreviation: "WEST"),
                relevance: .high,
                inTheSky: "Mercury passes the degree it turned retrograde at three weeks ago. From here it is covering new ground.",
                forYou: personal
                    ? .available("Anything you set down in the last three weeks can be picked up without the sense of arguing with it. This is the first day that is true.")
                    : .unavailable(reason: .requiresBirthTime),
                basisFacts: [
                    "☿  24°08′ ♌︎  DIRECT",
                    "SHADOW OUT  11 AUG 06:12",
                ],
                provenance: provenance
            ),
            SkyEvent(
                id: "mars-station",
                system: .western,
                title: "Mars slows before its station",
                date: DateComponents(year: 2026, month: 8, day: 28),
                time: .dayOnly,
                relevance: .context,
                inTheSky: "Mars approaches a standstill against the background stars before turning retrograde. The apparent stopping takes several days rather than a moment, which is why no clock time is given here.",
                forYou: personal
                    ? .available("Effort meets more resistance for the next fortnight. Not obstruction — the same push covering less ground.")
                    : .unavailable(reason: .requiresBirthTime),
                basisFacts: [
                    "♂  MOTION < 0°01′ / DAY",
                    "STATION DATE APPROXIMATE",
                ],
                provenance: provenance
            ),
        ]
    }

    static func monthEvents(
        month: DateComponents,
        personal: Bool,
        provenance: ContentProvenance
    ) -> [SkyEvent] {
        events(personal: personal, provenance: provenance)
    }

    private static func referenceDate(day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = day
        components.hour = hour
        components.minute = minute
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(identifier: "UTC")
        return components.date ?? .now
    }
}
