// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Illustrative sample content. Not ephemeris output. Not a test oracle.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// Relationship readings, from fixtures.
///
/// Both tiers use the same four axes, so the vocabulary carries across. What changes is
/// what the reading is entitled to claim: the general tier works from two Sun signs and
/// says so; the precise tier speaks about both charts and can reach the things a pair
/// of dates cannot support — shared values among them.
///
/// There is no score anywhere here, and no ordering over verdicts. A qualitative
/// judgement with a sentence behind it is the whole output.
struct MockCompatibilityService: CompatibilityService, MockContentProvider {
    static let fixtureNamespace = "compatibility"

    let latency: MockLatency

    init(latency: MockLatency = .realistic) {
        self.latency = latency
    }

    func generalReading(
        _ first: WesternSign,
        _ second: WesternSign,
        tone: Tone
    ) async throws -> GeneralCompatibilityReading {
        await latency.wait()
        let pairing = CompatibilityFixtures.pairing(first, second)

        return GeneralCompatibilityReading(
            pairLabel: "\(first.spokenName) + \(second.spokenName)",
            firstSign: first,
            secondSign: second,
            headline: pairing.headline(for: tone),
            body: pairing.body(for: tone),
            axes: CompatibilityAxis.allCases.map { axis in
                CompatibilityAxisReading(
                    axis: axis,
                    verdict: pairing.verdict(for: axis),
                    explanation: pairing.explanation(for: axis, tier: .general)
                )
            },
            basis: ReadingBasis(
                summary: "A general, sign-to-sign reading — from two birth dates, not from either chart.",
                factors: []
            ),
            provenance: Self.provenance("general.\(first.rawValue)-\(second.rawValue)")
        )
    }

    func preciseReading(
        user: UserProfile,
        person: CirclePerson,
        tone: Tone
    ) async throws -> PreciseCompatibilityReading {
        await latency.wait()
        let userSign = MockAstrology.sunSign(for: user.birth)
        let personSign = MockAstrology.sunSign(for: person.birth)
        let pairing = CompatibilityFixtures.pairing(userSign, personSign)

        return PreciseCompatibilityReading(
            pairLabel: "\(user.displayName) & \(person.name)",
            relationshipLabel: person.role.displayName,
            headline: pairing.preciseHeadline(for: tone),
            body: pairing.preciseBody(for: tone, name: person.name),
            axes: CompatibilityAxis.allCases.map { axis in
                CompatibilityAxisReading(
                    axis: axis,
                    verdict: pairing.verdict(for: axis),
                    explanation: pairing.explanation(for: axis, tier: .precise)
                )
            },
            deeperNote: CompatibilityFixtures.deeperNote(userSign, personSign, name: person.name),
            basis: ReadingBasis(
                summary: "From both of your calculated charts, read against each other.",
                factors: CompatibilityFixtures.basisFactors(userSign, personSign)
            ),
            provenance: Self.provenance("precise.\(userSign.rawValue)-\(personSign.rawValue)")
        )
    }

    func todayTogether(
        user: UserProfile,
        person: CirclePerson,
        date: DateComponents,
        tone: Tone
    ) async throws -> HoroscopeReading {
        await latency.wait()
        let userSign = MockAstrology.sunSign(for: user.birth)
        let personSign = MockAstrology.sunSign(for: person.birth)

        return HoroscopeReading(
            id: "todayTogether.\(user.id).\(person.id)",
            date: date,
            tier: .precise,
            tone: tone,
            subjectLabel: "You and \(person.name)",
            headline: CompatibilityFixtures.todayTogetherHeadline(userSign, personSign, tone: tone),
            overview: CompatibilityFixtures.todayTogetherBody(userSign, personSign, name: person.name, tone: tone),
            categories: [:],
            basis: ReadingBasis(
                summary: "What today is doing to the two of you — separate from what you permanently are.",
                factors: CompatibilityFixtures.basisFactors(userSign, personSign)
            ),
            provenance: Self.provenance("todayTogether.\(userSign.rawValue)-\(personSign.rawValue)")
        )
    }
}
