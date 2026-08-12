import Foundation

/// Small cross-feature preferences that already have product authority.
///
/// Notification, purchase, provider and experiment state are intentionally absent from
/// the clean baseline. They are introduced when those production phases are designed.
struct AppSettings: Sendable, Hashable {
    var leadingTradition: AstrologyTradition
    var tone: Tone
    var onboardingCompletedAt: Date?

    var hasCompletedOnboarding: Bool { onboardingCompletedAt != nil }

    static let `default` = AppSettings(
        leadingTradition: .western,
        tone: .normal,
        onboardingCompletedAt: nil
    )
}
