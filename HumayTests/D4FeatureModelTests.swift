import Foundation
import Testing
@testable import Humay

@Suite("D4 Chart feature contracts")
struct D4FeatureModelTests {
    @Test("Production composition stays unavailable and payload-free")
    func productionCompositionStaysUnavailable() {
        let input = D4FeatureInput.productionUnavailable

        #expect(input.source == .productionUnavailable)
        #expect(!input.source.isDevelopmentSample)
        #expect(input.chart.payload == nil)
        #expect(input.chart.payload?.western?.placement(for: .sun) == nil)
        #expect(input.chart.payload?.western?.placement(for: .moon) == nil)
        #expect(input.chart.payload?.western?.placement(for: .ascendant) == nil)
        #expect(input.chart.payload?.western?.wheel.houses.count == nil)

        let releaseCopy = [
            ChartProductCopy.freeTitle,
            ChartProductCopy.freeDescription,
            ChartProductCopy.precisionTitle,
            ChartProductCopy.precisionDescription,
            ChartProductCopy.freeBannerTitle,
            ChartProductCopy.freeBannerDetail
        ]
        let engineeringTerms = [
            "foundation", "next layer", "provider", "service", "implementation",
            "development sample", "not calculated"
        ]
        for sentence in releaseCopy {
            for term in engineeringTerms {
                #expect(!sentence.localizedCaseInsensitiveContains(term))
            }
        }

        guard case .freePreview(let readiness) = input.chart else {
            Issue.record("Production Chart foundation should remain an explicit free entry")
            return
        }
        #expect(readiness.birthTime == .unknown)
        #expect(readiness.birthPlace.isAvailable == false)
    }

    @Test("Free preview contains readiness but no calculated facts")
    func freePreviewContainsReadinessOnly() {
        let input = D4FeatureInput(
            source: .developmentSample,
            chart: .freePreview(ChartReadiness(
                birthDate: .supplied(detail: "14 March 1994"),
                birthTime: .unknown,
                birthPlace: .notProvided(detail: "Not provided")
            ))
        )

        #expect(input.chart.payload == nil)
        guard case .freePreview(let readiness) = input.chart else {
            Issue.record("Expected free preview state")
            return
        }
        #expect(readiness.birthTime == .unknown)
        #expect(readiness.birthPlace.detail == "Not provided")
    }

#if DEBUG
    @Test("Known-time fixture is deterministic and typed")
    func knownTimeFixtureIsDeterministic() throws {
        let input = DevelopmentD4Sample.makeInput(arguments: [
            "-HumayD4ChartState", "loaded"
        ])

        #expect(input.source == .developmentSample)
        guard case .loaded(let payload) = input.chart,
              case .western(let chart) = payload else {
            Issue.record("Expected loaded Western development fixture")
            return
        }

        let sun = try #require(chart.placement(for: .sun))
        let moon = try #require(chart.placement(for: .moon))
        let ascendant = try #require(chart.placement(for: .ascendant))

        #expect(sun.position.sign == .aquarius)
        #expect(moon.position.sign == .libra)
        #expect(ascendant.position.sign == .gemini)
        #expect(moon.degreeText == "14° 27′")
        #expect(ascendant.degreeText == "03° 02′")
        #expect(moon.house == .fifth)
        #expect(chart.wheel.houses.count == 12)
        #expect(chart.wheel.aspects.contains { $0.kind == .trine })
    }

    @Test("Unknown time withholds ascendant and houses without substituting a time")
    func unknownTimeWithholdsPrecisionFacts() throws {
        let input = DevelopmentD4Sample.makeInput(arguments: [
            "-HumayD4ChartState", "unknown-time"
        ])

        guard case .insufficientBirthPrecision(let context, let missingInputs) = input.chart,
              case .unknownTime(let unknownTime) = context else {
            Issue.record("Expected explicit unknown-time precision state")
            return
        }

        #expect(missingInputs == [.birthTime, .birthPlace])
        #expect(unknownTime.knownFact.point == .sun)
        #expect(unknownTime.knownFact.sign == .pisces)
        #expect(unknownTime.knownFact.reliability == .reliable)
        let storedPropertyNames = Set(Mirror(reflecting: unknownTime.knownFact).children.compactMap(\.label))
        #expect(storedPropertyNames.contains("point"))
        #expect(storedPropertyNames.contains("sign"))
        #expect(storedPropertyNames.contains("reliability"))
        #expect(!storedPropertyNames.contains("position"))
        #expect(!storedPropertyNames.contains("degree"))
        #expect(!storedPropertyNames.contains("house"))
        #expect(unknownTime.withheldFacts.contains(.ascendant))
        #expect(unknownTime.withheldFacts.contains(.houses))
        #expect(input.chart.payload == nil)
        #expect(unknownTime.readiness.birthTime == .unknown)

        let readiness = DevelopmentD4Sample.unknownTimeReadiness
        #expect(readiness.birthTime == .unknown)
        #expect(readiness.birthPlace.isAvailable == false)
    }

    @Test("Cache and offline states preserve the same chart payload")
    func cacheStatesPreservePayload() {
        let loaded = DevelopmentD4Sample.knownTimeChart
        let savedAt = Date(timeIntervalSince1970: 1_710_432_000)
        let cached = D4FeatureState.cached(loaded, savedAt: savedAt)
        let offline = D4FeatureState.offlineCached(loaded, savedAt: savedAt)

        #expect(cached.payload == loaded)
        #expect(offline.payload == loaded)
        #expect(cached != offline)
    }

    @Test("Development launch arguments expose every typed state")
    func developmentStateVariants() {
        let states: [(String, (D4FeatureState) -> Bool)] = [
            ("loading", { if case .loading = $0 { true } else { false } }),
            ("locked", { if case .precisionLocked = $0 { true } else { false } }),
            ("available", { if case .generationAvailable = $0 { true } else { false } }),
            ("loaded", { if case .loaded = $0 { true } else { false } }),
            ("cached", { if case .cached = $0 { true } else { false } }),
            ("offline", { if case .offlineCached = $0 { true } else { false } }),
            ("offline-empty", { if case .offlineNoCache = $0 { true } else { false } }),
            ("unsupported", { if case .unsupportedMethodology = $0 { true } else { false } }),
            ("unknown-time", { if case .insufficientBirthPrecision = $0 { true } else { false } }),
            ("failed", { if case .failed = $0 { true } else { false } })
        ]

        for (argument, matches) in states {
            let input = DevelopmentD4Sample.makeInput(arguments: [
                "-HumayD4ChartState", argument
            ])
            #expect(matches(input.chart), "Unexpected state for \(argument)")
        }
    }

    @Test("Chart degree formatter stays within one sign")
    func chartDegreeFormatterStaysWithinOneSign() {
        let values: [(Double, String)] = [
            (0, "00° 00′"),
            (-1, "00° 00′"),
            (14.45, "14° 27′"),
            (29.0, "29° 00′"),
            (29.99, "29° 59′"),
            (29.999999, "29° 59′"),
            (30, "29° 59′"),
            (42, "29° 59′"),
            (Double.nan, "00° 00′")
        ]

        for (value, expected) in values {
            let formatted = ChartDegreeFormatter.string(for: value)
            #expect(formatted == expected)
            #expect(!formatted.contains("60′"))
            #expect(!formatted.hasPrefix("30°"))
        }
    }

    @Test("Other chart formatters keep values legible")
    func otherChartFormatters() {
        #expect(ChartDegreeFormatter.string(for: 3.0333) == "03° 02′")
        #expect(ChartReliabilityFormatter.string(for: .reliable) == "Reliable")
        #expect(
            ChartReliabilityFormatter.string(for: .unavailable(.missingBirthTime))
                == "Unavailable without birth time"
        )
    }
#endif
}
