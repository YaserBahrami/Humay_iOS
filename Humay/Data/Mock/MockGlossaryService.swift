// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Definitions are editorial. Not ephemeris output. Not a test oracle.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// Definitions for terms that belong to one system.
///
/// Every term is scoped, so a Nakshatra definition cannot surface from a Western
/// screen. That is not tidiness — presenting a Vedic concept inside a Western reading is
/// how the traditions start looking interchangeable.
struct MockGlossaryService: GlossaryService, MockContentProvider {
    static let fixtureNamespace = "glossary"

    let latency: MockLatency

    init(latency: MockLatency = .realistic) {
        self.latency = latency
    }

    func term(id: String) async throws -> GlossaryTerm {
        await latency.wait()
        guard let match = Self.terms.first(where: { $0.id == id }) else {
            throw HumayServiceError.contentUnavailable(id)
        }
        return match
    }

    static let terms: [GlossaryTerm] = [
        GlossaryTerm(
            id: "nakshatra",
            system: .vedic,
            term: "Nakshatra",
            definition: "One of twenty-seven lunar segments marking the Moon's exact position. Vedic reading treats it as carrying more specific character than the rashi alone, and it anchors the dasha sequence.",
            requirement: "Needs a birth time to place accurately."
        ),
        GlossaryTerm(
            id: "lagna",
            system: .vedic,
            term: "Lagna",
            definition: "The sign rising on the eastern horizon at the moment of birth. It sets the bhavas for the rest of the chart, so almost every house-based judgement follows from it.",
            requirement: "Needs a birth time and place."
        ),
        GlossaryTerm(
            id: "mahadasha",
            system: .vedic,
            term: "Mahadasha",
            definition: "A major planetary period. Each graha governs a multi-year chapter that colours everything read within it. This is Vedic timing, and it is not the same idea as a transit.",
            requirement: "Needs a birth time — the sequence starts from the Moon's exact position."
        ),
        GlossaryTerm(
            id: "bhava",
            system: .vedic,
            term: "Bhava",
            definition: "One of twelve divisions counted from the Lagna. Bhavas cover related ground to Western houses but are not the same construct and are not judged the same way.",
            requirement: "Needs a birth time and place."
        ),
        GlossaryTerm(
            id: "ayanamsa",
            system: .vedic,
            term: "Ayanamsa",
            definition: "The offset between the tropical and sidereal zodiacs, currently around twenty-four degrees. Which value is used changes every position in the chart, which is why the choice is a methodology decision rather than a setting.",
            requirement: nil
        ),
        GlossaryTerm(
            id: "day-master",
            system: .chinese,
            term: "Day Master",
            definition: "The element of your Day Pillar's stem. In BaZi it is the reference point the rest of the chart is judged against — whether the other pillars support it, drain it or control it.",
            requirement: "Needs a birth time to place the Day and Hour pillars precisely."
        ),
        GlossaryTerm(
            id: "pillar",
            system: .chinese,
            term: "Pillar",
            definition: "One of four two-character units — Year, Month, Day and Hour — each pairing a heavenly stem with an earthly branch. The chart is read through how they interact.",
            requirement: nil
        ),
        GlossaryTerm(
            id: "luck-cycle",
            system: .chinese,
            term: "Luck Cycle",
            definition: "A sequence of roughly ten-year periods layered over the four pillars. The direction it runs depends on a convention that has not been settled here, so it is not shown as decided.",
            requirement: "Method still being decided."
        ),
        GlossaryTerm(
            id: "wu-xing",
            system: .chinese,
            term: "Five Elements",
            definition: "Wood, Fire, Earth, Metal and Water, related through cycles of generation and control. BaZi reads the balance between them across the pillars rather than tracking bodies through a sky.",
            requirement: nil
        ),
        GlossaryTerm(
            id: "orb",
            system: .western,
            term: "Orb",
            definition: "How far an aspect is from exact. A tight orb means the two bodies are harder to experience separately; a wide one means the connection is present but easier to set aside.",
            requirement: nil
        ),
        GlossaryTerm(
            id: "retrograde",
            system: .western,
            term: "Retrograde",
            definition: "The apparent backward motion of a planet against the background stars, caused by the relative motion of Earth. Nothing actually reverses.",
            requirement: nil
        ),
        GlossaryTerm(
            id: "ascendant",
            system: .western,
            term: "Ascendant",
            definition: "The degree rising on the eastern horizon at birth. It sets the house cusps, which is why so much of a chart depends on knowing the time.",
            requirement: "Needs a birth time and place."
        ),
    ]
}
