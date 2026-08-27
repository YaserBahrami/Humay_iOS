import SwiftUI

struct BirthPlaceSearchView: View {
    @Bindable var draft: OnboardingDraftState
    var searchService: any BirthPlaceSearching
    let onBack: () -> Void
    let onContinue: () -> Void
    let onSkip: (() -> Void)?

    @State private var query: String = ""
    @State private var searchState: BirthPlaceSearchUIState = .idle
    @State private var searchTask: Task<Void, Never>?
    @State private var generation: Int = 0
    @State private var resolutionGeneration: Int = 0

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
            // Resolved place owned by draft; query mirrors it but does not trigger search.
            if let resolved = draft.birthPlaceResult {
                query = resolved.displayName
                draft.birthPlaceQuery = resolved.displayName
            } else {
                query = draft.birthPlaceQuery
            }
            searchState = .idle
        }
        .onChange(of: query) { _, newValue in
            draft.birthPlaceQuery = newValue
            debounceSearch(query: newValue)
        }
        .onChange(of: draft.birthPlaceResult) { _, _ in
            // If resolved externally cleared, keep query in sync only when clear.
        }
        .onDisappear {
            searchTask?.cancel()
            // Invalidate any in-flight resolution
            resolutionGeneration &+= 1
        }
        .accessibilityIdentifier("onboarding.birthPlace.screen")
    }

    private var canContinue: Bool { draft.birthPlaceResult != nil }

    private var primaryTitle: String {
        if draft.birthPlaceResult != nil { return "Continue" }
        return "Continue"
    }

    private func handleContinue() {
        // Only resolved place is valid; raw query alone never becomes a place.
        guard draft.birthPlaceResult != nil else { return }
        onContinue()
    }

    private func handleClearPlace() {
        generation &+= 1
        resolutionGeneration &+= 1
        searchTask?.cancel()
        draft.birthPlaceResult = nil
        draft.birthPlaceQuery = ""
        query = ""
        searchState = .idle
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
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.45)
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
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.45)
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
                        Button {
                            // Clear search text only; preserve resolved place until explicit Clear place.
                            // If user clears query field via X, we clear query but keep resolved separately;
                            // search state goes idle. Explicit Clear place is separate control.
                            query = ""
                            searchState = .idle
                            generation &+= 1
                            searchTask?.cancel()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear search")
                    }
                    if case .searching = searchState {
                        ProgressView().accessibilityLabel("Searching places")
                    } else if case .resolving = searchState {
                        ProgressView().accessibilityLabel("Resolving place")
                    }
                }
                .padding(HumaySpacing.small)
                .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.compact))
                .overlay { RoundedRectangle(cornerRadius: HumayRadius.compact).strokeBorder(Color.humayHairline) }

                if let sel = draft.birthPlaceResult {
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
                        Button("Clear place") { handleClearPlace() }
                            .font(HumayTypography.caption.weight(.semibold))
                            .foregroundStyle(Color.humayCoral)
                            .accessibilityIdentifier("onboarding.birthPlace.clear")
                    }
                    .padding(HumaySpacing.small)
                    .background(Color.humayCoral.opacity(0.08), in: RoundedRectangle(cornerRadius: HumayRadius.compact))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("onboarding.birthPlace.selected")
                }

                if case .failed(let err) = searchState {
                    Text(errorText(for: err))
                        .font(HumayTypography.caption)
                        .foregroundStyle(Color.red)
                        .accessibilityIdentifier("onboarding.birthPlace.error")
                }
            }
        }
    }

    private func resultsSection(compactHeight: Bool) -> some View {
        Group {
            switch searchState {
            case .searching:
                HumaySurface(padding: HumaySpacing.large) {
                    HStack(spacing: HumaySpacing.small) {
                        ProgressView()
                        Text("Searching places…")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
            case .resolving:
                HumaySurface(padding: HumaySpacing.large) {
                    HStack(spacing: HumaySpacing.small) {
                        ProgressView()
                        Text("Resolving…")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
            case .suggestions(let sugs) where !sugs.isEmpty:
                HumaySurface(padding: HumaySpacing.small) {
                    VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                        ForEach(sugs) { sug in
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
                            if sug.id != sugs.last?.id {
                                Divider().overlay(Color.humayHairline.opacity(0.6))
                            }
                        }
                    }
                }
            case .noResults:
                HumaySurface(padding: HumaySpacing.large) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("No matching cities found.")
                            .font(HumayTypography.bodyEmphasized)
                        Text("Try a broader city and country, e.g. \"Paris, France\".")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
                .accessibilityIdentifier("onboarding.birthPlace.noResults")
            case .failed:
                // Failure already shown inline; no duplicate noResults.
                EmptyView()
            case .idle, .suggestions:
                if draft.birthPlaceResult != nil {
                    EmptyView()
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
    }

    // MARK: Resolve

    private func resolve(suggestion: BirthPlaceSuggestion) async {
        let capturedResolution = resolutionGeneration &+ 1
        resolutionGeneration = capturedResolution
        let capturedGeneration = generation
        searchState = .resolving(suggestion)
        do {
            let result = try await searchService.resolve(suggestion)
            guard resolutionGeneration == capturedResolution else { return }
            guard capturedGeneration == generation else { return }
            // Successful resolution replaces canonical place, query syncs, transient idle.
            draft.birthPlaceResult = result
            query = result.displayName
            draft.birthPlaceQuery = result.displayName
            searchState = .idle
        } catch let e as BirthPlaceSearchError {
            guard resolutionGeneration == capturedResolution else { return }
            // Preserve previous canonical place.
            switch e {
            case .networkUnavailable, .missingTimeZone, .resolutionFailed:
                searchState = .failed(e)
            case .noResults:
                searchState = .noResults
            case .invalidQuery:
                searchState = .idle
            }
        } catch {
            guard resolutionGeneration == capturedResolution else { return }
            searchState = .failed(.resolutionFailed)
        }
    }

    // MARK: Search debounce / cancellation

    private func debounceSearch(query newValue: String) {
        searchTask?.cancel()
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        // If query equals resolved display name, hide suggestions and go idle without searching.
        if let resolved = draft.birthPlaceResult, resolved.displayName == trimmed {
            searchState = .idle
            return
        }
        // Typing never clears resolved place — preserve draft.birthPlaceResult.
        guard trimmed.count >= 2 else {
            searchState = .idle
            return
        }
        generation &+= 1
        let currentGen = generation
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled else { return }
            guard currentGen == generation else { return }
            // If user already resolved to exactly this query, do not search.
            if let resolved = draft.birthPlaceResult, resolved.displayName == trimmed {
                searchState = .idle
                return
            }
            searchState = .searching
            do {
                let newSugs = try await searchService.suggestions(for: trimmed)
                guard !Task.isCancelled else { return }
                guard currentGen == generation else { return }
                if draft.birthPlaceQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    if newSugs.isEmpty {
                        searchState = .noResults
                    } else {
                        searchState = .suggestions(newSugs)
                    }
                }
            } catch let e as BirthPlaceSearchError {
                guard !Task.isCancelled else { return }
                guard currentGen == generation else { return }
                if draft.birthPlaceQuery.trimmingCharacters(in: .whitespacesAndNewlines) == trimmed {
                    switch e {
                    case .networkUnavailable: searchState = .failed(.networkUnavailable)
                    case .noResults: searchState = .noResults
                    case .missingTimeZone: searchState = .failed(.missingTimeZone)
                    case .invalidQuery: searchState = .idle
                    case .resolutionFailed: searchState = .failed(.resolutionFailed)
                    }
                }
            } catch {
                searchState = .failed(.networkUnavailable)
            }
        }
        searchTask = task
    }

    private func errorText(for error: BirthPlaceSearchError) -> String {
        switch error {
        case .networkUnavailable: return "Couldn't search places right now. Check your connection and try again."
        case .missingTimeZone: return "Humay couldn't resolve a timezone for that place. Try a nearby city."
        case .noResults: return "No matching cities found."
        case .resolutionFailed: return "Couldn't resolve that place. Try again."
        case .invalidQuery: return ""
        }
    }

    private func bounded(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }
}

#Preview("Birth Place Light") {
    BirthPlaceSearchView(draft: OnboardingDraftState(), searchService: InMemoryBirthPlaceSearchService(), onBack: {}, onContinue: {}, onSkip: {})
        .preferredColorScheme(.light)
}
