import SwiftUI

struct ExploreView: View {
    let d2Input: D2FeatureInput
    let d3Input: D3FeatureInput
    let d4Input: D4FeatureInput
    let d5Input: D5FeatureInput
    let calendarToday: SkyCalendarDate?
    let profileName: String
    let openProfile: () -> Void

    var body: some View {
        HumayPage(maximum: .immersive) {
            HumayScreenHeader(
                section: "Explore",
                profileName: profileName,
                profileAction: openProfile
            )

            hero
            questionGrid
            tools
            disclosurePrinciple
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier("explore.screen")
    }

    private var hero: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: HumaySpacing.hero) {
                heroCopy
                    .frame(minWidth: 360, maxWidth: 560, alignment: .leading)
                Spacer(minLength: 0)
                HumayCelestialStage()
                    .frame(width: 260, height: 260)
            }

            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                heroCopy
                HumayCelestialStage(compact: true)
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
            }
        }
        .padding(.vertical, HumaySpacing.large)
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "Begin with your life")

            Text("What do you want to understand?")
                .font(HumayTypography.displayTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text("Choose a question first. Humay reveals the astrology only as deeply as you want to go.")
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 520, alignment: .leading)
        }
    }

    private var questionGrid: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumaySectionHeader(
                title: "Explore by question",
                subtitle: "Every path opens an existing Humay reading, chart, timing, or connection experience."
            )

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 250), spacing: HumaySpacing.large)],
                spacing: HumaySpacing.large
            ) {
                ForEach(ExploreTopic.allCases) { topic in
                    NavigationLink {
                        destination(for: topic.destination)
                    } label: {
                        topicTile(topic)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(topic.accessibilityHint)
                    .accessibilityIdentifier("explore.topic.\(topic.id)")
                }
            }
        }
    }

    private func topicTile(_ topic: ExploreTopic) -> some View {
        HStack(alignment: .top, spacing: HumaySpacing.large) {
            HumayGlyph(kind: topic.glyph)
                .frame(width: 38, height: 38)
                .foregroundStyle(topic.accent)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(topic.title)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)

                Text(topic.subtitle)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "arrow.up.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.humayTextSecondary)
                .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                .accessibilityHidden(true)
        }
        .padding(.vertical, HumaySpacing.large)
        .padding(.horizontal, HumaySpacing.large)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .background(Color.humaySurface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(topic.accent.opacity(0.62)).frame(height: 1)
        }
        .contentShape(Rectangle())
    }

    private var tools: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumaySectionHeader(
                title: "Celestial tools",
                subtitle: "For moments when you already know which lens you need."
            )

            VStack(spacing: 0) {
                toolLink(
                    title: "Current sky & calendar",
                    subtitle: "Planetary events, timing, and observation context",
                    glyph: .orbit,
                    accent: .humayAccentCelestial,
                    identifier: "explore.tool.current-sky"
                ) {
                    currentSkyDestination
                }

                Rectangle().fill(Color.humaySeparator).frame(height: 1)

                toolLink(
                    title: "Ask Humay",
                    subtitle: "Bring a personal question to available chart context",
                    glyph: .eye,
                    accent: .humayAccentPrestige,
                    identifier: "explore.tool.ask"
                ) {
                    AskView(
                        input: d5Input,
                        profileName: profileName,
                        openProfile: openProfile
                    )
                }

                Rectangle().fill(Color.humaySeparator).frame(height: 1)

                toolLink(
                    title: "Natal chart",
                    subtitle: "Placements, houses, aspects, and interpretation",
                    glyph: .crown,
                    accent: .humayAccentPrestige,
                    identifier: "explore.tool.chart"
                ) {
                    ChartView(
                        input: d4Input,
                        profileName: profileName,
                        openProfile: openProfile
                    )
                }
            }
        }
    }

    private func toolLink<Destination: View>(
        title: String,
        subtitle: String,
        glyph: HumayGlyphKind,
        accent: Color,
        identifier: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: HumaySpacing.large) {
                HumayGlyph(kind: glyph)
                    .frame(width: 36, height: 36)
                    .foregroundStyle(accent)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text(title)
                        .font(HumayTypography.bodyEmphasized)
                    Text(subtitle)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.humayTextSecondary)
                    .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, HumaySpacing.large)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private var disclosurePrinciple: some View {
        HumayHairlineSurface(style: .celestial) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                HumayEyebrow(text: "How Humay explains")
                Text("Meaning first. Mechanics when you want them.")
                    .font(HumayTypography.editorialTitle)
                    .fixedSize(horizontal: false, vertical: true)

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                        disclosureStep("01", title: "Human", detail: "Clear language about what you may feel or notice.")
                        disclosureStep("02", title: "Why", detail: "The chart area, timing, or connection behind it.")
                        disclosureStep("03", title: "Technical", detail: "Placements, aspects, degrees, reliability, and method.")
                    }

                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        disclosureStep("01", title: "Human", detail: "Clear language about what you may feel or notice.")
                        disclosureStep("02", title: "Why", detail: "The chart area, timing, or connection behind it.")
                        disclosureStep("03", title: "Technical", detail: "Placements, aspects, degrees, reliability, and method.")
                    }
                }
            }
        }
    }

    private func disclosureStep(_ number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Text(number)
                .font(HumayTypography.technicalSmall)
                .foregroundStyle(Color.humayAccentPrestige)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(title)
                    .font(HumayTypography.bodyEmphasized)
                Text(detail)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func destination(for destination: ExploreDestination) -> some View {
        switch destination {
        case .daily:
            DailyHoroscopeView(
                states: d2Input.dailyHoroscope,
                precisePreview: d2Input.preciseDailyPreview,
                source: d2Input.source
            )
        case .chart:
            ChartView(
                input: d4Input,
                profileName: profileName,
                openProfile: openProfile
            )
        case .currentSky:
            currentSkyDestination
        case .ask:
            AskView(
                input: d5Input,
                profileName: profileName,
                openProfile: openProfile
            )
        case .compatibility:
            CompatibilitySelectionView(
                people: d2Input.circle.people,
                state: d2Input.compatibility,
                precisePreview: d2Input.preciseCompatibilityPreview,
                source: d2Input.source
            )
        }
    }

    private var currentSkyDestination: some View {
        CurrentSkyView(
            state: d3Input.currentSky,
            source: d3Input.source,
            calendarMonth: d3Input.calendarMonth,
            calendarWeek: d3Input.calendarWeek,
            calendarToday: calendarToday,
            eventDetailState: d3Input.eventDetailState,
            profileName: profileName,
            openProfile: openProfile
        )
    }
}

private enum ExploreDestination: Sendable, Hashable {
    case daily
    case chart
    case currentSky
    case ask
    case compatibility
}

private enum ExploreTopic: String, CaseIterable, Identifiable {
    case love
    case career
    case money
    case health
    case personality
    case strengths
    case challenges
    case currentTiming
    case lifeThemes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .love: "Love & relationships"
        case .career: "Career"
        case .money: "Money"
        case .health: "Health"
        case .personality: "Personality"
        case .strengths: "Strengths"
        case .challenges: "Challenges"
        case .currentTiming: "Current timing"
        case .lifeThemes: "Major life themes"
        }
    }

    var subtitle: String {
        switch destination {
        case .daily: "Open your daily reading"
        case .chart: "Explore your natal chart"
        case .currentSky: "See the sky and upcoming events"
        case .ask: "Ask with available context"
        case .compatibility: "Compare a saved pair"
        }
    }

    var destination: ExploreDestination {
        switch self {
        case .love: .compatibility
        case .career, .money, .health: .daily
        case .personality, .strengths, .lifeThemes: .chart
        case .challenges: .ask
        case .currentTiming: .currentSky
        }
    }

    var glyph: HumayGlyphKind {
        switch self {
        case .love: .connection
        case .career: .feather
        case .money: .crown
        case .health: .orbit
        case .personality: .eye
        case .strengths: .crown
        case .challenges: .eclipse
        case .currentTiming: .orbit
        case .lifeThemes: .feather
        }
    }

    var accent: Color {
        switch self {
        case .love, .challenges: .humayAccentRoast
        case .career, .personality, .currentTiming: .humayAccentCelestial
        case .money, .strengths, .lifeThemes: .humayAccentPrestige
        case .health: .humaySage
        }
    }

    var accessibilityHint: String {
        switch destination {
        case .daily: "Opens Daily Horoscope"
        case .chart: "Opens Chart"
        case .currentSky: "Opens Current Sky"
        case .ask: "Opens Ask Humay"
        case .compatibility: "Opens Compatibility selection"
        }
    }
}
