import SwiftUI

struct BirthPlaceSearchView: View {
    @Bindable var draft: OnboardingDraftState
    var searchService: any BirthPlaceSearching
    let onBack: () -> Void
    let onContinue: () -> Void
    let onSkip: (() -> Void)?

    @State private var query: String = ""
    @State private var suggestions: [BirthPlaceSuggestion] = []
    @State private var isSearching = false
    @State private var isResolving = false
    @State private var errorMessage: String?
    @State private var hasSearched = false
    @State private var selectedResult: BirthPlaceSearchResult?
    @State private var searchTask: Task<Void, Never>?
    @State private var generation: Int = 0

    var body: some View {
        OnboardingScreen { proxy in
            let compactHeight = proxy.size.height < 700
            let sectionSpacing = bounded(proxy.size.height * (compactHeight ? 0.012 : 0.016), minimum: 8, maximum: 16)
            if proxy.size.width > proxy.size.height {
                landscapeLayout(compactHeight: compactHeight, sectionSpacing: sectionSpacing)
            } else {
                portraitLayout(compactHeight: compactHeight, sectionSpacing: sectionSpacing)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            query = draft.birthPlaceQuery
            selectedResult = draft.birthPlaceResult
            if let r = draft.birthPlaceResult {
                query = r.displayName
                hasSearched = false
                suggestions = []
            }
        }
        .onChange(of: query) { _, newValue in
            draft.birthPlaceQuery = newValue
            debounceSearch(query: newValue)
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .accessibilityIdentifier("onboarding.birthPlace.screen")
    }

    private var primaryTitle: String {
        if draft.birthPlaceResult != nil { return "Continue" }
        return selectedResult != nil ? "Use this place" : "Continue"
    }

    private func handleContinue() {
        if let sel = selectedResult {
            draft.birthPlaceResult = sel
        }
        onContinue()
    }

    // MARK: Layout

    private func portraitLayout(compactHeight: Bool, sectionSpacing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            OnboardingChrome(stepLabel: "03 · Birth place", progressIndex: 3, onBack: onBack)
            OnboardingTitleBlock(title: "Where did you make your entrance?", supporting: "Moon and Rising need the place to be honest.", hero: false)
            searchField(compactHeight: compactHeight)
            resultsSection(compactHeight: compactHeight)
            if draft.birthPlaceResult == nil {
                Text("Search is online once. After saving, calculation stays fully offline.")
                    .font(HumayTypography.caption)
                    .foregroundStyle(Color.humayTextSecondary)
            }
            OnboardingPrimaryAction(title: primaryTitle, identifier: "onboarding.birthPlace.continue", action: handleContinue)
                .padding(.top, HumaySpacing.medium)
            if onSkip != nil && draft.birthPlaceResult == nil {
                Button("Skip for now") { onSkip?() }
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextSecondary)
                    .accessibilityIdentifier("onboarding.birthPlace.skip")
            }
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func landscapeLayout(compactHeight: Bool, sectionSpacing: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            HStack(alignment: .top, spacing: compactHeight ? HumaySpacing.large : HumaySpacing.extraExtraLarge) {
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    OnboardingChrome(stepLabel: "03 · Birth place", progressIndex: 3, onBack: onBack)
                    OnboardingTitleBlock(title: "Where did you make your entrance?", supporting: "Moon and Rising need the place to be honest.", hero: false)
                    searchField(compactHeight: compactHeight)
                }
                .frame(maxWidth: 420, alignment: .leading)
                VStack(alignment: .leading, spacing: sectionSpacing) {
                    resultsSection(compactHeight: compactHeight)
                }
                .frame(maxWidth: 620, alignment: .leading)
            }
            .frame(maxWidth: 1120, alignment: .center)
            OnboardingPrimaryAction(title: primaryTitle, identifier: "onboarding.birthPlace.continue", action: handleContinue)
                .padding(.top, HumaySpacing.medium)
            if onSkip != nil && draft.birthPlaceResult == nil {
                Button("Skip for now") { onSkip?() }
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextSecondary)
                    .accessibilityIdentifier("onboarding.birthPlace.skip")
            }
        }
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func searchField(compactHeight: Bool) -> some View {
        HumaySurface(level: .standard, padding: compactHeight ? HumaySpacing.small : HumaySpacing.medium) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                HStack(spacing: HumaySpacing.small) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.humayTextSecondary)
                        .accessibilityHidden(true)
                    TextField("Tehran, Iran · Istanbul, Türkiye · London, UK", text: $query)
                        .textContentType(.addressCity)
                        .submitLabel(.search)
                        .font(HumayTypography.body)
                        .accessibilityLabel("Birth place")
                        .accessibilityHint("Search a city and country for your birthplace")
                        .accessibilityIdentifier("onboarding.birthPlace.field")
                    if !query.isEmpty {
                        Button { query = ""; suggestions = []; errorMessage = nil; hasSearched = false; generation &+= 1 } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear search")
                    }
                    if isSearching || isResolving {
                        ProgressView()
                            .accessibilityLabel(isResolving ? "Resolving place" : "Searching places")
                    }
                }
                .padding(HumaySpacing.small)
                .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.compact))
                .overlay { RoundedRectangle(cornerRadius: HumayRadius.compact).strokeBorder(Color.humayHairline) }

                if let sel = selectedResult {
                    HStack(spacing: HumaySpacing.small) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.humayCoral)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sel.displayName)
                                .font(HumayTypography.bodyEmphasized)
                            if let sec = sel.secondaryLabel {
                                Text(sec)
                                    .font(HumayTypography.caption)
                                    .foregroundStyle(Color.humayTextSecondary)
                            }
#if DEBUG
                            Text("\(sel.timeZoneIdentifier) · \(String(format: "%.2f, %.2f", sel.latitude, sel.longitude))")
                                .font(HumayTypography.caption)
                                .foregroundStyle(Color.humayTextSecondary)
#endif
                        }
                        Spacer()
                        Button("Change") { selectedResult = nil; draft.birthPlaceResult = nil }
                            .font(HumayTypography.caption.weight(.semibold))
                            .foregroundStyle(Color.humayCoral)
                    }
                    .padding(HumaySpacing.small)
                    .background(Color.humayCoral.opacity(0.08), in: RoundedRectangle(cornerRadius: HumayRadius.compact))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("onboarding.birthPlace.selected")
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(HumayTypography.caption)
                        .foregroundStyle(Color.red)
                        .accessibilityIdentifier("onboarding.birthPlace.error")
                }
            }
        }
    }

    private func resultsSection(compactHeight: Bool) -> some View {
        Group {
            if isSearching {
                HumaySurface(padding: HumaySpacing.large) {
                    HStack(spacing: HumaySpacing.small) {
                        ProgressView()
                        Text("Searching places…")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
            } else if isResolving {
                HumaySurface(padding: HumaySpacing.large) {
                    HStack(spacing: HumaySpacing.small) {
                        ProgressView()
                        Text("Resolving…")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
            } else if selectedResult != nil && suggestions.isEmpty {
                EmptyView()
            } else if !suggestions.isEmpty {
                HumaySurface(padding: HumaySpacing.small) {
                    VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                        ForEach(suggestions) { sug in
                            Button {
                                Task { await resolve(suggestion: sug) }
                            } label: {
                                HStack(spacing: HumaySpacing.small) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(sug.title)
                                            .font(HumayTypography.bodyEmphasized)
                                            .foregroundStyle(Color.humayTextPrimary)
                                        if let sub = sug.subtitle {
                                            Text(sub)
                                                .font(HumayTypography.caption)
                                                .foregroundStyle(Color.humayTextSecondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.humayTextSecondary)
                                }
                                .padding(HumaySpacing.small)
                                .contentShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .frame(minHeight: HumayMetrics.minimumHitTarget)
                            .accessibilityLabel("\(sug.title), \(sug.subtitle ?? "")")
                            .accessibilityHint("Double tap to select this birthplace")
                            .accessibilityIdentifier("onboarding.birthPlace.suggestion.\(sug.id)")
                            if sug.id != suggestions.last?.id {
                                Divider().overlay(Color.humayHairline.opacity(0.6))
                            }
                        }
                    }
                }
            } else if hasSearched {
                HumaySurface(padding: HumaySpacing.large) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("No results")
                            .font(HumayTypography.bodyEmphasized)
                        Text("Try a broader city and country, e.g. \"Paris, France\".")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
                .accessibilityIdentifier("onboarding.birthPlace.noResults")
            } else {
                HumaySurface(padding: HumaySpacing.large) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("Try: Tehran, Iran · Istanbul, Türkiye · London, United Kingdom")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    // MARK: Resolve

    private func resolve(suggestion: BirthPlaceSuggestion) async {
        isResolving = true
        errorMessage = nil
        do {
            let result = try await searchService.resolve(suggestion)
            // Ensure query still matches user's intent (not overwritten by stale resolve)
            selectedResult = result
            draft.birthPlaceResult = result
            query = result.displayName
            suggestions = []
            hasSearched = false
            errorMessage = nil
        } catch let e as BirthPlaceSearchError {
            switch e {
            case .networkUnavailable: errorMessage = "Couldn't search places right now. Check your connection and try again."
            case .missingTimeZone: errorMessage = "Humay couldn't resolve a timezone for that place. Try a nearby city."
            case .resolutionFailed: errorMessage = "Couldn't resolve that place. Try again."
            case .noResults: errorMessage = "No matching cities found."
            case .invalidQuery: errorMessage = nil
            }
        } catch {
            errorMessage = "Couldn't resolve that place. Try again."
        }
        isResolving = false
    }

    // MARK: Search debounce / cancellation

    private func debounceSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        // If query matches selected display, don't search
        if let sel = selectedResult, sel.displayName == trimmed {
            suggestions = []
            hasSearched = false
            isSearching = false
            errorMessage = nil
            return
        }
        // Editing away from selected clears selection
        if let sel = selectedResult, sel.displayName != trimmed {
            selectedResult = nil
            draft.birthPlaceResult = nil
        }
        guard trimmed.count >= 2 else {
            suggestions = []
            errorMessage = nil
            hasSearched = false
            isSearching = false
            return
        }
        errorMessage = nil
        generation &+= 1
        let currentGen = generation
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled else { return }
            // Only latest generation proceeds
            guard currentGen == generation else { return }
            isSearching = true
            hasSearched = true
            do {
                let newSugs = try await searchService.suggestions(for: trimmed)
                guard !Task.isCancelled else { return }
                guard currentGen == generation else { return }
                if draft.birthPlaceQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    // If we already have a selected result with same query, hide suggestions
                    if selectedResult != nil {
                        suggestions = []
                    } else {
                        suggestions = newSugs
                    }
                    errorMessage = nil
                }
            } catch let e as BirthPlaceSearchError {
                guard !Task.isCancelled else { return }
                guard currentGen == generation else { return }
                if draft.birthPlaceQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    suggestions = []
                    switch e {
                    case .networkUnavailable: errorMessage = "Couldn't search places right now. Check your connection and try again."
                    case .noResults: errorMessage = nil
                    case .missingTimeZone: errorMessage = "Humay couldn't resolve a timezone for that place. Try a nearby city."
                    case .invalidQuery: errorMessage = nil
                    case .resolutionFailed: errorMessage = "Couldn't search places right now."
                    }
                }
            } catch {
                suggestions = []
                errorMessage = "Couldn't search places right now."
            }
            isSearching = false
        }
        searchTask = task
    }

    private func bounded(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }
}

#Preview("Birth Place Light") {
    BirthPlaceSearchView(draft: OnboardingDraftState(), searchService: InMemoryBirthPlaceSearchService(), onBack: {}, onContinue: {}, onSkip: {})
        .preferredColorScheme(.light)
}
