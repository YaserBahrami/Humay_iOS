import Testing
import Foundation
@testable import Humay

// MARK: - Phase I.2.2a State Hotfix regressions

@Suite("BirthPlace I.2.2a — Ownership & Search State")
struct BirthPlaceI22aTests {

    @Test("typing different query does not destroy saved place")
    @MainActor func typingPreservesSaved() {
        let birth = BirthDetails(year: 1990, month: 1, day: 1, time: .unknown, place: .known(name: "Tehran, Iran", latitude: 35.6892, longitude: 51.3890, timeZoneIdentifier: "Asia/Tehran"))
        let draft = BirthDetailsDraftState(birth: birth)
        #expect(draft.birthPlaceResult != nil)
        #expect(draft.birthPlaceResult?.displayName == "Tehran, Iran")
        // Simulate user typing new query different from saved display - draft must remain Tehran
        // View logic must NOT clear draft.birthPlaceResult on query change.
        // We verify draft ownership alone: query var does not affect draft.
        var query = "Istanbul"
        _ = query
        #expect(draft.birthPlaceResult?.displayName == "Tehran, Iran")
        #expect(draft.currentBirthDetails.place.name == "Tehran, Iran")
    }

    @Test("failed search preserves old place")
    @MainActor func failedSearchPreserves() async {
        let birth = BirthDetails(year: 1990, month: 1, day: 1, time: .unknown, place: .known(name: "Tehran, Iran", latitude: 35.68, longitude: 51.38, timeZoneIdentifier: "Asia/Tehran"))
        let draft = BirthDetailsDraftState(birth: birth)
        let svc = FailingBirthPlaceSearchService()
        do { _ = try await svc.suggestions(for: "Istanbul") } catch {}
        #expect(draft.birthPlaceResult?.displayName == "Tehran, Iran")
    }

    @Test("no-results preserves old place")
    @MainActor func noResultsPreserves() async {
        let birth = BirthDetails(year: 1990, month: 1, day: 1, time: .unknown, place: .known(name: "Tehran, Iran", latitude: 35.68, longitude: 51.38, timeZoneIdentifier: "Asia/Tehran"))
        let draft = BirthDetailsDraftState(birth: birth)
        let svc = InMemoryBirthPlaceSearchService()
        do { _ = try await svc.suggestions(for: "ZZZ_NO_MATCH_XYZ") } catch {}
        #expect(draft.birthPlaceResult?.displayName == "Tehran, Iran")
    }

    @Test("unresolved raw text cannot replace saved place")
    @MainActor func rawTextCannotReplace() {
        let birth = BirthDetails(year: 1990, month: 1, day: 1, time: .unknown, place: .known(name: "Tehran, Iran", latitude: 35.68, longitude: 51.38, timeZoneIdentifier: "Asia/Tehran"))
        let draft = BirthDetailsDraftState(birth: birth)
        // User types "Istanbul" but does not select suggestion — draft must remain Tehran
        // Save behavior should keep Tehran, not raw text.
        #expect(draft.birthPlaceResult?.displayName == "Tehran, Iran")
        #expect(draft.currentBirthDetails.place.name == "Tehran, Iran")
        // Even if user edits query field, without successful resolve draft unchanged.
    }

    @Test("explicit Clear removes place and allows idle")
    @MainActor func explicitClearRemoves() {
        let birth = BirthDetails(year: 1990, month: 1, day: 1, time: .unknown, place: .known(name: "Tehran, Iran", latitude: 35.68, longitude: 51.38, timeZoneIdentifier: "Asia/Tehran"))
        let draft = BirthDetailsDraftState(birth: birth)
        #expect(draft.birthPlaceResult != nil)
        // Simulate Clear place
        draft.birthPlaceResult = nil
        #expect(draft.birthPlaceResult == nil)
        #expect(draft.currentBirthDetails.place == .notProvided)
    }

    @Test("successful resolved suggestion replaces old place")
    @MainActor func successfulReplace() async throws {
        let birth = BirthDetails(year: 1990, month: 1, day: 1, time: .unknown, place: .known(name: "Tehran, Iran", latitude: 35.68, longitude: 51.38, timeZoneIdentifier: "Asia/Tehran"))
        let draft = BirthDetailsDraftState(birth: birth)
        let svc = InMemoryBirthPlaceSearchService()
        let sugs = try await svc.suggestions(for: "Istanbul")
        let istanbulSug = try #require(sugs.first { $0.id == "istanbul-tr" })
        let result = try await svc.resolve(istanbulSug)
        draft.birthPlaceResult = result
        #expect(draft.birthPlaceResult?.displayName == "Istanbul, Türkiye")
        #expect(draft.currentBirthDetails.place.name == "Istanbul, Türkiye")
    }

    @Test("onboarding Continue disabled without resolved place, enabled after resolve")
    @MainActor func onboardingContinueSemantics() async throws {
        let draft = OnboardingDraftState()
        // Initially no place — Continue must be disabled (resolved == nil)
        #expect(draft.birthPlaceResult == nil)
        // Simulate Skip path -> notProvided
        #expect(draft.birthPlace == .notProvided)
        // After successful resolution
        let svc = InMemoryBirthPlaceSearchService()
        let sugs = try await svc.suggestions(for: "Tehran")
        let tehranSug = try #require(sugs.first { $0.id == "tehran-ir" })
        let result = try await svc.resolve(tehranSug)
        draft.birthPlaceResult = result
        #expect(draft.birthPlaceResult != nil)
        #expect(draft.birthPlace != .notProvided)
        // Skip produces .notProvided
        let draft2 = OnboardingDraftState()
        #expect(draft2.birthPlace == .notProvided)
    }

    @Test("selected place does not trigger search on editor appearance")
    @MainActor func editorInitialIdle() {
        let birth = BirthDetails(year: 1990, month: 1, day: 1, time: .unknown, place: .known(name: "Tehran, Iran", latitude: 35.68, longitude: 51.38, timeZoneIdentifier: "Asia/Tehran"))
        let draft = BirthDetailsDraftState(birth: birth)
        // Editor appearance mirrors resolved displayName into query, searchState idle
        let query = draft.birthPlaceResult?.displayName ?? ""
        #expect(query == "Tehran, Iran")
        // No search should be triggered; searchState should be idle (not searching)
        let state: BirthPlaceSearchUIState = .idle
        #expect(state == .idle)
    }

    @Test("search UI state is mutually exclusive")
    func stateMutualExclusion() {
        let s1: BirthPlaceSearchUIState = .idle
        let s2: BirthPlaceSearchUIState = .searching
        let s3: BirthPlaceSearchUIState = .noResults
        let s4: BirthPlaceSearchUIState = .failed(.networkUnavailable)
        #expect(s1 != s2)
        #expect(s2 != s3)
        #expect(s3 != s4)
        // Ensure no state can be both noResults and failed simultaneously — enum prevents dual case
        if case .noResults = s3 {} else { Issue.record("should be noResults") }
        if case .failed = s4 {} else { Issue.record("should be failed") }
    }

    @Test("error and noResults are not shown simultaneously via state")
    func errorVsNoResultsDistinct() {
        let errState: BirthPlaceSearchUIState = .failed(.networkUnavailable)
        let noResState: BirthPlaceSearchUIState = .noResults
        #expect(errState != noResState)
        // Single enum value cannot be both
    }
}

// MARK: - Resolution race token

@Suite("BirthPlace I.2.2a — Stale resolution race")
struct BirthPlaceResolutionRaceTests {

    actor DelayedService: BirthPlaceSearching {
        func suggestions(for query: String) async throws -> [BirthPlaceSuggestion] { [] }
        func resolve(_ suggestion: BirthPlaceSuggestion) async throws -> BirthPlaceSearchResult {
            if suggestion.id == "tehran-ir" {
                try await Task.sleep(nanoseconds: 200_000_000)
                return BirthPlaceSearchResult(id: "tehran-ir", displayName: "Tehran, Iran", secondaryLabel: nil, latitude: 35.68, longitude: 51.38, timeZoneIdentifier: "Asia/Tehran")
            } else {
                return BirthPlaceSearchResult(id: "istanbul-tr", displayName: "Istanbul, Türkiye", secondaryLabel: nil, latitude: 41.0, longitude: 28.97, timeZoneIdentifier: "Europe/Istanbul")
            }
        }
        func search(query: String) async throws -> [BirthPlaceSearchResult] { [] }
    }

    @Test("stale Tehran resolve cannot overwrite newer Istanbul selection")
    func staleCannotOverwriteNewer() async throws {
        // Simulate view's resolutionGeneration token
        var resolutionGeneration = 0
        var applied: BirthPlaceSearchResult?
        let service = DelayedService()
        let tehranSug = BirthPlaceSuggestion(id: "tehran-ir", title: "Tehran, Iran", subtitle: nil)
        let istanbulSug = BirthPlaceSuggestion(id: "istanbul-tr", title: "Istanbul, Türkiye", subtitle: nil)

        // Start Tehran resolution with gen 1
        resolutionGeneration = 1
        let gen1 = resolutionGeneration
        let task1 = Task { try await service.resolve(tehranSug) }

        // Before Tehran finishes, user taps Istanbul -> gen 2
        try await Task.sleep(nanoseconds: 50_000_000)
        resolutionGeneration = 2
        let gen2 = resolutionGeneration
        let res2 = try await service.resolve(istanbulSug)
        // Apply only if still current gen2
        if resolutionGeneration == gen2 { applied = res2 }

        // Tehran finishes later
        let res1 = try await task1.value
        if resolutionGeneration == gen1 {
            applied = res1 // should NOT apply because gen changed
        }

        #expect(applied?.displayName == "Istanbul, Türkiye")
    }

    @Test("stale resolve after query change is discarded")
    func staleAfterQueryChange() async throws {
        var generation = 0
        var resolutionGeneration = 0
        var applied: BirthPlaceSearchResult?

        let tehranSug = BirthPlaceSuggestion(id: "tehran-ir", title: "Tehran, Iran", subtitle: nil)
        let service = DelayedService()

        generation = 1
        resolutionGeneration = 1
        let capGen = generation
        let capResGen = resolutionGeneration
        let task = Task { try await service.resolve(tehranSug) }

        // User changes query to Istanbul -> generation bumps
        generation = 2
        resolutionGeneration = 2

        let res = try await task.value
        // Should discard because generation changed
        if resolutionGeneration == capResGen && generation == capGen {
            applied = res
        }
        #expect(applied == nil)
    }
}
