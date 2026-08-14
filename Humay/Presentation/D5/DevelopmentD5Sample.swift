#if DEBUG
import Foundation

enum DevelopmentD5Sample {
    static let primaryQuestion = AskQuestion(
        questionText: "How can I work with my Moon in Libra?",
        locale: "en-US",
        tone: .normal,
        selectedTradition: "Western",
        selectedSystem: "Tropical",
        contextScope: .relevantChartContext
    )

    static let context = AskContext(
        selectedTradition: "Western",
        selectedSystem: "Tropical",
        availability: .available,
        detail: AskProductCopy.contextDetail
    )

    static let primaryAnswer = AskAnswer(
        question: primaryQuestion,
        disclosure: "Development sample · not generated",
        headline: "A gentler kind of balance",
        sections: [
            AskAnswerSection(
                title: "Balance before reaction",
                body: "Your Moon in Libra can meet strong feelings by looking for balance before moving to an answer. Give yourself a little space to name what feels uneven, then choose the response that keeps you connected to yourself as well as to others."
            ),
            AskAnswerSection(
                title: "Make room for beauty and play",
                body: "The 5th house gives this reflection a playful, creative doorway. A beautiful room, a small creative ritual, or an unhurried pleasure can help your emotional world feel less like a problem to solve."
            )
        ],
        tryThis: [
            "Before responding, ask: what would make this feel more balanced and more alive?"
        ],
        basis: [
            AskBasisFact(kind: .methodology, label: "Tradition", value: "Western"),
            AskBasisFact(kind: .system, label: "System", value: "Tropical"),
            AskBasisFact(kind: .placement, label: "Placement", value: "Moon in Libra"),
            AskBasisFact(kind: .degree, label: "Degree", value: "14° 27′"),
            AskBasisFact(kind: .house, label: "House", value: "5th house")
        ]
    )

    static func makeInput(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> D5FeatureInput {
        let state = argumentValue(named: "-HumayD5AskState", arguments: arguments)?.lowercased()

        switch state {
        case "access":
            return sample(.accessRequired(question: primaryQuestion, access: .rewardedRequired))
        case "generating":
            return sample(.generating(question: primaryQuestion))
        case "loaded":
            return sample(.loaded(primaryAnswer))
        case "cached":
            return sample(.cached(primaryAnswer, savedAt: savedAt))
        case "offline-cached":
            return sample(.offlineCached(primaryAnswer, savedAt: savedAt))
        case "offline-empty":
            return sample(.offlineNoCache(question: primaryQuestion))
        case "insufficient":
            return sample(.insufficientContext(AskContextIssue(
                title: "This question needs a little more context",
                detail: "Humay can use the chart context you share, but it will not invent a missing fact.",
                missing: [
                    "Birth time unavailable",
                    "Required chart context absent",
                    "Precision fact unavailable"
                ]
            )))
        case "unsupported":
            return sample(.unsupported(AskUnsupportedReason(
                title: "This question is not supported yet",
                detail: "Humay does not have an approved method for this kind of reading."
            )))
        case "safety":
            return sample(.safetyRefusal(AskSafetyRefusal(
                title: "Humay can’t guide high-stakes decisions with astrology",
                detail: "Astrology is not a substitute for qualified care or professional advice.",
                recommendation: "For medical, legal or financial decisions, speak with a qualified professional."
            )))
        case "failed":
            return sample(.failed(AskFailure(
                title: AskProductCopy.failedTitle,
                detail: "Your question is still here, but this reading is not available right now."
            )))
        case "empty", nil, "":
            return sample(.empty)
        default:
            return sample(.empty)
        }
    }

    static func state(for question: AskQuestion) -> AskFeatureState {
        if question.cacheIdentity == primaryQuestion.cacheIdentity {
            return .accessRequired(question: question, access: .rewardedRequired)
        }

        return .unsupported(AskUnsupportedReason(
            title: "This question is not supported yet",
            detail: "This development fixture demonstrates a supported context without claiming to evaluate a new reading."
        ))
    }

    private static let savedAt = Date(timeIntervalSince1970: 1_710_432_000)

    private static func sample(_ state: AskFeatureState) -> D5FeatureInput {
        D5FeatureInput(
            source: .developmentSample,
            submissionAvailability: .available,
            context: context,
            state: state
        )
    }

    private static func argumentValue(named name: String, arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }
}
#endif
