import SwiftUI

/// Motion, as four verbs plus one signature.
///
/// Each verb has a job. Nothing animates on a loop under any setting, and nothing here
/// exists to create urgency.
enum HumayMotion {
    /// An element enters and settles.
    static let rise = Animation.easeOut(duration: 0.42)
    /// A relationship forms — a chart drawing its aspect lines.
    static let draw = Animation.easeInOut(duration: 0.9)
    /// Immediate confirmation. A tone change, a selection.
    static let strike = Animation.easeOut(duration: 0.18)
    /// A screen-level transition.
    static let turn = Animation.easeInOut(duration: 0.32)

    /// The signature reveal. Plays once, at launch and at a chart reveal, nowhere else.
    static let occultation = Animation.timingCurve(0.22, 0.61, 0.36, 1, duration: 0.64)

    /// What replaces the occultation when motion is reduced.
    static let reducedCrossfade = Animation.easeInOut(duration: 0.16)
    /// What onboarding beats collapse to when motion is reduced.
    static let reducedFade = Animation.easeInOut(duration: 0.12)

    /// Picks the honest animation for the current setting.
    static func reveal(reduceMotion: Bool) -> Animation {
        reduceMotion ? reducedCrossfade : occultation
    }

    static func beat(reduceMotion: Bool) -> Animation {
        reduceMotion ? reducedFade : rise
    }
}

/// Staggers a sequence of elements into view.
///
/// Used for onboarding beats and the chart reveal. Under Reduce Motion the stagger
/// collapses to a single fade — the information still arrives in order, it just does
/// not travel.
struct RiseIn: ViewModifier {
    let index: Int
    var spacingSeconds: Double = 0.09

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared || reduceMotion ? 0 : 10)
            .onAppear {
                let delay = reduceMotion ? 0 : Double(index) * spacingSeconds
                withAnimation(HumayMotion.beat(reduceMotion: reduceMotion).delay(delay)) {
                    hasAppeared = true
                }
            }
    }
}

extension View {
    /// Enters and settles, offset by position in a sequence.
    func riseIn(_ index: Int) -> some View {
        modifier(RiseIn(index: index))
    }
}
