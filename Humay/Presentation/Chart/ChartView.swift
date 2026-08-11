import SwiftUI

/// What a birth date alone supports, across all three traditions.
struct ChartView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    @State private var profile: SignProfile?
    @State private var failure: String?

    var body: some View {
        ScreenScaffold(title: "Chart") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                if let profile {
                    content(profile)
                } else if let failure {
                    ErrorStateView(message: failure) { Task { await load() } }
                } else {
                    LoadingState(message: "Reading your date…")
                }
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private func content(_ profile: SignProfile) -> some View {
        HStack(alignment: .firstTextBaseline) {
            MonoKicker(text: "Your sign profile")
            Spacer(minLength: HumaySpacing.xs)
            TierBadge(tier: .general)
        }

        Text(profile.headline)
            .humayFont(.displayL)
            .foregroundStyle(theme.colors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)

        VStack(spacing: 0) {
            HairlineRule()
            ForEach(profile.entries) { entry in
                SignProfileRow(entry: entry)
                HairlineRule()
            }
        }

        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            SampleContentMarker(provenance: profile.provenance)
            Text(profile.basisNote)
                .humayFont(.callout)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }

        ReadingBody(text: profile.body, role: .bodySmall)

        PreciseEntryPoint(
            title: "Your full chart",
            message: "Moon, Rising, houses and aspects — plus the Vedic and Chinese readings in their own terms.",
            actionTitle: "Open your full chart"
        ) {
            router.push(.chartFull, on: .chart)
        }
        .padding(.top, HumaySpacing.s)
    }

    private func load() async {
        guard let birth = environment.profile?.birth else { return }
        failure = nil
        do {
            profile = try await environment.chartService.signProfile(for: birth)
        } catch {
            failure = "Your profile could not be loaded."
            HumayLog.contentFailure("Sign profile failed: \(error)")
        }
    }
}

/// The full chart, in one system at a time.
///
/// The system switch is in place rather than a push, and each system gets genuinely
/// different content — not the same layout with the labels translated. Vedic has dashas
/// and bhavas; Chinese has pillars and elements and no houses at all.
struct ChartFullView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    @State private var system: ChartSystem = .western
    @State private var chart: SystemChart?
    @State private var failure: String?
    @State private var glossaryTermID: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                HumaySegmentedControl(
                    options: ChartSystem.allCases,
                    title: \.shortName,
                    selection: $system
                )

                if let chart {
                    switch chart {
                    case .western(let western):
                        WesternChartSection(chart: western) { placementID in
                            router.push(.placement(id: placementID, system: .western), on: .chart)
                        }
                    case .vedic(let vedic):
                        VedicChartSection(chart: vedic, onGlossaryTerm: { glossaryTermID = $0 }) { placementID in
                            router.push(.placement(id: placementID, system: .vedic), on: .chart)
                        }
                    case .chinese(let chinese):
                        ChineseChartSection(chart: chinese, onGlossaryTerm: { glossaryTermID = $0 }) { placementID in
                            router.push(.placement(id: placementID, system: .chinese), on: .chart)
                        }
                    }
                } else if let failure {
                    ErrorStateView(message: failure) { Task { await load() } }
                } else {
                    LoadingState(message: "Reading your placements…")
                }
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, HumaySpacing.m)
            .padding(.bottom, HumaySpacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle("Your chart")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: system) { await load() }
        .sheet(item: Binding(
            get: { glossaryTermID.map(GlossaryRequest.init) },
            set: { glossaryTermID = $0?.id }
        )) { request in
            GlossarySheet(termID: request.id)
        }
        .onAppear {
            if chart == nil { system = environment.settings.leadingTradition.chartSystem }
        }
    }

    private func load() async {
        guard let birth = environment.profile?.birth else { return }
        failure = nil
        chart = nil
        do {
            chart = try await environment.chartService.chart(for: birth, system: system)
        } catch {
            failure = "This chart could not be loaded."
            HumayLog.contentFailure("Chart failed: \(error)")
        }
    }
}

/// Wrapper so a term identifier can drive a `sheet(item:)`.
struct GlossaryRequest: Identifiable {
    let id: String
}

struct GlossarySheet: View {
    let termID: String

    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.humayTheme) private var theme

    @State private var term: GlossaryTerm?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: HumaySpacing.m) {
                if let term {
                    MonoKicker(text: term.system.displayName)
                    Text(term.term)
                        .humayFont(.displayM)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(term.definition)
                        .humayFont(.bodySmall)
                        .foregroundStyle(theme.colors.textBody)
                        .fixedSize(horizontal: false, vertical: true)
                    if let requirement = term.requirement {
                        HairlineRule()
                        Text(requirement)
                            .humayFont(.callout)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                } else {
                    LoadingState(message: "Loading…")
                }
                Spacer(minLength: 0)
                Button("Got it") { dismiss() }
                    .buttonStyle(.humayPrimary)
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, HumaySpacing.l)
            .padding(.bottom, HumaySpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.colors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 13))
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationDetents([.medium])
        .task {
            term = try? await environment.glossaryService.term(id: termID)
        }
    }
}

/// One placement, opened on its own.
struct PlacementDetailView: View {
    let placementID: String
    let system: ChartSystem

    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var detail: PlacementDetail?
    @State private var failure: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                if let detail {
                    content(detail)
                } else if let failure {
                    ErrorStateView(message: failure)
                } else {
                    LoadingState(message: "Loading…")
                }
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, HumaySpacing.m)
            .padding(.bottom, HumaySpacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(detail?.title ?? "Placement")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    @ViewBuilder
    private func content(_ detail: PlacementDetail) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            MonoKicker(text: detail.system.displayName)
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.s) {
                GlyphLabel(
                    glyph: detail.glyph,
                    spokenName: detail.glyphSpokenName,
                    role: .displayM,
                    color: theme.colors.accentMark
                )
                VStack(alignment: .leading, spacing: 0) {
                    Text(detail.title)
                        .humayFont(.displayM)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(detail.subtitle)
                        .humayFont(.titleS)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer(minLength: HumaySpacing.xs)
                if let precision = detail.precision {
                    MonoFact(text: precision, emphasised: true)
                }
            }
            SampleContentMarker(provenance: detail.provenance)
        }

        ForEach(detail.sections) { section in
            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                SectionHeader(title: section.title)
                ReadingBody(text: section.body, role: .bodySmall)
                if !section.facts.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(section.facts, id: \.self) { fact in
                            MonoFact(text: fact)
                                .frame(minHeight: 24)
                        }
                    }
                }
            }
        }
    }

    private func load() async {
        guard let birth = environment.profile?.birth else { return }
        do {
            let chart = try await environment.chartService.chart(for: birth, system: system)
            detail = try await environment.chartService.placementDetail(id: placementID, in: chart)
        } catch {
            failure = "This placement could not be loaded."
        }
    }
}

#Preview {
    NavigationStack { ChartView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
