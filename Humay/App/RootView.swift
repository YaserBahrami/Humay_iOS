import SwiftUI

/// Decides between onboarding and the application.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var router = AppRouter()

    var body: some View {
        Group {
            if environment.hasCompletedOnboarding {
                RootTabView()
                    .environment(router)
                    .transition(.opacity)
            } else {
                OnboardingFlowView()
                    .transition(.opacity)
            }
        }
        .animation(HumayMotion.turn, value: environment.hasCompletedOnboarding)
        .tint(HumayTheme.paper.colors.accentText)
    }
}

/// The five tabs.
///
/// Each holds its own `NavigationStack`. The tab bar is given an opaque Paper
/// appearance with a hairline top rule — the system default is translucent and rounded,
/// which reads as a different product than the one above it.
struct RootTabView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    var body: some View {
        @Bindable var router = router

        TabView(selection: tabSelection) {
            ForEach(HumayTab.allCases) { tab in
                NavigationStack(path: router.path(for: tab)) {
                    rootView(for: tab)
                        .navigationDestination(for: Route.self) { route in
                            destination(for: route)
                        }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.symbolName)
                }
                .tag(tab)
            }
        }
        .fullScreenCover(isPresented: $router.isShowingSettings) {
            SettingsCoverView()
        }
        .environment(\.openHumaySettings, SettingsOpener { page in router.openSettings(page) })
    }

    /// Routes selection through the router so that tapping the active tab pops it.
    private var tabSelection: Binding<HumayTab> {
        Binding(
            get: { router.selectedTab },
            set: { router.select($0) }
        )
    }

    @ViewBuilder
    private func rootView(for tab: HumayTab) -> some View {
        switch tab {
        case .today: TodayView()
        case .circle: CircleView()
        case .sky: SkyView()
        case .chart: ChartView()
        case .ask: AskView()
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .todayPrecise:
            TodayPreciseView()
        case .person(let id):
            PersonDetailView(personID: id)
        case .compatibility(let personID, let tier):
            CompatibilityView(personID: personID, tier: tier)
        case .quickCheck:
            QuickCheckView()
        case .skyEvent(let id):
            SkyEventDetailView(eventID: id)
        case .skyCalendar:
            SkyCalendarView()
        case .chartFull:
            ChartFullView()
        case .placement(let id, let system):
            PlacementDetailView(placementID: id, system: system)
        }
    }

}

#Preview {
    RootView()
        .environment(AppEnvironment.preview())
}
