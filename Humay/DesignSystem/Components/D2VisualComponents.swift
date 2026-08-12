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

    var body: some View {
        HStack(spacing: HumaySpacing.large) {
            if let title {
                Text(title)
                    .font(HumayTypography.editorialTitle)
                    .accessibilityAddTraits(.isHeader)
            } else {
                Text("humay")
                    .font(HumayTypography.wordmark)
                    .accessibilityLabel("Humay")
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("main.today.wordmark")
            }

            Spacer(minLength: HumaySpacing.medium)

            Button(action: profileAction) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.humayCelestialBlue.opacity(0.75),
                                    Color.humayLavender.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(initials)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.humayTextPrimary)
                }
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Color.humayHairline))
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile and settings")
            .accessibilityHint("Opens your profile and settings")
            .accessibilityIdentifier("main.profile.button")
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget)
        .foregroundStyle(Color.humayTextPrimary)
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
                        Color.humayHairline.opacity(colorScheme == .light ? 0.35 : 1),
                        lineWidth: HumayMetrics.hairline(displayScale: displayScale)
                    )
            }
    }

    private var background: some ShapeStyle {
        LinearGradient(
            colors: colorScheme == .light
                ? [Color.humayTextPrimary, Color.humayTextPrimary.opacity(0.92)]
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
            .background(accent.color.opacity(0.16), in: Circle())
            .accessibilityHidden(true)
    }
}

struct CirclePersonMedallion: View {
    let person: CirclePerson
    let accent: HumayAccent
    var size: CGFloat = 88

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [accent.color.opacity(0.75), Color.humayRaisedSurface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.humaySurface.opacity(0.38))
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(y: size * 0.18)

            Image(systemName: "person.fill")
                .font(.system(size: size * 0.42, weight: .regular))
                .foregroundStyle(Color.humayTextPrimary.opacity(0.84))
                .offset(y: size * 0.1)

            Text(person.initials)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Color.humayTextPrimary)
                .padding(5)
                .background(Color.humaySurface.opacity(0.9), in: Capsule())
                .offset(x: size * 0.29, y: -size * 0.3)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.humayHairline, lineWidth: 1))
        .accessibilityHidden(true)
    }
}

struct CelestialCoffeeArt: View {
    var body: some View {
        ZStack {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 64, weight: .regular))
                .foregroundStyle(Color.humaySolarGold)

            Image(systemName: "wind")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Color.humayLavender)
                .offset(y: -44)

            Image(systemName: "sparkles")
                .foregroundStyle(Color.humayCoral)
                .offset(x: 52, y: -28)

            Image(systemName: "moon.fill")
                .font(.caption)
                .foregroundStyle(Color.humayCelestialBlue)
                .offset(x: -52, y: -34)
        }
        .frame(width: 142, height: 126)
        .accessibilityHidden(true)
    }
}

struct OrbitPlanetArt: View {
    var compact = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.humayLavender, Color.humayCelestialBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: compact ? 44 : 66, height: compact ? 44 : 66)

            Ellipse()
                .stroke(Color.humaySolarGold, lineWidth: 2)
                .frame(width: compact ? 76 : 112, height: compact ? 24 : 36)
                .rotationEffect(.degrees(-18))

            Circle()
                .fill(Color.humayCoral)
                .frame(width: compact ? 5 : 7, height: compact ? 5 : 7)
                .offset(x: compact ? 27 : 42, y: compact ? -8 : -12)
        }
        .frame(width: compact ? 82 : 122, height: compact ? 64 : 92)
        .accessibilityHidden(true)
    }
}

struct CrystalBallArt: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.humayLavender, lineWidth: 2)
                .frame(width: 58, height: 58)
            Image(systemName: "sparkles")
                .foregroundStyle(Color.humayCoral)
            Capsule()
                .fill(Color.humayLavender.opacity(0.55))
                .frame(width: 64, height: 10)
                .offset(y: 34)
        }
        .frame(width: 76, height: 82)
        .accessibilityHidden(true)
    }
}

struct RoastPlanetArt: View {
    var body: some View {
        ZStack {
            OrbitPlanetArt(compact: true)
            Image(systemName: "sunglasses.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.humayTextPrimary)
        }
        .frame(width: 90, height: 72)
        .accessibilityHidden(true)
    }
}

private extension String {
    var nonempty: String? { isEmpty ? nil : self }
}
