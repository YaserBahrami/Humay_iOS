// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//  Answers here are selected from a fixture bank by keyword. No model is
//  involved, nothing is generated, and no chart is consulted.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// Conversational answers, from fixtures.
///
/// The signature is the point of this file. A real provider will need the whole
/// conversation, the profile and the tone, and will return one message carrying its own
/// basis — which is exactly what this returns. Replacing it should not change a single
/// call site.
struct MockAstrologyAssistantService: AstrologyAssistantService, MockContentProvider {
    static let fixtureNamespace = "ask"

    let latency: MockLatency

    init(latency: MockLatency = .realistic) {
        // Answers are the one place a visible pause reads as considered rather than
        // slow, so this leans longer than the other mocks.
        self.latency = latency
    }

    func suggestedQuestions(
        for profile: UserProfile,
        date: DateComponents
    ) async throws -> [AskSuggestion] {
        await latency.wait()
        return AskFixtures.suggestions(for: MockAstrology.sunSign(for: profile.birth))
    }

    func answer(
        question: String,
        in conversation: AskConversation,
        profile: UserProfile,
        tone: Tone
    ) async throws -> AskMessage {
        await latency.wait()

        let isFollowUp = conversation.messages.contains { $0.role == .humay }
        let fixture = AskFixtures.answer(
            for: question,
            sign: MockAstrology.sunSign(for: profile.birth),
            tone: tone,
            isFollowUp: isFollowUp
        )

        return AskMessage(
            role: .humay,
            text: fixture.text,
            basisLine: profile.birth.supportsPrecision
                ? "From your calculated chart and today's transits"
                : "From your sign and today's sky — your chart needs a birth time and place",
            basisFactors: fixture.factors,
            provenance: Self.provenance(fixture.id)
        )
    }
}
