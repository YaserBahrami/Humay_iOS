import SwiftUI

/// Shared adaptive page shell for the Premium Celestial redesign.
struct HumayPage<Content: View>: View {
    private let maximum: HumayContentWidth
    private let spacing: CGFloat
    private let topPadding: CGFloat
    private let content: Content

    init(
        maximum: HumayContentWidth = .expanded,
        spacing: CGFloat = HumaySpacing.section,
        topPadding: CGFloat = HumaySpacing.large,
        @ViewBuilder content: () -> Content
    ) {
        self.maximum = maximum
        self.spacing = spacing
        self.topPadding = topPadding
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: spacing) {
                    content
                }
                .frame(maxWidth: maximum.rawValue, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.top, topPadding)
                .padding(.bottom, HumaySpacing.expansive)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayCanvas.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
    }
}

struct HumayScreenHeader: View {
    let section: String?
    let profileName: String
    let profileAction: () -> Void
    var wordmarkIdentifier: String?
    var showsProfileButton = true

    var body: some View {
        HStack(alignment: .center, spacing: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: 2) {
                Text("humay")
                    .font(HumayTypography.wordmark)
                    .accessibilityIdentifier(wordmarkIdentifier ?? "humay.wordmark")

                if let section {
                    Text(section)
                        .font(HumayTypography.eyebrow)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }

            Spacer(minLength: HumaySpacing.large)

            if showsProfileButton {
                Button(action: profileAction) {
                    Text(initials)
                        .font(HumayTypography.supportingEmphasized)
                        .foregroundStyle(Color.humayTextPrimary)
                        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                        .background(Color.humaySurface, in: Circle())
                        .overlay {
                            Circle()
                                .stroke(Color.humayAccentPrestige.opacity(0.72), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("You")
                .accessibilityHint("Opens your profile and settings")
            }
        }
    }

    private var initials: String {
        let value = profileName
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
        return value.isEmpty ? "H" : value
    }
}

struct HumayEyebrow: View {
    let text: String
    var color: Color = .humayAccentPrestige

    var body: some View {
        Text(text)
            .font(HumayTypography.eyebrow)
            .textCase(.uppercase)
            .tracking(1.6)
            .foregroundStyle(color)
    }
}

struct HumaySectionHeader: View {
    let title: String
    var subtitle: String?
    var editorial = true

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text(title)
                .font(editorial ? HumayTypography.narrativeSectionTitle : HumayTypography.bodyEmphasized)
                .accessibilityAddTraits(.isHeader)

            if let subtitle {
                Text(subtitle)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

enum HumayHairlineSurfaceStyle {
    case quiet
    case raised
    case selected
    case celestial
}

struct HumayHairlineSurface<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    let style: HumayHairlineSurfaceStyle
    let padding: CGFloat
    let content: Content

    init(
        style: HumayHairlineSurfaceStyle = .quiet,
        padding: CGFloat = HumaySpacing.extraLarge,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(background, in: shape)
            .overlay {
                shape.strokeBorder(
                    border,
                    lineWidth: style == .selected
                        ? HumayMetrics.selectedLineWidth
                        : HumayMetrics.hairline(displayScale: displayScale)
                )
            }
            .shadow(
                color: shadow,
                radius: style == .raised ? HumayElevation.subtleShadowRadius : 0,
                y: style == .raised ? HumayElevation.subtleShadowY : 0
            )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
    }

    private var background: Color {
        switch style {
        case .quiet:
            .humaySurface
        case .raised, .selected:
            .humaySurfaceElevated
        case .celestial:
            colorScheme == .dark
                ? .humaySurfaceElevated
                : .humaySurface
        }
    }

    private var border: Color {
        switch style {
        case .selected:
            .humayAccentPrestige
        case .celestial:
            .humayAccentCelestial.opacity(0.52)
        case .quiet, .raised:
            .humaySeparator
        }
    }

    private var shadow: Color {
        guard colorScheme == .light, style == .raised else { return .clear }
        return .black.opacity(HumayElevation.subtleShadowOpacity)
    }
}

struct HumayDisclosureGroup<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded: Bool

    let eyebrow: String?
    let title: String
    let summary: String?
    let content: Content

    init(
        eyebrow: String? = nil,
        title: String,
        summary: String? = nil,
        initiallyExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.summary = summary
        _isExpanded = State(initialValue: initiallyExpanded)
        self.content = content()
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            content
                .padding(.top, HumaySpacing.large)
        } label: {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                if let eyebrow {
                    HumayEyebrow(text: eyebrow, color: .humayAccentCelestial)
                }

                Text(title)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)

                if let summary {
                    Text(summary)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, HumaySpacing.small)
        }
        .tint(Color.humayAccentPrestige)
        .animation(HumayMotion.selection(reduceMotion: reduceMotion), value: isExpanded)
    }
}

struct HumayFactRow: View {
    let label: String
    let value: String
    var technical = false
    var note: String?

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.large) {
                labelView
                    .frame(width: 104, alignment: .leading)
                valueView
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                labelView
                valueView
            }
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var labelView: some View {
        Text(label)
            .font(HumayTypography.supportingEmphasized)
            .foregroundStyle(Color.humayTextSecondary)
    }

    private var valueView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(technical ? HumayTypography.technical : HumayTypography.body)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let note {
                Text(note)
                    .font(HumayTypography.caption)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
    }
}

struct HumayMetricBand: View {
    let label: String
    let score: Int
    var detail: String?
    var accent: Color = .humayAccentPrestige
    var showsTechnicalValue = false

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
                Text(label)
                    .font(HumayTypography.bodyEmphasized)
                Spacer(minLength: HumaySpacing.small)
                Text(quality)
                    .font(HumayTypography.supportingEmphasized)
                    .foregroundStyle(accent)
                if showsTechnicalValue {
                    Text("\(score)%")
                        .font(HumayTypography.technicalSmall)
                        .foregroundStyle(Color.humayTextSecondary)
                        .monospacedDigit()
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.humaySeparator)
                        .frame(height: 1)

                    Rectangle()
                        .fill(accent)
                        .frame(width: geometry.size.width * CGFloat(clampedScore) / 100, height: 2)

                    Circle()
                        .fill(accent)
                        .frame(width: 8, height: 8)
                        .offset(x: max(0, geometry.size.width * CGFloat(clampedScore) / 100 - 4))
                }
                .frame(maxHeight: .infinity)
            }
            .frame(height: 8)

            if let detail {
                Text(detail)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue("\(quality), \(score) percent")
    }

    private var clampedScore: Int { min(max(score, 0), 100) }

    private var quality: String {
        switch clampedScore {
        case 84...: "Strong"
        case 72...: "Natural"
        case 58...: "Developing"
        default: "Needs care"
        }
    }
}

struct HumayStateView: View {
    let title: String
    let message: String
    var symbol: HumaySystemSymbol = .unavailable

    var body: some View {
        HumayHairlineSurface(style: .raised) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                HumaySystemSymbolImage(symbol: symbol, size: .feature)
                    .foregroundStyle(Color.humayAccentPrestige)

                Text(title)
                    .font(HumayTypography.editorialTitle)
                    .accessibilityAddTraits(.isHeader)

                Text(message)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}
