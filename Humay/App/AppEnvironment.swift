import Foundation
import Observation

/// Minimal application state for the clean production baseline.
///
/// Provider wiring, mock content, persistence and feature-specific state are added only
/// when the corresponding production phase reaches implementation. Keeping this small
/// prevents prototype assumptions from becoming permanent architecture.
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
