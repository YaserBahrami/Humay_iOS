import Foundation

/// Provider-independent input for deterministic astrology calculations.
///
/// This wraps the existing `BirthDetails` domain model rather than copying birth
/// facts into a second user model. Validation happens before an adapter/provider can
/// consume the input, so invalid dates, times, coordinates and time zones cannot
/// silently cross the calculation boundary.
struct BirthCalculationInput: Sendable, Hashable {
    let birth: BirthDetails
    let tradition: AstrologyTradition

    init(birth: BirthDetails, tradition: AstrologyTradition) throws {
        try Self.validateBirthDate(birth)
        try Self.validateBirthTime(birth.time)
        try Self.validateBirthPlace(birth.place)

        self.birth = birth
        self.tradition = tradition
    }

    private static func validateBirthDate(_ birth: BirthDetails) throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = birth.year
        components.month = birth.month
        components.day = birth.day

        guard let candidate = calendar.date(from: components) else {
            throw BirthCalculationInputValidationError.invalidBirthDate
        }

        let resolved = calendar.dateComponents([.year, .month, .day], from: candidate)
        guard resolved.year == birth.year,
              resolved.month == birth.month,
              resolved.day == birth.day,
              let earliest = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) else {
            throw BirthCalculationInputValidationError.invalidBirthDate
        }

        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date.now)
        guard let today = calendar.date(from: todayComponents),
              candidate >= earliest,
              candidate <= today else {
            throw BirthCalculationInputValidationError.invalidBirthDate
        }
    }

    private static func validateBirthTime(_ time: BirthTime) throws {
        switch time {
        case .exact(let minutesFromMidnight):
            guard validMinutes(minutesFromMidnight) else {
                throw BirthCalculationInputValidationError.invalidExactBirthTime
            }

        case .approximate(let minutesFromMidnight, let toleranceMinutes):
            guard validMinutes(minutesFromMidnight), toleranceMinutes > 0 else {
                throw BirthCalculationInputValidationError.invalidApproximateBirthTime
            }

        case .unknown:
            break
        }
    }

    private static func validateBirthPlace(_ place: BirthPlace) throws {
        guard case .known(
            let name,
            let latitude,
            let longitude,
            let timeZoneIdentifier
        ) = place else {
            return
        }

        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BirthCalculationInputValidationError.emptyBirthPlaceName
        }

        guard latitude.isFinite, (-90...90).contains(latitude) else {
            throw BirthCalculationInputValidationError.invalidLatitude
        }

        guard longitude.isFinite, (-180...180).contains(longitude) else {
            throw BirthCalculationInputValidationError.invalidLongitude
        }

        guard TimeZone(identifier: timeZoneIdentifier) != nil else {
            throw BirthCalculationInputValidationError.invalidTimeZoneIdentifier
        }
    }

    private static func validMinutes(_ minutes: Int) -> Bool {
        (0...1_439).contains(minutes)
    }
}

enum BirthCalculationInputValidationError: Error, Equatable, Sendable {
    case invalidBirthDate
    case invalidExactBirthTime
    case invalidApproximateBirthTime
    case emptyBirthPlaceName
    case invalidLatitude
    case invalidLongitude
    case invalidTimeZoneIdentifier
}
