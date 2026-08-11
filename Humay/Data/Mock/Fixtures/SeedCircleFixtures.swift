// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT REAL PEOPLE
//  Sample entries so the Circle feature is visible immediately rather than
//  requiring setup before it can be seen at all.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

enum SeedCircleFixtures {
    /// Two people, seeded on first launch.
    ///
    /// One has a birth time and one does not, so the interface's handling of missing
    /// data is visible from the start rather than only in a state nobody reaches.
    static let people: [CirclePerson] = [
        CirclePerson(
            name: "Sara",
            role: .partner,
            birth: BirthDetails(
                year: 1993,
                month: 8,
                day: 3,
                time: .exact(minutesFromMidnight: 9 * 60 + 20),
                place: .known(
                    name: "Lisbon, Portugal",
                    latitude: 38.7167,
                    longitude: -9.1333,
                    timeZoneIdentifier: "Europe/Lisbon"
                )
            )
        ),
        CirclePerson(
            name: "Alex",
            role: .friend,
            birth: BirthDetails(year: 1996, month: 6, day: 16)
        ),
    ]
}
