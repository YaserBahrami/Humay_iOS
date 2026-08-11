import Foundation

/// The five root destinations.
///
/// Calendar is deliberately absent: it lives inside Sky. Profile and settings are
/// absent too — they are a cover reached from the header, not a sixth tab.
enum HumayTab: String, CaseIterable, Identifiable, Hashable {
    case today, circle, sky, chart, ask

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .circle: "Circle"
        case .sky: "Sky"
        case .chart: "Chart"
        case .ask: "Ask"
        }
    }

    /// SF Symbol for the tab bar. Astrological glyphs are typographic marks and do not
    /// belong in a system tab bar, where they would not align or scale with the rest.
    var symbolName: String {
        switch self {
        case .today: "sun.max"
        case .circle: "circle.hexagongrid"
        case .sky: "moon.stars"
        case .chart: "circle.dotted"
        case .ask: "sparkle"
        }
    }
}

/// Everything reachable by pushing.
enum Route: Hashable {
    case todayPrecise
    case person(UUID)
    case compatibility(personID: UUID, tier: PrecisionTier)
    case quickCheck
    case skyEvent(String)
    case skyCalendar
    case chartFull
    case placement(id: String, system: ChartSystem)
}

/// Pages within the settings cover.
enum SettingsPage: Hashable {
    case home
    case birthDetails
    case tradition
    case tone
    case notifications
    case subscription
    case privacy
    case help
    case about
}
