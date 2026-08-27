import SwiftUI

struct BirthPlaceSearchView: View {
    @Bindable var draft: OnboardingDraftState
    var searchService: any BirthPlaceSearching
    let onBack: () -> Void
    let onContinue: () -> Void
    let onSkip: (() -> Void)?

    @State private var query: String = ""
    @State private var results: [BirthPlaceSearchResult] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var hasSearched = false
    @State private var selectedResult: BirthPlaceSearchResult?
    @State private var searchTask: Task<Void, Never>?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        .scrollDisabled(!dynamicTypeSize.isAccessibilitySize)
        .onAppear {
            query = draft.birthPlaceQuery
            selectedResult = draft.birthPlaceResult
            if let r = draft.birthPlaceResult {
                query = r.displayName
                results = [r]
                hasSearched = true
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
                        Button { query = ""; results = []; errorMessage = nil; hasSearched = false } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear search")
                    }
                    if isSearching {
                        ProgressView()
                            .accessibilityLabel("Searching places")
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
                            Text("\(sel.timeZoneIdentifier) · \(String(format: "%.2f, %.2f", sel.latitude, sel.longitude))")
                                .font(HumayTypography.caption)
                                .foregroundStyle(Color.humayTextSecondary)
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
            } else if !results.isEmpty {
                HumaySurface(padding: HumaySpacing.small) {
                    VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                        ForEach(results) { result in
                            Button {
                                selectedResult = result
                                draft.birthPlaceResult = result
                                errorMessage = nil
                            } label: {
                                HStack(spacing: HumaySpacing.small) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.displayName)
                                            .font(HumayTypography.bodyEmphasized)
                                            .foregroundStyle(Color.humayTextPrimary)
                                        if let sec = result.secondaryLabel {
                                            Text(sec)
                                                .font(HumayTypography.caption)
                                                .foregroundStyle(Color.humayTextSecondary)
                                        }
                                        Text(result.timeZoneIdentifier)
                                            .font(HumayTypography.caption)
                                            .foregroundStyle(Color.humayTextSecondary.opacity(0.8))
                                    }
                                    Spacer()
                                    if selectedResult?.id == result.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.humayCoral)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(Color.humayTextSecondary)
                                    }
                                }
                                .padding(HumaySpacing.small)
                                .background(selectedResult?.id == result.id ? Color.humayCoral.opacity(0.08) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                                .contentShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .frame(minHeight: HumayMetrics.minimumHitTarget)
                            .accessibilityLabel("\(result.displayName), \(result.secondaryLabel ?? "")")
                            .accessibilityHint("Double tap to select this birthplace")
                            .accessibilityIdentifier("onboarding.birthPlace.result.\(result.id)")
                            if result.id != results.last?.id {
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

    // MARK: Search debounce / cancellation (§52)

    private func debounceSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            results = []
            errorMessage = nil
            hasSearched = false
            isSearching = false
            return
        }
        // Defer clearing selected if user edits away from selected display name
        if let sel = selectedResult, sel.displayName != trimmed {
            selectedResult = nil
            draft.birthPlaceResult = nil
        }
        errorMessage = nil
        let task = Task { @MainActor in
            // modest debounce
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            isSearching = true
            hasSearched = true
            do {
                let newResults = try await searchService.search(query: trimmed)
                guard !Task.isCancelled else { return }
                // Latest-query only: ensure query hasn't changed during await
                if draft.birthPlaceQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    results = newResults
                    errorMessage = nil
                }
            } catch let e as BirthPlaceSearchError {
                guard !Task.isCancelled else { return }
                if draft.birthPlaceQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    results = []
                    switch e {
                    case .networkUnavailable: errorMessage = "Couldn't search places right now. Check your connection and try again."
                    case .noResults: errorMessage = nil // handled by no results UI
                    case .missingTimeZone: errorMessage = "That place couldn't be resolved to a timezone. Try a nearby city."
                    case .invalidQuery: errorMessage = nil
                    }
                }
            } catch {
                results = []
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
