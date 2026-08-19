import SwiftUI

struct TodayView: View {
    let state: TodayFeatureState
    let dailyStates: [HoroscopePeriod: DailyHoroscopeFeatureState]
    let precisePreview: DailyHoroscopeContent?
    let source: D2ContentSource
    let profileName: String
    let openProfile: () -> Void

    @State private var showRoastInfo = false

    var body: some View {
        HumayPage(maximum: .immersive) {
            HumayScreenHeader(
                section: "Today",
                profileName: profileName,
                profileAction: openProfile,
                wordmarkIdentifier: "main.today.wordmark"
            )

            stateContent
        }
        .navigationBarHidden(true)
        .alert("Roast Mode preview", isPresented: $showRoastInfo) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("Roast changes expression only. It never changes the astrology facts beneath a reading.")
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .loading:
            TodayLoadingView()

        case .loaded(let content):
            loadedContent(content)

        case .cached(let content, let savedAt):
            D2StatusBanner(
                symbol: "clock.arrow.circlepath",
                title: "Reopened from cache",
                detail: "Saved \(savedAt.formatted(date: .abbreviated, time: .shortened)).",
                accent: .sage
            )
            loadedContent(content)

        case .offline(let cached):
            D2StatusBanner(
                symbol: "wifi.slash",
                title: "Offline",
                detail: cached == nil
                    ? "No saved Today content is available."
                    : "Showing saved content while offline.",
                accent: .gold
            )
            if let cached {
                loadedContent(cached)
            } else {
                HumayStateView(
                    title: "Today is unavailable",
                    message: "Reconnect to open a current reading.",
                    glyph: .eclipse
                )
            }

        case .failed(let message):
            HumayStateView(
                title: "Today needs a moment",
                message: message,
                glyph: .orbit
            )
        }
    }

    private func loadedContent(_ content: TodayContent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.section) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: HumaySpacing.hero) {
                    greeting(content)
                        .frame(minWidth: 320, maxWidth: 440, alignment: .leading)
                    cosmicWeather(content)
                        .frame(minWidth: 420, maxWidth: .infinity)
                }

                VStack(alignment: .leading, spacing: HumaySpacing.extraExtraLarge) {
                    greeting(content)
                    cosmicWeather(content)
                }
            }

            themes(content)
            importantInsight(content)
            timingAndBasis
            roastMoment(content)
        }
    }

    private func greeting(_ content: TodayContent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "Your day, in focus", color: .humayAccentCelestial)

            Text(content.greeting)
                .font(HumayTypography.displayTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(content.introduction)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 420, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("today.greeting")
    }

    private func cosmicWeather(_ content: TodayContent) -> some View {
        NavigationLink {
            DailyHoroscopeView(
                states: dailyStates,
                precisePreview: precisePreview,
                source: source
            )
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
                        cosmicWeatherCopy(content)
                        Spacer(minLength: 0)
                        HumayCelestialStage(compact: true)
                            .frame(width: 190, height: 190)
                    }

                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        cosmicWeatherCopy(content)
                        HumayCelestialStage(compact: true)
                            .frame(maxWidth: .infinity)
                            .frame(height: 190)
                    }
                }

                HStack(spacing: HumaySpacing.small) {
                    Text("Read your full day")
                        .font(HumayTypography.control)
                    Spacer(minLength: HumaySpacing.small)
                    Image(systemName: "arrow.right")
                        .accessibilityHidden(true)
                }
                .padding(.top, HumaySpacing.large)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.humaySeparator)
                        .frame(height: 1)
                }
            }
            .padding(.vertical, HumaySpacing.extraLarge)
            .padding(.horizontal, HumaySpacing.extraLarge)
            .foregroundStyle(Color.humayTextPrimary)
            .background(cosmicBackground)
            .overlay(alignment: .top) {
                Rectangle().fill(Color.humayAccentCelestial.opacity(0.52)).frame(height: 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(Color.humayAccentPrestige.opacity(0.55)).frame(height: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Your Cosmic Weather. \(humanHeadline(for: content))")
        .accessibilityHint("Opens your full daily reading")
        .accessibilityIdentifier("today.daily.open")
    }

    private func cosmicWeatherCopy(_ content: TodayContent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HumayEyebrow(text: "Your Cosmic Weather")

            Text(humanHeadline(for: content))
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)

            Text(content.cosmicInsight)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 420, alignment: .leading)
    }

    private var cosmicBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.humayAccentCelestial.opacity(0.08),
                Color.humaySurface.opacity(0.76),
                Color.humayAccentPrestige.opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func themes(_ content: TodayContent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumaySectionHeader(
                title: "The themes moving through today",
                subtitle: "Start with what matters. Technical context waits deeper in the reading."
            )

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 230), spacing: HumaySpacing.large)],
                spacing: HumaySpacing.large
            ) {
                ForEach(DailyReadingCategory.allCases) { category in
                    themeLink(category, content: content)
                }
            }
        }
        .accessibilityIdentifier("today.highlights")
    }

    private func themeLink(_ category: DailyReadingCategory, content: TodayContent) -> some View {
        let highlight = content.highlights.first { $0.category == category }

        return NavigationLink {
            DailyHoroscopeView(
                states: dailyStates,
                precisePreview: precisePreview,
                source: source
            )
        } label: {
            HStack(alignment: .top, spacing: HumaySpacing.large) {
                HumayGlyph(kind: category.glyphKind)
                    .frame(width: 34, height: 34)
                    .foregroundStyle(category.premiumAccent)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text(category.displayName)
                        .font(HumayTypography.bodyEmphasized)
                    Text(highlight?.text ?? "Open your full daily reading.")
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
            .overlay(alignment: .bottom) {
                Rectangle().fill(Color.humaySeparator).frame(height: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens your daily reading")
    }

    private func importantInsight(_ content: TodayContent) -> some View {
        HumayHairlineSurface(style: .raised, padding: HumaySpacing.extraLarge) {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                HStack(alignment: .top, spacing: HumaySpacing.large) {
                    HumayGlyph(kind: .feather)
                        .frame(width: 42, height: 42)
                        .foregroundStyle(Color.humayAccentPrestige)

                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        HumayEyebrow(text: "One thing to carry")
                        Text(todayReading?.headline ?? content.cosmicInsight)
                            .font(HumayTypography.narrativeSectionTitle)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let reading = todayReading {
                    Text(reading.body)
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Rectangle()
                        .fill(Color.humaySeparator)
                        .frame(height: 1)

                    HumayDisclosureGroup(
                        eyebrow: "Level 2",
                        title: "Why this appears",
                        summary: basisSummary(for: reading)
                    ) {
                        Text("Humay keeps the interpretation separate from its basis. This reading uses the source shown below; no hidden birth time or transit is inferred.")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }

                    Rectangle()
                        .fill(Color.humaySeparator)
                        .frame(height: 1)

                    HumayDisclosureGroup(
                        eyebrow: "Level 3",
                        title: "Astrology details",
                        summary: "Inspect the reading basis and available facts."
                    ) {
                        VStack(spacing: HumaySpacing.small) {
                            HumayFactRow(label: "Period", value: reading.period.displayName)
                            HumayFactRow(label: "Sign", value: reading.sign.displayName)
                            HumayFactRow(label: "Basis", value: basisLabel(for: reading))
                            HumayFactRow(
                                label: "Source",
                                value: source.isDevelopmentSample
                                    ? "Development sample · not calculated"
                                    : "Production content"
                            )
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("today.important-insight")
    }

    private var timingAndBasis: some View {
        NavigationLink {
            DailyHoroscopeView(
                states: dailyStates,
                precisePreview: precisePreview,
                source: source
            )
        } label: {
            HStack(spacing: HumaySpacing.large) {
                HumayGlyph(kind: .orbit)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(Color.humayAccentCelestial)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text("Timing & reading basis")
                        .font(HumayTypography.bodyEmphasized)
                    Text("Today, tomorrow, this week, and available source details")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .foregroundStyle(Color.humayAccentPrestige)
                    .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, HumaySpacing.large)
            .overlay(alignment: .top) { Rectangle().fill(Color.humaySeparator).frame(height: 1) }
            .overlay(alignment: .bottom) { Rectangle().fill(Color.humaySeparator).frame(height: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func roastMoment(_ content: TodayContent) -> some View {
        Button {
            showRoastInfo = true
        } label: {
            HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    HumayEyebrow(text: "Roast Mode", color: .humayAccentRoast)
                    Text(content.roastTitle)
                        .font(HumayTypography.editorialTitle)
                    Text(content.roastBody)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HumayGlyph(kind: .eye)
                    .frame(width: 58, height: 58)
                    .foregroundStyle(Color.humayAccentRoast)

                Image(systemName: "arrow.up.right")
                    .foregroundStyle(Color.humayAccentRoast)
                    .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, HumaySpacing.extraLarge)
            .padding(.horizontal, HumaySpacing.large)
            .background(Color.humayAccentRoast.opacity(0.07))
            .overlay(alignment: .leading) {
                Rectangle().fill(Color.humayAccentRoast).frame(width: 2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Explains Roast Mode")
        .accessibilityIdentifier("today.roast")
    }

    private var todayReading: DailyHoroscopeContent? {
        guard let state = dailyStates[.today] else { return nil }
        switch state {
        case .free(let reading),
             .preciseLocked(let reading),
             .preciseLoaded(let reading),
             .cached(let reading, _):
            return reading
        case .offline(let reading):
            return reading
        case .loading, .failed:
            return nil
        }
    }

    private func humanHeadline(for content: TodayContent) -> String {
        todayReading?.headline ?? content.cosmicInsight
    }

    private func basisSummary(for reading: DailyHoroscopeContent) -> String {
        switch reading.basis {
        case .freeWesternSunSign(let sign):
            "A coarse \(sign.displayName) Sun-sign reading, not a natal transit interpretation."
        case .precisePersonalized:
            "A personalized reading whose calculation facts remain separate from interpretation."
        }
    }

    private func basisLabel(for reading: DailyHoroscopeContent) -> String {
        switch reading.basis {
        case .freeWesternSunSign(let sign):
            "Free Western · \(sign.displayName) Sun"
        case .precisePersonalized:
            "Precise personalized"
        }
    }
}

private struct TodayLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var visible = false

    var body: some View {
        HumayHairlineSurface(style: .raised) {
            VStack(spacing: HumaySpacing.extraLarge) {
                HumayCelestialStage(compact: true)
                    .frame(width: 150, height: 150)
                    .opacity(visible || reduceMotion ? 1 : 0.45)

                Text("Reading today’s sky…")
                    .font(HumayTypography.editorialTitle)

                Text("Preparing your day.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HumaySpacing.section)
        }
        .onAppear {
            withAnimation(HumayMotion.reveal(reduceMotion: reduceMotion)) {
                visible = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading Today")
    }
}

private extension DailyReadingCategory {
    var glyphKind: HumayGlyphKind {
        switch self {
        case .love: .connection
        case .career: .feather
        case .money: .crown
        case .health: .orbit
        }
    }

    var premiumAccent: Color {
        switch self {
        case .love: .humayAccentRoast
        case .career: .humayAccentCelestial
        case .money: .humayAccentPrestige
        case .health: .humaySage
        }
    }
}

extension DailyReadingCategory {
    var symbol: String {
        switch self {
        case .love: "heart.fill"
        case .career: "briefcase.fill"
        case .money: "dollarsign"
        case .health: "cross.case.fill"
        }
    }

    var accent: HumayAccent {
        switch self {
        case .love: .coral
        case .career: .lavender
        case .money: .gold
        case .health: .sage
        }
    }
}
