import SwiftUI

struct MainAppView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    let d2FeatureInput: D2FeatureInput
    let d3FeatureInput: D3FeatureInput

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
            .tabItem { Label("Today", systemImage: "sun.max") }
            .tag(MainDestination.today)

            MainTabRoot {
                NavigationStack {
                    CircleView(
                        state: d2FeatureInput.circle,
                        compatibilityState: d2FeatureInput.compatibility,
                        precisePreview: d2FeatureInput.preciseCompatibilityPreview,
                        source: d2FeatureInput.source,
                        profileName: profileName,
                        openProfile: openProfile
                    )
                }
            }
            .tabItem { Label("Circle", systemImage: "person.2") }
            .tag(MainDestination.circle)

            MainTabRoot {
                NavigationStack {
                    CurrentSkyView(
                        state: d3FeatureInput.currentSky,
                        source: d3FeatureInput.source,
                        calendarMonth: d3FeatureInput.calendarMonth,
                        calendarWeek: d3FeatureInput.calendarWeek,
                        calendarToday: calendarToday ?? SkyCalendarSupport.currentDate(),
                        profileName: profileName,
                        openProfile: openProfile
                    )
                }
            }
            .tabItem { Label("Sky", systemImage: "sparkles") }
            .tag(MainDestination.sky)

            MainTabRoot {
                NavigationStack {
                    MainDestinationPlaceholderView(
                        destination: .chart,
                        profileName: profileName,
                        openProfile: openProfile
                    )
                }
            }
            .tabItem { Label("Chart", systemImage: "circle.hexagongrid") }
            .tag(MainDestination.chart)

            MainTabRoot {
                NavigationStack {
                    MainDestinationPlaceholderView(
                        destination: .ask,
                        profileName: profileName,
                        openProfile: openProfile
                    )
                }
            }
            .tabItem { Label("Ask", systemImage: "bubble.left.and.text.bubble.right") }
            .tag(MainDestination.ask)
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(Color.humayCoral)
        .sheet(item: $navigation.auxiliaryRoute) { route in
            switch route {
            case .profileSettings:
                ProfileSettingsSummaryView()
                    .environment(environment)
            }
        }
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
        navigation.auxiliaryRoute = .profileSettings
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

private struct ProfileSettingsSummaryView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    LabeledContent("Name", value: displayName)
                    if let profile = environment.profile {
                        LabeledContent("Birth date", value: profile.birth.dateFormatted())
                        LabeledContent("Birth time", value: birthTimeText(profile.birth.time))
                        LabeledContent("Birth place", value: profile.birth.place.name ?? "Not provided")
                    }
                }

                Section("About your details") {
                    Text("Birth time and place can stay unknown. Humay only uses them when a feature genuinely needs more precision.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.humayGround)
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var displayName: String {
        let name = environment.profile?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return name.isEmpty ? "Not provided" : name
    }

    private func birthTimeText(_ birthTime: BirthTime) -> String {
        switch birthTime {
        case .unknown: "Unknown"
        case .exact: birthTime.formatted() ?? "Exact time"
        case .approximate: birthTime.formatted() ?? "Approximate time"
        }
    }
}
