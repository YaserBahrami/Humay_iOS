import Foundation

// MARK: - Protocol

protocol BigThreeCalculating: Sendable {
    func calculate(birth: BirthDetails) async throws -> BigThree
}

// MARK: - Errors

extension BigThreeCalculationError {
    static let version = "bigthree-v1"

    var asAvailabilityReason: AstrologyUnavailabilityReason {
        switch self {
        case .invalidBirthDate, .invalidBirthTime: .invalidInput
        case .invalidLatitude, .invalidLongitude: .invalidInput
        case .invalidTimeZoneIdentifier: .invalidInput
        case .invalidLongitudeValue: .invalidInput
        case .historicalTimezoneUnavailable: .calculationUnavailable
        }
    }
}

// MARK: - DefaultBigThreeCalculator

/// Deterministic, offline, vendor-neutral Big Three calculator.
/// Async adapter over the single canonical `BigThreeCalculationCore`.
struct DefaultBigThreeCalculator: BigThreeCalculating, Sendable {
    static let calculatorVersion = "bigthree-v1"
    static let engineIdentifier = HumayAstronomyEngine.identifier
    static let engineVersion = HumayAstronomyEngine.version

    func calculate(birth: BirthDetails) async throws -> BigThree {
        try BigThreeCalculationCore.calculate(birth: birth)
    }
}
