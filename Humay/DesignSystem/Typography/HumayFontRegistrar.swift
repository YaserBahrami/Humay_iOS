import UIKit

/// Verifies that every bundled face actually resolved at launch.
///
/// A missing or misnamed font does not crash — UIKit quietly substitutes San
/// Francisco, and the mistake can survive for weeks because the app still looks
/// plausible. This turns that silence into a loud failure during development, and a
/// unit test asserts the same thing in CI.
enum HumayFontRegistrar {
    /// Faces that failed to resolve. Empty when everything is wired correctly.
    static func missingFaces() -> [HumayFontFace] {
        HumayFontFace.allCases.filter { UIFont(name: $0.postScriptName, size: 12) == nil }
    }

    static func verifyAvailability() {
        #if DEBUG
        let missing = missingFaces()
        guard missing.isEmpty else {
            let names = missing.map(\.postScriptName).joined(separator: ", ")
            assertionFailure(
                """
                Humay fonts failed to load: \(names).

                Check that the .otf files are present in Humay/Resources/Fonts/ and \
                that Config/Info.plist lists their filenames under UIAppFonts. Note \
                that UIAppFonts takes filenames while UIFont(name:) takes PostScript \
                names — they are not the same string.
                """
            )
            return
        }
        #endif
    }
}
