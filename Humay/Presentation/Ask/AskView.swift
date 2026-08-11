import SwiftUI

/// Ask the Stars.
///
/// A focused conversation about one chart, not a general-purpose assistant. Suggested
/// questions open the door; the composer stays available; and every answer states what
/// it was read from, so the reasoning is visible rather than asserted.
struct AskView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var conversation = AskConversation()
    @State private var suggestions: [AskSuggestion] = []
    @State private var draft = ""
    @State private var isAnswering = false
    @FocusState private var composerFocused: Bool

    var body: some View {
        ScreenScaffold(title: "Ask") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                if conversation.isEmpty {
                    opening
                } else {
                    transcript
                }

                if isAnswering {
                    LoadingState(message: "Reading your placements…")
                }

                composer
            }
        }
        .task { await loadSuggestions() }
    }

    @ViewBuilder
    private var opening: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            Text("Ask about your chart.")
                .humayFont(.displayL)
                .foregroundStyle(theme.colors.textPrimary)
            Text("Answers are read against your placements and what the sky is doing today, and each one shows what it drew on.")
                .humayFont(.bodySmall)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }

        if !suggestions.isEmpty {
            VStack(spacing: 0) {
                SectionHeader(title: "Somewhere to start")
                ForEach(suggestions) { suggestion in
                    SuggestedQuestionRow(suggestion: suggestion) {
                        Task { await ask(suggestion.question) }
                    }
                    HairlineRule()
                }
            }
        }
    }

    @ViewBuilder
    private var transcript: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            ForEach(conversation.messages) { message in
                AskMessageView(message: message)
            }
        }
    }

    @ViewBuilder
    private var composer: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            HairlineRule()
            HStack(alignment: .bottom, spacing: HumaySpacing.s) {
                TextField(
                    conversation.isEmpty ? "Ask a question" : "Ask a follow-up",
                    text: $draft,
                    axis: .vertical
                )
                .humayFont(.body)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .focused($composerFocused)
                .submitLabel(.send)
                .onSubmit { Task { await ask(draft) } }

                Button {
                    Task { await ask(draft) }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(canSend ? theme.colors.actionLabel : theme.colors.textDisabled)
                        .frame(width: 34, height: 34)
                        .background(canSend ? theme.colors.actionFill : theme.colors.hairline)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
                .accessibilityLabel("Send question")
            }
            .frame(minHeight: HumayHitTarget.minimum)

            if !conversation.isEmpty {
                Button("Start over") {
                    conversation = AskConversation()
                    draft = ""
                }
                .buttonStyle(.humayQuiet)
            }
        }
        .padding(.top, HumaySpacing.s)
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isAnswering
    }

    private func loadSuggestions() async {
        guard let profile = environment.profile else { return }
        suggestions = (try? await environment.assistantService.suggestedQuestions(
            for: profile,
            date: Calendar.current.dateComponents([.year, .month, .day], from: .now)
        )) ?? []
    }

    private func ask(_ question: String) async {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let profile = environment.profile, !isAnswering else { return }

        composerFocused = false
        draft = ""
        conversation.messages.append(
            AskMessage(role: .person, text: trimmed, provenance: .mockFixture(fixtureID: "ask.question"))
        )
        isAnswering = true
        defer { isAnswering = false }

        do {
            let answer = try await environment.assistantService.answer(
                question: trimmed,
                in: conversation,
                profile: profile,
                tone: environment.settings.tone
            )
            conversation.messages.append(answer)
            try? environment.askRepository.save(conversation)
        } catch {
            HumayLog.contentFailure("Ask failed: \(error)")
            conversation.messages.append(
                AskMessage(
                    role: .humay,
                    text: "That could not be answered just now. Try again in a moment.",
                    provenance: .mockFixture(fixtureID: "ask.failure")
                )
            )
        }
    }
}

struct SuggestedQuestionRow: View {
    let suggestion: AskSuggestion
    let action: () -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.question)
                    .humayFont(.titleS)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if let prompt = suggestion.prompt {
                    MonoKicker(text: prompt)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: HumayHitTarget.minimum)
            .padding(.vertical, HumaySpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// One turn.
///
/// A question is set apart by a rule and a mono kicker rather than by a chat bubble —
/// bubbles would make this look like a messaging app, which is the wrong promise.
struct AskMessageView: View {
    let message: AskMessage

    @Environment(\.humayTheme) private var theme

    var body: some View {
        switch message.role {
        case .person:
            VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                MonoKicker(text: "You asked")
                Text(message.text)
                    .humayFont(.titleM)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("You asked: \(message.text)")

        case .humay:
            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                ReadingBody(text: message.text, role: .bodySmall)
                BasisDisclosure(
                    basis: ReadingBasis(
                        summary: message.basisLine ?? "",
                        factors: message.basisFactors
                    ),
                    provenance: message.provenance
                )
            }
        }
    }
}

#Preview {
    NavigationStack { AskView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
