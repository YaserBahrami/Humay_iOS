// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Illustrative sample content. Not model output. Not a test oracle.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

enum AskFixtures {
    struct Answer {
        let id: String
        let text: String
        let factors: [BasisFactor]
    }

    static func suggestions(for sign: WesternSign) -> [AskSuggestion] {
        [
            AskSuggestion(
                id: "sensitive",
                question: "Why have I been feeling more emotionally sensitive lately?",
                prompt: "The Moon has been crossing the private half of your chart"
            ),
            AskSuggestion(
                id: "conversation",
                question: "Should I bring this up today, or wait?",
                prompt: "Mercury cleared its shadow this morning"
            ),
            AskSuggestion(
                id: "stuck",
                question: "Why does this decision feel stuck?",
                prompt: nil
            ),
            AskSuggestion(
                id: "timing",
                question: "Is this a good week to start something new?",
                prompt: "Mars slows before its station on the 28th"
            ),
            AskSuggestion(
                id: "pattern",
                question: "Is there a pattern in how I handle conflict?",
                prompt: nil
            ),
        ]
    }

    /// Chooses an answer by keyword.
    ///
    /// Deliberately crude. A real implementation reads the chart and the conversation;
    /// this matches on words so that a demo conversation stays coherent.
    static func answer(
        for question: String,
        sign: WesternSign,
        tone: Tone,
        isFollowUp: Bool
    ) -> Answer {
        let lowered = question.lowercased()

        let base: Answer
        switch true {
        case lowered.contains("sensitive"), lowered.contains("emotional"), lowered.contains("feeling"):
            base = sensitive(tone: tone)
        case lowered.contains("bring this up"), lowered.contains("today"), lowered.contains("wait"), lowered.contains("say"):
            base = timing(tone: tone)
        case lowered.contains("stuck"), lowered.contains("decision"), lowered.contains("decide"):
            base = stuck(tone: tone)
        case lowered.contains("start"), lowered.contains("new"), lowered.contains("week"):
            base = starting(tone: tone)
        case lowered.contains("conflict"), lowered.contains("argu"), lowered.contains("fight"):
            base = conflict(tone: tone)
        default:
            base = general(sign: sign, tone: tone)
        }

        guard isFollowUp else { return base }
        return Answer(
            id: base.id + ".followUp",
            text: "\(base.text)\n\nTo pick up where we left off: the same placement is doing the work here, so this is less a separate question than the next part of the one you already asked.",
            factors: base.factors
        )
    }

    private static func sensitive(tone: Tone) -> Answer {
        Answer(
            id: "sensitive",
            text: tone == .normal
                ? "The Moon has spent most of the last week in the private half of your chart, and it crossed into your eighth house this afternoon — the part that deals with trust, exposure and what is not evenly shared. That tends to register as thinner skin rather than as a specific worry, which is why it is hard to point at a cause.\n\nIt is worth separating two things: whether you are more sensitive, or whether you are noticing something that was already there. The second is more likely this week. Mercury cleared its retrograde shadow this morning, so material you have been carrying without examining has become easier to look at directly."
                : "The Moon has been in the private half of your chart all week and crossed into your eighth house this afternoon, which is the part that deals with everything you have not been discussing.\n\nSo: not new sensitivity. You are just standing closer to something you have been carefully not standing near. Mercury cleared its shadow this morning, which means the excuse for postponing has technically expired.",
            factors: [
                BasisFactor(id: "ask-1", system: .western, label: "Moon H7 → H8", detail: "15:42"),
                BasisFactor(id: "ask-2", system: .western, label: "Mercury shadow out", detail: "06:12"),
            ]
        )
    }

    private static func timing(tone: Tone) -> Answer {
        Answer(
            id: "timing",
            text: tone == .normal
                ? "Yes — though this evening rather than this morning.\n\nMercury is clear of its retrograde shadow, which favours a conversation that has been postponed rather than one being started cold. The Moon crosses into your eighth house at 15:42, and that half of the day favours a direct conversation over a written one. Before then, the same words will land as a position rather than as an opening.\n\nThere is no urgency past today. The window stays reasonable through Friday."
                : "Yes, this evening. Not this morning, when you will over-prepare it.\n\nMercury is out of shadow and the Moon crosses into your eighth house at 15:42, which favours saying it out loud rather than sending the fourth draft. You have written the fourth draft. Do not send the fourth draft.\n\nAnd it holds through Friday, so the thing you are about to tell yourself about needing more time is available but not true.",
            factors: [
                BasisFactor(id: "ask-3", system: .western, label: "Mercury direct", detail: "shadow out 06:12"),
                BasisFactor(id: "ask-4", system: .western, label: "Moon → H8", detail: "15:42"),
            ]
        )
    }

    private static func stuck(tone: Tone) -> Answer {
        Answer(
            id: "stuck",
            text: tone == .normal
                ? "Mars and Saturn sit within a few arcminutes of each other in your chart, which means wanting something and holding back from it are not two separate movements for you — they arrive together. A decision that involves genuinely wanting one option will therefore feel like resistance rather than like clarity, and you can mistake that for the decision being wrong.\n\nMars is also slowing before its station this month, so the sense of pushing against something is real and temporary. The decision is probably already made; what is missing is permission rather than information."
                : "Mars and Saturn are fused in your chart, so wanting a thing and refusing it arrive as one move. This is why your decisions feel like arguments with yourself — they are.\n\nMars is slowing before its station, so everything is heavier this fortnight. But let us be accurate: you decided. You are now shopping for permission, which is a different activity and considerably slower.",
            factors: [
                BasisFactor(id: "ask-5", system: .western, label: "Mars ☌ Saturn", detail: "orb 0° 08′"),
                BasisFactor(id: "ask-6", system: .western, label: "Mars pre-station", detail: "28 Aug"),
            ]
        )
    }

    private static func starting(tone: Tone) -> Answer {
        Answer(
            id: "starting",
            text: tone == .normal
                ? "For continuing something, yes. For starting something, this is a poor fortnight.\n\nMars is slowing toward its station on the 28th, which means effort covers less ground than usual — not obstruction, but a worse exchange rate on the same push. Things begun now tend to need restarting.\n\nWhat this period does support is anything already underway that stalled during the retrograde. Mercury cleared its shadow this morning; that material is available again."
                : "To continue something, yes. To start something, no — and you know which one you were asking about.\n\nMars is slowing before its station on the 28th, so new things started now will need starting again, which you have done before and did not enjoy.\n\nThe thing you abandoned three weeks ago is, however, newly available. Mercury cleared its shadow this morning. That is the one.",
            factors: [
                BasisFactor(id: "ask-7", system: .western, label: "Mars station", detail: "28 Aug"),
                BasisFactor(id: "ask-8", system: .western, label: "Mercury shadow out", detail: "06:12"),
            ]
        )
    }

    private static func conflict(tone: Tone) -> Answer {
        Answer(
            id: "conflict",
            text: tone == .normal
                ? "There is a pattern, and it is structural rather than a habit you picked up. Mars is closely conjunct Saturn in your chart, so the impulse to push and the impulse to contain arrive at the same instant. In practice that means conflict tends to be delayed and then arrive fully formed — you do not escalate gradually, because the gradual part happened privately.\n\nThe useful adjustment is not to be calmer. It is to say the small version earlier, while it is still small enough to be uninteresting."
                : "Yes, and it is very consistent. Mars is conjunct Saturn in your chart, so you hold it, hold it, hold it, and then deliver a fully-researched position to someone who thought everything was fine.\n\nThe escalation looks sudden from outside because you did the escalating alone, over several weeks, in your head. Say the boring version earlier.",
            factors: [
                BasisFactor(id: "ask-9", system: .western, label: "Mars ☌ Saturn", detail: "orb 0° 08′"),
                BasisFactor(id: "ask-10", system: .western, label: "Moon ☍ Mars", detail: "orb 3° 02′"),
            ]
        )
    }

    private static func general(sign: WesternSign, tone: Tone) -> Answer {
        Answer(
            id: "general",
            text: tone == .normal
                ? "Reading this against your chart and today's sky: the Moon crossed into your eighth house this afternoon and Mercury cleared its retrograde shadow this morning. Together those favour looking directly at something that has been sitting unexamined, and they favour saying it aloud rather than writing it.\n\nWhat that means for your particular question depends on which part of it you actually want an answer to. Ask the narrower version and there is more to say."
                : "Against your chart and today's sky: the Moon is in your eighth house and Mercury is out of shadow. Both point at looking straight at the thing rather than around it.\n\nThat said, the question was broad enough to be about almost anything, which is often the first move of not asking the real one. Try the narrower version.",
            factors: [
                BasisFactor(id: "ask-11", system: .western, label: "Moon → H8", detail: "15:42"),
                BasisFactor(id: "ask-12", system: .western, label: "Mercury shadow out", detail: "06:12"),
            ]
        )
    }
}
