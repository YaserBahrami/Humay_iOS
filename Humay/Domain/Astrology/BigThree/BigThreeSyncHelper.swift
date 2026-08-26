import Foundation

/// Synchronous bridge for call-sites that cannot `await` (computed properties,
/// Document init). Delegates to the single canonical `BigThreeCalculationCore`.
enum BigThreeSyncHelper {
    static func compute(birth: BirthDetails) -> BigThree? {
        try? BigThreeCalculationCore.calculate(birth: birth)
    }
}
