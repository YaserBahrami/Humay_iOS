import CoreGraphics
import SwiftUI
import Testing
@testable import Humay

/// Pure geometry, no view involved.
///
/// This is the one place a silent visual bug would be invisible in review — a wheel
/// drawn with the wrong handedness still looks like a chart.
@Suite("Chart wheel geometry")
struct ChartWheelGeometryTests {
    private let geometry = ChartWheelGeometry(ascendantLongitude: 0)

    @Test("the Ascendant sits at the left of the wheel")
    func ascendantIsLeft() {
        #expect(geometry.screenAngle(forEclipticLongitude: 0).degrees == 180)
    }

    /// Ecliptic longitude increases counter-clockwise; screen angles increase clockwise.
    @Test("longitude and screen angle run in opposite directions")
    func handedness() {
        let first = geometry.screenAngle(forEclipticLongitude: 30).degrees
        let second = geometry.screenAngle(forEclipticLongitude: 60).degrees
        #expect(second < first)
    }

    @Test("rotating the Ascendant rotates the whole wheel with it")
    func ascendantRotation() {
        let rotated = ChartWheelGeometry(ascendantLongitude: 90)
        #expect(rotated.screenAngle(forEclipticLongitude: 90).degrees == 180)
        // A body ninety degrees from the Ascendant keeps that separation.
        let base = geometry.screenAngle(forEclipticLongitude: 90).degrees
        let moved = rotated.screenAngle(forEclipticLongitude: 180).degrees
        #expect(base == moved)
    }

    @Test("a point at zero radius is the centre")
    func centrePoint() {
        let centre = CGPoint(x: 100, y: 100)
        let point = geometry.point(longitude: 42, radius: 0, centre: centre)
        #expect(abs(point.x - centre.x) < 0.001)
        #expect(abs(point.y - centre.y) < 0.001)
    }

    @Test("a point sits on the circle of the given radius")
    func radiusIsHonoured() {
        let centre = CGPoint(x: 0, y: 0)
        for longitude in stride(from: 0.0, to: 360.0, by: 37) {
            let point = geometry.point(longitude: longitude, radius: 50, centre: centre)
            let distance = (point.x * point.x + point.y * point.y).squareRoot()
            #expect(abs(distance - 50) < 0.001)
        }
    }

    @Test("declutter preserves count and order")
    func declutterKeepsOrder() {
        let input = [10.0, 12.0, 13.0, 200.0]
        let output = geometry.declutter(input, minimumSeparation: 7)
        #expect(output.count == input.count)
        // The crowded trio stays in the same relative order it arrived in.
        #expect(output[0] < output[1])
        #expect(output[1] < output[2])
    }

    @Test("declutter separates crowded bodies")
    func declutterSeparates() {
        let output = geometry.declutter([10.0, 12.0, 13.0], minimumSeparation: 7)
        let sorted = output.sorted()
        for index in 1..<sorted.count {
            #expect(sorted[index] - sorted[index - 1] >= 6.99)
        }
    }

    @Test("declutter leaves already-separated bodies alone")
    func declutterIsIdempotentWhenSpaced() {
        let input = [0.0, 90.0, 180.0, 270.0]
        #expect(geometry.declutter(input, minimumSeparation: 7) == input)
    }

    /// The wheel must never write its layout adjustments back onto the chart: a chart
    /// where two bodies are eight arcminutes apart has to keep saying eight arcminutes.
    @Test("declutter is a drawing concern only")
    func declutterDoesNotMutateSource() {
        let input = [10.0, 11.0]
        _ = geometry.declutter(input, minimumSeparation: 20)
        #expect(input == [10.0, 11.0])
    }
}

@Suite("Ecliptic")
struct EclipticTests {
    @Test("longitude maps to the expected sign")
    func signBoundaries() {
        #expect(Ecliptic(longitudeDegrees: 0).sign == .aries)
        #expect(Ecliptic(longitudeDegrees: 29.99).sign == .aries)
        #expect(Ecliptic(longitudeDegrees: 30).sign == .taurus)
        #expect(Ecliptic(longitudeDegrees: 359.9).sign == .pisces)
    }

    @Test("longitude wraps")
    func wrapping() {
        #expect(Ecliptic(longitudeDegrees: 370).longitudeDegrees == 10)
        #expect(Ecliptic(longitudeDegrees: -10).longitudeDegrees == 350)
    }

    @Test("degrees within a sign are formatted for a mono readout")
    func formatting() {
        let position = Ecliptic(longitudeDegrees: 334.2)
        #expect(position.sign == .pisces)
        #expect(position.degreeInSign == 4)
        #expect(position.arcminuteInSign == 12)
        #expect(position.degreeFormatted == "4° 12′")
    }

    @Test("the spoken form names the sign rather than the symbol")
    func spokenForm() {
        #expect(Ecliptic(longitudeDegrees: 334.2).spokenPosition.contains("Pisces"))
    }
}
