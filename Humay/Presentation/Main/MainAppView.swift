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
    @Environment(ForecastStore.self) private var forecastStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.birthPlaceSearching) private var birthPlaceSearchService

    @State private var saveFailed = false
    @State private var exportWrapper: IdentifiableURL?
    @State private var exportError = false
    @State private var showBirthDetails = false
    @State private var birthDetailsSaving = false
    @State private var birthDetailsDraft: BirthDetailsDraftState?

    private struct IdentifiableURL: Identifiable {
        let url: URL
        var id: String { url.absoluteString }
    }

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
                        if missingBirthDetails(profile.birth) {
                            Label("Add birth time and place for your full Big Three.", systemImage: "sparkles")
                                .font(HumayTypography.caption)
                                .foregroundStyle(Color.humayLavender)
                        }
                    }
                    Button {
                        guard let profile = environment.profile else { return }
                        birthDetailsDraft = BirthDetailsDraftState(birth: profile.birth)
                        showBirthDetails = true
                    } label: {
                        Label("Birth Details", systemImage: "pencil")
                    }
                    .disabled(environment.profile == nil)
                    .accessibilityIdentifier("profile.birthDetails.edit")
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

#if DEBUG
                Section {
                    Button {
                        guard let profile = environment.profile else { return }
                        Task { @MainActor in
                            do {
                                let url = try await forecastStore.exportFileURL(for: profile.forecastSubject)
                                exportWrapper = IdentifiableURL(url: url)
                            } catch {
                                exportError = true
                            }
                        }
                    } label: {
                        Label("Export forecast JSON", systemImage: "square.and.arrow.up")
                    }
                    .disabled(environment.profile == nil)
                    .accessibilityIdentifier("profile.export.forecast")
                } header: {
                    Text("Debug")
                } footer: {
                    Text("Writes the normalized forecast to a shareable JSON file for QA and prompt debugging. Debug builds only.")
                }
#endif
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
            .sheet(item: $exportWrapper) { wrapper in
                ShareLink(item: wrapper.url) {
                    Label("Share forecast JSON", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .presentationDetents([.medium])
            }
            .alert("Nothing to export yet", isPresented: $exportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Generate a forecast first — open Today or You to trigger generation.")
            }
            .navigationDestination(isPresented: $showBirthDetails) {
                if let draft = birthDetailsDraft {
                    BirthDetailsEditorView(
                        draft: draft,
                        searchService: birthPlaceSearchService,
                        onSave: {
                            Task { @MainActor in
                                guard let profile = environment.profile else { return }
                                let newBirth = draft.currentBirthDetails
                                if let err = draft.validationError {
                                    saveFailed = true
                                    return
                                }
                                birthDetailsSaving = true
                                do {
                                    let hadChange = try await environment.updateBirthDetails(newBirth)
                                    if hadChange {
                                        await forecastStore.invalidateForBirthChange(subject: profile.forecastSubject)
                                        // Recalculate immediately: ensure forecast uses new identity
                                        forecastStore.ensureForecast(for: ForecastSubject(id: profile.id, name: profile.displayName, birth: newBirth))
                                    } else {
                                        // Even display-name-only place change still persisted but no invalidation
                                    }
                                    showBirthDetails = false
                                } catch {
                                    saveFailed = true
                                }
                                birthDetailsSaving = false
                            }
                        },
                        onCancel: { showBirthDetails = false }
                    )
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func missingBirthDetails(_ birth: BirthDetails) -> Bool {
        if case .unknown = birth.time { return true }
        if case .notProvided = birth.place { return true }
        return false
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
