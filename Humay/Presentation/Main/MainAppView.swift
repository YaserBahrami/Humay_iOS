import SwiftUI

/// Main shell for the entertainment-first IA:
/// Today (Cosmic Feed) · Chemistry · You · Sky.
struct MainAppView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    let skyInput: D3FeatureInput

    var body: some View {
        @Bindable var navigation = navigation

        TabView(selection: $navigation.mainDestination) {
            Tab(value: MainDestination.today) {
                NavigationStack {
                    CosmicFeedView()
                }
            } label: {
                Label("Today", systemImage: "sun.max")
            }

            Tab(value: MainDestination.chemistry) {
                NavigationStack {
                    ChemistryView()
                }
            } label: {
                Label("Chemistry", systemImage: "heart.text.square")
            }

            Tab(value: MainDestination.you) {
                NavigationStack {
                    YouView()
                }
            } label: {
                Label("You", systemImage: "person.crop.circle")
            }

            Tab(value: MainDestination.sky) {
                NavigationStack {
                    CurrentSkyView(
                        state: skyInput.currentSky,
                        source: skyInput.source,
                        calendarMonth: skyInput.calendarMonth,
                        calendarWeek: skyInput.calendarWeek,
                        calendarToday: calendarToday,
                        eventDetailState: skyInput.eventDetailState,
                        profileName: profileDisplayName,
                        openProfile: { navigation.auxiliaryRoute = .profileSettings }
                    )
                }
            } label: {
                Label("Sky", systemImage: "sparkles")
            }
        }
        .tint(Color.humayCoral)
        .sheet(item: $navigation.auxiliaryRoute) { route in
            switch route {
            case .profileSettings:
                ProfileSettingsSheet()
                    .environment(environment)
            }
        }
    }

    private var profileDisplayName: String {
        let persisted = environment.profile?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let persisted, !persisted.isEmpty {
            return persisted
        }
        return environment.people.first?.name ?? "Humay"
    }

    private var calendarToday: SkyCalendarDate? {
#if DEBUG
        if skyInput.source.isDevelopmentSample {
            return DevelopmentD3Sample.referenceToday
        }
#endif
        return nil
    }
}

/// Profile & settings sheet: facts, personality mode, honest precision note.
struct ProfileSettingsSheet: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss

    @State private var saveFailed = false

    var body: some View {
        @Bindable var environment = environment

        NavigationStack {
            Form {
                Section {
                    LabeledContent("Name", value: displayName)
                    if let profile = environment.profile {
                        LabeledContent("Birth date", value: profile.birth.dateFormatted())
                        LabeledContent("Birth time", value: birthTimeText(profile.birth.time))
                        LabeledContent("Birth place", value: profile.birth.place.name ?? "Not provided")
                    }
                } header: {
                    Text("Profile")
                } footer: {
                    Text("Humay keeps things honest: missing birth details stay missing.")
                }

                Section {
                    Picker("Mode", selection: $environment.settings.personalityMode) {
                        ForEach(PersonalityMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .onChange(of: environment.settings.personalityMode) { _, newMode in
                        Task { @MainActor in
                            do {
                                try await environment.setPersonalityMode(newMode)
                            } catch {
                                saveFailed = true
                            }
                        }
                    }
                    if let selected = PersonalityMode.allCases.first(where: { $0 == environment.settings.personalityMode }) {
                        Text(selected.tagline)
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                } header: {
                    Text("Humay's tone")
                } footer: {
                    Text("Changes how Humay talks. Never changes the underlying data.")
                }

                Section {
                    LabeledContent("Leading tradition", value: environment.settings.leadingTradition.shortName)
                } header: {
                    Text("Astrology")
                } footer: {
                    Text("Humay is entertainment, not advice. The stars have opinions; they are not experts.")
                }
            }
            .navigationTitle("You, technically")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Couldn't save that", isPresented: $saveFailed) {
                Button("OK", role: .cancel) { saveFailed = false }
            } message: {
                Text("Your change didn't stick. Check your connection and try again.")
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
