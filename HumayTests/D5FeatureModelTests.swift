import Foundation
import Testing
@testable import Humay

@Suite("D5 Ask feature contracts")
struct D5FeatureModelTests {
    @Test("Release composition is unavailable and payload-free")
    func productionCompositionIsSafe() {
        let input = D5FeatureInput.productionUnavailable

        #expect(input.source == .productionUnavailable)
        #expect(!input.source.isDevelopmentSample)
        #expect(input.state == .empty)
        #expect(input.state.answer == nil)
        #expect(input.state.question == nil)
        #expect(input.context.availability == .unavailable)

        let releaseSurface = [
            AskProductCopy.title,
            AskProductCopy.prompt,
            AskProductCopy.contextHeading,
            AskProductCopy.contextDetail,
            AskProductCopy.offlineNoCache,
            AskProductCopy.failedTitle
        ]
        for sentence in releaseSurface {
            #expect(!sentence.localizedCaseInsensitiveContains("development sample"))
            #expect(!sentence.localizedCaseInsensitiveContains("not generated"))
            #expect(!sentence.localizedCaseInsensitiveContains("provider"))
            #expect(!sentence.localizedCaseInsensitiveContains("model"))
            #expect(!sentence.localizedCaseInsensitiveContains("api"))
        }
    }

    @Test("Cache identity uses semantic inputs, never access")
    func cacheIdentityIsAccessIndependent() {
        let base = AskQuestion(
            questionText: "  How can I work with my Moon in Libra?  ",
            locale: "en-US",
            tone: .gentle,
            selectedTradition: "Western",
            selectedSystem: "Tropical",
            contextScope: .relevantChartContext
        )
        let equivalent = AskQuestion(
            questionText: "How   can I work with my Moon in Libra?",
            locale: "en-US",
            tone: .gentle,
            selectedTradition: "Western",
            selectedSystem: "Tropical",
            contextScope: .relevantChartContext
        )

        #expect(base.cacheIdentity == equivalent.cacheIdentity)
        #expect(base.cacheIdentity != AskQuestion(
            questionText: base.questionText,
            locale: "en-US",
            tone: .gentle,
            selectedTradition: "Western",
            selectedSystem: "Tropical",
            contextScope: .noChartContext
        ).cacheIdentity)

        let storedPropertyNames = Set(Mirror(reflecting: base.cacheIdentity).children.compactMap(\.label))
        #expect(!storedPropertyNames.contains("access"))
        #expect(!storedPropertyNames.contains("entitlement"))
        #expect(!storedPropertyNames.contains("provider"))
        #expect(!storedPropertyNames.contains("requestID"))
    }

#if DEBUG
    @Test("Primary fixture keeps facts separate from interpretation")
    func primaryFixtureIsDeterministicAndScoped() throws {
        let input = DevelopmentD5Sample.makeInput(arguments: [
            "-HumayD5AskState", "loaded"
        ])

        #expect(input.source == .developmentSample)
        #expect(input.context.summary == "Using: Western · available chart context")

        guard case .loaded(let answer) = input.state else {
            Issue.record("Expected loaded Ask development fixture")
            return
        }

        #expect(answer.question.questionText == "How can I work with my Moon in Libra?")
        #expect(answer.headline == "A gentler kind of balance")
        #expect(answer.sections.map(\.title) == [
            "Balance before reaction",
            "Make room for beauty and play"
        ])
        #expect(answer.basis.map(\.value) == [
            "Western",
            "Tropical",
            "Moon in Libra",
            "14° 27′",
            "5th house"
        ])

        let interpretation = ([answer.headline] + answer.sections.map(\.body) + answer.tryThis)
            .joined(separator: " ")
        for forbidden in ["Sun", "Mars", "Venus", "Jupiter", "Saturn", "transit", "prediction"] {
            #expect(!interpretation.localizedCaseInsensitiveContains(forbidden))
        }
    }

    @Test("Development launch argument exposes each D5 state")
    func launchStatesAreTyped() {
        let states: [(String, (AskFeatureState) -> Bool)] = [
            ("empty", { if case .empty = $0 { true } else { false } }),
            ("access", { if case .accessRequired = $0 { true } else { false } }),
            ("generating", { if case .generating = $0 { true } else { false } }),
            ("loaded", { if case .loaded = $0 { true } else { false } }),
            ("cached", { if case .cached = $0 { true } else { false } }),
            ("offline-cached", { if case .offlineCached = $0 { true } else { false } }),
            ("offline-empty", { if case .offlineNoCache = $0 { true } else { false } }),
            ("insufficient", { if case .insufficientContext = $0 { true } else { false } }),
            ("unsupported", { if case .unsupported = $0 { true } else { false } }),
            ("safety", { if case .safetyRefusal = $0 { true } else { false } }),
            ("failed", { if case .failed = $0 { true } else { false } })
        ]

        for (argument, matches) in states {
            let input = DevelopmentD5Sample.makeInput(arguments: [
                "-HumayD5AskState", argument
            ])
            #expect(matches(input.state), "Unexpected state for \(argument)")
        }
    }

    @Test("Submitted primary question reaches access without claiming evaluation")
    func primarySubmissionIsAccessOnly() {
        let state = DevelopmentD5Sample.state(for: DevelopmentD5Sample.primaryQuestion)

        guard case .accessRequired(let question, let access) = state else {
            Issue.record("Expected primary fixture to stop at access")
            return
        }

        #expect(question == DevelopmentD5Sample.primaryQuestion)
        #expect(access == .rewardedRequired)
        #expect(state.answer == nil)
    }

    @Test("Cached and offline cached states preserve one answer")
    func cacheStatesPreserveAnswer() throws {
        let answer = try #require(DevelopmentD5Sample.primaryAnswer)
        let savedAt = Date(timeIntervalSince1970: 1_710_432_000)
        let cached = AskFeatureState.cached(answer, savedAt: savedAt)
        let offline = AskFeatureState.offlineCached(answer, savedAt: savedAt)

        #expect(cached.answer == answer)
        #expect(offline.answer == answer)
        #expect(cached != offline)
    }
#endif
}
