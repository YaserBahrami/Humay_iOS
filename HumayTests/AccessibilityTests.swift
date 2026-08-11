import Testing
import UIKit
@testable import Humay

/// The parts of the accessibility contract that can be asserted without a screen.
///
/// The rest of `IOS-010` — reading order, wrapping, whether a screen still makes sense —
/// is a sweep in the simulator. What is here is what a future change could silently
/// break: a hit target trimmed to fit a row, a type ceiling lowered to tidy a layout.
@Suite("Accessibility")
struct AccessibilityTests {
    private static let largest = UIContentSizeCategory.accessibilityExtraExtraExtraLarge

    /// The reading hierarchy has to survive the whole Dynamic Type ramp.
    ///
    /// It did not before: display and title roles were capped at 1.4x while body copy was
    /// uncapped, so at the accessibility sizes a row title came out smaller than the
    /// subtitle beneath it. The caps are staggered now, and this is what holds them there.
    @Test("type roles keep their order at the largest accessibility size")
    func hierarchyHoldsAtLargestSize() {
        let descending: [HumayTypeRole] = [
            .displayXL, .displayL, .displayM, .titleM, .titleS,
        ]

        for (larger, smaller) in zip(descending, descending.dropFirst()) {
            let largerSize = larger.resolvedFont(at: Self.largest).pointSize
            let smallerSize = smaller.resolvedFont(at: Self.largest).pointSize
            #expect(
                largerSize > smallerSize,
                "\(larger) resolved to \(largerSize)pt, which is not above \(smaller) at \(smallerSize)pt"
            )
        }
    }

    /// A title set smaller than its own subtitle is the specific failure this guards.
    @Test(
        "a row title outgrows its supporting copy",
        arguments: [HumayTypeRole.callout, .label, .caption]
    )
    func rowTitleOutgrowsSupportingCopy(_ supporting: HumayTypeRole) {
        let title = HumayTypeRole.titleS.resolvedFont(at: Self.largest).pointSize
        let support = supporting.resolvedFont(at: Self.largest).pointSize
        #expect(title > support, "titleS at \(title)pt is not above \(supporting) at \(support)pt")
    }

    /// Reading prose is never capped. Someone who asks for the largest text gets it.
    @Test("reading roles are uncapped", arguments: [HumayTypeRole.body, .bodySmall, .callout])
    func readingRolesAreUncapped(_ role: HumayTypeRole) {
        #expect(role.maxScale == nil, "\(role) must not cap reading text")
    }

    /// Mono stays close to its base size so degree columns keep their alignment.
    @Test("mono roles stay tight", arguments: [HumayTypeRole.monoKicker, .monoFact, .monoDegree])
    func monoRolesStayTight(_ role: HumayTypeRole) {
        #expect(role.maxScale == 1.2)
    }

    /// The floor every interactive element is measured against.
    @Test("the minimum hit target is 44 points")
    func hitTargetMinimum() {
        #expect(HumayHitTarget.minimum == 44)
    }

    /// Icons are marks; the target around them is what has to reach 44pt. If a symbol
    /// were ever sized at the target it would mean someone had confused the two.
    @Test("no icon size is doing the work of a hit target")
    func iconSizesAreMarksNotTargets() {
        for size in [HumayIconSize.hint, HumayIconSize.row, HumayIconSize.inline, HumayIconSize.chrome] {
            #expect(size < HumayHitTarget.minimum)
        }
    }

    /// A withheld triad value is drawn differently from a real one, so the placeholder
    /// does not read as a mark that means something.
    @Test("a placeholder glyph is distinguishable from a real one")
    func placeholderGlyphIsDistinguishable() {
        let withheld = ChartTriad.Entry(
            id: "rising",
            label: "Rising",
            value: "—",
            glyph: ChartTriad.Entry.unavailableGlyph,
            glyphSpokenName: "Rising, not available"
        )
        let present = ChartTriad.Entry(
            id: "sun",
            label: "Sun",
            value: "Pisces",
            glyph: "♓",
            glyphSpokenName: "Pisces"
        )
        #expect(!withheld.hasGlyph)
        #expect(present.hasGlyph)
    }
}
