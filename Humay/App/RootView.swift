import SwiftUI

/// Deliberately minimal launch surface after the production-baseline reset.
///
/// Approved screens replace this placeholder one phase at a time. It uses only native
/// semantic colors so it remains valid in Light/Dark mode and at every iPhone/iPad size
/// while the new Humay design system is rebuilt from repository references.
struct RootView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            Text("Humay")
                .font(.system(size: 44, weight: .regular, design: .serif))
                .foregroundStyle(.primary)
                .accessibilityIdentifier("humay.foundation.title")
        }
    }
}

#Preview("iPhone") {
    RootView()
}

#Preview("iPad") {
    RootView()
        .previewDevice("iPad Pro 13-inch (M4)")
}
