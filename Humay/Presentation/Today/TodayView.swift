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
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    D2WordmarkHeader(
                        title: nil,
                        profileName: profileName,
                        profileAction: openProfile
                    )

                    stateContent(availableWidth: proxy.size.width)
                }
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.top, HumaySpacing.large)
                .padding(.bottom, HumaySpacing.extraExtraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
        .alert("Roast Mode preview", isPresented: $showRoastInfo) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("Roast changes expression only. Real tone switching arrives with its owning feature work.")
        }
    }

    @ViewBuilder
    private func stateContent(availableWidth: CGFloat) -> some View {
        switch state {
        case .loading:
            loadingState

        case .loaded(let content):
            loadedContent(content, availableWidth: availableWidth)

        case .cached(let content, let savedAt):
            D2StatusBanner(
                symbol: "clock.arrow.circlepath",
                title: "Reopened from cache",
                detail: "Saved \(savedAt.formatted(date: .abbreviated, time: .shortened)).",
                accent: .sage
            )
            loadedContent(content, availableWidth: availableWidth)

        case .offline(let cached):
            D2StatusBanner(
                symbol: "wifi.slash",
                title: "Offline",
                detail: cached == nil
                    ? "No saved Today content is available."
                    : "Showing saved development content while offline.",
                accent: .gold
            )
            if let cached {
                loadedContent(cached, availableWidth: availableWidth)
            } else {
                D2UnavailableState(
                    symbol: "moon.zzz",
                    title: "Today is unavailable",
                    detail: "Reconnect to open a current reading. No precision request will be started as a fallback."
                )
            }

        case .failed(let message):
            D2UnavailableState(
                symbol: "sparkles",
                title: "Today needs a moment",
                detail: message
            )
        }
    }

    @ViewBuilder
    private func loadedContent(_ content: TodayContent, availableWidth: CGFloat) -> some View {
        if availableWidth >= 820 {
            HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    greeting(content)
                    cosmicInsight(content)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    highlights(content)
                    roastCard(content)
                    D2SampleNotice(source: source)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        } else {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                greeting(content)
                cosmicInsight(content)
                highlights(content)
                roastCard(content)
                D2SampleNotice(source: source)
            }
        }
    }

    private func greeting(_ content: TodayContent) -> some View {
        HStack(alignment: .center, spacing: HumaySpacing.small) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text(content.greeting)
                    .font(HumayTypography.editorialTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(content.introduction)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            CelestialCoffeeArt()
                .frame(maxWidth: 132)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("today.greeting")
    }

    private func cosmicInsight(_ content: TodayContent) -> some View {
        NavigationLink {
            DailyHoroscopeView(
                states: dailyStates,
                precisePreview: precisePreview,
                source: source
            )
        } label: {
            HumayCosmicSurface(padding: HumaySpacing.large) {
                HStack(spacing: HumaySpacing.large) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("Cosmic Weather")
                            .font(HumayTypography.utility)
                            .textCase(.uppercase)
                            .tracking(1.1)
                            .foregroundStyle(Color.humayLavender)

                        Text(content.cosmicInsight)
                            .font(HumayTypography.onboardingCardTitle)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    OrbitPlanetArt(compact: true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cosmic Weather. \(content.cosmicInsight)")
        .accessibilityHint("Opens Daily Horoscope")
        .accessibilityIdentifier("today.daily.open")
    }

    private func highlights(_ content: TodayContent) -> some View {
        HumaySurface(padding: 0) {
            VStack(spacing: 0) {
                ForEach(Array(content.highlights.enumerated()), id: \.element.id) { index, highlight in
                    NavigationLink {
                        DailyHoroscopeView(
                            states: dailyStates,
                            precisePreview: precisePreview,
                            source: source
                        )
                    } label: {
                        HStack(alignment: .center, spacing: HumaySpacing.large) {
                            HumayCategoryIcon(
                                symbol: highlight.category.symbol,
                                accent: highlight.category.accent
                            )

                            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                                Text(highlight.category.displayName)
                                    .font(HumayTypography.bodyEmphasized)
                                Text(highlight.text)
                                    .font(HumayTypography.supporting)
                                    .foregroundStyle(Color.humayTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.humayTextSecondary)
                                .frame(width: 44, height: 44)
                                .accessibilityHidden(true)
                        }
                        .padding(.horizontal, HumaySpacing.large)
                        .padding(.vertical, HumaySpacing.medium)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens Daily Horoscope")

                    if index < content.highlights.count - 1 {
                        Divider()
                            .overlay(Color.humayHairline)
                            .padding(.leading, 80)
                    }
                }
            }
        }
        .accessibilityIdentifier("today.highlights")
    }

    private func roastCard(_ content: TodayContent) -> some View {
        Button {
            showRoastInfo = true
        } label: {
            HStack(spacing: HumaySpacing.large) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text("Roast Mode")
                        .font(HumayTypography.utility)
                        .textCase(.uppercase)
                        .tracking(1.1)
                    Text(content.roastTitle)
                        .font(HumayTypography.cardTitle)
                    Text(content.roastBody)
                        .font(HumayTypography.supporting)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                RoastPlanetArt()

                Image(systemName: "arrow.right")
                    .frame(width: 44, height: 44)
                    .background(Color.humaySurface.opacity(0.28), in: Circle())
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Color.humayTextPrimary)
            .padding(HumaySpacing.extraLarge)
            .background(
                LinearGradient(
                    colors: [
                        Color.humayCoral.opacity(0.66),
                        Color.humaySolarGold.opacity(0.28)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: HumayRadius.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface)
                    .stroke(Color.humayCoral.opacity(0.42))
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Explains the development Roast Mode preview")
        .accessibilityIdentifier("today.roast")
    }

    private var loadingState: some View {
        HumaySurface(level: .raised) {
            VStack(spacing: HumaySpacing.extraLarge) {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.humayLavender)
                Text("Reading today’s sky…")
                    .font(HumayTypography.cardTitle)
                Text("Development loading state. No request is being made.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HumaySpacing.extraExtraLarge)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading Today")
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
