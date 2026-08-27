import SwiftUI

// MARK: - Draft state (reusable for current user and connections §30)

@Observable
@MainActor
final class BirthDetailsDraftState {
    var year: Int
    var month: Int
    var day: Int

    var timeKind: OnboardingTimeKind
    var timePickerDate: Date
    var toleranceMinutes: Int
    var birthPlaceResult: BirthPlaceSearchResult?

    private let calendar: Calendar
    private let original: BirthDetails

    init(birth: BirthDetails, calendar: Calendar = .autoupdatingCurrent) {
        var g = Calendar(identifier: .gregorian)
        g.timeZone = calendar.timeZone
        g.locale = calendar.locale
        self.calendar = g
        self.original = birth
        self.year = birth.year
        self.month = birth.month
        self.day = birth.day
        switch birth.time {
        case .exact(let m):
            timeKind = .exact
            toleranceMinutes = 30
            let h = m / 60; let min = m % 60
            timePickerDate = g.date(from: DateComponents(hour: h, minute: min)) ?? Date()
        case .approximate(let m, let tol):
            timeKind = .approximate
            toleranceMinutes = tol
            let h = m / 60; let min = m % 60
            timePickerDate = g.date(from: DateComponents(hour: h, minute: min)) ?? Date()
        case .unknown:
            timeKind = .unknown
            toleranceMinutes = 30
            timePickerDate = g.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
        }
        if case .known(let name, let lat, let lon, let tz) = birth.place {
            birthPlaceResult = BirthPlaceSearchResult(id: "\(lat),\(lon)|\(tz)", displayName: name, secondaryLabel: nil, latitude: lat, longitude: lon, timeZoneIdentifier: tz)
        } else {
            birthPlaceResult = nil
        }
    }

    var datePickerDate: Date {
        get {
            calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
        }
        set {
            let comps = calendar.dateComponents([.year, .month, .day], from: newValue)
            if let y = comps.year, let m = comps.month, let d = comps.day {
                year = y; month = m; day = d
            }
        }
    }

    var earliestDate: Date {
        calendar.date(from: DateComponents(year: 1900, month: 1, day: 1))!
    }

    var latestDate: Date {
        let now = Date.now
        let comps = calendar.dateComponents([.year, .month, .day], from: now)
        return calendar.date(from: comps) ?? now
    }

    var currentBirthDetails: BirthDetails {
        let comps = calendar.dateComponents([.hour, .minute], from: timePickerDate)
        let minutes = (comps.hour ?? 12) * 60 + (comps.minute ?? 0)
        let time: BirthTime
        switch timeKind {
        case .exact: time = .exact(minutesFromMidnight: max(0, min(1439, minutes)))
        case .approximate: time = .approximate(minutesFromMidnight: max(0, min(1439, minutes)), toleranceMinutes: toleranceMinutes)
        case .unknown: time = .unknown
        }
        let place: BirthPlace
        if let r = birthPlaceResult {
            place = .known(name: r.displayName, latitude: r.latitude, longitude: r.longitude, timeZoneIdentifier: r.timeZoneIdentifier)
        } else {
            place = .notProvided
        }
        return BirthDetails(year: year, month: month, day: day, time: time, place: place)
    }

    var hasSemanticChange: Bool {
        BirthDetailsSemanticChange.hasSemanticChange(from: original, to: currentBirthDetails)
    }

    func reset() {
        let fresh = BirthDetailsDraftState(birth: original)
        year = fresh.year; month = fresh.month; day = fresh.day
        timeKind = fresh.timeKind; timePickerDate = fresh.timePickerDate; toleranceMinutes = fresh.toleranceMinutes
        birthPlaceResult = fresh.birthPlaceResult
    }

    var validationError: String? {
        let b = currentBirthDetails
        guard let date = calendar.date(from: DateComponents(year: b.year, month: b.month, day: b.day)) else { return "Invalid date." }
        if date < earliestDate || date > latestDate { return "Choose a date between 1900 and today." }
        switch b.time {
        case .exact(let m): if !(0...1439).contains(m) { return "Invalid time." }
        case .approximate(let m, let t): if !(0...1439).contains(m) || t <= 0 { return "Invalid approximate time." }
        case .unknown: break
        }
        if case .known(let name, let lat, let lon, let tz) = b.place {
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Place name required." }
            if !(-90...90).contains(lat) || !(-180...180).contains(lon) { return "Invalid coordinates." }
            if TimeZone(identifier: tz) == nil { return "Invalid timezone for that place. Re-select it." }
        }
        return nil
    }
}

enum BirthDetailsSemanticChange {
    static func hasSemanticChange(from old: BirthDetails, to new: BirthDetails) -> Bool {
        if old.year != new.year || old.month != new.month || old.day != new.day { return true }
        if old.time != new.time { return true }
        switch (old.place, new.place) {
        case (.notProvided, .notProvided): return false
        case (.notProvided, .known), (.known, .notProvided): return true
        case (.known(_, let olat, let olon, let otz), .known(_, let nlat, let nlon, let ntz)):
            let rOlat = (olat * 100).rounded() / 100
            let rOlon = (olon * 100).rounded() / 100
            let rNlat = (nlat * 100).rounded() / 100
            let rNlon = (nlon * 100).rounded() / 100
            if rOlat != rNlat || rOlon != rNlon || otz != ntz { return true }
            return false
        }
    }
}

// MARK: - Editor View

struct BirthDetailsEditorView: View {
    @Bindable var draft: BirthDetailsDraftState
    var searchService: any BirthPlaceSearching
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var query: String = ""
    @State private var suggestions: [BirthPlaceSuggestion] = []
    @State private var isSearching = false
    @State private var isResolving = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    @State private var hasSearched = false
    @State private var generation: Int = 0

    var body: some View {
        Form {
            dateSection
            timeSection
            placeSection
            if let bt = BigThreeSyncHelper.compute(birth: draft.currentBirthDetails) {
                Section {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("Preview — honest Big Three").font(HumayTypography.utility).foregroundStyle(Color.humayTextSecondary)
                        previewRow(label: "Sun", availability: bt.sun)
                        previewRow(label: "Moon", availability: bt.moon)
                        previewRow(label: "Rising", availability: bt.rising)
                    }
                    .accessibilityIdentifier("birthDetails.preview")
                }
            }
            if let err = draft.validationError {
                Section { Text(err).font(HumayTypography.caption).foregroundStyle(.red) }
            }
        }
        .navigationTitle("Birth Details")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: onCancel) }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { onSave() }.disabled(draft.validationError != nil)
                    .accessibilityIdentifier("birthDetails.save")
            }
        }
        .onAppear {
            query = draft.birthPlaceResult?.displayName ?? ""
            suggestions = []
            hasSearched = false
        }
        .onChange(of: query) { _, newValue in
            debounce(query: newValue)
        }
        .onDisappear { searchTask?.cancel() }
    }

    // MARK: Sections

    private var dateSection: some View {
        Section {
            DatePicker("Birth date", selection: Binding(get: { draft.datePickerDate }, set: { draft.datePickerDate = $0 }), in: draft.earliestDate...draft.latestDate, displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 180)
                .clipped()
                .accessibilityIdentifier("birthDetails.datePicker")
            LabeledContent("Selected", value: draft.currentBirthDetails.dateFormatted())
        } header: { Text("Birth date") }
    }

    private var timeSection: some View {
        Section {
            Picker("Time kind", selection: $draft.timeKind) {
                Text("Exact").tag(OnboardingTimeKind.exact)
                Text("Approximate").tag(OnboardingTimeKind.approximate)
                Text("I don't know").tag(OnboardingTimeKind.unknown)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("birthDetails.timeKind")

            switch draft.timeKind {
            case .exact:
                DatePicker("Exact time", selection: $draft.timePickerDate, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 150)
                    .accessibilityIdentifier("birthDetails.exactPicker")
            case .approximate:
                DatePicker("Central time", selection: $draft.timePickerDate, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 150)
                Picker("Uncertainty", selection: $draft.toleranceMinutes) {
                    Text("±15 min").tag(15); Text("±30 min").tag(30); Text("±1 hour").tag(60)
                }
                .pickerStyle(.segmented)
                Text("Humay will only show a Rising or Moon sign when the full time range supports it.")
                    .font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary)
            case .unknown:
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("No birth time? That's fine.").font(HumayTypography.bodyEmphasized)
                    Text("We won't make one up.").font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary)
                }
            }
        } header: { Text("Birth time") }
    }

    private var placeSection: some View {
        Section {
            HStack(spacing: HumaySpacing.small) {
                Image(systemName: "magnifyingglass").foregroundStyle(Color.humayTextSecondary)
                TextField("Tehran, Iran · London, UK", text: $query)
                    .accessibilityIdentifier("birthDetails.placeField")
                if isSearching || isResolving { ProgressView() }
                if !query.isEmpty {
                    Button { query = ""; suggestions = []; hasSearched = false; generation &+= 1 } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(Color.humayTextSecondary) }
                }
            }
            .padding(HumaySpacing.small)
            .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: 8))
            .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(Color.humayHairline) }

            if let sel = draft.birthPlaceResult {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sel.displayName).font(HumayTypography.bodyEmphasized)
                    if let sec = sel.secondaryLabel { Text(sec).font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary) }
#if DEBUG
                    Text("\(sel.timeZoneIdentifier) · \(String(format: "%.2f, %.2f", sel.latitude, sel.longitude))").font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary)
                    Text("Source: resolved").font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary.opacity(0.6))
#endif
                }
                .accessibilityIdentifier("birthDetails.selectedPlace")
                Button("Clear place", role: .destructive) { draft.birthPlaceResult = nil; query = "" }
            }

            if isSearching {
                HStack { ProgressView(); Text("Searching…").font(HumayTypography.supporting) }
            } else if isResolving {
                HStack { ProgressView(); Text("Resolving…").font(HumayTypography.supporting) }
            } else if !suggestions.isEmpty {
                ForEach(suggestions) { s in
                    Button {
                        Task { await resolve(suggestion: s) }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(s.title).font(HumayTypography.bodyEmphasized).foregroundStyle(Color.humayTextPrimary)
                            if let sub = s.subtitle { Text(sub).font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary) }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("birthDetails.suggestion.\(s.id)")
                }
            } else if hasSearched {
                Text("No matching cities found.").font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary)
                    .accessibilityIdentifier("birthDetails.noResults")
            }

            if let msg = errorMessage {
                Text(msg).font(HumayTypography.caption).foregroundStyle(.red)
                    .accessibilityIdentifier("birthDetails.searchError")
            }

            Text("Search needs connectivity once. After saving, calculation stays offline.").font(HumayTypography.caption).foregroundStyle(Color.humayTextSecondary)
        } header: { Text("Birth place") }
        footer: { Text("Coordinates and IANA timezone determine the calculation. Display name is cosmetic.") }
    }

    @ViewBuilder
    private func previewRow(label: String, availability: AstrologyAvailability<BigThreePosition>) -> some View {
        HStack {
            Text(label).font(HumayTypography.caption.weight(.bold)).foregroundStyle(Color.humayTextSecondary)
            Spacer()
            switch availability {
            case .available(let pos): Text(pos.sign.displayName).font(HumayTypography.bodyEmphasized)
            case .ambiguous(let opts): Text(opts.map(\.sign.displayName).joined(separator: " or ")).font(HumayTypography.bodyEmphasized).foregroundStyle(Color.humayTextSecondary)
            case .unavailable: Text("—").foregroundStyle(Color.humayTextSecondary)
            }
        }
    }

    private func resolve(suggestion: BirthPlaceSuggestion) async {
        isResolving = true
        errorMessage = nil
        do {
            let result = try await searchService.resolve(suggestion)
            draft.birthPlaceResult = result
            query = result.displayName
            suggestions = []
            hasSearched = false
        } catch let e as BirthPlaceSearchError {
            switch e {
            case .networkUnavailable: errorMessage = "Couldn't search places right now. Check your connection and try again."
            case .missingTimeZone: errorMessage = "Humay couldn't resolve a timezone for that place. Try a nearby city."
            case .noResults: errorMessage = "No matching cities found."
            case .resolutionFailed: errorMessage = "Couldn't resolve that place. Try again."
            case .invalidQuery: errorMessage = nil
            }
        } catch {
            errorMessage = "Couldn't resolve that place. Try again."
        }
        isResolving = false
    }

    private func debounce(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if let sel = draft.birthPlaceResult, sel.displayName == trimmed {
            suggestions = []; hasSearched = false; isSearching = false; errorMessage = nil; return
        }
        // Editing away from selected display name clears selection but preserves it until new resolution?
        // We clear draft result so raw text cannot be persisted.
        if draft.birthPlaceResult != nil, draft.birthPlaceResult?.displayName != trimmed, !trimmed.isEmpty {
            // Don't erase immediately if user is still editing; instead clear only if they diverge significantly.
            // To avoid raw text persistence, clear birthPlaceResult when query no longer matches selection.
            draft.birthPlaceResult = nil
        }
        guard trimmed.count >= 2 else {
            suggestions = []; hasSearched = false; isSearching = false; errorMessage = nil; return
        }
        errorMessage = nil
        generation &+= 1
        let currentGen = generation
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled else { return }
            guard currentGen == generation else { return }
            isSearching = true; hasSearched = true
            do {
                let sugs = try await searchService.suggestions(for: trimmed)
                guard !Task.isCancelled else { return }
                guard currentGen == generation else { return }
                if query.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    if draft.birthPlaceResult != nil {
                        suggestions = []
                    } else {
                        suggestions = sugs
                    }
                    errorMessage = nil
                }
            } catch let e as BirthPlaceSearchError {
                guard !Task.isCancelled else { return }
                guard currentGen == generation else { return }
                if query.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    suggestions = []
                    switch e {
                    case .networkUnavailable: errorMessage = "Couldn't search places right now. Check your connection and try again."
                    case .missingTimeZone: errorMessage = "Humay couldn't resolve a timezone for that place. Try a nearby city."
                    case .noResults: errorMessage = nil
                    case .invalidQuery: errorMessage = nil
                    case .resolutionFailed: errorMessage = "Couldn't search places right now."
                    }
                }
            } catch {
                suggestions = []; errorMessage = "Couldn't search places right now."
            }
            isSearching = false
        }
        searchTask = task
    }
}
