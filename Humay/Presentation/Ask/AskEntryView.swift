import SwiftUI

struct AskEntryView: View {
    @Binding var draft: String

    let submissionAvailability: AskSubmissionAvailability
    let context: AskContext
    let onSubmit: (String) -> Void

    @FocusState private var composerFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    entryLayout(for: proxy.size.width)
                        .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                        .padding(.vertical, HumaySpacing.extraLarge)
                        .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .accessibilityIdentifier("ask.entry.screen")
                .onChange(of: composerFocused) { _, focused in
                    guard focused else { return }
                    withAnimation(.easeOut(duration: 0.2)) {
                        scrollProxy.scrollTo("ask.composer", anchor: .center)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func entryLayout(for width: CGFloat) -> some View {
        if width >= 720 {
            HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    AskIntroView(includeArt: false)
                    AskContextCard(context: context)
                    AskSuggestionsView(draft: $draft)
                }
                .frame(maxWidth: 340, alignment: .leading)

                VStack(spacing: HumaySpacing.extraLarge) {
                    AskIllustrationView(size: CGSize(width: 250, height: 170))
                    AskComposerCard(
                        draft: $draft,
                        composerFocused: $composerFocused,
                        submissionAvailability: submissionAvailability,
                        onSubmit: onSubmit
                    )
                }
                .frame(maxWidth: HumayContentWidth.readable.rawValue)
            }
            .frame(maxWidth: HumayContentWidth.expanded.rawValue, alignment: .center)
        } else {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                AskIntroView(includeArt: true)
                AskComposerCard(
                    draft: $draft,
                    composerFocused: $composerFocused,
                    submissionAvailability: submissionAvailability,
                    onSubmit: onSubmit
                )
                AskSuggestionsView(draft: $draft)
                AskContextCard(context: context)
            }
            .frame(maxWidth: HumayContentWidth.form.rawValue, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct AskIntroView: View {
    let includeArt: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            Text(AskProductCopy.prompt)
                .font(HumayTypography.detailTitle)
                .foregroundStyle(Color.humayTextPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Bring one focused question. Humay will keep the reflection close to the context you shared.")
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if includeArt {
                AskIllustrationView(size: CGSize(width: 190, height: 128))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AskIllustrationView: View {
    let size: CGSize

    var body: some View {
        HumayIllustration(asset: .askStars)
            .frame(width: size.width, height: size.height)
            .accessibilityHidden(true)
    }
}

private struct AskComposerCard: View {
    @Binding var draft: String
    var composerFocused: FocusState<Bool>.Binding
    let submissionAvailability: AskSubmissionAvailability
    let onSubmit: (String) -> Void

    private var hasQuestion: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var canSubmit: Bool {
        hasQuestion && submissionAvailability.isAvailable
    }

    var body: some View {
        HumaySurface(level: .raised, padding: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text(AskProductCopy.questionHeading)
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $draft)
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextPrimary)
                        .scrollContentBackground(.hidden)
                        .focused(composerFocused)
                        .frame(height: 144)
                        .accessibilityLabel("Your question")
                        .accessibilityHint("Enter one focused question")
                        .accessibilityIdentifier("ask.composer")

                    if draft.isEmpty {
                        Text("Ask something about the context you’ve shared…")
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayTextSecondary)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }

                if !submissionAvailability.isAvailable {
                    Text(AskProductCopy.submissionUnavailable)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("ask.composer.unavailable")
                }

                HStack(alignment: .center, spacing: HumaySpacing.medium) {
                    Label("Relevant context only", systemImage: "sparkles")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("ask.composer.context")

                    Spacer(minLength: HumaySpacing.small)

                    Button("Ask") {
                        onSubmit(draft)
                    }
                    .buttonStyle(.humayPrimary)
                    .disabled(!canSubmit)
                    .accessibilityHint(
                        submissionAvailability.isAvailable
                            ? "Submits your focused question"
                            : AskProductCopy.submissionUnavailable
                    )
                    .accessibilityIdentifier("ask.composer.action")
                }
            }
        }
        .id("ask.composer")
    }
}

private struct AskSuggestionsView: View {
    @Binding var draft: String

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text("TRY A QUESTION")
                .font(HumayTypography.utility)
                .foregroundStyle(Color.humayTextSecondary)
                .accessibilityIdentifier("ask.suggestions")

            VStack(spacing: 0) {
                ForEach(Array(AskProductCopy.suggestions.enumerated()), id: \.offset) { index, suggestion in
                    Button {
                        draft = suggestion
                    } label: {
                        HStack(alignment: .center, spacing: HumaySpacing.medium) {
                            Text(suggestion)
                                .font(HumayTypography.body)
                                .foregroundStyle(Color.humayTextPrimary)
                                .multilineTextAlignment(.leading)

                            Spacer(minLength: HumaySpacing.small)

                            Image(systemName: "arrow.up.left")
                                .font(HumayTypography.supportingEmphasized)
                                .foregroundStyle(Color.humayCoral)
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, minHeight: HumayMetrics.minimumHitTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Fills your question without submitting it")
                    .accessibilityIdentifier("ask.suggestion.\(index)")

                    if index < AskProductCopy.suggestions.count - 1 {
                        Divider()
                            .overlay(Color.humayHairline)
                    }
                }
            }
            .padding(.horizontal, HumaySpacing.medium)
            .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface)
                    .stroke(Color.humayHairline)
            }
        }
    }
}

struct AskContextCard: View {
    let context: AskContext

    var body: some View {
        HumaySurface(level: .standard, padding: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(AskProductCopy.contextHeading)
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)
                    .accessibilityIdentifier("ask.context")

                Text(context.summary)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(context.detail)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
