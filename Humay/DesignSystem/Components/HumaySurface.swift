import SwiftUI

enum HumaySurfaceLevel {
    case standard
    case raised
}

struct HumaySurface<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    private let level: HumaySurfaceLevel
    private let padding: CGFloat
    private let content: Content

    init(
        level: HumaySurfaceLevel = .standard,
        padding: CGFloat = HumaySpacing.extraLarge,
        @ViewBuilder content: () -> Content
    ) {
        self.level = level
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface)
                    .strokeBorder(
                        Color.humayHairline,
                        lineWidth: HumayMetrics.hairline(displayScale: displayScale)
                    )
            }
            .shadow(
                color: shadowColor,
                radius: colorScheme == .light ? HumayElevation.subtleShadowRadius : 0,
                y: colorScheme == .light ? HumayElevation.subtleShadowY : 0
            )
    }

    private var backgroundColor: Color {
        switch level {
        case .standard:
            .humaySurface
        case .raised:
            .humayRaisedSurface
        }
    }

    private var shadowColor: Color {
        colorScheme == .light
            ? .black.opacity(HumayElevation.subtleShadowOpacity)
            : .clear
    }
}
