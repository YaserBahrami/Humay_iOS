// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Illustrative sample content. Not ephemeris output. Not a test oracle.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// The classical element of a sign. Used here only to give the fixture bank a
/// deterministic way to cover all 144 pairings with prose that is at least coherent.
///
/// This is emphatically **not** a compatibility formula. There is no number, nothing is
/// summed and nothing is ranked — it selects which paragraph to show. A real
/// implementation reads two charts, not two elements.
private enum SignElement {
    case fire, earth, air, water

    static func of(_ sign: WesternSign) -> SignElement {
        switch sign {
        case .aries, .leo, .sagittarius: .fire
        case .taurus, .virgo, .capricorn: .earth
        case .gemini, .libra, .aquarius: .air
        case .cancer, .scorpio, .pisces: .water
        }
    }

    var noun: String {
        switch self {
        case .fire: "Fire"
        case .earth: "Earth"
        case .air: "Air"
        case .water: "Water"
        }
    }
}

private enum SignModality {
    case cardinal, fixed, mutable

    static func of(_ sign: WesternSign) -> SignModality {
        switch sign {
        case .aries, .cancer, .libra, .capricorn: .cardinal
        case .taurus, .leo, .scorpio, .aquarius: .fixed
        case .gemini, .virgo, .sagittarius, .pisces: .mutable
        }
    }
}

struct CompatibilityPairing {
    let first: WesternSign
    let second: WesternSign

    private var firstElement: SignElement { .of(first) }
    private var secondElement: SignElement { .of(second) }
    private var sameElement: Bool { firstElement == secondElement }
    private var sameModality: Bool { SignModality.of(first) == SignModality.of(second) }

    private var compatible: Bool {
        switch (firstElement, secondElement) {
        case (.fire, .air), (.air, .fire), (.earth, .water), (.water, .earth): true
        default: sameElement
        }
    }

    // MARK: - Verdicts

    func verdict(for axis: CompatibilityAxis) -> CompatibilityVerdict {
        switch axis {
        case .loveAndChemistry:
            if compatible && !sameElement { return .strong }
            if sameElement { return .balanced }
            return crossesWaterAndFire ? .mixed : .balanced
        case .communication:
            if firstElement == .air || secondElement == .air {
                return compatible ? .strong : .mixed
            }
            return compatible ? .balanced : .mixed
        case .emotionalConnection:
            if firstElement == .water && secondElement == .water { return .strong }
            if crossesWaterAndFire { return .mixed }
            return compatible ? .strong : .balanced
        case .conflictAndPace:
            if sameModality { return .friction }
            return compatible ? .balanced : .mixed
        }
    }

    private var crossesWaterAndFire: Bool {
        (firstElement == .water && secondElement == .fire) || (firstElement == .fire && secondElement == .water)
    }

    // MARK: - Prose

    func headline(for tone: Tone) -> String {
        switch tone {
        case .normal:
            if sameElement { return "Familiar ground. Easy to recognise, harder to be surprised by." }
            if crossesWaterAndFire { return "Easy to love. Harder to agree with." }
            if compatible { return "Different rooms, same building." }
            return "Two ways of being right about the same thing."
        case .roast:
            if sameElement { return "You are the same person twice. Nobody is going to do the dishes." }
            if crossesWaterAndFire { return "Devotion at first, depletion later, unless someone adjusts." }
            if compatible { return "It works, and neither of you can explain why to your friends." }
            return "You are both correct, loudly, about different things."
        }
    }

    func body(for tone: Tone) -> String {
        let elements = sameElement
            ? "\(firstElement.noun) meets \(secondElement.noun.lowercased()) — you recognise each other quickly, which is comfortable and means fewer things get questioned."
            : "\(firstElement.noun) meets \(secondElement.noun.lowercased()), which is the whole shape of it."

        switch tone {
        case .normal:
            return "\(elements) \(normalBody) This is a general reading, drawn from the two Sun signs rather than from either chart, so it describes a tendency between two kinds of people rather than the two of you."
        case .roast:
            return "\(elements) \(roastBody) Bear in mind this is derived from two birthdays, so if it is wrong, it is wrong about a great many people at once."
        }
    }

    private var normalBody: String {
        if crossesWaterAndFire {
            return "One of you softens where the other pushes forward, which reads as devotion at the start and as depletion later if neither adjusts."
        }
        if sameElement {
            return "The strengths double and so do the blind spots — whatever neither of you is naturally good at will simply not get done."
        }
        if compatible {
            return "The instincts differ enough to be useful. Each of you tends to reach for the thing the other would not have thought of."
        }
        return "The disagreement is rarely about facts. It is about pace and about what counts as settled."
    }

    private var roastBody: String {
        if crossesWaterAndFire {
            return "One of you will call it passion and the other will call it Tuesday."
        }
        if sameElement {
            return "Your shared blind spot has a name and neither of you will say it."
        }
        if compatible {
            return "You balance each other, which mostly means you take turns being the reasonable one and keep score."
        }
        return "Neither of you is losing this argument, which is why it is now nine months old."
    }

    func preciseHeadline(for tone: Tone) -> String {
        switch tone {
        case .normal: "Easy to love. Harder to argue with."
        case .roast: "You are both extremely good at not starting this conversation."
        }
    }

    func preciseBody(for tone: Tone, name: String) -> String {
        switch tone {
        case .normal:
            return "Both of your charts value independence — genuinely healthy room rather than distance. It also lets important conversations sit unstarted for weeks, because neither of you experiences the silence as a problem until it has been one for a while."
        case .roast:
            return "You both call it giving each other space. \(name) calls it that too. Between you, you have given each other so much space that a conversation from March is still out there somewhere, unaddressed."
        }
    }

    func explanation(for axis: CompatibilityAxis, tier: PrecisionTier) -> String {
        switch (axis, tier) {
        case (.loveAndChemistry, .general):
            crossesWaterAndFire
                ? "Attraction is quick here and rarely the difficulty. What follows it is."
                : "\(firstElement.noun) and \(secondElement.noun.lowercased()) meet each other at a similar temperature."
        case (.loveAndChemistry, .precise):
            "Venus in one chart sits close to the other's Ascendant, which is why the first impression held rather than wearing off."
        case (.communication, .general):
            compatible
                ? "You reach for the same register without agreeing to. Explanations are shorter than they should need to be."
                : "The words are not the problem. The assumed context underneath them is."
        case (.communication, .precise):
            "Mercury in one chart squares Saturn in the other. Not misunderstanding — a difference in how much needs saying before a thing counts as said."
        case (.emotionalConnection, .general):
            firstElement == .water || secondElement == .water
                ? "One of you tends to register the mood before it is announced, which is a gift and a load."
                : "Warmth here is shown in what gets done rather than in what gets named."
        case (.emotionalConnection, .precise):
            "The Moons are in compatible elements, so what settles one of you does not unsettle the other. That is rarer than it sounds."
        case (.conflictAndPace, .general):
            sameModality
                ? "You move at the same speed, which is why neither of you yields first."
                : "One of you closes things and the other keeps them open. That difference is the mechanism, not the fault."
        case (.conflictAndPace, .precise):
            "Mars in one chart opposes the other's Moon. Disagreements escalate faster than either of you intends, and cool down faster than either expects."
        }
    }
}

enum CompatibilityFixtures {
    static func pairing(_ first: WesternSign, _ second: WesternSign) -> CompatibilityPairing {
        CompatibilityPairing(first: first, second: second)
    }

    /// What the precise tier can say that the general tier cannot.
    ///
    /// Shared values live here rather than as an axis, because two Sun signs do not
    /// support a claim about what two people hold important.
    static func deeperNote(_ first: WesternSign, _ second: WesternSign, name: String) -> String {
        "With both charts in view there is more to say than a sign pairing supports. What the two of you actually hold important shows up in the ninth-house material and in where Jupiter sits for each of you — not in the Sun signs. On that reading you agree about what a life should be for and disagree about what it should cost, which is why the arguments are about time and money rather than about values, even when they are about values."
    }

    static func basisFactors(_ first: WesternSign, _ second: WesternSign) -> [BasisFactor] {
        [
            BasisFactor(id: "syn-1", system: .western, label: "Venus △ Ascendant", detail: "orb 2° 10′"),
            BasisFactor(id: "syn-2", system: .western, label: "Mercury □ Saturn", detail: "orb 1° 44′"),
            BasisFactor(id: "syn-3", system: .western, label: "Moon ☍ Mars", detail: "orb 3° 02′"),
        ]
    }

    static func todayTogetherHeadline(_ first: WesternSign, _ second: WesternSign, tone: Tone) -> String {
        switch tone {
        case .normal: "A good day to say the thing you would normally postpone."
        case .roast: "Today is the day. It was also Tuesday. And the Tuesday before."
        }
    }

    static func todayTogetherBody(
        _ first: WesternSign,
        _ second: WesternSign,
        name: String,
        tone: Tone
    ) -> String {
        switch tone {
        case .normal:
            "The Moon crosses into the part of your chart that deals with what is shared rather than divided, and \(name)'s Venus is steady through the end of the week. The conditions favour a direct conversation over a written one, and there is no urgency before this evening."
        case .roast:
            "The window is open and you will both use it to ask whether the other has eaten. \(name) is not going to start it either, so that is two of you waiting for a third person who does not exist."
        }
    }
}
