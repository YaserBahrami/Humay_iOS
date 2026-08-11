// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Illustrative sample content. Not ephemeris output. Not a test oracle.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// The precise reading's own headline and body.
///
/// Deliberately written to reference mechanics — a house ingress, a retrograde shadow
/// clearing — because that is the difference the tier is claiming. The general reading
/// describes a tendency; this one points at a moving part.
enum PreciseReadingFixtures {
    static func headline(for sign: WesternSign, tone: Tone) -> String {
        switch tone {
        case .normal: normalHeadlines[sign] ?? "The day turns on one hour."
        case .roast: roastHeadlines[sign] ?? "One hour matters. You will spend it scrolling."
        }
    }

    static func overview(for sign: WesternSign, tone: Tone) -> String {
        let mechanics = mechanicsLine(for: sign)
        switch tone {
        case .normal:
            return "\(mechanics) \(normalBodies[sign] ?? "The shift is small and the timing is the point.")"
        case .roast:
            return "\(mechanics) \(roastBodies[sign] ?? "You will notice it at 11pm and do nothing.")"
        }
    }

    private static func mechanicsLine(for sign: WesternSign) -> String {
        switch sign {
        case .pisces:
            "Mercury clears its retrograde shadow this morning, and the Moon crosses from your seventh house into your eighth at 15:42."
        case .aries, .leo, .sagittarius:
            "Mars is applying to your Ascendant while the Moon moves through your fifth house from mid-afternoon."
        case .taurus, .virgo, .capricorn:
            "Venus is direct in your second house and the Moon trines Saturn at 11:20."
        case .gemini, .libra, .aquarius:
            "Mercury is out of shadow and the Moon enters your third house shortly after noon."
        case .cancer, .scorpio:
            "The Moon crosses your fourth house cusp at 15:42, opposed by Saturn within a degree and a half."
        }
    }

    private static let normalHeadlines: [WesternSign: String] = [
        .aries: "The window is this afternoon, not this morning.",
        .taurus: "What felt stuck starts moving after eleven.",
        .gemini: "Say it out loud rather than writing it again.",
        .cancer: "The house you keep for other people wants you in it.",
        .leo: "Visibility peaks mid-afternoon. Use it once.",
        .virgo: "The correction you have been holding back lands well today.",
        .libra: "The decision has already been made. Announce it.",
        .scorpio: "What felt withheld becomes sayable at quarter to four.",
        .sagittarius: "One more step on the existing thing outruns the new one.",
        .capricorn: "Ask before eleven. The answer is easier then.",
        .aquarius: "Come inside the conversation you have been narrating.",
        .pisces: "Say the thing you have been drafting all week.",
    ]

    private static let roastHeadlines: [WesternSign: String] = [
        .aries: "You will act at 9am and regret it by 10. Wait.",
        .taurus: "It unsticks at eleven. You will still be deciding at four.",
        .gemini: "Another draft. That is six. Send one.",
        .cancer: "You made the house comfortable and then stood in the hall.",
        .leo: "Peak visibility, and you will use it to check who looked.",
        .virgo: "The note is fine. It has been fine since Tuesday.",
        .libra: "You decided days ago. Everyone is waiting for the announcement.",
        .scorpio: "Quarter to four, and you will still be building the case.",
        .sagittarius: "The new idea is a getaway car. Finish the old one.",
        .capricorn: "Ask before eleven, or carry it alone again. Your call, obviously.",
        .aquarius: "Excellent commentary. Terrible attendance.",
        .pisces: "You know exactly which conversation you are avoiding.",
    ]

    private static let normalBodies: [WesternSign: String] = [
        .aries: "Acting on the earlier impulse would have been reaction; acting on it after the ingress is a decision. Same move, different footing.",
        .taurus: "The resistance was real and it lifts on its own schedule, not yours. What you do at eleven counts for more than anything you push before it.",
        .gemini: "Written, this reads as a position to defend. Spoken, it reads as a question, which is what it actually is.",
        .cancer: "Everything you have arranged for other people is working. The part you have not arranged is your own place in it.",
        .leo: "Warmth extended now travels further than usual, and it does not need to be performed to work.",
        .virgo: "The standard you are applying is correct. Saying it once, plainly, does more than the third revision would.",
        .libra: "Suspending it further does not gather information; the two options have stopped changing. Naming the choice ends more tension than it creates.",
        .scorpio: "A direct conversation lands better than a written one today, and there is no rush past the evening — the window stays open.",
        .sagittarius: "The existing project is one step from a state where it can survive being set down. The new one is not.",
        .capricorn: "The help is available and the refusal you are bracing for has not been offered. Asking early costs less than asking tired.",
        .aquarius: "The perspective is genuinely useful, and it is worth more said inside the room than observed from the edge of it.",
        .pisces: "What felt withheld becomes sayable. A direct conversation will carry better than a written one, and there is no rush before this evening.",
    ]

    private static let roastBodies: [WesternSign: String] = [
        .aries: "You will do it at nine, out of impatience, and then spend the afternoon managing the consequences of being four hours early.",
        .taurus: "It genuinely does get easier after eleven. You will notice this at six, while explaining why you did not start.",
        .gemini: "You have written it six ways. All six are fine. The problem was never the wording.",
        .cancer: "You made it lovely for everyone and then stood in the doorway waiting to be invited into your own evening.",
        .leo: "You will get the attention and immediately audit who was not paying it.",
        .virgo: "The note has been ready since Tuesday. You are now improving things nobody will see.",
        .libra: "You made the decision on Sunday. The performance of weighing it is for an audience that left.",
        .scorpio: "The window opens at quarter to four and you will spend it gathering one more piece of evidence for a trial nobody knows about.",
        .sagittarius: "The new idea is not inspiration, it is an exit. You have used this exit before.",
        .capricorn: "Ask before eleven or do not ask at all and be quietly furious about it, which is the option you are actually planning.",
        .aquarius: "You have analysed the conversation so well you have not had it. Come inside.",
        .pisces: "Finish it before you accidentally start three new ones and call the resulting mess a busy week.",
    ]
}
