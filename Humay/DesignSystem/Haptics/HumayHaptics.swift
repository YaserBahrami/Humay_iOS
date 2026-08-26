import UIKit

/// Centralized haptic vocabulary. One place to tune intensity and pattern so the
/// app feels consistent under the finger. Haptics respect system settings
/// automatically (they no-op in silent/reduced-transparency contexts where the OS
/// decides); callers never need feature-level opt-outs.
@MainActor
enum HumayHaptics {
    /// Light tick — selection, meter settle, small confirmations.
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium impact — card reveals completing, tab changes.
    static func thump() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Heavy hit — reserved for collisions and chaos moments only.
    static func collision() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.9)
    }

    /// Success notification — compatibility results, share completion.
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Warning notification — "don't text them" peaks, danger zones.
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Rising ramp used during hold-to-reveal anticipation.
    static func revealRamp() {
        // A short sequence approximated with two impacts; CoreHaptics can replace
        // this if a finer curve is ever needed.
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.4)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(140))
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
        }
    }
}
