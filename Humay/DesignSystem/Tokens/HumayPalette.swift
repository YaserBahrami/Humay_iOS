import SwiftUI

/// The Humay palette, as locked by the brand reference.
///
/// Ink and Paper are *semantic surfaces*, not a light/dark theme pair. A future dark
/// appearance is a separate design decision and must not be implemented by inverting
/// these two values.
///
/// Adding an appearance later means adding one conforming struct and selecting it in
/// `HumayTheme`. No view changes.
protocol HumayPalette: Sendable {
    /// Primary text, and the dark surface ground where one is used.
    var ink: Color { get }
    /// Raised surface on ink.
    var slate: Color { get }
    /// The reading ground.
    var paper: Color { get }
    /// Accent at full strength. Stroke and state, never a large fill.
    var gilt: Color { get }
    /// Contrast-safe accent for body-size text on paper.
    var giltText: Color { get }
    /// Roast expression only. Never chrome, never a status colour.
    var cinnabar: Color { get }
}

/// The only place in the application where a colour literal appears.
struct PaperPalette: HumayPalette {
    let ink = Color(red: 0x12 / 255, green: 0x15 / 255, blue: 0x1C / 255)
    let slate = Color(red: 0x1B / 255, green: 0x20 / 255, blue: 0x2A / 255)
    let paper = Color(red: 0xF4 / 255, green: 0xF1 / 255, blue: 0xEA / 255)
    let gilt = Color(red: 0xB0 / 255, green: 0x86 / 255, blue: 0x3F / 255)
    let giltText = Color(red: 0x8A / 255, green: 0x65 / 255, blue: 0x24 / 255)
    let cinnabar = Color(red: 0xC2 / 255, green: 0x47 / 255, blue: 0x2A / 255)
}
