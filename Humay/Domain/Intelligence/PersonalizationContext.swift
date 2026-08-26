import Foundation

/// Structured, privacy-minimal context for generation.
///
/// Contains only what entertainment generation needs: Big Three facts,
/// Humay archetype, and temporal confidence. No name, no UUID, no raw
/// coordinates, no contact info. Same canonical context is supplied to
/// year outline, month chunk, and day regeneration so monthly content never
/// depends only on prose written by the year-outline AI.
struct PersonalizationContext: Sendable, Hashable, Codable {
    // Big Three — nil when unavailable/ambiguous (never invented)
    let sunSign: String?
    let sunDegreeWithinSign: Double?
    let moonSign: String?
    let moonDegreeWithinSign: Double?
    let risingSign: String?
    let risingDegreeWithinSign: Double?
    /// True when birth time is known (exact or approximate). Used for prompt hedging.
    let birthTimeKnown: Bool
    /// Humay-original archetype; invented, not astrology.
    let archetypeID: String
    let archetypeName: String

    /// Human-readable astrology snippet for prompt flavor text.
    var astrologyContextJSON: String {
        var dict: [String: String] = [:]
        if let sunSign { dict["sun"] = sunDegreeWithinSign.map { String(format: "%@ %.1f°", sunSign, $0) } ?? sunSign }
        if let moonSign { dict["moon"] = moonDegreeWithinSign.map { String(format: "%@ %.1f°", moonSign, $0) } ?? moonSign }
        if let risingSign { dict["rising"] = risingDegreeWithinSign.map { String(format: "%@ %.1f°", risingSign, $0) } ?? risingSign }
        if dict.isEmpty { return "{}" }
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
           let s = String(data: data, encoding: .utf8) { return s }
        return "{}"
    }

    /// Factory from a subject's deterministic Big Three.
    static func from(subject: ForecastSubject) -> PersonalizationContext {
        let archetype = HumayContentEngine.archetype(profileID: subject.id)
        if let bigThree = subject.bigThree() {
            return PersonalizationContext(
                sunSign: bigThree.sun.value?.sign.rawValue,
                sunDegreeWithinSign: bigThree.sun.value?.degreeWithinSign,
                moonSign: bigThree.moon.value?.sign.rawValue,
                moonDegreeWithinSign: bigThree.moon.value?.degreeWithinSign,
                risingSign: bigThree.rising.value?.sign.rawValue,
                risingDegreeWithinSign: bigThree.rising.value?.degreeWithinSign,
                birthTimeKnown: subject.birth.time.isKnown,
                archetypeID: archetype.id,
                archetypeName: archetype.name
            )
        } else {
            return PersonalizationContext(
                sunSign: subject.sunSign?.rawValue,
                sunDegreeWithinSign: nil,
                moonSign: nil,
                moonDegreeWithinSign: nil,
                risingSign: nil,
                risingDegreeWithinSign: nil,
                birthTimeKnown: subject.birth.time.isKnown,
                archetypeID: archetype.id,
                archetypeName: archetype.name
            )
        }
    }
}
