import Foundation
import Testing
@testable import Humay

@Suite("ASTRO-001 birth calculation inputs")
struct BirthCalculationInputTests {
    @Test("Date-only input preserves unknown time and missing place")
    func dateOnlyInputPreservesUnknownPrecision() throws {
        let birth = BirthDetails(year: 1994, month: 3, day: 14)

        let input = try BirthCalculationInput(birth: birth, tradition: .western)

        #expect(input.birth == birth)
        #expect(input.birth.time == .unknown)
        #expect(input.birth.place == .notProvided)
        #expect(input.tradition == .western)
    }

    @Test("Exact time and canonical place remain unchanged")
    func exactTimeAndPlaceRemainUnchanged() throws {
        let birth = BirthDetails(
            year: 1997,
            month: 10,
            day: 8,
            time: .exact(minutesFromMidnight: 17 * 60 + 5),
            place: .known(
                name: "Tehran, Iran",
                latitude: 35.6892,
                longitude: 51.3890,
                timeZoneIdentifier: "Asia/Tehran"
            )
        )

        let input = try BirthCalculationInput(birth: birth, tradition: .vedic)

        #expect(input.birth == birth)
        #expect(input.tradition == .vedic)
    }

    @Test("Approximate time retains its uncertainty")
    func approximateTimeRetainsUncertainty() throws {
        let birth = BirthDetails(
            year: 1993,
            month: 5,
            day: 10,
            time: .approximate(minutesFromMidnight: 7 * 60 + 30, toleranceMinutes: 30),
            place: .known(
                name: "Zanjan, Iran",
                latitude: 36.6736,
                longitude: 48.4787,
                timeZoneIdentifier: "Asia/Tehran"
            )
        )

        let input = try BirthCalculationInput(birth: birth, tradition: .chinese)

        #expect(input.birth.time == .approximate(minutesFromMidnight: 450, toleranceMinutes: 30))
    }

    @Test("Impossible, unsupported and future dates are rejected")
    func invalidDatesAreRejected() {
        #expect(throws: BirthCalculationInputValidationError.invalidBirthDate) {
            try BirthCalculationInput(
                birth: BirthDetails(year: 1994, month: 2, day: 30),
                tradition: .western
            )
        }

        #expect(throws: BirthCalculationInputValidationError.invalidBirthDate) {
            try BirthCalculationInput(
                birth: BirthDetails(year: 1899, month: 12, day: 31),
                tradition: .western
            )
        }

        #expect(throws: BirthCalculationInputValidationError.invalidBirthDate) {
            try BirthCalculationInput(
                birth: BirthDetails(year: 2999, month: 1, day: 1),
                tradition: .western
            )
        }
    }

    @Test("Exact time must be inside one civil day")
    func exactTimeRangeIsValidated() {
        for invalidMinutes in [-1, 1_440] {
            #expect(throws: BirthCalculationInputValidationError.invalidExactBirthTime) {
                try BirthCalculationInput(
                    birth: BirthDetails(
                        year: 1994,
                        month: 3,
                        day: 14,
                        time: .exact(minutesFromMidnight: invalidMinutes)
                    ),
                    tradition: .western
                )
            }
        }
    }

    @Test("Approximate time must carry real uncertainty")
    func approximateTimeRequiresPositiveTolerance() {
        for invalidTolerance in [-1, 0] {
            #expect(throws: BirthCalculationInputValidationError.invalidApproximateBirthTime) {
                try BirthCalculationInput(
                    birth: BirthDetails(
                        year: 1994,
                        month: 3,
                        day: 14,
                        time: .approximate(
                            minutesFromMidnight: 12 * 60,
                            toleranceMinutes: invalidTolerance
                        )
                    ),
                    tradition: .western
                )
            }
        }
    }

    @Test("Known place requires a nonblank name")
    func placeNameIsValidated() {
        #expect(throws: BirthCalculationInputValidationError.emptyBirthPlaceName) {
            try BirthCalculationInput(
                birth: BirthDetails(
                    year: 1994,
                    month: 3,
                    day: 14,
                    place: .known(
                        name: "   ",
                        latitude: 35.6892,
                        longitude: 51.3890,
                        timeZoneIdentifier: "Asia/Tehran"
                    )
                ),
                tradition: .western
            )
        }
    }

    @Test("Latitude and longitude are finite and bounded")
    func coordinatesAreValidated() {
        #expect(throws: BirthCalculationInputValidationError.invalidLatitude) {
            try BirthCalculationInput(
                birth: BirthDetails(
                    year: 1994,
                    month: 3,
                    day: 14,
                    place: .known(
                        name: "Invalid",
                        latitude: 90.1,
                        longitude: 0,
                        timeZoneIdentifier: "UTC"
                    )
                ),
                tradition: .western
            )
        }

        #expect(throws: BirthCalculationInputValidationError.invalidLatitude) {
            try BirthCalculationInput(
                birth: BirthDetails(
                    year: 1994,
                    month: 3,
                    day: 14,
                    place: .known(
                        name: "Invalid",
                        latitude: .nan,
                        longitude: 0,
                        timeZoneIdentifier: "UTC"
                    )
                ),
                tradition: .western
            )
        }

        #expect(throws: BirthCalculationInputValidationError.invalidLongitude) {
            try BirthCalculationInput(
                birth: BirthDetails(
                    year: 1994,
                    month: 3,
                    day: 14,
                    place: .known(
                        name: "Invalid",
                        latitude: 0,
                        longitude: 180.1,
                        timeZoneIdentifier: "UTC"
                    )
                ),
                tradition: .western
            )
        }

        #expect(throws: BirthCalculationInputValidationError.invalidLongitude) {
            try BirthCalculationInput(
                birth: BirthDetails(
                    year: 1994,
                    month: 3,
                    day: 14,
                    place: .known(
                        name: "Invalid",
                        latitude: 0,
                        longitude: .infinity,
                        timeZoneIdentifier: "UTC"
                    )
                ),
                tradition: .western
            )
        }
    }

    @Test("Known place requires a real timezone identifier")
    func timeZoneIdentifierIsValidated() {
        #expect(throws: BirthCalculationInputValidationError.invalidTimeZoneIdentifier) {
            try BirthCalculationInput(
                birth: BirthDetails(
                    year: 1994,
                    month: 3,
                    day: 14,
                    place: .known(
                        name: "Tehran, Iran",
                        latitude: 35.6892,
                        longitude: 51.3890,
                        timeZoneIdentifier: "Mars/Olympus_Mons"
                    )
                ),
                tradition: .western
            )
        }
    }
}
