import SwiftUI

enum ChartWheelFocus: Hashable {
    case point(ChartPoint)
    case house(ChartHouse)
    case aspect(String)
}

struct ChartWheelView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: ChartWheelModel
    let focus: ChartWheelFocus
    let onSelect: (ChartWheelFocus) -> Void

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: diameter / 2, y: diameter / 2)

            ZStack {
                Circle()
                    .fill(Color.humaySurface.opacity(0.36))
                    .overlay {
                        Circle().stroke(Color.humayOrbit, lineWidth: 0.7)
                    }

                Circle()
                    .stroke(Color.humayOrbit.opacity(0.78), lineWidth: 0.65)
                    .padding(diameter * 0.105)

                Circle()
                    .stroke(Color.humayOrbit.opacity(0.58), lineWidth: 0.65)
                    .padding(diameter * 0.255)

                Canvas { context, size in
                    drawHouses(context: &context, size: size)
                    drawAspects(context: &context, size: size)
                }
                .accessibilityHidden(true)

                ForEach(Array(WesternZodiacSign.allCases.enumerated()), id: \.element) { index, sign in
                    Image(sign.glyphAssetName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.humayTextSecondary)
                        .frame(width: max(14, diameter * 0.045), height: max(14, diameter * 0.045))
                        .position(
                            point(
                                longitude: Double(index) * 30 + 15,
                                radius: diameter * 0.425,
                                center: center
                            )
                        )
                        .accessibilityHidden(true)
                }

                ForEach(model.houses) { house in
                    Button {
                        select(.house(house.number))
                    } label: {
                        Text("\(house.number.rawValue)")
                            .font(HumayTypography.micro)
                            .monospacedDigit()
                            .foregroundStyle(
                                focus == .house(house.number)
                                    ? Color.humayCanvas
                                    : Color.humayTextSecondary
                            )
                            .frame(width: 28, height: 28)
                            .background(
                                focus == .house(house.number)
                                    ? Color.humayChartSelected
                                    : Color.humaySurface.opacity(0.82),
                                in: Circle()
                            )
                    }
                    .buttonStyle(.plain)
                    .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                    .contentShape(Circle())
                    .position(
                        point(
                            longitude: house.cuspLongitudeDegrees + 15,
                            radius: diameter * 0.19,
                            center: center
                        )
                    )
                    .accessibilityLabel(house.number.label)
                    .accessibilityHint("Shows the house interpretation")
                }

                ForEach(model.placements) { placement in
                    Button {
                        select(.point(placement.point))
                    } label: {
                        ChartWheelMarker(
                            placement: placement,
                            isSelected: focus == .point(placement.point)
                        )
                    }
                    .buttonStyle(.plain)
                    .position(
                        point(
                            longitude: placement.position.longitudeDegrees,
                            radius: diameter * 0.31,
                            center: center
                        )
                    )
                    .accessibilityLabel(
                        "\(placement.point.label) in \(placement.position.sign.displayName), "
                            + ChartDegreeFormatter.string(for: placement.position.degreeWithinSign)
                    )
                    .accessibilityHint("Shows placement interpretation")
                }

                chartCenter
                    .frame(width: diameter * 0.17, height: diameter * 0.17)
                    .position(center)
            }
            .frame(width: diameter, height: diameter)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("chart.wheel.interactive")
    }

    @ViewBuilder
    private var chartCenter: some View {
        ZStack {
            Circle()
                .fill(Color.humayCanvas)
            Circle()
                .stroke(Color.humayAccentPrestige.opacity(0.72), lineWidth: 0.8)

            switch focus {
            case .point(let point):
                HumayChartPointGlyph(point: point)
                    .foregroundStyle(Color.humayAccentPrestige)
                    .padding(13)
            case .house(let house):
                Text("\(house.rawValue)")
                    .font(HumayTypography.technical)
                    .foregroundStyle(Color.humayAccentPrestige)
            case .aspect:
                HumayGlyph(kind: .connection)
                    .foregroundStyle(Color.humayAccentPrestige)
                    .padding(12)
            }
        }
        .accessibilityHidden(true)
    }

    private func select(_ newFocus: ChartWheelFocus) {
        if reduceMotion {
            onSelect(newFocus)
        } else {
            withAnimation(HumayMotion.selection(reduceMotion: false)) {
                onSelect(newFocus)
            }
        }
    }

    private func drawHouses(context: inout GraphicsContext, size: CGSize) {
        guard !model.houses.isEmpty else { return }
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let innerRadius = min(size.width, size.height) * 0.12
        let outerRadius = min(size.width, size.height) * 0.372

        for house in model.houses {
            var path = Path()
            path.move(to: point(longitude: house.cuspLongitudeDegrees, radius: innerRadius, center: center))
            path.addLine(to: point(longitude: house.cuspLongitudeDegrees, radius: outerRadius, center: center))
            context.stroke(path, with: .color(Color.humayOrbit.opacity(0.54)), lineWidth: 0.55)
        }
    }

    private func drawAspects(context: inout GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) * 0.245
        let longitudes = Dictionary(uniqueKeysWithValues: model.placements.map {
            ($0.point, $0.position.longitudeDegrees)
        })

        for aspect in model.aspects {
            guard let firstLongitude = longitudes[aspect.firstPoint],
                  let secondLongitude = longitudes[aspect.secondPoint] else {
                continue
            }

            var path = Path()
            path.move(to: point(longitude: firstLongitude, radius: radius, center: center))
            path.addLine(to: point(longitude: secondLongitude, radius: radius, center: center))
            context.stroke(
                path,
                with: .color(aspectColor(aspect).opacity(isFocused(aspect) ? 0.94 : 0.48)),
                style: StrokeStyle(
                    lineWidth: isFocused(aspect) ? 1.35 : 0.7,
                    dash: aspect.kind.isDynamic ? [3, 3] : []
                )
            )
        }
    }

    private func isFocused(_ aspect: ChartWheelAspect) -> Bool {
        focus == .aspect(aspect.id)
    }

    private func aspectColor(_ aspect: ChartWheelAspect) -> Color {
        switch aspect.kind {
        case .trine, .sextile: .humayChartHarmonious
        case .square, .opposition: .humayChartDynamic
        case .conjunction: .humayAccentPrestige
        }
    }

    private func point(longitude: Double, radius: CGFloat, center: CGPoint) -> CGPoint {
        let radians = (longitude - 90) * .pi / 180
        return CGPoint(
            x: center.x + CGFloat(cos(radians)) * radius,
            y: center.y + CGFloat(sin(radians)) * radius
        )
    }
}

struct HumayChartPointGlyph: View {
    let point: ChartPoint

    var body: some View {
        Group {
            if let assetName = point.glyphAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("AC")
                    .font(HumayTypography.micro)
                    .tracking(0.2)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct ChartWheelMarker: View {
    let placement: ChartWheelPlacement
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.humaySurface)
                .overlay {
                    Circle()
                        .stroke(pointColor, lineWidth: isSelected ? 1.8 : 0.75)
                }
                .shadow(color: isSelected ? pointColor.opacity(0.20) : .clear, radius: 8)

            HumayChartPointGlyph(point: placement.point)
                .foregroundStyle(pointColor)
                .padding(12)
        }
        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
        .scaleEffect(isSelected ? 1.06 : 1)
    }

    private var pointColor: Color {
        switch placement.point {
        case .sun: .humayAccentPrestige
        case .moon: .humayAccentCelestial
        case .ascendant: .humayAccentRoast
        default: .humayChartHarmonious
        }
    }
}

private extension ChartPoint {
    var glyphAssetName: String? {
        switch self {
        case .sun: "PlanetGlyphSun"
        case .moon: "PlanetGlyphMoon"
        case .mercury: "PlanetGlyphMercury"
        case .venus: "PlanetGlyphVenus"
        case .mars: "PlanetGlyphMars"
        case .jupiter: "PlanetGlyphJupiter"
        case .saturn: "PlanetGlyphSaturn"
        case .ascendant: nil
        }
    }
}

private extension WesternZodiacSign {
    var glyphAssetName: String {
        switch self {
        case .aries: "ZodiacGlyphAries"
        case .taurus: "ZodiacGlyphTaurus"
        case .gemini: "ZodiacGlyphGemini"
        case .cancer: "ZodiacGlyphCancer"
        case .leo: "ZodiacGlyphLeo"
        case .virgo: "ZodiacGlyphVirgo"
        case .libra: "ZodiacGlyphLibra"
        case .scorpio: "ZodiacGlyphScorpio"
        case .sagittarius: "ZodiacGlyphSagittarius"
        case .capricorn: "ZodiacGlyphCapricorn"
        case .aquarius: "ZodiacGlyphAquarius"
        case .pisces: "ZodiacGlyphPisces"
        }
    }
}

private extension WesternAspectKind {
    var isDynamic: Bool {
        self == .square || self == .opposition
    }
}
