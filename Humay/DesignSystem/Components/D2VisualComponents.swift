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
                .frame(
                    width: HumayMetrics.minimumHitTarget,
                    height: HumayMetrics.minimumHitTarget
                )
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
                .font(HumayTypography.supportingEmphasized)
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
                    .frame(
                        minWidth: HumayMetrics.minimumHitTarget,
                        minHeight: HumayMetrics.minimumHitTarget
                    )
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

struct CirclePersonMedallion: View {
    let person: CirclePerson
    let accent: HumayAccent
    var size: CGFloat = 88

    var body: some View {
        portraitFallback
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(accent.color.opacity(0.58), lineWidth: 1))
            .accessibilityHidden(true)
    }

    private var portraitFallback: some View {
        ZStack {
            Circle()
                .fill(Color.humaySurfaceElevated)

            Text(personInitials)
                .font(size >= 72 ? HumayTypography.sectionTitle : HumayTypography.supportingEmphasized)
                .foregroundStyle(accent.color)
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

struct HumayIllustration: View {
    let asset: HumayIllustrationAsset

    var body: some View {
        HumayAssetImage(asset: .illustration(asset))
    }
}

private extension String {
    var nonempty: String? { isEmpty ? nil : self }
}
