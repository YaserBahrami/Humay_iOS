import SwiftUI

/// The active appearance.
///
/// V1 ships Paper only. A future appearance is added by conforming another palette and
/// selecting it here — no view changes.
struct HumayTheme: Sendable {
    let colors: HumayColors

    static let paper = HumayTheme(colors: HumayColors(palette: PaperPalette()))
}

private struct HumayThemeKey: EnvironmentKey {
    static let defaultValue = HumayTheme.paper
}

extension EnvironmentValues {
    var humayTheme: HumayTheme {
        get { self[HumayThemeKey.self] }
        set { self[HumayThemeKey.self] = newValue }
    }
}

extension View {
    /// Applies the Humay ground colour and extends it under the safe areas.
    func humayBackground(_ theme: HumayTheme = .paper) -> some View {
        background(theme.colors.background.ignoresSafeArea())
    }
}
