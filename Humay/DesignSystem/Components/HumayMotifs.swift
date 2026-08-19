import SwiftUI

enum HumayGlyphKind: Sendable, Hashable {
    case orbit
    case feather
    case eye
    case connection
    case eclipse
    case crown
}

struct HumayGlyph: View {
    let kind: HumayGlyphKind

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                switch kind {
                case .orbit:
                    orbitalGlyph(size: size)
                case .feather:
                    HumayFeatherShape()
                        .stroke(style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
                        .padding(size * 0.10)
                case .eye:
                    eyeGlyph(size: size)
                case .connection:
                    connectionGlyph(size: size)
                case .eclipse:
                    eclipseGlyph(size: size)
                case .crown:
                    crownGlyph(size: size)
                }
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityHidden(true)
    }

    private func orbitalGlyph(size: CGFloat) -> some View {
        ZStack {
            Ellipse()
                .stroke(lineWidth: 1.2)
                .frame(width: size * 0.88, height: size * 0.42)
                .rotationEffect(.degrees(-20))
            Ellipse()
                .stroke(lineWidth: 0.8)
                .frame(width: size * 0.72, height: size * 0.30)
                .rotationEffect(.degrees(38))
            Circle()
                .fill(.tint)
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: size * 0.31, y: -size * 0.14)
        }
    }

    private func eyeGlyph(size: CGFloat) -> some View {
        ZStack {
            HumayEyeShape()
                .stroke(lineWidth: 1.3)
                .frame(width: size * 0.88, height: size * 0.50)
            Circle()
                .fill(.tint)
                .frame(width: size * 0.15, height: size * 0.15)
        }
    }

    private func connectionGlyph(size: CGFloat) -> some View {
        ZStack {
            Ellipse()
                .stroke(lineWidth: 1.1)
                .frame(width: size * 0.68, height: size * 0.42)
                .rotationEffect(.degrees(34))
                .offset(x: -size * 0.12)
            Ellipse()
                .stroke(lineWidth: 1.1)
                .frame(width: size * 0.68, height: size * 0.42)
                .rotationEffect(.degrees(-34))
                .offset(x: size * 0.12)
            Circle()
                .fill(.tint)
                .frame(width: size * 0.10, height: size * 0.10)
        }
    }

    private func eclipseGlyph(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 1)
                .frame(width: size * 0.64, height: size * 0.64)
            Circle()
                .fill(.tint)
                .frame(width: size * 0.56, height: size * 0.56)
                .offset(x: size * 0.16)
        }
    }

    private func crownGlyph(size: CGFloat) -> some View {
        ZStack {
            HumayFeatherShape()
                .stroke(lineWidth: 1.2)
                .frame(width: size * 0.32, height: size * 0.72)
                .offset(y: size * 0.02)
            HumayFeatherShape()
                .stroke(lineWidth: 1)
                .frame(width: size * 0.26, height: size * 0.58)
                .rotationEffect(.degrees(-28), anchor: .bottom)
                .offset(x: -size * 0.15, y: size * 0.08)
            HumayFeatherShape()
                .stroke(lineWidth: 1)
                .frame(width: size * 0.26, height: size * 0.58)
                .rotationEffect(.degrees(28), anchor: .bottom)
                .offset(x: size * 0.15, y: size * 0.08)
        }
    }
}

struct HumayFeatherShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stemBottom = CGPoint(x: rect.midX * 0.82, y: rect.maxY)
        let tip = CGPoint(x: rect.midX * 1.18, y: rect.minY)

        path.move(to: stemBottom)
        path.addCurve(
            to: tip,
            control1: CGPoint(x: rect.width * 0.42, y: rect.height * 0.64),
            control2: CGPoint(x: rect.width * 0.48, y: rect.height * 0.20)
        )
        path.addCurve(
            to: stemBottom,
            control1: CGPoint(x: rect.width * 0.94, y: rect.height * 0.22),
            control2: CGPoint(x: rect.width * 0.82, y: rect.height * 0.76)
        )

        path.move(to: stemBottom)
        path.addCurve(
            to: tip,
            control1: CGPoint(x: rect.width * 0.54, y: rect.height * 0.64),
            control2: CGPoint(x: rect.width * 0.58, y: rect.height * 0.25)
        )

        for fraction in [0.34, 0.50, 0.66, 0.80] {
            let y = rect.height * fraction
            let x = rect.width * (0.54 - fraction * 0.05)
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: rect.width * 0.18, y: y + rect.height * 0.10))
        }

        return path
    }
}

struct HumayEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.width * 0.26, y: rect.minY),
            control2: CGPoint(x: rect.width * 0.74, y: rect.minY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control1: CGPoint(x: rect.width * 0.74, y: rect.maxY),
            control2: CGPoint(x: rect.width * 0.26, y: rect.maxY)
        )
        return path
    }
}

struct HumayWingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let root = CGPoint(x: rect.maxX, y: rect.height * 0.72)
        let crown = CGPoint(x: rect.width * 0.64, y: rect.height * 0.10)

        path.move(to: root)
        path.addCurve(
            to: crown,
            control1: CGPoint(x: rect.width * 0.88, y: rect.height * 0.48),
            control2: CGPoint(x: rect.width * 0.82, y: rect.height * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.02, y: rect.height * 0.56),
            control1: CGPoint(x: rect.width * 0.40, y: rect.height * 0.04),
            control2: CGPoint(x: rect.width * 0.10, y: rect.height * 0.24)
        )
        path.addCurve(
            to: root,
            control1: CGPoint(x: rect.width * 0.22, y: rect.height * 0.62),
            control2: CGPoint(x: rect.width * 0.60, y: rect.height * 0.66)
        )

        for offset in stride(from: 0.20, through: 0.62, by: 0.14) {
            path.move(to: CGPoint(x: rect.width * 0.78, y: rect.height * offset))
            path.addCurve(
                to: CGPoint(x: rect.width * 0.14, y: rect.height * (offset + 0.22)),
                control1: CGPoint(x: rect.width * 0.56, y: rect.height * (offset + 0.02)),
                control2: CGPoint(x: rect.width * 0.30, y: rect.height * (offset + 0.12))
            )
        }

        return path
    }
}

struct HumayHumaMark: View {
    var lineColor: Color = .humayAccentPrestige

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                HumayWingShape()
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 1.15, lineCap: .round, lineJoin: .round))
                    .frame(width: size * 0.44, height: size * 0.56)
                    .offset(x: -size * 0.21, y: size * 0.03)

                HumayWingShape()
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 1.15, lineCap: .round, lineJoin: .round))
                    .scaleEffect(x: -1, y: 1)
                    .frame(width: size * 0.44, height: size * 0.56)
                    .offset(x: size * 0.21, y: size * 0.03)

                Circle()
                    .stroke(lineColor.opacity(0.78), lineWidth: 1)
                    .frame(width: size * 0.23, height: size * 0.23)
                    .offset(y: size * 0.04)

                HumayEyeShape()
                    .stroke(lineColor, lineWidth: 1.15)
                    .frame(width: size * 0.15, height: size * 0.075)
                    .offset(y: size * 0.04)

                Circle()
                    .fill(lineColor)
                    .frame(width: size * 0.025, height: size * 0.025)
                    .offset(y: size * 0.04)

                HumayFeatherShape()
                    .stroke(lineColor, lineWidth: 1)
                    .frame(width: size * 0.10, height: size * 0.20)
                    .offset(y: -size * 0.20)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityHidden(true)
    }
}

struct HumayCelestialStage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var compact = false

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                Ellipse()
                    .trim(from: 0, to: revealed ? 1 : 0.12)
                    .stroke(Color.humayOrbit.opacity(0.82), lineWidth: HumayMetrics.orbitalLineWidth)
                    .frame(width: size * 0.94, height: size * 0.55)
                    .rotationEffect(.degrees(-18))

                Ellipse()
                    .trim(from: 0, to: revealed ? 1 : 0.08)
                    .stroke(Color.humayAccentCelestial.opacity(0.58), lineWidth: HumayMetrics.orbitalLineWidth)
                    .frame(width: size * 0.76, height: size * 0.42)
                    .rotationEffect(.degrees(42))

                Circle()
                    .fill(Color.humayAccentPrestige)
                    .frame(width: max(6, size * 0.035), height: max(6, size * 0.035))
                    .offset(x: size * 0.36, y: -size * 0.13)
                    .opacity(revealed ? 1 : 0)

                HumayHumaMark()
                    .frame(width: size * (compact ? 0.52 : 0.58), height: size * (compact ? 0.52 : 0.58))
                    .scaleEffect(revealed || reduceMotion ? 1 : 0.92)
                    .opacity(revealed || reduceMotion ? 1 : 0)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if reduceMotion {
                    revealed = true
                } else {
                    withAnimation(HumayMotion.reveal(reduceMotion: false)) {
                        revealed = true
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}

struct HumayConnectionMotif: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Ellipse()
                    .stroke(Color.humayAccentCelestial.opacity(0.72), lineWidth: 1)
                    .frame(width: width * 0.70, height: height * 0.56)
                    .rotationEffect(.degrees(18))
                    .offset(x: -width * 0.10)

                Ellipse()
                    .stroke(Color.humayAccentPrestige.opacity(0.82), lineWidth: 1)
                    .frame(width: width * 0.70, height: height * 0.56)
                    .rotationEffect(.degrees(-18))
                    .offset(x: width * 0.10)

                HumayFeatherShape()
                    .stroke(Color.humayAccentPrestige.opacity(0.72), lineWidth: 1)
                    .frame(width: min(width, height) * 0.18, height: min(width, height) * 0.34)
                    .rotationEffect(.degrees(26))

                Circle()
                    .fill(Color.humayAccentPrestige)
                    .frame(width: 6, height: 6)
                    .offset(x: width * 0.27, y: -height * 0.18)
            }
            .frame(width: width, height: height)
        }
        .accessibilityHidden(true)
    }
}
