import SwiftUI

enum AskAnswerStatus: Hashable {
    case live
    case saved(date: Date)
    case offlineSaved(date: Date)

    var label: String? {
        switch self {
        case .live:
            nil
        case .saved:
            "Saved"
        case .offlineSaved:
            "Offline · saved answer"
        }
    }

    var symbol: String {
        switch self {
        case .live: "sparkles"
        case .saved: "bookmark.fill"
        case .offlineSaved: "wifi.slash"
        }
    }
}

struct AskAccessView: View {
    let question: AskQuestion
    let access: AskAccessState
    let context: AskContext
    let onEdit: () -> Void

    var body: some View {
        AskScrollablePage(identifier: "ask.access.screen") {
            AskQuestionCard(question: question)

            HumayCosmicSurface {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    AskIllustrationView(size: CGSize(width: 180, height: 120))
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(AskProductCopy.accessHeading)
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humaySolarGold)

                    Text(AskProductCopy.accessDetail)
                        .font(HumayTypography.cardTitle)
                        .foregroundStyle(Color.humayGround)
                        .fixedSize(horizontal: false, vertical: true)

                    Button(AskProductCopy.accessAction) {
                        // Rewarded access is intentionally not wired in D5.1.
                    }
                    .buttonStyle(.humayPrimary)
                    .disabled(true)
                    .accessibilityHint("This access action is not available yet")
                    .accessibilityIdentifier("ask.access.watch")

                    if access == .rewardedRequired {
                        HStack(spacing: HumaySpacing.small) {
                            Image(systemName: "star.circle")
                                .accessibilityHidden(true)
                            Text(AskProductCopy.premiumAlternative)
                                .font(HumayTypography.supportingEmphasized)
                        }
                        .foregroundStyle(Color.humayGround.opacity(0.82))
                        .accessibilityIdentifier("ask.access.premium")
                    }
                }
            }

            AskContextCard(context: context)

            Button("Edit question", action: onEdit)
                .buttonStyle(.humaySecondary)
                .accessibilityIdentifier("ask.access.edit")
        }
    }
}

struct AskGeneratingView: View {
    let question: AskQuestion
    let context: AskContext

    var body: some View {
        AskScrollablePage(identifier: "ask.generating.screen") {
            AskQuestionCard(question: question)

            HumayCosmicSurface {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    AskIllustrationView(size: CGSize(width: 180, height: 120))
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(AskProductCopy.generatingTitle)
                        .font(HumayTypography.cardTitle)
                        .foregroundStyle(Color.humayGround)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(AskProductCopy.generatingDetail)
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayGround.opacity(0.84))

                    Text(AskProductCopy.generatingFooter)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayGround.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            AskContextCard(context: context)
        }
    }
}

struct AskAnswerView: View {
    let answer: AskAnswer
    let status: AskAnswerStatus
    let onAskAnother: () -> Void

    var body: some View {
        AskScrollablePage(identifier: "ask.answer.screen") {
            AskQuestionCard(question: answer.question)

            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
                    Text(AskProductCopy.readingHeading)
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humayTextSecondary)

                    Spacer(minLength: HumaySpacing.small)

                    if let statusLabel = status.label {
                        Label(statusLabel, systemImage: status.symbol)
                            .font(HumayTypography.utility)
                            .foregroundStyle(Color.humayTextSecondary)
                            .accessibilityIdentifier("ask.answer.status")
                    }
                }

                Text(answer.headline)
                    .font(HumayTypography.detailTitle)
                    .foregroundStyle(Color.humayTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                if let disclosure = answer.disclosure {
                    Text(disclosure)
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humayTextSecondary)
                        .accessibilityIdentifier("ask.answer.disclosure")
                }

                ForEach(answer.sections) { section in
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text(section.title)
                            .font(HumayTypography.sectionTitle)
                            .foregroundStyle(Color.humayTextPrimary)

                        Text(section.body)
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .accessibilityIdentifier("ask.answer.interpretation")

            HumayCosmicSurface {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    Text(AskProductCopy.tryThisHeading)
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humaySolarGold)

                    ForEach(answer.tryThis, id: \.self) { reflection in
                        Text(reflection)
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayGround)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .accessibilityIdentifier("ask.answer.try-this")

            AskBasisCard(facts: answer.basis)

            Button(AskProductCopy.askAnother, action: onAskAnother)
                .buttonStyle(.humaySecondary)
                .accessibilityIdentifier("ask.answer.ask-another")
        }
    }
}

struct AskStatusView: View {
    enum State: Hashable {
        case offlineNoCache
        case insufficientContext(AskContextIssue)
        case unsupported(AskUnsupportedReason)
        case safetyRefusal(AskSafetyRefusal)
        case failed(AskFailure)
    }

    let state: State
    let question: AskQuestion?
    let context: AskContext
    let onEdit: (() -> Void)?

    var body: some View {
        AskScrollablePage(identifier: identifier) {
            if let question {
                AskQuestionCard(question: question)
            }

            HumaySurface(level: .raised) {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    Image(systemName: symbol)
                        .font(HumayTypography.statusSymbol)
                        .foregroundStyle(accent)
                        .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: HumayMetrics.minimumHitTarget)
                        .accessibilityHidden(true)

                    Text(title)
                        .font(HumayTypography.cardTitle)
                        .foregroundStyle(Color.humayTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text(detail)
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if !missing.isEmpty {
                        VStack(alignment: .leading, spacing: HumaySpacing.small) {
                            Text("What’s missing")
                                .font(HumayTypography.supportingEmphasized)

                            ForEach(missing, id: \.self) { item in
                                Label(item, systemImage: "minus")
                                    .font(HumayTypography.supporting)
                                    .foregroundStyle(Color.humayTextSecondary)
                            }
                        }
                    }

                    if let recommendation {
                        Text(recommendation)
                            .font(HumayTypography.supportingEmphasized)
                            .foregroundStyle(Color.humayTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let onEdit {
                        Button("Edit question", action: onEdit)
                            .buttonStyle(.humaySecondary)
                            .accessibilityIdentifier("ask.state.edit")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityIdentifier(identifier)

            if case .offlineNoCache = state {
                AskContextCard(context: context)
            }
        }
    }

    private var identifier: String {
        switch state {
        case .offlineNoCache: "ask.state.offline.no-cache"
        case .insufficientContext: "ask.state.insufficient-context"
        case .unsupported: "ask.state.unsupported"
        case .safetyRefusal: "ask.state.safety-refusal"
        case .failed: "ask.state.failed"
        }
    }

    private var symbol: String {
        switch state {
        case .offlineNoCache: "wifi.slash"
        case .insufficientContext: "questionmark.circle"
        case .unsupported: "sparkles"
        case .safetyRefusal: "hand.raised"
        case .failed: "moon.zzz"
        }
    }

    private var accent: Color {
        switch state {
        case .offlineNoCache: .humayCelestialBlue
        case .insufficientContext: .humaySolarGold
        case .unsupported: .humayLavender
        case .safetyRefusal: .humayCoral
        case .failed: .humayTextSecondary
        }
    }

    private var title: String {
        switch state {
        case .offlineNoCache: AskProductCopy.offlineNoCache
        case .insufficientContext(let issue): issue.title
        case .unsupported(let reason): reason.title
        case .safetyRefusal(let refusal): refusal.title
        case .failed: AskProductCopy.failedTitle
        }
    }

    private var detail: String {
        switch state {
        case .offlineNoCache:
            "Your question stays here. Humay will not queue a request or invent an answer while offline."
        case .insufficientContext(let issue): issue.detail
        case .unsupported(let reason): reason.detail
        case .safetyRefusal(let refusal): refusal.detail
        case .failed(let failure): failure.detail
        }
    }

    private var missing: [String] {
        if case .insufficientContext(let issue) = state { return issue.missing }
        return []
    }

    private var recommendation: String? {
        if case .safetyRefusal(let refusal) = state { return refusal.recommendation }
        return nil
    }
}

private struct AskQuestionCard: View {
    let question: AskQuestion

    var body: some View {
        HumaySurface(level: .standard, padding: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(AskProductCopy.questionHeading)
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)

                Text(question.questionText)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("ask.question.card")
    }
}

private struct AskBasisCard: View {
    let facts: [AskBasisFact]

    var body: some View {
        HumaySurface(level: .standard, padding: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text(AskProductCopy.basisHeading)
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)

                ForEach(facts) { fact in
                    HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
                        Text(fact.label)
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                            .frame(width: 96, alignment: .leading)

                        Text(fact.value)
                            .font(fact.kind == .degree ? HumayTypography.technical : HumayTypography.body)
                            .foregroundStyle(Color.humayTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("ask.answer.basis")
    }
}

private struct AskScrollablePage<Content: View>: View {
    let identifier: String
    let content: Content

    init(
        identifier: String,
        @ViewBuilder content: () -> Content
    ) {
        self.identifier = identifier
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    content
                }
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.extraLarge)
                .frame(
                    maxWidth: HumayContentWidth.readable.rawValue,
                    alignment: .leading
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .scrollDismissesKeyboard(.interactively)
            .accessibilityIdentifier(identifier)
        }
    }
}
