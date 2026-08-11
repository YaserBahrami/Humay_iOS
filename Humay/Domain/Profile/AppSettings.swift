import Foundation

/// Preferences that shape the experience but are not facts about the person.
///
/// Deliberately does not hold any entitlement or purchase state. Access is a separate
/// concern with its own lifecycle, and folding it in here would make the profile the
/// wrong place to look for it.
struct AppSettings: Sendable, Hashable {
    var leadingTradition: AstrologyTradition
    var tone: Tone
    var onboardingCompletedAt: Date?
    var notifications: NotificationSettings

    var hasCompletedOnboarding: Bool { onboardingCompletedAt != nil }

    static let `default` = AppSettings(
        leadingTradition: .western,
        tone: .normal,
        onboardingCompletedAt: nil,
        notifications: .default
    )
}

/// Notification preferences.
///
/// There is no tone toggle here by design: notifications are always written in the
/// Normal register regardless of the in-app setting. Roast never reaches the lock
/// screen, where there is no context and no way to opt out in the moment.
struct NotificationSettings: Sendable, Hashable {
    var morningReading: Bool
    var todayTogether: Bool
    var meaningfulTransit: Bool
    var lunarPhases: Bool
    var quietHoursEnabled: Bool
    var quietHoursStartHour: Int
    var quietHoursEndHour: Int

    static let `default` = NotificationSettings(
        morningReading: true,
        todayTogether: true,
        meaningfulTransit: true,
        lunarPhases: false,
        quietHoursEnabled: true,
        quietHoursStartHour: 22,
        quietHoursEndHour: 7
    )
}
