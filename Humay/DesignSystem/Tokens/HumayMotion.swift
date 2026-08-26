import SwiftUI

/// Centralized motion language. Springs over eases; every preset has a meaning.
/// Presentation must respect Reduce Motion via `HumayMotion.animation(_:enabled:)`.
enum HumayMotion {
    /// Standard interactive response — taps, selections, small state changes.
    static let snappy = Animation.snappy(duration: 0.28)

    /// Softer arrival for content entering a screen.
    static let gentle = Animation.spring(response: 0.45, dampingFraction: 0.85)

    /// Playful overshoot reserved for reveals and collisions. Rare by design.
    static let bouncy = Animation.spring(response: 0.42, dampingFraction: 0.62)

    /// Long choreographed sequences (timeline scrub settle).
    static let smooth = Animation.smooth(duration: 0.5)

    static let fastDuration: TimeInterval = 0.18
    static let revealHoldDuration: Double = 0.55

    /// Returns the animation when motion is allowed, nil otherwise — the standard
    /// pattern for honoring Reduce Motion without branching every call site.
    static func animated(_ animation: Animation, enabled: Bool) -> Animation? {
        enabled ? animation : nil
    }
}
