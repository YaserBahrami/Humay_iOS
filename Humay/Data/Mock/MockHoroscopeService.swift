// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Illustrative sample content. Not ephemeris output. Not a test oracle.
//  See docs/development/DEVIATIONS.md (DEV-001).
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// Daily readings, from fixtures.
///
/// Note where the basis comes from: it is read once per fixture and used for both
/// registers. There is no code path in which choosing Roast changes the reasoning, only
/// the wording — which is the product rule, expressed as structure rather than
/// discipline.
struct MockHoroscopeService: HoroscopeService, MockContentProvider {
    static let fixtureNamespace = "horoscope"

    let latency: MockLatency

    init(latency: MockLatency = .realistic) {
        self.latency = latency
    }

    func generalReading(
        sign: WesternSign,
        date: DateComponents,
        tone: Tone
    ) async throws -> HoroscopeReading {
        await latency.wait()
        let fixture = DailyReadingFixtures.fixture(for: sign)
        let register = fixture.register(for: tone)

        return HoroscopeReading(
            id: "general.\(sign.rawValue).\(tone.rawValue)",
            date: date,
            tier: .general,
            tone: tone,
            subjectLabel: sign.spokenName,
            headline: register.headline,
            overview: register.overview,
            categories: Dictionary(
                uniqueKeysWithValues: ReadingCategory.allCases.map { ($0, register.text(for: $0)) }
            ),
            basis: ReadingBasis(
                summary: "The sign-wide picture for \(sign.spokenName) today — not your personal chart.",
                factors: []
            ),
            provenance: Self.provenance("general.\(sign.rawValue)")
        )
    }

    func preciseReading(
        profile: UserProfile,
        date: DateComponents,
        tone: Tone
    ) async throws -> HoroscopeReading {
        await latency.wait()
        let sign = MockAstrology.sunSign(for: profile.birth)
        let fixture = DailyReadingFixtures.fixture(for: sign)
        let register = fixture.register(for: tone)

        return HoroscopeReading(
            id: "precise.\(sign.rawValue).\(tone.rawValue)",
            date: date,
            tier: .precise,
            tone: tone,
            subjectLabel: "Your chart",
            headline: PreciseReadingFixtures.headline(for: sign, tone: tone),
            overview: PreciseReadingFixtures.overview(for: sign, tone: tone),
            categories: Dictionary(
                uniqueKeysWithValues: ReadingCategory.allCases.map { ($0, register.text(for: $0)) }
            ),
            basis: ReadingBasis(
                summary: fixture.basisSummaryPrecise,
                factors: fixture.basisFactors
            ),
            provenance: Self.provenance("precise.\(sign.rawValue)")
        )
    }
}
