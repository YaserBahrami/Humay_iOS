// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Illustrative sample content. Not ephemeris output. Not a test oracle.
//  See docs/development/DEVIATIONS.md (DEV-001).
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// Sample daily readings, one per sign.
///
/// The two registers are held side by side in a single fixture, sharing one basis. That
/// is not a storage convenience — it is the tone invariant made structural. Roast cannot
/// drift onto different reasoning, because there is only one set of reasoning here.
struct DailyReadingFixture: Sendable {
    struct Register: Sendable {
        let headline: String
        let overview: String
        let love: String
        let career: String
        let finance: String
        let health: String

        func text(for category: ReadingCategory) -> String {
            switch category {
            case .love: love
            case .career: career
            case .finance: finance
            case .health: health
            }
        }
    }

    let sign: WesternSign
    let normal: Register
    let roast: Register
    /// Shared across both registers, deliberately.
    let basisSummaryPrecise: String
    let basisFactors: [BasisFactor]

    func register(for tone: Tone) -> Register {
        switch tone {
        case .normal: normal
        case .roast: roast
        }
    }
}

enum DailyReadingFixtures {
    static func fixture(for sign: WesternSign) -> DailyReadingFixture {
        all.first { $0.sign == sign } ?? all[0]
    }

    static let all: [DailyReadingFixture] = [
        DailyReadingFixture(
            sign: .aries,
            normal: .init(
                headline: "Move first, explain second.",
                overview: "The impulse you keep talking yourself out of is the one worth acting on today. Not because it is safe, but because deliberating further will not make it clearer — it will only make it later.",
                love: "Say the direct version. The tactful one has been misread twice already.",
                career: "You will get further starting badly than planning well. Begin the thing.",
                finance: "A decision made quickly today is not the same as a decision made carelessly. Check which one this is.",
                health: "Energy is high and patience is not. Spend the first on something physical before the second runs out."
            ),
            roast: .init(
                headline: "You already decided. Stop pretending this is deliberation.",
                overview: "You have been \"thinking it over\" for six days, which is a generous word for rehearsing the same conclusion in different chairs. Do it or admit you are not going to.",
                love: "Being direct is not a personality flaw you need to warn people about first.",
                career: "The plan is a procrastination method wearing a spreadsheet. You know this.",
                finance: "Fast is fine. Fast because you are bored is how last month happened.",
                health: "You are not tired. You have been sitting still while furious, which is worse."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "aries-1", system: .western, label: "Mars → H1", detail: "applying"),
                BasisFactor(id: "aries-2", system: .western, label: "Moon ♈︎ 15°04′", detail: "waxing"),
            ]
        ),
        DailyReadingFixture(
            sign: .taurus,
            normal: .init(
                headline: "Comfort is not the same as rest.",
                overview: "Today rewards the slower option, but only if slow means considered. There is a version of patience that is really just delay, and you will be able to tell them apart by whether you feel calmer or heavier.",
                love: "Someone is waiting for you to name what you want rather than demonstrate it.",
                career: "Steady work lands better than a burst. Nothing needs to be finished today.",
                finance: "A small ongoing cost is worth an honest look. It has stopped being small.",
                health: "The body is asking for movement, not indulgence. They can feel identical at 4pm."
            ),
            roast: .init(
                headline: "Being immovable is not the same as being right.",
                overview: "You have decided this is patience. It has been three weeks. At some point patience becomes a very well-upholstered refusal to deal with it.",
                love: "Nobody can read the meaningful silence. It just looks like silence.",
                career: "Slow and steady, yes. This is neither steady nor going anywhere.",
                finance: "The subscription you forgot about remembers you monthly.",
                health: "Comfort food is food. It is not, structurally, a comfort strategy."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "taurus-1", system: .western, label: "Venus → H2", detail: "direct"),
                BasisFactor(id: "taurus-2", system: .western, label: "Moon trine Saturn", detail: "orb 1° 12′"),
            ]
        ),
        DailyReadingFixture(
            sign: .gemini,
            normal: .init(
                headline: "Say the shorter version.",
                overview: "You have the words for this, which is exactly the risk. The point will land better with less around it, and the parts you cut were mostly there to soften an impact that would have been fine.",
                love: "One clear sentence today outperforms a week of thoughtful context.",
                career: "You have gathered enough. More input is now a way of not deciding.",
                finance: "Two small commitments are pulling in opposite directions. Pick one.",
                health: "Sleep is the variable. Everything else you are blaming is downstream of it."
            ),
            roast: .init(
                headline: "Fewer words. You are not being charged by the sentence.",
                overview: "You have explained this to four people, each time slightly differently, and now you are unsure what you think. That is not curiosity. That is a focus problem with excellent vocabulary.",
                love: "They stopped following around clause three. Start again, shorter.",
                career: "Opening more tabs is not the same as doing more research.",
                finance: "You have two plans and are funding neither.",
                health: "Two hours of scrolling is not rest, it is just a horizontal version of the same day."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "gemini-1", system: .western, label: "Mercury → H3", detail: "shadow out"),
                BasisFactor(id: "gemini-2", system: .western, label: "Moon ♊︎", detail: "06:19"),
            ]
        ),
        DailyReadingFixture(
            sign: .cancer,
            normal: .init(
                headline: "You are allowed to be the one who is looked after.",
                overview: "The instinct to manage everyone else's comfort is doing real work today, and it is also a way of staying out of your own weather. Someone would help if asked plainly.",
                love: "Ask for the specific thing. Hinting has a poor success rate and a high cost.",
                career: "Your read on the room is accurate. Say it out loud rather than adjusting silently.",
                finance: "Generosity is fine when it is chosen. Check that this one was.",
                health: "Rest earlier than feels justified. The tiredness arrived hours before you noticed."
            ),
            roast: .init(
                headline: "You are not fine. You are just organised about it.",
                overview: "You have handled everyone's day beautifully and yours is a disaster site with a nice tablecloth over it. Nobody gave you this job.",
                love: "The hint was too subtle. It has now been too subtle for a month.",
                career: "You noticed the problem first and said nothing first. Both of those are choices.",
                finance: "You paid for it again. That is now a pattern, not a kindness.",
                health: "\"I'll rest when this is done\" is not a plan, it is a genre."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "cancer-1", system: .western, label: "Moon → H4", detail: "15:42"),
                BasisFactor(id: "cancer-2", system: .western, label: "Venus sextile Moon", detail: "orb 2° 04′"),
            ]
        ),
        DailyReadingFixture(
            sign: .leo,
            normal: .init(
                headline: "The generous version costs you nothing.",
                overview: "You are more visible today than you think, which cuts both ways. Warmth extended first tends to come back; warmth withheld until it is earned tends to sit there.",
                love: "Go first. Waiting to be chosen is not the same as being wanted.",
                career: "Credit given away today returns with interest. Give it specifically, by name.",
                finance: "The expensive gesture is not the meaningful one. It rarely was.",
                health: "Something that makes you feel capable rather than depleted. You know which is which."
            ),
            roast: .init(
                headline: "Nobody is withholding applause. They are just busy.",
                overview: "You have interpreted a quiet week as a verdict. It was a quiet week. Not everything is about you, which is genuinely good news if you sit with it.",
                love: "Waiting to be pursued is a strategy with a terrible conversion rate.",
                career: "You want the credit and the appearance of not wanting it. Pick.",
                finance: "The grand gesture was for you. It is fine. Just do not call it generosity.",
                health: "Rest is not a concession. Nobody is scoring this."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "leo-1", system: .western, label: "Sun → H5", detail: "23° 26′"),
                BasisFactor(id: "leo-2", system: .western, label: "Moon opposite Sun", detail: "orb 3° 40′"),
            ]
        ),
        DailyReadingFixture(
            sign: .virgo,
            normal: .init(
                headline: "Good enough, sent today, beats perfect next week.",
                overview: "The remaining improvements are real but small, and the cost of holding this back has quietly overtaken them. Notice where refinement turned into avoidance.",
                love: "Fixing was not what was wanted. Being present was, and still is.",
                career: "Ship it. The last ten percent can be a second version.",
                finance: "Your figures are right. The decision they point to is the part you are avoiding.",
                health: "The standard you are holding yourself to is not one you would set for anyone else."
            ),
            roast: .init(
                headline: "It has been finished for two weeks. You are just fiddling.",
                overview: "The list has a list. At some point the preparation became the project, and the actual project is sitting there being fine and unsent.",
                love: "They did not ask for notes. They asked how you were.",
                career: "Reorganising the folder structure is not work. It is work-shaped.",
                finance: "The spreadsheet is beautiful and you still have not moved the money.",
                health: "You have optimised your routine into something you now dread. Well done."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "virgo-1", system: .western, label: "Mercury → H6", detail: "direct"),
                BasisFactor(id: "virgo-2", system: .western, label: "Moon ♍︎ → ♎︎", detail: "15:42"),
            ]
        ),
        DailyReadingFixture(
            sign: .libra,
            normal: .init(
                headline: "Balance is a decision, not an average.",
                overview: "Holding both sides has been genuinely useful and has now become its own kind of stalling. Choosing does not betray the option you set down; it just ends the suspension.",
                love: "The unsaid preference is doing more damage than stating it would.",
                career: "Consensus is not available today. A clear call is.",
                finance: "Comparing further will not surface new information. It is the same two options.",
                health: "Tension is sitting in the jaw and shoulders. It is a decision, not a posture."
            ),
            roast: .init(
                headline: "Weighing it up is not the same as thinking about it.",
                overview: "You have been fair to every option for so long that the deadline is going to choose for you, and then you will be annoyed at the deadline.",
                love: "\"Whatever you want\" has never once been true and everyone knows.",
                career: "You want everyone to agree so that nobody can blame you. Bold.",
                finance: "Eleven tabs of comparison. Same conclusion as tab one.",
                health: "You are not relaxed. You are pleasant, which is a completely different muscle."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "libra-1", system: .western, label: "Venus → H7", detail: "23° 44′"),
                BasisFactor(id: "libra-2", system: .western, label: "Moon square Mars", detail: "orb 0° 51′"),
            ]
        ),
        DailyReadingFixture(
            sign: .scorpio,
            normal: .init(
                headline: "Ask rather than deduce.",
                overview: "Your read is probably right, and it is still a read. A direct question today costs less than another week of building a case that nobody knows they are on trial for.",
                love: "The thing you are protecting yourself from has not happened. Ask.",
                career: "Say what you actually want from this. The indirect route is slower here.",
                finance: "A commitment you made privately deserves to be said out loud.",
                health: "Intensity without an outlet becomes sleeplessness. Give it somewhere to go."
            ),
            roast: .init(
                headline: "You built a whole case. They do not know there is a trial.",
                overview: "Three weeks of evidence-gathering about a person who would have answered the question in eleven seconds. Detective work is not a substitute for a conversation.",
                love: "Testing whether they will notice is not the same as telling them.",
                career: "You have a plan nobody has been told about. It is not going well for them.",
                finance: "Secrecy about money is only strategy if there is a strategy.",
                health: "Lying awake rehearsing a confrontation counts as neither rest nor confrontation."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "scorpio-1", system: .western, label: "Moon → H8", detail: "15:42"),
                BasisFactor(id: "scorpio-2", system: .western, label: "Pluto ♑︎", detail: "retrograde"),
            ]
        ),
        DailyReadingFixture(
            sign: .sagittarius,
            normal: .init(
                headline: "Finish one before opening the next.",
                overview: "The new idea is genuinely good, which is what makes it dangerous today. It will still be good in a week, and the thing already underway will not survive being set down again.",
                love: "Staying is a choice you can make out loud rather than by default.",
                career: "Depth beats range this week. Pick the one and go further into it.",
                finance: "The plan needs a boring next step, not a better plan.",
                health: "Movement outdoors resets more than another late night reading about it would."
            ),
            roast: .init(
                headline: "Another brilliant idea. That is four unfinished ones.",
                overview: "You are not exploring, you are fleeing, and the destinations keep getting more interesting because the thing behind you keeps getting more overdue.",
                love: "Keeping your options open is a phrase people use right before they are alone.",
                career: "You are excellent at starting. It has become a whole identity.",
                finance: "The trip you cannot afford is not a plan, it is an escape route.",
                health: "You cannot outrun a sleep debt. You have tried. Repeatedly."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "sag-1", system: .western, label: "Jupiter → H9", detail: "direct"),
                BasisFactor(id: "sag-2", system: .western, label: "Moon ♐︎", detail: "waxing"),
            ]
        ),
        DailyReadingFixture(
            sign: .capricorn,
            normal: .init(
                headline: "Doing it alone is a choice, not a requirement.",
                overview: "You have carried more of this than anyone realises, largely because you have not said so. Delegating today is not a loss of standard; it is the only way the standard survives the month.",
                love: "Competence is not intimacy. Let someone see the unfinished version.",
                career: "Ask for the resource. The refusal you are pre-empting has not happened.",
                finance: "Long-term thinking is your strength. It is also how you keep deferring the present.",
                health: "The pace is not sustainable and you have known that for a while."
            ),
            roast: .init(
                headline: "Nobody gave you this much to carry. You volunteered.",
                overview: "You are exhausted, competent and quietly furious that nobody noticed. They did not notice because you built the whole thing so that they would not have to.",
                love: "Being reliable is lovely. It is not, on its own, a relationship.",
                career: "You did not ask for help so you could be annoyed nobody offered. Efficient.",
                finance: "Saving for a future in which you also do not rest. Interesting.",
                health: "Burnout is not a productivity method with a bad name."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "cap-1", system: .western, label: "Saturn → H10", detail: "applying"),
                BasisFactor(id: "cap-2", system: .western, label: "Moon trine Saturn", detail: "orb 1° 33′"),
            ]
        ),
        DailyReadingFixture(
            sign: .aquarius,
            normal: .init(
                headline: "The distance is not protecting you from anything.",
                overview: "Standing slightly outside it has been useful, and today it mostly costs. The perspective you have is worth more inside the conversation than observed from the edge of it.",
                love: "Being known is not the same as being figured out. Let it happen.",
                career: "Your unusual read is the valuable one. State it without the disclaimers.",
                finance: "A principled refusal is fine. Check it is a principle and not a habit.",
                health: "The mind has been running well ahead of the body. Let them meet."
            ),
            roast: .init(
                headline: "Detached is not a personality, it is a distance.",
                overview: "You have analysed the feeling so thoroughly that you have not had it. That is not perspective, that is a very sophisticated method of not being in the room.",
                love: "Nobody can get close to a running commentary.",
                career: "Being the only one who sees it is not the achievement. Saying it is.",
                finance: "You refused on principle and it cost you money. Which principle, exactly?",
                health: "You cannot think your way out of being tired. You have tested this."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "aqu-1", system: .western, label: "Uranus → H11", detail: "direct"),
                BasisFactor(id: "aqu-2", system: .western, label: "Full Moon ♒︎ 27° 42′", detail: "20 Aug"),
            ]
        ),
        DailyReadingFixture(
            sign: .pisces,
            normal: .init(
                headline: "Finish what you started, don't start what you'll abandon.",
                overview: "There is one thing already underway that would change the shape of the week if it were closed today. The other three are ideas, and ideas cost nothing to leave where they are.",
                love: "The conversation you keep almost having is smaller than the avoiding of it.",
                career: "Focus holds best on tasks you have already committed to, not new ones.",
                finance: "A vague number is causing more worry than the real one would. Look at it.",
                health: "Sensitivity is high. Less input, earlier, does more than any correction later."
            ),
            roast: .init(
                headline: "You know exactly which conversation you're avoiding.",
                overview: "Finish it before you \"accidentally\" start three new ones and call the resulting mess a busy period. The avoidance is now larger than the thing.",
                love: "Drafting it for the ninth time is not preparing. It is hiding with a keyboard.",
                career: "You did not run out of time, you ran out of the specific hour you needed.",
                finance: "Not looking at the balance does not change the balance.",
                health: "You absorbed everyone's mood today and are calling it exhaustion. Close enough."
            ),
            basisSummaryPrecise: "From your calculated placements and today's transits",
            basisFactors: [
                BasisFactor(id: "pisces-1", system: .western, label: "Mercury shadow out", detail: "06:12"),
                BasisFactor(id: "pisces-2", system: .western, label: "Moon H7 → H8", detail: "15:42"),
                BasisFactor(id: "pisces-3", system: .western, label: "Sun ♓︎ 23° 26′", detail: "H5"),
            ]
        ),
    ]
}
