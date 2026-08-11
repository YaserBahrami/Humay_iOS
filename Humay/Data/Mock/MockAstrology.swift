// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//
//  Nothing in this file is astronomy. These are crude lookups that produce a
//  plausible-looking value so the interface can be built and driven. They ignore
//  the year, the hour, the observer's location, precession and every calendar
//  convention that a real implementation must resolve.
//
//  Do not port any of this into the calculation layer, and do not use it as a
//  test oracle. See docs/development/METHODOLOGY_TRACK.md.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

enum MockAstrology {
    /// Sun sign from month and day, using fixed boundary dates.
    ///
    /// Real cusp dates move by up to a day or so between years because the tropical
    /// year is not a whole number of days. This ignores that entirely.
    static func sunSign(for birth: BirthDetails) -> WesternSign {
        switch (birth.month, birth.day) {
        case (1, 20...31), (2, 1...18): .aquarius
        case (2, 19...29), (3, 1...20): .pisces
        case (3, 21...31), (4, 1...19): .aries
        case (4, 20...30), (5, 1...20): .taurus
        case (5, 21...31), (6, 1...20): .gemini
        case (6, 21...30), (7, 1...22): .cancer
        case (7, 23...31), (8, 1...22): .leo
        case (8, 23...31), (9, 1...22): .virgo
        case (9, 23...30), (10, 1...22): .libra
        case (10, 23...31), (11, 1...21): .scorpio
        case (11, 22...30), (12, 1...21): .sagittarius
        default: .capricorn
        }
    }

    /// Sidereal Sun rashi.
    ///
    /// Stands in for applying an ayanamsa by simply stepping back one division, which
    /// is roughly what a ~24° correction does for most of a sign and wrong near every
    /// boundary. The ayanamsa itself is an open methodology question — see METHOD-003.
    static func suryaRashi(for birth: BirthDetails) -> Rashi {
        let tropical = sunSign(for: birth)
        let index = WesternSign.allCases.firstIndex(of: tropical) ?? 0
        return Rashi.allCases[(index + 11) % 12]
    }

    /// The Moon rashi. Purely a spread over the birth day; not lunar motion.
    static func chandraRashi(for birth: BirthDetails) -> Rashi {
        Rashi.allCases[(birth.day + birth.month) % 12]
    }

    /// Year pillar from the calendar year.
    ///
    /// Uses the sexagenary cycle offset only. A real implementation must decide where
    /// the year boundary falls — the solar term, not 1 January — which is an open
    /// question. See METHOD-006.
    static func yearPillar(for birth: BirthDetails) -> Pillar {
        let offset = birth.year - 4
        let stem = HeavenlyStem.allCases[((offset % 10) + 10) % 10]
        let branch = EarthlyBranch.allCases[((offset % 12) + 12) % 12]
        return Pillar(
            position: .year,
            stem: stem,
            branch: branch,
            meaning: "The year you arrived in, read as a stem paired with a branch — the outermost of the four pillars, and the one that says most about inherited conditions."
        )
    }

    /// Month pillar. Derived from the month index alone.
    static func monthPillar(for birth: BirthDetails) -> Pillar {
        let stem = HeavenlyStem.allCases[(birth.month + 2) % 10]
        let branch = EarthlyBranch.allCases[(birth.month + 1) % 12]
        return Pillar(
            position: .month,
            stem: stem,
            branch: branch,
            meaning: "The season of your birth. In BaZi this pillar carries the most weight in judging whether the Day Master is supported or drained."
        )
    }

    /// Day pillar. Derived from the day index alone.
    static func dayPillar(for birth: BirthDetails) -> Pillar {
        let offset = birth.day + birth.month * 3
        let stem = HeavenlyStem.allCases[offset % 10]
        let branch = EarthlyBranch.allCases[offset % 12]
        return Pillar(
            position: .day,
            stem: stem,
            branch: branch,
            meaning: "The pillar that holds your Day Master — the element the whole chart is read from."
        )
    }

    /// Hour pillar. Genuinely requires a birth time, so this returns nil without one.
    static func hourPillar(for birth: BirthDetails) -> Pillar? {
        guard let minutes = birth.time.minutesFromMidnight else { return nil }
        let doubleHour = ((minutes + 60) / 120) % 12
        return Pillar(
            position: .hour,
            stem: HeavenlyStem.allCases[(doubleHour + 4) % 10],
            branch: EarthlyBranch.allCases[doubleHour],
            meaning: "The two-hour period you were born into. It refines the reading of everything above it, and cannot be recovered from a date."
        )
    }

    /// An ecliptic longitude for a planet, spread deterministically from the birth date
    /// so that a given person always sees the same chart. Not an ephemeris.
    static func longitude(for planet: Planet, birth: BirthDetails) -> Ecliptic {
        let seed = birth.day * 13 + birth.month * 29 + birth.year
        let planetIndex = Planet.allCases.firstIndex(of: planet) ?? 0
        switch planet {
        case .sun:
            // The Sun is the one body pinned to the sign the date implies, so the
            // interface stays internally consistent with the general reading.
            let sign = sunSign(for: birth)
            let base = sign.startLongitude
            return Ecliptic(longitudeDegrees: base + Double((seed % 29)) + 0.2 * Double(birth.day % 5))
        default:
            let spread = Double((seed &* (planetIndex + 7)) % 360)
            return Ecliptic(longitudeDegrees: spread + Double(planetIndex) * 7.3)
        }
    }
}
