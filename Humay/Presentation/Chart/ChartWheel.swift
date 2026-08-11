import SwiftUI

/// Wheel geometry. Pure maths, no SwiftUI and no domain types.
///
/// This layer already works in real ecliptic longitudes, so when a calculation service
/// replaces the fixtures nothing here changes — the numbers arriving are simply true.
struct ChartWheelGeometry: Sendable {
    /// Where the Ascendant sits, in ecliptic longitude. The wheel is drawn with it on
    /// the left, which is the convention every Western chart uses.
    let ascendantLongitude: Double

    /// Ecliptic longitude to screen angle.
    ///
    /// Longitude increases counter-clockwise; screen angles increase clockwise, so the
    /// sign flips. 180° places the Ascendant at the left of the circle.
    func screenAngle(forEclipticLongitude longitude: Double) -> Angle {
        .degrees(180 - (longitude - ascendantLongitude))
    }

    func point(longitude: Double, radius: CGFloat, centre: CGPoint) -> CGPoint {
        let angle = screenAngle(forEclipticLongitude: longitude).radians
        return CGPoint(
            x: centre.x + radius * cos(angle),
            y: centre.y - radius * sin(angle)
        )
    }

    /// Nudges crowded bodies apart so their glyphs stay readable.
    ///
    /// Purely a drawing concern — the returned values are for placing marks and are
    /// never written back onto a placement. A chart where two planets are genuinely
    /// eight arcminutes apart must keep saying eight arcminutes.
    func declutter(_ longitudes: [Double], minimumSeparation: Double = 7) -> [Double] {
        guard longitudes.count > 1 else { return longitudes }

        let indexed = longitudes.enumerated().sorted { $0.element < $1.element }
        var adjusted = indexed.map(\.element)

        for index in 1..<adjusted.count {
            let gap = adjusted[index] - adjusted[index - 1]
            if gap < minimumSeparation {
                adjusted[index] = adjusted[index - 1] + minimumSeparation
            }
        }

        var result = Array(repeating: 0.0, count: longitudes.count)
        for (position, original) in indexed.enumerated() {
            result[original.offset] = adjusted[position].truncatingRemainder(dividingBy: 360)
        }
        return result
    }
}

/// What the wheel draws.
///
/// Built by an explicit builder from a `WesternChart`, so the view never reaches into
/// the domain and the domain never knows a wheel exists.
struct ChartWheelModel: Sendable {
    struct Body: Sendable, Identifiable {
        let id: String
        let glyph: String
        let spokenName: String
        let longitude: Double
        let spokenPosition: String
        let isRetrograde: Bool
    }

    struct Cusp: Sendable, Identifiable {
        let id: Int
        let longitude: Double
        let spokenDescription: String
    }

    struct Chord: Sendable, Identifiable {
        let id: String
        let from: Double
        let to: Double
        let isEmphasised: Bool
        let spokenDescription: String
    }

    let bodies: [Body]
    let cusps: [Cusp]
    let chords: [Chord]
    let ascendantLongitude: Double
    let provenance: ContentProvenance
}

/// Builds a wheel from a Western chart.
///
/// Western only, deliberately. There is no builder taking a `VedicChart` or a
/// `ChineseChart`: a Vedic chart is drawn as a square bhava diagram and a BaZi chart has
/// no wheel at all. A generic "any chart" wheel would be exactly the flattening the
/// product is built to avoid.
enum ChartWheelModelBuilder {
    static func build(from chart: WesternChart) -> ChartWheelModel {
        // The same property a real ephemeris populates.
        let ascendant = chart.rising.value?.position.longitudeDegrees ?? 0

        let bodies = chart.placements.map { placement in
            ChartWheelModel.Body(
                id: placement.id,
                glyph: placement.planet.glyph,
                spokenName: placement.planet.spokenName,
                longitude: placement.position.longitudeDegrees,
                spokenPosition: placement.position.spokenPosition,
                isRetrograde: placement.isRetrograde
            )
        }

        let cusps = (chart.houses.value ?? []).map { house in
            ChartWheelModel.Cusp(
                id: house.id,
                longitude: house.cusp.longitudeDegrees,
                spokenDescription: house.spokenDescription
            )
        }

        let positions = Dictionary(
            uniqueKeysWithValues: chart.placements.map { ($0.planet, $0.position.longitudeDegrees) }
        )

        let chords = chart.aspects.prefix(14).compactMap { aspect -> ChartWheelModel.Chord? in
            guard
                let from = positions[aspect.first],
                let to = positions[aspect.second]
            else { return nil }
            return ChartWheelModel.Chord(
                id: aspect.id,
                from: from,
                to: to,
                isEmphasised: aspect.orbDegrees < 1,
                spokenDescription: aspect.spokenDescription
            )
        }

        return ChartWheelModel(
            bodies: bodies,
            cusps: cusps,
            chords: chords,
            ascendantLongitude: ascendant,
            provenance: chart.provenance
        )
    }
}

/// The wheel.
///
/// Drawn on a `Canvas` in one pass, and replaced entirely for assistive technology by a
/// navigable list — an image label saying "chart wheel" would be a description of the
/// picture rather than access to what it contains.
struct ChartWheelView: View {
    let model: ChartWheelModel

    @Environment(\.humayTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var chordProgress: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let centre = CGPoint(x: size.width / 2, y: size.height / 2)
            let outer = side * 0.46
            let inner = outer * 0.72
            let geometry = ChartWheelGeometry(ascendantLongitude: model.ascendantLongitude)

            draw(rings: context, centre: centre, outer: outer, inner: inner)
            draw(signDivisions: context, geometry: geometry, centre: centre, outer: outer, inner: inner)
            draw(cusps: context, geometry: geometry, centre: centre, inner: inner)
            draw(chords: context, geometry: geometry, centre: centre, radius: inner)
            draw(bodies: context, geometry: geometry, centre: centre, radius: (outer + inner) / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(reduceMotion ? HumayMotion.reducedCrossfade : HumayMotion.draw) {
                chordProgress = 1
            }
        }
        .accessibilityRepresentation {
            List {
                Section("Placements") {
                    ForEach(model.bodies) { body in
                        Text("\(body.spokenName), \(body.spokenPosition)\(body.isRetrograde ? ", retrograde" : "")")
                    }
                }
                if !model.cusps.isEmpty {
                    Section("House cusps") {
                        ForEach(model.cusps) { cusp in
                            Text(cusp.spokenDescription)
                        }
                    }
                }
                if !model.chords.isEmpty {
                    Section("Aspects") {
                        ForEach(model.chords) { chord in
                            Text(chord.spokenDescription)
                        }
                    }
                }
            }
        }
    }

    private func draw(rings context: GraphicsContext, centre: CGPoint, outer: CGFloat, inner: CGFloat) {
        for radius in [outer, inner] {
            let path = Path(ellipseIn: CGRect(
                x: centre.x - radius,
                y: centre.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
            context.stroke(path, with: .color(theme.colors.hairline), lineWidth: 1)
        }
    }

    private func draw(
        signDivisions context: GraphicsContext,
        geometry: ChartWheelGeometry,
        centre: CGPoint,
        outer: CGFloat,
        inner: CGFloat
    ) {
        for division in 0..<12 {
            let longitude = Double(division) * 30
            var path = Path()
            path.move(to: geometry.point(longitude: longitude, radius: inner, centre: centre))
            path.addLine(to: geometry.point(longitude: longitude, radius: outer, centre: centre))
            context.stroke(path, with: .color(theme.colors.hairline), lineWidth: 1)
        }
    }

    private func draw(
        cusps context: GraphicsContext,
        geometry: ChartWheelGeometry,
        centre: CGPoint,
        inner: CGFloat
    ) {
        for cusp in model.cusps {
            var path = Path()
            path.move(to: centre)
            path.addLine(to: geometry.point(longitude: cusp.longitude, radius: inner, centre: centre))
            context.stroke(
                path,
                with: .color(theme.colors.hairline.opacity(0.6)),
                lineWidth: cusp.id == 1 || cusp.id == 10 ? 1 : 0.5
            )
        }
    }

    private func draw(
        chords context: GraphicsContext,
        geometry: ChartWheelGeometry,
        centre: CGPoint,
        radius: CGFloat
    ) {
        for chord in model.chords {
            var path = Path()
            path.move(to: geometry.point(longitude: chord.from, radius: radius, centre: centre))
            path.addLine(to: geometry.point(longitude: chord.to, radius: radius, centre: centre))
            context.stroke(
                path,
                with: .color(chord.isEmphasised ? theme.colors.hairlineAccent : theme.colors.hairline),
                lineWidth: chord.isEmphasised ? 1 : 0.5
            )
        }
        _ = chordProgress
    }

    private func draw(
        bodies context: GraphicsContext,
        geometry: ChartWheelGeometry,
        centre: CGPoint,
        radius: CGFloat
    ) {
        let spread = geometry.declutter(model.bodies.map(\.longitude))
        for (index, body) in model.bodies.enumerated() {
            let point = geometry.point(longitude: spread[index], radius: radius, centre: centre)
            let text = Text(body.glyph)
                .font(.system(size: 13))
                .foregroundStyle(theme.colors.textPrimary)
            context.draw(text, at: point)
        }
    }
}
