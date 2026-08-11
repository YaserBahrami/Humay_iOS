import SwiftUI

/// A reading's headline.
struct ReadingHeadline: View {
    let text: String

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Text(text)
            .humayFont(.displayXL)
            .foregroundStyle(theme.colors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A reading's body copy.
struct ReadingBody: View {
    let text: String
    var role: HumayTypeRole = .body

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Text(text)
            .humayFont(role)
            .foregroundStyle(theme.colors.textBody)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// The astrological basis, disclosed rather than asserted.
///
/// The summary is always visible; the factors expand. The order matters for VoiceOver
/// too — the insight is read first and the basis second, never the reverse, because the
/// reasoning explains the reading rather than replacing it.
struct BasisDisclosure: View {
    let basis: ReadingBasis
    let provenance: ContentProvenance
    @State private var isExpanded = false

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            if !basis.summary.isEmpty {
                // The marker sits above the basis on its own line rather than beside
                // it: inline, it lands mid-paragraph wherever the text happens to wrap.
                SampleContentMarker(provenance: provenance)
                Text(basis.summary)
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !basis.factors.isEmpty {
                Button {
                    withAnimation(HumayMotion.strike) { isExpanded.toggle() }
                } label: {
                    HStack(spacing: HumaySpacing.xs) {
                        MonoKicker(text: "What's influencing this", color: theme.colors.accentText)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(theme.colors.accentText)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .frame(minHeight: HumayHitTarget.minimum)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("What's influencing this")
                .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")

                if isExpanded {
                    VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                        HairlineRule()
                        ForEach(basis.factors) { factor in
                            HStack(alignment: .firstTextBaseline) {
                                MonoFact(text: factor.label, emphasised: true)
                                Spacer(minLength: HumaySpacing.s)
                                MonoFact(text: factor.detail)
                            }
                            .frame(minHeight: 26)
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

/// The entry point from a general reading to its precise counterpart.
///
/// Deliberately not a card with a fill — under the minimal direction this is a rule, a
/// title, a sentence and a link. It reads as the next thing to do rather than as an
/// advertisement.
struct PreciseEntryPoint: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                HairlineRule(color: theme.colors.hairlineAccent)
                    .padding(.bottom, HumaySpacing.xs)
                HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.xs) {
                    Text(title)
                        .humayFont(.titleM)
                        .foregroundStyle(theme.colors.textPrimary)
                    TierBadge(tier: .precise)
                }
                Text(message)
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 4) {
                    Text(actionTitle)
                        .humayFont(.label)
                        .foregroundStyle(theme.colors.accentText)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(theme.colors.accentText)
                }
                .padding(.top, 2)
                .frame(minHeight: HumayHitTarget.minimum, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
        .accessibilityHint(actionTitle)
        .accessibilityAddTraits(.isButton)
    }
}

/// One labelled area of a daily reading.
struct ReadingCategoryRow: View {
    let category: ReadingCategory
    let text: String

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            HairlineRule()
            MonoKicker(text: category.displayName)
                .padding(.top, HumaySpacing.xs)
            Text(text)
                .humayFont(.bodySmall)
                .foregroundStyle(theme.colors.textBody)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, HumaySpacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.displayName). \(text)")
    }
}

/// The triad each chart leads with, laid out as three columns divided by rules.
struct ChartTriadView: View {
    let triad: ChartTriad
    var onGlossaryTerm: ((String) -> Void)?

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            HairlineRule()
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(triad.entries.enumerated()), id: \.element.id) { index, entry in
                    if index > 0 {
                        Rectangle()
                            .fill(theme.colors.hairline)
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)
                    }
                    entryColumn(entry)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            HairlineRule()
        }
    }

    @ViewBuilder
    private func entryColumn(_ entry: ChartTriad.Entry) -> some View {
        VStack(spacing: HumaySpacing.xs) {
            GlyphLabel(
                glyph: entry.glyph,
                spokenName: entry.glyphSpokenName,
                role: .displayM,
                color: theme.colors.accentMark
            )
            HStack(spacing: 0) {
                MonoKicker(text: entry.label)
                if let termID = entry.glossaryTermID, let onGlossaryTerm {
                    InfoTrigger(termID: termID, termName: entry.label, action: onGlossaryTerm)
                        .frame(width: 22, height: 22)
                }
            }
            Text(entry.value)
                .humayFont(.titleS)
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HumaySpacing.m)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.label): \(entry.value)")
    }
}

/// The one thing a chart most wants to say about itself.
struct ChartFeatureView: View {
    let feature: ChartFeature

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            MonoKicker(text: feature.kicker, color: theme.colors.accentText)
            Text(feature.headline)
                .humayFont(.displayM)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            ReadingBody(text: feature.body, role: .bodySmall)
        }
    }
}
