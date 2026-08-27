import Foundation
import Observation

enum AppRestorationState: String, Equatable, Sendable {
    case restoring
    case ready
    case failed
}

enum AppEnvironmentError: Error, Equatable, Sendable {
    case notReady
    case operationInProgress
}

/// Application-owned profile/settings state and its durable ownership boundary.
@Observable
@MainActor
final class AppEnvironment {
    private let userStateStore: any UserStateStore

    var profile: UserProfile?
    var settings: AppSettings
    var people: [ConnectionPerson]
    private(set) var restorationState: AppRestorationState
    private(set) var isSaving = false

    init(
        store: any UserStateStore,
        profile: UserProfile? = nil,
        settings: AppSettings = .default,
        people: [ConnectionPerson] = [],
        initialRestorationState: AppRestorationState = .restoring
    ) {
        self.userStateStore = store
        self.profile = profile
        self.settings = settings
        self.people = people
        self.restorationState = initialRestorationState
    }

    var hasCompletedOnboarding: Bool {
        restorationState == .ready
            && settings.hasCompletedOnboarding
            && profile != nil
    }

    func restore() async {
        restorationState = .restoring

        do {
            if let state = try await userStateStore.load() {
                profile = state.profile
                settings = state.settings
                people = state.people
            } else {
                profile = nil
                settings = .default
                people = []
            }
            restorationState = .ready
        } catch let error as UserStatePersistenceError {
            restorationState = .failed
            switch error {
            case .unsupportedSchema:
                HumayLog.persistence(.unsupportedSchema)
            default:
                HumayLog.persistence(.restoreFailed)
            }
        } catch {
            restorationState = .failed
            HumayLog.persistence(.restoreFailed)
        }
    }

    func completeOnboarding(
        profile: UserProfile,
        tradition: AstrologyTradition,
        completedAt: Date = .now
    ) async throws {
        guard restorationState == .ready else {
            throw AppEnvironmentError.notReady
        }
        guard !isSaving else {
            throw AppEnvironmentError.operationInProgress
        }

        isSaving = true
        defer { isSaving = false }

        var updatedSettings = settings
        updatedSettings.leadingTradition = tradition
        updatedSettings.onboardingCompletedAt = completedAt

        let state = UserStateSnapshot(
            profile: profile,
            settings: updatedSettings,
            people: people
        )

        do {
            try await userStateStore.save(state)
        } catch {
            HumayLog.persistence(.saveFailed)
            throw error
        }

        self.profile = profile
        settings = updatedSettings
        restorationState = .ready
    }

    // MARK: - Connections

    /// Adds a person and persists the change. In-memory state updates first so the
    /// UI feels immediate; persistence failures surface through the returned error.
    func addPerson(_ person: ConnectionPerson) async throws {
        guard !people.contains(where: { $0.id == person.id }) else { return }
        let previous = people
        people.append(person)

        do {
            try await persistCurrentState()
        } catch {
            people = previous
            throw error
        }
    }

    func removePerson(id: UUID) async throws {
        let previous = people
        people.removeAll { $0.id == id }

        do {
            try await persistCurrentState()
        } catch {
            people = previous
            throw error
        }
    }

    func updatePerson(_ person: ConnectionPerson) async throws {
        guard let index = people.firstIndex(where: { $0.id == person.id }) else { return }
        let previous = people
        people[index] = person

        do {
            try await persistCurrentState()
        } catch {
            people = previous
            throw error
        }
    }

    // MARK: - Preferences

    func setPersonalityMode(_ mode: PersonalityMode) async throws {
        let previous = settings
        settings.personalityMode = mode

        do {
            try await persistCurrentState()
        } catch {
            settings = previous
            throw error
        }
    }

    // MARK: - Birth Details editing (§25-27)

    /// Updates the current user's birth details. Invalidates derived caches when semantic inputs change.
    /// Returns whether a semantic change (date/time/coordinates/timezone) occurred.
    @discardableResult
    func updateBirthDetails(_ newBirth: BirthDetails) async throws -> Bool {
        guard var current = profile else { throw AppEnvironmentError.notReady }
        let hadSemanticChange = BirthDetailsSemanticChange.hasSemanticChange(from: current.birth, to: newBirth)
        let previousProfile = current
        current.birth = newBirth
        let previousInMemory = profile
        profile = current
        do {
            try await persistCurrentState()
        } catch {
            profile = previousInMemory
            throw error
        }
        if hadSemanticChange {
            await BigThreeCacheShared.shared.invalidate(for: previousProfile.birth)
        }
        return hadSemanticChange
    }

    func updateDisplayName(_ newName: String) async throws {
        guard var current = profile else { throw AppEnvironmentError.notReady }
        let previous = profile
        current.displayName = newName
        profile = current
        do {
            try await persistCurrentState()
        } catch {
            profile = previous
            throw error
        }
    }

    /// Whether the current profile's semantic fingerprint changed vs a new BirthDetails.
    func hasSemanticBirthChange(to newBirth: BirthDetails) -> Bool {
        guard let current = profile else { return true }
        return BirthDetailsSemanticChange.hasSemanticChange(from: current.birth, to: newBirth)
    }

    private func persistCurrentState() async throws {
        guard restorationState == .ready else {
            throw AppEnvironmentError.notReady
        }
        guard !isSaving else {
            throw AppEnvironmentError.operationInProgress
        }

        isSaving = true
        defer { isSaving = false }

        let state = UserStateSnapshot(
            profile: profile,
            settings: settings,
            people: people
        )

        do {
            try await userStateStore.save(state)
        } catch {
            HumayLog.persistence(.saveFailed)
            throw error
        }
    }

    func resetForDevelopment() async throws {
        do {
            try await userStateStore.clear()
        } catch {
            restorationState = .failed
            HumayLog.persistence(.clearFailed)
            throw error
        }

        profile = nil
        settings = .default
        people = []
        restorationState = .ready
    }
}
