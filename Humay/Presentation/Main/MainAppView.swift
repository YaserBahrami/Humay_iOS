import SwiftUI

struct MainAppView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    let featureInput: D2FeatureInput

    var body: some View {
        @Bindable var navigation = navigation

        TabView(selection: $navigation.mainDestination) {
            NavigationStack {
                TodayView(
                    state: featureInput.today,
                    dailyStates: featureInput.dailyHoroscope,
                    precisePreview: featureInput.preciseDailyPreview,
                    source: featureInput.source,
                    profileName: profileName,
                    openProfile: openProfile
                )
            }
            .tabItem { Label("Today", systemImage: "sun.max") }
            .tag(MainDestination.today)

            NavigationStack {
                CircleView(
                    state: featureInput.circle,
                    compatibilityState: featureInput.compatibility,
                    precisePreview: featureInput.preciseCompatibilityPreview,
                    source: featureInput.source,
                    profileName: profileName,
                    openProfile: openProfile
                )
            }
            .tabItem { Label("Circle", systemImage: "person.2") }
            .tag(MainDestination.circle)

            NavigationStack {
                MainDestinationPlaceholderView(
                    destination: .sky,
                    profileName: profileName,
                    openProfile: openProfile
                )
            }
            .tabItem { Label("Sky", systemImage: "sparkles") }
            .tag(MainDestination.sky)

            NavigationStack {
                MainDestinationPlaceholderView(
                    destination: .chart,
                    profileName: profileName,
                    openProfile: openProfile
                )
            }
            .tabItem { Label("Chart", systemImage: "circle.hexagongrid") }
            .tag(MainDestination.chart)

            NavigationStack {
                MainDestinationPlaceholderView(
                    destination: .ask,
                    profileName: profileName,
                    openProfile: openProfile
                )
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
        return featureInput.circle.people.first?.name ?? "Humay"
    }

    private func openProfile() {
        navigation.auxiliaryRoute = .profileSettings
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
