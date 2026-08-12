import Testing
@testable import Humay

@Suite("Production foundation")
struct FoundationTests {
    @Test("Date-only birth details do not claim precision")
    func dateOnlyBirthIsNotPrecise() {
        let birth = BirthDetails(year: 1994, month: 3, day: 14)
        #expect(birth.time == .unknown)
        #expect(birth.place == .notProvided)
        #expect(!birth.supportsPrecision)
    }

    @Test("Precision requires both time and place")
    func precisionRequiresTimeAndPlace() {
        let withTimeOnly = BirthDetails(
            year: 1994,
            month: 3,
            day: 14,
            time: .exact(minutesFromMidnight: 7 * 60 + 42)
        )
        #expect(!withTimeOnly.supportsPrecision)

        let complete = BirthDetails(
            year: 1994,
            month: 3,
            day: 14,
            time: .exact(minutesFromMidnight: 7 * 60 + 42),
            place: .known(
                name: "Lisbon, Portugal",
                latitude: 38.7167,
                longitude: -9.1333,
                timeZoneIdentifier: "Europe/Lisbon"
            )
        )
        #expect(complete.supportsPrecision)
    }

    @Test("Fresh settings have not completed onboarding")
    func freshSettingsAreIncomplete() {
        #expect(!AppSettings.default.hasCompletedOnboarding)
        #expect(AppSettings.default.leadingTradition == .western)
        #expect(AppSettings.default.tone == .normal)
    }
}
