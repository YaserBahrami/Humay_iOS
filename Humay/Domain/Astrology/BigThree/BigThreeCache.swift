import Foundation

/// Lightweight memoisation for Big Three calculations.
///
/// Do not recalculate on every SwiftUI redraw. Results are cached per
/// `BirthDetails` + calculator version. In-memory cache is the primary layer
/// (actor-isolated); callers that need persistence can store `BigThree`
/// inside `PersonalizedForecastDocument` or a dedicated file. Business rule:
/// changing `displayName` does not invalidate the cache — only inputs that
/// appear in `BigThreeInputFingerprint` do.
actor BigThreeCache {
    private let calculator: any BigThreeCalculating
    private var memory: [String: BigThree] = [:]

    init(calculator: any BigThreeCalculating = DefaultBigThreeCalculator()) {
        self.calculator = calculator
    }

    /// Returns a cached result or calculates once and memoises. Thread-safe.
    func bigThree(for birth: BirthDetails) async throws -> BigThree {
        let key = BigThreeInputFingerprint.fingerprint(birth: birth, calculatorVersion: DefaultBigThreeCalculator.calculatorVersion)
        if let cached = memory[key] { return cached }
        let computed = try await calculator.calculate(birth: birth)
        memory[key] = computed
        return computed
    }

    /// Explicit invalidation (e.g. after profile update).
    func invalidate(for birth: BirthDetails) {
        let key = BigThreeInputFingerprint.fingerprint(birth: birth, calculatorVersion: DefaultBigThreeCalculator.calculatorVersion)
        memory.removeValue(forKey: key)
    }

    func invalidateAll() { memory.removeAll() }

    /// Synchronous peek for previews/tests when calculation is already cached.
    func cached(for birth: BirthDetails) -> BigThree? {
        let key = BigThreeInputFingerprint.fingerprint(birth: birth, calculatorVersion: DefaultBigThreeCalculator.calculatorVersion)
        return memory[key]
    }
}

/// Global shared cache for simple call-sites (Previews, YouView) that don't
/// own an actor. Kept intentionally non-singleton-heavy — production code
/// should inject `BigThreeCache` where possible.
enum BigThreeCacheShared {
    static let shared = BigThreeCache()
}
