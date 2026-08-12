import SwiftUI

enum HumayAccent: Sendable, Hashable {
    case coral
    case lavender
    case gold
    case blue
    case sage

    var color: Color {
        switch self {
        case .coral: .humayCoral
        case .lavender: .humayLavender
        case .gold: .humaySolarGold
        case .blue: .humayCelestialBlue
        case .sage: .humaySage
        }
    }
}

struct D2WordmarkHeader: View {
    let title: String?
    let profileName: String
    let profileAction: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: HumaySpacing.large) {
            if let title {
                Text(title)
                    .font(HumayTypography.editorialTitle)
                    .foregroundStyle(Color.humayTextPrimary)
                    .accessibilityAddTraits(.isHeader)
            } else {
                Text("humay")
                    .font(HumayTypography.wordmark)
                    .foregroundStyle(wordmarkColor)
                    .accessibilityLabel("Humay")
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("main.today.wordmark")
            }

            Spacer(minLength: HumaySpacing.medium)

            Button(action: profileAction) {
                profileFallback
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.humayHairline))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile and settings")
            .accessibilityHint("Opens your profile and settings")
            .accessibilityIdentifier("main.profile.button")
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget)
    }

    private var wordmarkColor: Color {
        colorScheme == .dark ? .humayCoral : .humayTextPrimary
    }

    private var profileFallback: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.humayCelestialBlue.opacity(0.72),
                            Color.humayLavender.opacity(0.86)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(initials)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.humayTextPrimary)
        }
    }

    private var initials: String {
        profileName
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
            .nonempty ?? "H"
    }
}

struct D2SampleNotice: View {
    let source: D2ContentSource

    var body: some View {
        if source.isDevelopmentSample {
            Label("Development sample · not calculated", systemImage: "hammer.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.humayTextSecondary)
                .padding(.horizontal, HumaySpacing.medium)
                .padding(.vertical, HumaySpacing.small)
                .background(Color.humayRaisedSurface, in: Capsule())
                .accessibilityIdentifier("d2.development-sample.notice")
        }
    }
}

struct D2StatusBanner: View {
    let symbol: String
    let title: String
    let detail: String
    var accent: HumayAccent = .blue

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(accent.color)
                .frame(width: 32, height: 32)
                .background(accent.color.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(title)
                    .font(HumayTypography.bodyEmphasized)
                Text(detail)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HumaySpacing.large)
        .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.compact))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.compact)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .combine)
    }
}

struct D2UnavailableState: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HumaySurface(level: .raised) {
            VStack(spacing: HumaySpacing.large) {
                Image(systemName: symbol)
                    .font(.system(.largeTitle, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.humayLavender)
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityHidden(true)

                Text(title)
                    .font(HumayTypography.cardTitle)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(detail)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct HumayCosmicSurface<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    private let content: Content
    private let padding: CGFloat

    init(
        padding: CGFloat = HumaySpacing.extraLarge,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(foreground)
            .background(background, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface)
                    .strokeBorder(
                        Color.humayHairline.opacity(colorScheme == .light ? 0.30 : 0.75),
                        lineWidth: HumayMetrics.hairline(displayScale: displayScale)
                    )
            }
    }

    private var background: some ShapeStyle {
        LinearGradient(
            colors: colorScheme == .light
                ? [Color.humayTextPrimary, Color.humayTextPrimary.opacity(0.93)]
                : [Color.humayRaisedSurface, Color.humaySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var foreground: Color {
        colorScheme == .light ? Color.humayGround : Color.humayTextPrimary
    }
}

struct HumayCategoryIcon: View {
    let symbol: String
    let accent: HumayAccent
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.36, weight: .semibold))
            .foregroundStyle(accent.color)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [
                        accent.color.opacity(0.20),
                        accent.color.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
            .accessibilityHidden(true)
    }
}

struct CirclePersonMedallion: View {
    let person: CirclePerson
    let accent: HumayAccent
    var size: CGFloat = 88

    var body: some View {
        portraitFallback
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(accent.color.opacity(0.34), lineWidth: 1))
            .accessibilityHidden(true)
    }

    private var portraitFallback: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [accent.color.opacity(0.72), Color.humayRaisedSurface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(personInitials)
                .font(.system(size: size * 0.30, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.humayTextPrimary)
        }
    }

    private var personInitials: String {
        person.name
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
            .nonempty ?? "H"
    }
}

struct CelestialCoffeeArt: View {
    var body: some View {
        D2ArtworkImage(name: D2Artwork.todayCoffee)
            .frame(width: 142, height: 126)
    }
}

struct OrbitPlanetArt: View {
    var compact = false

    var body: some View {
        D2ArtworkImage(name: D2Artwork.cosmicPlanet)
            .frame(
                width: compact ? 108 : 132,
                height: compact ? 78 : 98
            )
    }
}

struct CrystalBallArt: View {
    var body: some View {
        D2ArtworkImage(name: D2Artwork.crystalBall)
            .frame(width: 86, height: 86)
    }
}

struct RoastFireArt: View {
    var body: some View {
        D2ArtworkImage(name: D2Artwork.roastMode)
            .frame(width: 88, height: 76)
    }
}

struct RoastPlanetArt: View {
    var body: some View {
        D2ArtworkImage(name: D2Artwork.roastMode)
            .frame(width: 90, height: 78)
    }
}

struct ZodiacSignArt: View {
    let sign: WesternZodiacSign
    var size: CGFloat = 76

    var body: some View {
        D2ArtworkImage(name: sign.d2ArtworkAssetName)
            .frame(width: size, height: size)
    }
}

struct HumayIllustration: View {
    let name: String

    var body: some View {
        D2ArtworkImage(name: name)
    }
}

private struct D2ArtworkImage: View {
    let name: String

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

enum D2Artwork {
    static let todayCoffee = "IllustrationCosmicCoffee"
    static let cosmicPlanet = "IllustrationCosmicWeather"
    static let crystalBall = "IllustrationDailyTipCrystalBall"
    static let roastMode = "IllustrationRoastMode"

    static let decorativeAssetNames = [
        todayCoffee,
        cosmicPlanet,
        crystalBall,
        roastMode
    ]

    static var allAdaptiveAssetNames: [String] {
        decorativeAssetNames + WesternZodiacSign.allCases.map(\.d2ArtworkAssetName)
    }
}

extension WesternZodiacSign {
    var d2ArtworkAssetName: String {
        switch self {
        case .aries: "ZodiacAries"
        case .taurus: "ZodiacTaurus"
        case .gemini: "ZodiacGemini"
        case .cancer: "ZodiacCancer"
        case .leo: "ZodiacLeo"
        case .virgo: "ZodiacVirgo"
        case .libra: "ZodiacLibra"
        case .scorpio: "ZodiacScorpio"
        case .sagittarius: "ZodiacSagittarius"
        case .capricorn: "ZodiacCapricorn"
        case .aquarius: "ZodiacAquarius"
        case .pisces: "ZodiacPisces"
        }
    }
}

private extension String {
    var nonempty: String? { isEmpty ? nil : self }
}
