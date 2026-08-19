import Testing
import UIKit
@testable import Humay

@Suite("Premium Celestial design system")
struct DesignSystemFoundationTests {
    @Test("Every semantic color role has Light and Dark asset variants")
    func semanticColorsExist() {
        let assetNames = [
            "HumayGround",
            "HumaySurface",
            "HumayRaisedSurface",
            "HumayTextPrimary",
            "HumayTextSecondary",
            "HumayHairline",
            "HumayCoral",
            "HumayLavender",
            "HumaySolarGold",
            "HumayCelestialBlue",
            "HumaySage"
        ]

        #expect(HumayColorRole.allCases.count == assetNames.count)

        for assetName in assetNames {
            let lightColor = UIColor(
                named: assetName,
                in: .main,
                compatibleWith: lightTraits
            )?.resolvedColor(with: lightTraits)
            let darkColor = UIColor(
                named: assetName,
                in: .main,
                compatibleWith: darkTraits
            )?.resolvedColor(with: darkTraits)
            #expect(lightColor != nil)
            #expect(darkColor != nil)
            #expect(lightColor != darkColor)
        }
    }

    @Test("Typed astrology glyphs resolve for Light and Dark")
    func astrologyGlyphsExist() {
        let assetNames = HumayAsset.astrologyGlyphs.map(\.catalogName)
        let expectedAssetNames: Set = [
            "ZodiacGlyphAries", "ZodiacGlyphTaurus", "ZodiacGlyphGemini",
            "ZodiacGlyphCancer", "ZodiacGlyphLeo", "ZodiacGlyphVirgo",
            "ZodiacGlyphLibra", "ZodiacGlyphScorpio", "ZodiacGlyphSagittarius",
            "ZodiacGlyphCapricorn", "ZodiacGlyphAquarius", "ZodiacGlyphPisces",
            "PlanetGlyphSun", "PlanetGlyphMoon", "PlanetGlyphMercury",
            "PlanetGlyphVenus", "PlanetGlyphMars", "PlanetGlyphJupiter",
            "PlanetGlyphSaturn", "PlanetGlyphUranus", "PlanetGlyphNeptune",
            "PlanetGlyphPluto", "AspectGlyphConjunction", "AspectGlyphOpposition",
            "AspectGlyphTrine", "AspectGlyphSquare", "AspectGlyphSextile"
        ]

        #expect(assetNames.count == 27)
        #expect(Set(assetNames) == expectedAssetNames)
        #expect(Set(assetNames).count == assetNames.count)

        for assetName in assetNames {
            let lightImage = UIImage(
                named: assetName,
                in: .main,
                compatibleWith: lightTraits
            )
            let darkImage = UIImage(
                named: assetName,
                in: .main,
                compatibleWith: darkTraits
            )

            #expect(lightImage != nil, "Missing Light glyph: \(assetName)")
            #expect(darkImage != nil, "Missing Dark glyph: \(assetName)")
        }
    }

    @Test("Retained adaptive artwork resolves through typed access")
    func retainedAdaptiveArtworkExists() {
        let assetNames = HumayAsset.retainedAdaptiveArtwork.map(\.catalogName)

        #expect(assetNames.count == 22)
        #expect(Set(assetNames).count == assetNames.count)

        for assetName in assetNames {
            #expect(UIImage(named: assetName, in: .main, compatibleWith: lightTraits) != nil)
            #expect(UIImage(named: assetName, in: .main, compatibleWith: darkTraits) != nil)
        }
    }

    @Test("Text and primary action combinations meet normal-text contrast")
    func semanticContrast() throws {
        let combinations = [
            ("HumayTextPrimary", "HumayGround", lightTraits),
            ("HumayTextSecondary", "HumayGround", lightTraits),
            ("HumayTextPrimary", "HumayGround", darkTraits),
            ("HumayTextSecondary", "HumayGround", darkTraits),
            ("HumayGround", "HumayCoral", darkTraits),
            ("HumayGround", "HumayLavender", darkTraits)
        ]

        for (foreground, background, traits) in combinations {
            let ratio = try contrastRatio(
                foreground: resolvedColor(named: foreground, traits: traits),
                background: resolvedColor(named: background, traits: traits)
            )
            #expect(ratio >= 4.5)
        }
    }

    @Test("Committed Cormorant Garamond display font loads")
    func cormorantLoads() {
        #expect(UIFont(name: "CormorantGaramond-Regular", size: 24) != nil)
        #expect(UIFont(name: "CormorantGaramond-Light", size: 24) != nil)
    }

    @Test("Interactive and hairline metrics preserve platform minimums")
    func interactionMetrics() {
        #expect(HumayMetrics.minimumHitTarget == 44)
        #expect(HumayMetrics.primaryControlMinimumHeight == 54)
        #expect(HumayMetrics.primaryControlMinimumHeight >= HumayMetrics.minimumHitTarget)
        #expect(HumayMetrics.hairline(displayScale: 2) == 0.5)
        #expect(HumayMetrics.hairline(displayScale: 3) < 0.34)
    }

    @Test("Adaptive columns stay inset on phone and bounded on iPad")
    func adaptiveLayoutWidths() {
        #expect(HumayLayout.screenGutter(for: 393) == 20)
        #expect(HumayLayout.contentWidth(for: 393, maximum: .readable) == 353)
        #expect(HumayLayout.screenGutter(for: 600) == 28)
        #expect(HumayLayout.contentWidth(for: 600, maximum: .form) == 544)
        #expect(HumayLayout.screenGutter(for: 1024) == 40)
        #expect(HumayLayout.contentWidth(for: 1024, maximum: .readable) == 680)
        #expect(HumayLayout.contentWidth(for: 1366, maximum: .expanded) == 960)
    }

    private var lightTraits: UITraitCollection {
        UITraitCollection(userInterfaceStyle: .light)
    }

    private var darkTraits: UITraitCollection {
        UITraitCollection(userInterfaceStyle: .dark)
    }

    private func resolvedColor(
        named name: String,
        traits: UITraitCollection
    ) throws -> UIColor {
        let color = try #require(
            UIColor(named: name, in: .main, compatibleWith: traits)
        )
        return color.resolvedColor(with: traits)
    }

    private func contrastRatio(foreground: UIColor, background: UIColor) throws -> CGFloat {
        let foregroundLuminance = try relativeLuminance(foreground)
        let backgroundLuminance = try relativeLuminance(background)
        let lighter = max(foregroundLuminance, backgroundLuminance)
        let darker = min(foregroundLuminance, backgroundLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func relativeLuminance(_ color: UIColor) throws -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let converted = color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #expect(converted)

        func linearized(_ component: CGFloat) -> CGFloat {
            component <= 0.04045
                ? component / 12.92
                : pow((component + 0.055) / 1.055, 2.4)
        }

        return (0.2126 * linearized(red))
            + (0.7152 * linearized(green))
            + (0.0722 * linearized(blue))
    }
}
