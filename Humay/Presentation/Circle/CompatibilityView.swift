import SwiftUI

/// A compatibility reading.
///
/// Both tiers use the same four axes, so the vocabulary carries across. Verdicts are
/// qualitative and each one is followed by the sentence that justifies it — a verdict
/// on its own would be an assertion, which is the thing this product is trying not to do.
struct CompatibilityView: View {
    let personID: UUID
    let tier: PrecisionTier

    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var reading: CompatibilityReading?
    @State private var failure: String?

    private var person: CirclePerson? {
        environment.people.first { $0.id == personID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                if let reading {
                    CompatibilityReadingView(reading: reading)
                } else if let failure {
                    ErrorStateView(message: failure) { Task { await load() } }
                } else {
                    LoadingState(message: tier == .precise ? "Reading both charts…" : "Reading the pairing…")
                }
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, HumaySpacing.m)
            .padding(.bottom, HumaySpacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(person?.name ?? "Compatibility")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: environment.settings.tone) { await load() }
    }

    private func load() async {
        guard let person, let profile = environment.profile else { return }
        failure = nil
        do {
            switch tier {
            case .general:
                let result = try await environment.compatibilityService.generalReading(
                    MockAstrology.sunSign(for: profile.birth),
                    MockAstrology.sunSign(for: person.birth),
                    tone: environment.settings.tone
                )
                reading = .general(result)
            case .precise:
                let result = try await environment.compatibilityService.preciseReading(
                    user: profile,
                    person: person,
                    tone: environment.settings.tone
                )
                reading = .precise(result)
            }
        } catch {
            failure = "This reading could not be loaded."
            HumayLog.contentFailure("Compatibility failed: \(error)")
        }
    }
}

struct CompatibilityReadingView: View {
    let reading: CompatibilityReading

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            switch reading {
            case .general(let general):
                header(
                    label: general.pairLabel,
                    glyphs: [
                        (general.firstSign.glyph, general.firstSign.spokenName),
                        (general.secondSign.glyph, general.secondSign.spokenName),
                    ],
                    tier: .general
                )
                ReadingHeadline(text: general.headline)
                ReadingBody(text: general.body)
                BasisDisclosure(basis: general.basis, provenance: general.provenance)
                axes(general.axes)

            case .precise(let precise):
                header(label: precise.pairLabel, subtitle: precise.relationshipLabel, glyphs: [], tier: .precise)
                ReadingHeadline(text: precise.headline)
                ReadingBody(text: precise.body)
                BasisDisclosure(basis: precise.basis, provenance: precise.provenance)
                axes(precise.axes)

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "What two charts reach")
                    ReadingBody(text: precise.deeperNote, role: .bodySmall)
                }
            }
        }
    }

    @ViewBuilder
    private func header(
        label: String,
        subtitle: String? = nil,
        glyphs: [(String, String)],
        tier: PrecisionTier
    ) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.xs) {
                MonoKicker(text: subtitle ?? "Sign to sign")
                Spacer(minLength: HumaySpacing.xs)
                TierBadge(tier: tier)
            }
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.s) {
                Text(label)
                    .humayFont(.displayM)
                    .foregroundStyle(theme.colors.textPrimary)
                if !glyphs.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(glyphs.enumerated()), id: \.offset) { index, glyph in
                            if index > 0 {
                                Text("+")
                                    .humayFont(.callout)
                                    .foregroundStyle(theme.colors.textLabel)
                            }
                            GlyphLabel(
                                glyph: glyph.0,
                                spokenName: glyph.1,
                                role: .titleM,
                                color: theme.colors.accentMark
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func axes(_ axes: [CompatibilityAxisReading]) -> some View {
        VStack(spacing: 0) {
            HairlineRule()
            ForEach(axes) { axis in
                CompatibilityAxisRow(reading: axis)
                HairlineRule()
            }
        }
    }
}

struct CompatibilityAxisRow: View {
    let reading: CompatibilityAxisReading

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(reading.axis.displayName)
                    .humayFont(.titleS)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer(minLength: HumaySpacing.s)
                // A word, never a number. There is no score here and nothing is ranked.
                Text(reading.verdict.displayName.uppercased())
                    .humayFont(.monoKicker)
                    .foregroundStyle(verdictColor)
            }
            Text(reading.explanation)
                .humayFont(.callout)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, HumaySpacing.s)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(reading.spokenSummary)
    }

    private var verdictColor: Color {
        switch reading.verdict {
        case .strong, .balanced: theme.colors.accentText
        case .mixed: theme.colors.textSecondary
        case .friction: theme.colors.textTertiary
        }
    }
}

/// Comparing two signs without saving anyone.
struct QuickCheckView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var first: WesternSign = .pisces
    @State private var second: WesternSign = .leo
    @State private var reading: GeneralCompatibilityReading?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                Text("Any two signs, no saving required.")
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)

                HStack(spacing: HumaySpacing.m) {
                    signPicker("First", selection: $first)
                    signPicker("Second", selection: $second)
                }

                if let reading {
                    CompatibilityReadingView(reading: .general(reading))
                } else {
                    LoadingState(message: "Reading the pairing…")
                }
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, HumaySpacing.m)
            .padding(.bottom, HumaySpacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle("Quick check")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: "\(first.rawValue)-\(second.rawValue)-\(environment.settings.tone.rawValue)") {
            reading = try? await environment.compatibilityService.generalReading(
                first,
                second,
                tone: environment.settings.tone
            )
        }
    }

    @ViewBuilder
    private func signPicker(_ label: String, selection: Binding<WesternSign>) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            MonoKicker(text: label)
            Picker(label, selection: selection) {
                ForEach(WesternSign.allCases) { sign in
                    Text(sign.spokenName).tag(sign)
                }
            }
            .pickerStyle(.menu)
            .tint(theme.colors.accentText)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
