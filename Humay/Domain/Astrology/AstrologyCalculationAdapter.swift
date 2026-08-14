/// Common contract for a provider-independent astrology calculation boundary.
///
/// Concrete implementations are composed outside Domain. This protocol carries no
/// networking, credentials, endpoint, vendor SDK or persistence assumptions.
protocol AstrologyCalculationAdapter: Sendable {
    associatedtype Fact: AstrologyCalculationFact

    static var tradition: AstrologyTradition { get }

    func calculate(
        _ input: BirthCalculationInput
    ) async throws -> AstrologyCalculationResult<Fact>
}

/// Western calculation boundary. The concrete engine/provider implementation is not
/// selected by the iOS Domain contract.
protocol WesternCalculationAdapter: AstrologyCalculationAdapter {}

extension WesternCalculationAdapter {
    static var tradition: AstrologyTradition { .western }
}

/// Vedic calculation boundary. Methodology-sensitive production behavior remains
/// gated by the relevant methodology decisions.
protocol VedicCalculationAdapter: AstrologyCalculationAdapter {}

extension VedicCalculationAdapter {
    static var tradition: AstrologyTradition { .vedic }
}

/// Chinese/BaZi calculation boundary. Personalized Four-Pillars calculation is
/// distinct from any coarse Chinese Free catalog key.
protocol BaZiCalculationAdapter: AstrologyCalculationAdapter {}

extension BaZiCalculationAdapter {
    static var tradition: AstrologyTradition { .chinese }
}

extension AstrologyCalculationAdapter {
    /// Shared guard for adapters before calculation begins. A calculation input is
    /// never silently reinterpreted as another tradition.
    func requireCompatibleTradition(_ input: BirthCalculationInput) throws {
        guard input.tradition == Self.tradition else {
            throw AstrologyCalculationError.unsupportedMethodology
        }
    }
}
