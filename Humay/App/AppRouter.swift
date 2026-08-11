import Observation
import SwiftUI

/// Navigation state.
///
/// Each tab keeps its own stack, so moving between tabs never discards where someone
/// was. Re-selecting the current tab pops that one stack to its root and leaves the
/// other four untouched, which is the behaviour people expect from an iOS tab bar.
@Observable
@MainActor
final class AppRouter {
    var selectedTab: HumayTab = .today {
        didSet {
            // Re-selection is handled by `select(_:)`; this only guards against a
            // programmatic change leaving a stale cover open.
            if oldValue != selectedTab { settingsPath = [] }
        }
    }

    var todayPath: [Route] = []
    var circlePath: [Route] = []
    var skyPath: [Route] = []
    var chartPath: [Route] = []
    var askPath: [Route] = []

    var isShowingSettings = false
    var settingsPath: [SettingsPage] = []

    /// The binding a tab's `NavigationStack` uses.
    func path(for tab: HumayTab) -> Binding<[Route]> {
        switch tab {
        case .today: Binding(get: { self.todayPath }, set: { self.todayPath = $0 })
        case .circle: Binding(get: { self.circlePath }, set: { self.circlePath = $0 })
        case .sky: Binding(get: { self.skyPath }, set: { self.skyPath = $0 })
        case .chart: Binding(get: { self.chartPath }, set: { self.chartPath = $0 })
        case .ask: Binding(get: { self.askPath }, set: { self.askPath = $0 })
        }
    }

    /// Tab bar selection. Tapping the active tab returns it to its root.
    func select(_ tab: HumayTab) {
        guard tab != selectedTab else {
            popToRoot(tab)
            return
        }
        selectedTab = tab
    }

    func popToRoot(_ tab: HumayTab) {
        switch tab {
        case .today: todayPath.removeAll()
        case .circle: circlePath.removeAll()
        case .sky: skyPath.removeAll()
        case .chart: chartPath.removeAll()
        case .ask: askPath.removeAll()
        }
    }

    func push(_ route: Route, on tab: HumayTab) {
        switch tab {
        case .today: todayPath.append(route)
        case .circle: circlePath.append(route)
        case .sky: skyPath.append(route)
        case .chart: chartPath.append(route)
        case .ask: askPath.append(route)
        }
    }

    func openSettings(_ page: SettingsPage = .home) {
        settingsPath = page == .home ? [] : [page]
        isShowingSettings = true
    }

    func closeSettings() {
        isShowingSettings = false
        settingsPath = []
    }
}
