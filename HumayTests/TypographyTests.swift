import Testing
import UIKit
@testable import Humay

@Suite("Typography")
struct TypographyTests {
    /// A missing font does not crash — UIKit substitutes San Francisco silently. This
    /// is the only thing that catches a broken Info.plist or a renamed file.
    @Test("every bundled Cormorant face resolves", arguments: HumayFontFace.allCases)
    func faceResolves(_ face: HumayFontFace) {
        #expect(
            UIFont(name: face.postScriptName, size: 12) != nil,
            "\(face.postScriptName) did not resolve"
        )
    }

    @Test("no face is missing at launch")
    func noMissingFaces() {
        #expect(HumayFontRegistrar.missingFaces().isEmpty)
    }
}
