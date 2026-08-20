import SwiftUI

/// Typed access to bundled Humay artwork and astrology glyphs.
///
/// Feature views describe meaning with enum cases instead of constructing asset-catalog
/// strings. This keeps replacement, rendering intent, and accessibility behavior in one place.
enum HumayAsset: Sendable, Hashable {
    case zodiac(WesternZodiacSign)
    case planet(WesternPlanet)
    case aspect(WesternAspectKind)
    case illustration(HumayIllustrationAsset)

    var catalogName: String {
        switch self {
        case .zodiac(let sign):
            "ZodiacGlyph\(sign.assetSuffix)"
        case .planet(let planet):
            "PlanetGlyph\(planet.assetSuffix)"
        case .aspect(let aspect):
            "AspectGlyph\(aspect.assetSuffix)"
        case .illustration(let illustration):
            illustration.rawValue
        }
    }

    var renderingMode: Image.TemplateRenderingMode {
        switch self {
        case .zodiac, .planet, .aspect:
            .template
        case .illustration:
            .original
        }
    }

    static var astrologyGlyphs: [Self] {
        WesternZodiacSign.allCases.map(Self.zodiac)
            + WesternPlanet.allCases.map(Self.planet)
            + WesternAspectKind.allCases.map(Self.aspect)
    }

    static var retainedAdaptiveArtwork: [Self] {
        HumayIllustrationAsset.allCases.map { .illustration($0) }
    }
}

enum HumayIllustrationAsset: String, CaseIterable, Sendable, Hashable {
    case askStars = "IllustrationAskStars"
    case calendarCelestial = "IllustrationCalendarCelestial"
    case cosmicCoffee = "IllustrationCosmicCoffee"
    case currentSky = "IllustrationCurrentSky"
    case profileReveal = "IllustrationProfileReveal"
    case traditionChinese = "IllustrationTraditionChinese"
    case traditionVedic = "IllustrationTraditionVedic"
    case traditionWestern = "IllustrationTraditionWestern"
}

/// Central rendering behavior for catalog artwork.
struct HumayAssetImage: View {
    let asset: HumayAsset
    var contentMode: ContentMode = .fit
    var accessibilityLabel: String?

    var body: some View {
        if let accessibilityLabel {
            image.accessibilityLabel(accessibilityLabel)
        } else {
            image.accessibilityHidden(true)
        }
    }

    private var image: some View {
        Image(asset.catalogName)
            .renderingMode(asset.renderingMode)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

/// Native interface concepts used where a custom asset would obscure meaning.
enum HumaySystemSymbol: String, Sendable, Hashable {
    case ask = "questionmark.bubble"
    case career = "briefcase"
    case chart = "circle.grid.cross"
    case challenge = "flag"
    case compatibility = "person.2"
    case currentSky = "moon.stars"
    case health = "cross.case"
    case insight = "lightbulb"
    case lifeThemes = "map"
    case love = "heart"
    case money = "dollarsign.circle"
    case offline = "wifi.slash"
    case personality = "person.crop.circle"
    case placements = "list.bullet"
    case privacy = "hand.raised"
    case reading = "text.book.closed"
    case roast = "flame"
    case strength = "star"
    case timing = "clock"
    case tradition = "books.vertical"
    case unavailable = "exclamationmark.triangle"
}

enum HumaySystemSymbolSize: Sendable, Hashable {
    case inline
    case compact
    case standard
    case feature

    var pointSize: CGFloat {
        switch self {
        case .inline: 15
        case .compact: 18
        case .standard: 21
        case .feature: 28
        }
    }

    var opticalFrame: CGFloat {
        switch self {
        case .inline: 24
        case .compact: 32
        case .standard: 36
        case .feature: 48
        }
    }
}

/// Consistent SF Symbol weight and optical frame for non-action interface concepts.
struct HumaySystemSymbolImage: View {
    let symbol: HumaySystemSymbol
    var size: HumaySystemSymbolSize = .standard

    var body: some View {
        Image(systemName: symbol.rawValue)
            .font(.system(size: size.pointSize, weight: .regular))
            .symbolRenderingMode(.monochrome)
            .frame(width: size.opticalFrame, height: size.opticalFrame)
            .accessibilityHidden(true)
    }
}

private extension WesternZodiacSign {
    var assetSuffix: String {
        switch self {
        case .aries: "Aries"
        case .taurus: "Taurus"
        case .gemini: "Gemini"
        case .cancer: "Cancer"
        case .leo: "Leo"
        case .virgo: "Virgo"
        case .libra: "Libra"
        case .scorpio: "Scorpio"
        case .sagittarius: "Sagittarius"
        case .capricorn: "Capricorn"
        case .aquarius: "Aquarius"
        case .pisces: "Pisces"
        }
    }
}

private extension WesternPlanet {
    var assetSuffix: String {
        switch self {
        case .sun: "Sun"
        case .moon: "Moon"
        case .mercury: "Mercury"
        case .venus: "Venus"
        case .mars: "Mars"
        case .jupiter: "Jupiter"
        case .saturn: "Saturn"
        case .uranus: "Uranus"
        case .neptune: "Neptune"
        case .pluto: "Pluto"
        }
    }
}

private extension WesternAspectKind {
    var assetSuffix: String {
        switch self {
        case .conjunction: "Conjunction"
        case .opposition: "Opposition"
        case .trine: "Trine"
        case .square: "Square"
        case .sextile: "Sextile"
        }
    }
}
