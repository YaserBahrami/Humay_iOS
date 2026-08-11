import SwiftUI

/// Beat one. What this is, in two lines.
struct OnboardingWelcomeView: View {
    let onContinue: () -> Void

    @Environment(\.humayTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var markVisible = false

    var body: some View {
        OnboardingScaffold(actionTitle: "Begin", fillsHeight: true, action: onContinue) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: HumaySpacing.xl)

                OccultationMark(size: 34)
                    .opacity(markVisible ? 1 : 0)
                    .scaleEffect(markVisible || reduceMotion ? 1 : 0.94)
                    .padding(.bottom, HumaySpacing.l)
                    .onAppear {
                        // The signature reveal. Plays once, here and at a chart reveal.
                        withAnimation(HumayMotion.reveal(reduceMotion: reduceMotion)) {
                            markVisible = true
                        }
                    }

                Wordmark(size: 17)
                    .padding(.bottom, HumaySpacing.l)
                    .riseIn(1)

                Text("Read the sky.\nSee the reasoning.")
                    .humayFont(.displayXL)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, HumaySpacing.m)
                    .riseIn(2)

                Text("Western, Vedic and Chinese traditions, each kept in its own language. Every reading opens to show the chart factors behind it.")
                    .humayFont(.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .riseIn(3)

                Spacer(minLength: HumaySpacing.xl)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Beat two. A birth date, and an explanation of why that is enough for now.
struct OnboardingBirthDateView: View {
    @Binding var date: Date
    let onContinue: () -> Void
    let onBack: () -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        OnboardingScaffold(
            stepLabel: "01 · Birth date",
            onBack: onBack,
            actionTitle: "Continue",
            action: onContinue
        ) {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                Text("When were you born?")
                    .humayFont(.displayL)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                DatePicker(
                    "Date of birth",
                    selection: $date,
                    in: Self.earliestDate...Date.now,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Date of birth")

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    HairlineRule()
                    Text("This is all the general reading needs — your Sun sign, your Chinese year and sign-to-sign compatibility all follow from the date alone.")
                        .humayFont(.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, HumaySpacing.xs)

                    Text("Birth time and place are not required now. You can add them later in Profile, and they unlock the parts of a chart that genuinely depend on them.")
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private static var earliestDate: Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? .distantPast
    }
}

/// Beat three. Which tradition leads.
struct OnboardingTraditionView: View {
    @Binding var selection: AstrologyTradition
    let onContinue: () -> Void
    let onBack: () -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        OnboardingScaffold(
            stepLabel: "02 · Tradition",
            onBack: onBack,
            actionTitle: "Continue",
            action: onContinue
        ) {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                    Text("Which tradition should lead?")
                        .humayFont(.displayL)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("All three stay available. This sets the vocabulary of your daily reading.")
                        .humayFont(.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 0) {
                    HairlineRule()
                    ForEach(AstrologyTradition.allCases) { tradition in
                        TraditionRow(
                            tradition: tradition,
                            isSelected: tradition == selection
                        ) {
                            withAnimation(HumayMotion.strike) { selection = tradition }
                        }
                        HairlineRule()
                    }
                }

                Text("Different frameworks, not different settings — each keeps its own concepts rather than pretending to be equivalent to the others.")
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TraditionRow: View {
    let tradition: AstrologyTradition
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: HumaySpacing.s) {
                GlyphLabel(
                    glyph: tradition.mark,
                    spokenName: tradition.markSpokenName,
                    role: .titleM,
                    color: isSelected ? theme.colors.accentMark : theme.colors.textTertiary
                )
                .frame(width: 26, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(tradition.displayName)
                        .humayFont(.titleS)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(tradition.premise)
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: HumaySpacing.xs)

                Image(systemName: "checkmark")
                    .font(.system(size: HumayIconSize.inline, weight: .medium))
                    .foregroundStyle(theme.colors.accentText)
                    .opacity(isSelected ? 1 : 0)
            }
            .padding(.vertical, HumaySpacing.s)
            .frame(minHeight: HumayHitTarget.minimum)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tradition.displayName). \(tradition.premise)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

/// Beat four. What the date alone already says, across all three traditions.
struct OnboardingRevealView: View {
    let birth: BirthDetails
    let tradition: AstrologyTradition
    let onEnter: () -> Void

    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var profile: SignProfile?

    var body: some View {
        OnboardingScaffold(
            stepLabel: "03 · Your profile",
            actionTitle: "Enter Humay",
            action: onEnter
        ) {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                if let profile {
                    VStack(alignment: .leading, spacing: HumaySpacing.s) {
                        Text(profile.headline)
                            .humayFont(.displayL)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .riseIn(0)
                    }

                    VStack(spacing: 0) {
                        HairlineRule()
                        ForEach(Array(profile.entries.enumerated()), id: \.element.id) { index, entry in
                            SignProfileRow(entry: entry)
                                .riseIn(index + 1)
                            HairlineRule()
                        }
                    }

                    HStack(spacing: HumaySpacing.xs) {
                        TierBadge(tier: .general)
                        MonoKicker(text: "· from your birth date")
                        SampleContentMarker(provenance: profile.provenance)
                    }
                    .riseIn(4)

                    Text(profile.basisNote)
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .riseIn(5)
                } else {
                    LoadingState(message: "Reading your date…")
                }
            }
        }
        .task {
            profile = try? await environment.chartService.signProfile(for: birth)
        }
    }
}

struct SignProfileRow: View {
    let entry: SignProfile.Entry

    @Environment(\.humayTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var glyphColumn: CGFloat = 30

    var body: some View {
        AdaptiveRow(horizontalAlignment: .center) {
            HStack(spacing: HumaySpacing.s) {
                GlyphLabel(
                    glyph: entry.glyph,
                    spokenName: entry.glyphSpokenName,
                    role: .titleM,
                    color: theme.colors.accentMark
                )
                .frame(width: glyphColumn, alignment: .leading)

                VStack(alignment: .leading, spacing: 1) {
                    MonoKicker(text: entry.system.displayName)
                    Text(entry.label)
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } trailing: {
            Text(entry.value)
                .humayFont(.titleS)
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(dynamicTypeSize.rowTrailingAlignment)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, HumaySpacing.s)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.system.displayName). \(entry.label): \(entry.value)")
    }
}

#Preview("Welcome") {
    OnboardingFlowView()
        .environment(AppEnvironment.preview(profile: nil, settings: .default, people: []))
}
