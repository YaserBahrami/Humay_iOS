import SwiftUI

struct AskView: View {
    let input: D5FeatureInput
    let profileName: String
    let openProfile: () -> Void

    var body: some View {
        AskFeatureHost(
            input: input,
            profileName: profileName,
            openProfile: openProfile
        )
    }
}

private struct AskFeatureHost: View {
    let input: D5FeatureInput
    let profileName: String
    let openProfile: () -> Void

    @State private var state: AskFeatureState
    @State private var draft = ""
    @State private var showingFreshComposer = false

    init(
        input: D5FeatureInput,
        profileName: String,
        openProfile: @escaping () -> Void,
        initialState: AskFeatureState? = nil
    ) {
        self.input = input
        self.profileName = profileName
        self.openProfile = openProfile

        let safeState = input.source.isDevelopmentSample
            ? (initialState ?? input.state)
            : .empty
        _state = State(initialValue: safeState)
    }

    var body: some View {
        Group {
            switch state {
            case .empty:
                AskEntryView(
                    draft: $draft,
                    context: input.context,
                    onSubmit: submit
                )

            case .accessRequired(let question, let access):
                AskAccessView(
                    question: question,
                    access: access,
                    context: input.context,
                    onEdit: { edit(question: question) }
                )

            case .generating(let question):
                AskGeneratingView(question: question, context: input.context)

            case .loaded(let answer):
                AskAnswerView(
                    answer: answer,
                    status: .live,
                    onAskAnother: showFreshComposer
                )

            case .cached(let answer, let savedAt):
                AskAnswerView(
                    answer: answer,
                    status: .saved(date: savedAt),
                    onAskAnother: showFreshComposer
                )

            case .offlineCached(let answer, let savedAt):
                AskAnswerView(
                    answer: answer,
                    status: .offlineSaved(date: savedAt),
                    onAskAnother: showFreshComposer
                )

            case .offlineNoCache(let question):
                AskStatusView(
                    state: .offlineNoCache,
                    question: question,
                    context: input.context,
                    onEdit: question.map { question in
                        { edit(question: question) }
                    }
                )

            case .insufficientContext(let issue):
                AskStatusView(
                    state: .insufficientContext(issue),
                    question: nil,
                    context: input.context,
                    onEdit: nil
                )

            case .unsupported(let reason):
                AskStatusView(
                    state: .unsupported(reason),
                    question: nil,
                    context: input.context,
                    onEdit: nil
                )

            case .safetyRefusal(let refusal):
                AskStatusView(
                    state: .safetyRefusal(refusal),
                    question: nil,
                    context: input.context,
                    onEdit: nil
                )

            case .failed(let failure):
                AskStatusView(
                    state: .failed(failure),
                    question: nil,
                    context: input.context,
                    onEdit: nil
                )
            }
        }
        .background(Color.humayGround)
        .navigationTitle(AskProductCopy.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AskProfileToolbarButton(
                    profileName: profileName,
                    action: openProfile
                )
            }
        }
        .navigationDestination(isPresented: $showingFreshComposer) {
            AskFeatureHost(
                input: input,
                profileName: profileName,
                openProfile: openProfile,
                initialState: .empty
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(screenIdentifier)
    }

    private var screenIdentifier: String {
        switch state {
        case .empty: "ask.entry.screen"
        case .accessRequired: "ask.access.screen"
        case .generating: "ask.generating.screen"
        case .loaded, .cached, .offlineCached: "ask.answer.screen"
        case .offlineNoCache: "ask.state.offline.no-cache"
        case .insufficientContext: "ask.state.insufficient-context"
        case .unsupported: "ask.state.unsupported"
        case .safetyRefusal: "ask.state.safety-refusal"
        case .failed: "ask.state.failed"
        }
    }

    private func submit(questionText: String) {
        let trimmed = questionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let question = AskQuestion(
            questionText: trimmed,
            locale: "en-US",
            tone: .gentle,
            selectedTradition: input.context.selectedTradition,
            selectedSystem: input.context.selectedSystem,
            contextScope: input.context.availability == .available
                ? .relevantChartContext
                : .noChartContext
        )

#if DEBUG
        guard input.source.isDevelopmentSample else { return }
        state = DevelopmentD5Sample.state(for: question)
#endif
    }

    private func edit(question: AskQuestion) {
        draft = question.questionText
        state = .empty
    }

    private func showFreshComposer() {
        showingFreshComposer = true
    }
}

private struct AskProfileToolbarButton: View {
    let profileName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(initials)
                .font(HumayTypography.supportingEmphasized)
                .foregroundStyle(Color.humayTextPrimary)
                .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                .background(
                    LinearGradient(
                        colors: [
                            Color.humayCelestialBlue.opacity(0.72),
                            Color.humayLavender.opacity(0.86)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )
                .overlay(Circle().stroke(Color.humayHairline))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile and settings")
        .accessibilityHint("Opens your profile and settings")
        .accessibilityIdentifier("main.profile.button")
    }

    private var initials: String {
        let value = profileName
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
        return value.isEmpty ? "H" : value
    }
}
