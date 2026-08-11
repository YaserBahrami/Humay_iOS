import Foundation

/// The bundled Cormorant Garamond faces.
///
/// Cormorant carries the Humay identity: the wordmark, major titles and editorial
/// headlines. Everything else uses the system faces — SF Pro for UI and body, SF Mono
/// for degrees, coordinates, dates and chart data.
///
/// The brand lock allows weights 300 and 400 only, and states that the larger the
/// size, the lighter the weight. There is deliberately no bold face bundled.
enum HumayFontFace: String, CaseIterable, Sendable {
    case light = "CormorantGaramond-Light"
    case lightItalic = "CormorantGaramond-LightItalic"
    case regular = "CormorantGaramond-Regular"
    case italic = "CormorantGaramond-Italic"

    /// The PostScript name, which is what `UIFont(name:size:)` requires.
    ///
    /// `UIAppFonts` in Info.plist lists *filenames*; these differ. Mixing the two up
    /// produces a silent fall back to San Francisco, which is why
    /// `HumayFontRegistrar` verifies every face at launch.
    var postScriptName: String { rawValue }

    var fileName: String { "\(rawValue).otf" }

    /// The italic counterpart of this face, or itself when already italic.
    var italicised: HumayFontFace {
        switch self {
        case .light, .lightItalic: .lightItalic
        case .regular, .italic: .italic
        }
    }
}
