import Foundation
import Observation

/// Small in-memory application state for the current production onboarding slice.
///
/// Provider wiring, mock content, persistence and feature-specific state are added only
/// when their owning production tasks require them. Persistence and provider wiring
/// remain out of scope for the current onboarding slice. Keeping this small prevents
/// prototype assumptions from becoming architecture.
@Observable
@MainActor
final class AppEnvironment {
    var profile: UserProfile?
    var settings: AppSettings

    init(
        profile: UserProfile? = nil,
        settings: AppSettings = .default
    ) {
        self.profile = profile
        self.settings = settings
    }

    var hasCompletedOnboarding: Bool {
        settings.hasCompletedOnboarding && profile != nil
    }

    func completeOnboarding(
        profile: UserProfile,
        tradition: AstrologyTradition
    ) {
        self.profile = profile
        settings.leadingTradition = tradition
        settings.onboardingCompletedAt = .now
    }

    func resetForDevelopment() {
        profile = nil
        settings = .default
    }
}
