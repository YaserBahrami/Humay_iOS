import SwiftUI

struct ChartWheelView: View {
    let model: ChartWheelModel

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)

            ZStack {
                Circle()
                    .fill(Color.humayGround.opacity(0.42))
                    .overlay {
                        Circle()
                            .stroke(Color.humayHairline, lineWidth: 1)
                    }

                Circle()
                    .stroke(Color.humayHairline.opacity(0.74), lineWidth: 1)
                    .padding(diameter * 0.12)

                Circle()
                    .stroke(Color.humayHairline.opacity(0.52), lineWidth: 1)
                    .padding(diameter * 0.27)

                Canvas { context, size in
                    drawAspects(context: &context, size: size)
                }

                if !model.houses.isEmpty {
                    ForEach(model.houses) { house in
                        Rectangle()
                            .fill(Color.humayHairline.opacity(0.52))
                            .frame(width: 1, height: diameter * 0.38)
                            .offset(y: -(diameter * 0.19))
                            .rotationEffect(.degrees(house.cuspLongitudeDegrees))
                            .accessibilityHidden(true)
                    }
                }

                ForEach(Array(WesternZodiacSign.allCases.enumerated()), id: \.element) { index, sign in
                    Text(String(sign.displayName.prefix(3)).uppercased())
                        .font(HumayTypography.micro)
                        .foregroundStyle(Color.humayTextSecondary)
                        .frame(width: 42, height: HumayMetrics.minimumHitTarget)
                        .position(
                            point(
                                longitude: Double(index) * 30 + 15,
                                radius: diameter * 0.405,
                                center: CGPoint(x: diameter / 2, y: diameter / 2)
                            )
                        )
                        .accessibilityHidden(true)
                }

                ForEach(model.placements) { placement in
                    ChartWheelMarker(placement: placement, isSelected: placement.point == model.selectedPoint)
                        .position(
                            point(
                                longitude: placement.position.longitudeDegrees,
                                radius: diameter * 0.30,
                                center: CGPoint(x: diameter / 2, y: diameter / 2)
                            )
                        )
                        .accessibilityHidden(true)
                }
            }
            .frame(width: diameter, height: diameter)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilitySummary)
        .accessibilityHint("An ordered placement list provides the same facts in reading order.")
        .accessibilityIdentifier("chart.wheel")
    }

    private func drawAspects(context: inout GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) * 0.23
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
                with: .color(Color.humayLavender.opacity(0.66)),
                style: StrokeStyle(lineWidth: 1, dash: [4, 3])
            )
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

private struct ChartWheelMarker: View {
    let placement: ChartWheelPlacement
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.humaySurface)
                .frame(width: 38, height: 38)
                .overlay {
                    Circle()
                        .stroke(pointColor, lineWidth: isSelected ? 2 : 1)
                }

            Text(String(placement.point.label.prefix(1)))
                .font(HumayTypography.utility)
                .foregroundStyle(pointColor)
        }
        .frame(width: 44, height: 44)
    }

    private var pointColor: Color {
        switch placement.point {
        case .sun: .humaySolarGold
        case .moon: .humayLavender
        case .ascendant: .humayCoral
        default: .humayCelestialBlue
        }
    }
}
