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
    private(set) var restorationState: AppRestorationState
    private(set) var isSaving = false

    init(
        store: any UserStateStore,
        profile: UserProfile? = nil,
        settings: AppSettings = .default,
        initialRestorationState: AppRestorationState = .restoring
    ) {
        self.userStateStore = store
        self.profile = profile
        self.settings = settings
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
            } else {
                profile = nil
                settings = .default
            }
            restorationState = .ready
        } catch {
            restorationState = .failed
            HumayLog.persistenceFailure("profile restore failed")
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
            settings: updatedSettings
        )

        do {
            try await userStateStore.save(state)
        } catch {
            HumayLog.persistenceFailure("profile save failed")
            throw error
        }

        self.profile = profile
        settings = updatedSettings
        restorationState = .ready
    }

    func resetForDevelopment() async throws {
        do {
            try await userStateStore.clear()
        } catch {
            restorationState = .failed
            HumayLog.persistenceFailure("development reset failed")
            throw error
        }

        profile = nil
        settings = .default
        restorationState = .ready
    }
}
