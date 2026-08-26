import SwiftUI
import UIKit

/// A pending share composition. Dedicated compositions — never raw app screenshots.
struct ShareActivity: Identifiable {
    enum Kind {
        case roast(RoastContent)
        case flags(FlagPairContent)
        case reading(DailyReadingContent)
        case headline(HeadlineContent)
        case meters(MeterSetContent)
        case compatibility(CompatibilityVerdict, firstName: String, secondName: String)
        case dayCard(anchor: ForecastAnchor, mood: DailyMood)
    }

    let kind: Kind
    var id: String { "\(kind)" }
}

enum HumayShareCards {
    /// Renders the correct dedicated composition for an activity.
    @MainActor
    @ViewBuilder
    static func composition(for activity: ShareActivity) -> some View {
        switch activity.kind {
        case .roast(let content):
            RoastShareCard(content: content)
        case .flags(let content):
            FlagsShareCard(content: content)
        case .reading(let content):
            ReadingShareCard(content: content)
        case .headline(let content):
            HeadlineShareCard(content: content)
        case .meters(let content):
            MetersShareCard(content: content)
        case .compatibility(let verdict, let firstName, let secondName):
            CompatibilityShareCard(verdict: verdict, firstName: firstName, secondName: secondName)
        case .dayCard(let anchor, let mood):
            DayShareCard(anchor: anchor, mood: mood)
        }
    }

    @MainActor
    static func renderImage(for activity: ShareActivity) -> UIImage? {
        let renderer = ImageRenderer(
            content: composition(for: activity)
                .frame(width: 640, height: 800)
                .background(Color.humayGround)
        )
        renderer.scale = 2
        return renderer.uiImage
    }
}

// MARK: - Compositions

/// Shared visual grammar for share cards: kicker, big statement, Humay mark.
private struct ShareCardShell<Content: View>: View {
    let kicker: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack {
                Text("humay")
                    .font(HumayTypography.wordmark)
                    .foregroundStyle(Color.humayCoral)
                Spacer()
                Text(kicker.uppercased())
                    .font(HumayTypography.utility)
                    .tracking(1.6)
                    .foregroundStyle(Color.humayTextSecondary)
            }

            Spacer(minLength: 12)

            content

            Spacer(minLength: 12)

            Text("The stars have opinions. They are not experts.")
                .font(HumayTypography.caption)
                .foregroundStyle(Color.humayTextSecondary)
        }
        .padding(44)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct RoastShareCard: View {
    let content: RoastContent

    var body: some View {
        ShareCardShell(kicker: "today's roast") {
            VStack(alignment: .leading, spacing: 20) {
                Text(content.title)
                    .font(HumayTypography.editorialTitle)
                    .foregroundStyle(Color.humayCoral)
                Text("\"\(content.body)\"")
                    .font(HumayTypography.heroTitle)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct FlagsShareCard: View {
    let content: FlagPairContent

    var body: some View {
        ShareCardShell(kicker: "flags of the day") {
            VStack(alignment: .leading, spacing: 26) {
                shareRow(tint: .humayCoral, label: "RED FLAG", text: content.redFlag)
                Divider().overlay(Color.humayHairline)
                shareRow(tint: .humaySage, label: "GREEN FLAG", text: content.greenFlag)
            }
        }
    }

    private func shareRow(tint: Color, label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(HumayTypography.utility)
                .tracking(1.4)
                .foregroundStyle(tint)
            Text(text)
                .font(HumayTypography.cardTitle)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ReadingShareCard: View {
    let content: DailyReadingContent

    var body: some View {
        ShareCardShell(kicker: content.kicker) {
            VStack(alignment: .leading, spacing: 18) {
                Text(content.headline)
                    .font(HumayTypography.heroTitle)
                    .fixedSize(horizontal: false, vertical: true)
                if let tip = content.tip {
                    Text(tip)
                        .font(HumayTypography.bodyEmphasized)
                        .foregroundStyle(Color.humayCoral)
                }
            }
        }
    }
}

struct HeadlineShareCard: View {
    let content: HeadlineContent

    var body: some View {
        ShareCardShell(kicker: content.kicker) {
            VStack(alignment: .leading, spacing: 16) {
                Text(content.headline)
                    .font(HumayTypography.heroTitle)
                    .fixedSize(horizontal: false, vertical: true)
                if let supporting = content.supporting {
                    Text(supporting)
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
        }
    }
}

struct MetersShareCard: View {
    let content: MeterSetContent

    var body: some View {
        ShareCardShell(kicker: content.title) {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(content.meters) { meter in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(meter.metric.displayName)
                                .font(HumayTypography.supportingEmphasized)
                            Spacer()
                            Text("\(meter.value)%")
                                .font(HumayTypography.meterValue.monospacedDigit())
                                .foregroundStyle(Color.humay(FeedAccent.accent(for: meter.metric)))
                        }
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.humayHairline)
                                Capsule()
                                    .fill(Color.humay(FeedAccent.accent(for: meter.metric)))
                                    .frame(width: proxy.size.width * Double(meter.value) / 100)
                            }
                        }
                        .frame(height: 8)
                        if let caption = meter.caption {
                            Text(caption)
                                .font(HumayTypography.caption)
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                    }
                }
            }
        }
    }
}

struct CompatibilityShareCard: View {
    let verdict: CompatibilityVerdict
    let firstName: String
    let secondName: String

    var body: some View {
        ShareCardShell(kicker: "chemistry report") {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(firstName) + \(secondName)")
                    .font(HumayTypography.sectionTitle)
                    .foregroundStyle(Color.humayTextSecondary)

                Text("\(verdict.overall)%")
                    .font(HumayTypography.compatibilityScore)
                    .foregroundStyle(Color.humayCoral)

                Text(verdict.headline)
                    .font(HumayTypography.editorialTitle)
                    .fixedSize(horizontal: false, vertical: true)

                if let first = verdict.verdictLines.first {
                    Text("\(first.question) \(first.answer)")
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct DayShareCard: View {
    let anchor: ForecastAnchor
    let mood: DailyMood

    var body: some View {
        ShareCardShell(kicker: "on this day") {
            VStack(alignment: .leading, spacing: 20) {
                Text(anchor.date(forDayOffset: mood.dayOffset)?
                    .formatted(.dateTime.weekday(.wide).day().month(.wide)) ?? "")
                    .font(HumayTypography.sectionTitle)
                    .foregroundStyle(Color.humayTextSecondary)

                Text("\(mood.scores[.overall])%")
                    .font(HumayTypography.compatibilityScore)
                    .foregroundStyle(Color.humaySage)

                Text("Overall forecast. Chaos level \(mood.scores[.chaos])%. Plan accordingly.")
                    .font(HumayTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Sheet

@MainActor
struct ShareSheet: View {
    let activity: ShareActivity
    @Environment(\.dismiss) private var dismiss
    @State private var renderedImage: UIImage?

    var body: some View {
        VStack(spacing: HumaySpacing.large) {
            Capsule()
                .fill(Color.humayHairline)
                .frame(width: 40, height: 5)
                .padding(.top, HumaySpacing.small)

            Text("Your card")
                .font(HumayTypography.sectionTitle)

            Group {
                if let renderedImage {
                    Image(uiImage: renderedImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous)
                                .strokeBorder(Color.humayHairline)
                        }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: 420)
            .frame(maxHeight: .infinity)

            if let renderedImage {
                ShareLink(
                    item: Image(uiImage: renderedImage),
                    preview: SharePreview("Made with Humay", image: Image(uiImage: renderedImage))
                ) {
                    Label("Share", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: HumayMetrics.primaryControlMinimumHeight - 12)
                }
                .buttonStyle(.humayPrimary)
                .padding(.horizontal, HumaySpacing.extraLarge)
                .padding(.bottom, HumaySpacing.medium)
            }
        }
        .background(Color.humayGround.ignoresSafeArea())
        .presentationDetents([.large])
        .task {
            renderedImage = HumayShareCards.renderImage(for: activity)
            await MainActor.run { HumayHaptics.tap() }
        }
    }
}
