import Foundation

/// The locked text-opacity ramp.
///
/// Every artifact from the brand lock forward uses exactly these six stops. Do not
/// introduce new ones, and do not call `.opacity()` with a literal in a view — the
/// ramp is the vocabulary for text weight in this design.
enum HumayInkOpacity: Double, Sendable, CaseIterable {
    case primary = 1.0
    case body = 0.84
    case secondary = 0.74
    case tertiary = 0.62
    case label = 0.50
    case disabled = 0.45

    var value: Double { rawValue }
}
