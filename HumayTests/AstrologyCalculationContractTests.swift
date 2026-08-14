import Foundation
import Testing
@testable import Humay

@Suite("ASTRO-002 calculation contracts")
struct AstrologyCalculationContractTests {
    @Test("Normalized result preserves Humay provenance and fact reliability")
    func resultPreservesProvenanceAndReliability() {
        let provenance = AstrologyCalculationProvenance(
            calculationContractVersion: "1",
            methodologyVersion: "western-test-1",
            adapterIdentifier: "humay.test.western",
            engineVersion: "fixture-engine-1",
            configurationVersion: "fixture-config-1"
        )
        let calculatedAt = Date(timeIntervalSince1970: 1_754_000_000)
        let facts = [
            TestFact(identifier: "sun", reliability: .reliable),
            TestFact(
                identifier: "ascendant",
                reliability: .uncertain(.approximateBirthTime)
            ),
            TestFact(
                identifier: "house-1",
                reliability: .unavailable(.missingBirthTime)
            )
        ]

        let result = AstrologyCalculationResult(
            tradition: .western,
            provenance: provenance,
            calculatedAt: calculatedAt,
            facts: facts
        )

        #expect(result.tradition == .western)
        #expect(result.provenance == provenance)
        #expect(result.calculatedAt == calculatedAt)
        #expect(result.facts == facts)
    }

    @Test("Tradition adapters expose independent Humay boundaries")
    func adapterTraditionsAreIndependent() {
        #expect(TestWesternAdapter.tradition == .western)
        #expect(TestVedicAdapter.tradition == .vedic)
        #expect(TestBaZiAdapter.tradition == .chinese)
    }

    @Test("Adapter guard rejects cross-tradition reinterpretation")
    func adapterRejectsTraditionMismatch() throws {
        let input = try BirthCalculationInput(
            birth: BirthDetails(year: 1994, month: 3, day: 14),
            tradition: .vedic
        )
        let adapter = TestWesternAdapter()

        #expect(throws: AstrologyCalculationError.unsupportedMethodology) {
            try adapter.requireCompatibleTradition(input)
        }
    }

    @Test("Typed adapter accepts normalized input and returns a typed Humay result")
    func typedAdapterCalculates() async throws {
        let input = try BirthCalculationInput(
            birth: BirthDetails(year: 1994, month: 3, day: 14),
            tradition: .western
        )
        let adapter = TestWesternAdapter()

        let result = try await adapter.calculate(input)

        #expect(result.tradition == .western)
        #expect(result.facts == [TestFact(identifier: "sun", reliability: .reliable)])
        #expect(result.provenance.adapterIdentifier == "humay.test.western")
    }

    @Test("Calculation failure surface remains Humay-owned and payload-free")
    func calculationErrorsAreFiniteAndPayloadFree() {
        let errors: [AstrologyCalculationError] = [
            .invalidInput,
            .insufficientBirthPrecision,
            .unsupportedMethodology,
            .unavailable,
            .requestRejected,
            .malformedResponse,
            .validationFailed,
            .methodologyGateDisabled
        ]

        #expect(Set(errors).count == 8)
    }
}

private struct TestFact: AstrologyCalculationFact {
    let identifier: String
    let reliability: AstrologyFactReliability
}

private struct TestWesternAdapter: WesternCalculationAdapter {
    func calculate(
        _ input: BirthCalculationInput
    ) async throws -> AstrologyCalculationResult<TestFact> {
        try requireCompatibleTradition(input)
        return AstrologyCalculationResult(
            tradition: Self.tradition,
            provenance: AstrologyCalculationProvenance(
                calculationContractVersion: "1",
                methodologyVersion: "western-test-1",
                adapterIdentifier: "humay.test.western"
            ),
            calculatedAt: Date(timeIntervalSince1970: 1_754_000_000),
            facts: [TestFact(identifier: "sun", reliability: .reliable)]
        )
    }
}

private struct TestVedicAdapter: VedicCalculationAdapter {
    func calculate(
        _ input: BirthCalculationInput
    ) async throws -> AstrologyCalculationResult<TestFact> {
        try requireCompatibleTradition(input)
        return AstrologyCalculationResult(
            tradition: Self.tradition,
            provenance: AstrologyCalculationProvenance(
                calculationContractVersion: "1",
                methodologyVersion: "vedic-test-1",
                adapterIdentifier: "humay.test.vedic"
            ),
            calculatedAt: Date(timeIntervalSince1970: 1_754_000_000),
            facts: []
        )
    }
}

private struct TestBaZiAdapter: BaZiCalculationAdapter {
    func calculate(
        _ input: BirthCalculationInput
    ) async throws -> AstrologyCalculationResult<TestFact> {
        try requireCompatibleTradition(input)
        return AstrologyCalculationResult(
            tradition: Self.tradition,
            provenance: AstrologyCalculationProvenance(
                calculationContractVersion: "1",
                methodologyVersion: "bazi-test-1",
                adapterIdentifier: "humay.test.bazi"
            ),
            calculatedAt: Date(timeIntervalSince1970: 1_754_000_000),
            facts: []
        )
    }
}
