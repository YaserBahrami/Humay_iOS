import SwiftUI

struct MainAppView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    let d2FeatureInput: D2FeatureInput
    let d3FeatureInput: D3FeatureInput
    let d4FeatureInput: D4FeatureInput
    let d5FeatureInput: D5FeatureInput

    var body: some View {
        @Bindable var navigation = navigation

        TabView(selection: $navigation.mainDestination) {
            MainTabRoot {
                NavigationStack {
                    TodayView(
                        state: d2FeatureInput.today,
                        dailyStates: d2FeatureInput.dailyHoroscope,
                        precisePreview: d2FeatureInput.preciseDailyPreview,
                        source: d2FeatureInput.source,
                        profileName: profileName,
                        openProfile: openProfile
                    )
                }
            }
            .tabItem { Label("Today", systemImage: "sun.horizon") }
            .tag(MainDestination.today)

            MainTabRoot {
                NavigationStack {
                    chartRoot
                }
            }
            .tabItem { Label("Chart", systemImage: "circle.grid.cross") }
            .tag(MainDestination.chart)

            MainTabRoot {
                NavigationStack {
                    exploreRoot
                }
            }
            .tabItem { Label("Explore", systemImage: "safari") }
            .tag(MainDestination.explore)

            MainTabRoot {
                NavigationStack {
                    connectionsRoot
                }
            }
            .tabItem { Label("Connections", systemImage: "person.2") }
            .tag(MainDestination.connections)

            MainTabRoot {
                NavigationStack {
                    YouView(
                        people: d2FeatureInput.circle.people,
                        profileName: profileName
                    )
                }
            }
            .tabItem { Label("You", systemImage: "person.crop.circle") }
            .tag(MainDestination.you)
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(Color.humayAccentPrestige)
    }

    @ViewBuilder
    private var exploreRoot: some View {
#if DEBUG
        if d5FeatureInput.source.isDevelopmentSample,
           d5FeatureInput.state != .empty {
            AskView(
                input: d5FeatureInput,
                profileName: profileName,
                openProfile: openProfile
            )
        } else {
            exploreHub
        }
#else
        exploreHub
#endif
    }

    @ViewBuilder
    private var chartRoot: some View {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-HumayPlacementDetailDemo"),
           let western = d4FeatureInput.chart.payload?.western,
           let moon = western.placement(for: .moon) {
            ChartPlacementDetailView(
                placement: moon,
                basis: western.basis,
                source: d4FeatureInput.source
            )
        } else if ProcessInfo.processInfo.arguments.contains("-HumayWesternChartDemo"),
                  let western = d4FeatureInput.chart.payload?.western {
            WesternChartView(model: western, source: d4FeatureInput.source)
        } else {
            chartHub
        }
#else
        chartHub
#endif
    }

    private var chartHub: some View {
        ChartView(
            input: d4FeatureInput,
            profileName: profileName,
            openProfile: openProfile
        )
    }

    @ViewBuilder
    private var connectionsRoot: some View {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-HumayCompatibilityDemo") {
            CompatibilityView(
                state: d2FeatureInput.compatibility,
                precisePreview: d2FeatureInput.preciseCompatibilityPreview,
                source: d2FeatureInput.source
            )
        } else {
            connectionsHub
        }
#else
        connectionsHub
#endif
    }

    private var connectionsHub: some View {
        CircleView(
            state: d2FeatureInput.circle,
            compatibilityState: d2FeatureInput.compatibility,
            precisePreview: d2FeatureInput.preciseCompatibilityPreview,
            source: d2FeatureInput.source,
            profileName: profileName,
            openProfile: openProfile
        )
    }

    private var exploreHub: some View {
        ExploreView(
            d2Input: d2FeatureInput,
            d3Input: d3FeatureInput,
            d4Input: d4FeatureInput,
            d5Input: d5FeatureInput,
            calendarToday: calendarToday ?? SkyCalendarSupport.currentDate(),
            profileName: profileName,
            openProfile: openProfile
        )
    }

    private var profileName: String {
        let persistedName = environment.profile?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let persistedName, !persistedName.isEmpty {
            return persistedName
        }
        return d2FeatureInput.circle.people.first?.name ?? "Humay"
    }

    private func openProfile() {
        navigation.auxiliaryRoute = nil
        navigation.mainDestination = .you
    }

    private var calendarToday: SkyCalendarDate? {
#if DEBUG
        if d3FeatureInput.source.isDevelopmentSample {
            return DevelopmentD3Sample.referenceToday
        }
#endif
        return nil
    }
}

private struct MainTabRoot<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: HumayMetrics.rootTabContentBreathingRoom)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
    }
}
