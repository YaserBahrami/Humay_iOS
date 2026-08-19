import SwiftUI

struct ChartPlacementDetailView: View {
    let placement: ChartPlacement
    let basis: ChartBasis
    let source: D4ContentSource

    var body: some View {
        HumayPage(maximum: .readable) {
            ChartDevelopmentNotice(source: source)
            titleBlock
            humanLayer
            explanationLayer
            technicalLayer
            ChartBasisView(basis: basis)
        }
        .navigationTitle(placement.point.label)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("chart.placement-detail.screen")
    }

    private var titleBlock: some View {
        HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
            ZStack {
                Circle()
                    .fill(Color.humaySurfaceElevated)
                Circle()
                    .stroke(accent.opacity(0.76), lineWidth: 1)
                HumayChartPointGlyph(point: placement.point)
                    .foregroundStyle(accent)
                    .padding(22)
            }
            .frame(width: 88, height: 88)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                HumayEyebrow(text: "Placement", color: accent)
                Text("\(placement.point.label) in \(placement.position.sign.displayName)")
                    .font(HumayTypography.displayTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("chart.placement-detail.title")
                HStack(spacing: HumaySpacing.small) {
                    Text(placement.degreeText)
                        .font(HumayTypography.technical)
                    Text("·")
                    Text(placement.house?.label ?? "House not supplied")
                        .font(HumayTypography.supporting)
                }
                .foregroundStyle(Color.humayTextSecondary)
            }
        }
    }

    private var humanLayer: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "What it may feel like")
            Text(placement.interpretationTitle)
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)
            Text(placement.interpretationBody)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("chart.placement-detail.interpretation")
    }

    private var explanationLayer: some View {
        HumayHairlineSurface(style: .celestial) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                HumayEyebrow(text: "Why this shows up", color: .humayAccentCelestial)

                explanationRow(
                    title: placement.point.label,
                    detail: placement.point.humanRole
                ) {
                    HumayChartPointGlyph(point: placement.point)
                        .foregroundStyle(Color.humayAccentPrestige)
                }
                explanationRow(
                    title: placement.position.sign.displayName,
                    detail: placement.position.sign.humanStyle
                ) {
                    HumayAssetImage(asset: .zodiac(placement.position.sign))
                        .foregroundStyle(Color.humayAccentCelestial)
                }
                if let house = placement.house {
                    explanationRow(
                        title: house.label,
                        detail: "The life area where this placement is most visibly expressed."
                    ) {
                        Text("\(house.rawValue)")
                            .font(HumayTypography.technicalSmall)
                            .foregroundStyle(Color.humayAccentPrestige)
                    }
                }
            }
        }
    }

    private func explanationRow<Icon: View>(
        title: String,
        detail: String,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        HStack(alignment: .top, spacing: HumaySpacing.large) {
            icon()
                .frame(width: 34, height: 34)
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
        .accessibilityElement(children: .combine)
    }

    private var technicalLayer: some View {
        HumayDisclosureGroup(
            eyebrow: "Technical astrology",
            title: placement.factText,
            summary: "Degree, house, and reliability"
        ) {
            HumayHairlineSurface(style: .quiet) {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    HumayFactRow(label: "Body", value: placement.point.label)
                    HumayFactRow(label: "Sign", value: placement.position.sign.displayName)
                    HumayFactRow(label: "Degree", value: placement.degreeText, technical: true)
                    HumayFactRow(label: "House", value: placement.house?.label ?? "Not supplied")
                    HumayFactRow(
                        label: "Reliability",
                        value: ChartReliabilityFormatter.string(for: placement.reliability)
                    )
                }
            }
        }
        .accessibilityIdentifier("chart.placement-detail.facts")
    }

    private var accent: Color {
        switch placement.point {
        case .sun: .humayAccentPrestige
        case .moon: .humayAccentCelestial
        case .ascendant: .humayAccentRoast
        default: .humayChartHarmonious
        }
    }
}

private extension ChartPoint {
    var humanRole: String {
        switch self {
        case .sun: "Your central identity, vitality, and direction."
        case .moon: "Your emotional rhythms, instincts, and need for safety."
        case .mercury: "How you notice, think, and communicate."
        case .venus: "How you relate, value, attract, and receive pleasure."
        case .mars: "How you pursue, defend, desire, and use energy."
        case .jupiter: "Where you seek growth, meaning, and wider possibility."
        case .saturn: "Where patience, responsibility, and mastery develop."
        case .ascendant: "The way you enter situations and meet the visible world."
        }
    }
}

private extension WesternZodiacSign {
    var humanStyle: String {
        switch self {
        case .aries: "Direct, initiating, and responsive to challenge."
        case .taurus: "Steady, embodied, and attentive to lasting value."
        case .gemini: "Curious, connective, and moved by exchange."
        case .cancer: "Protective, receptive, and guided by belonging."
        case .leo: "Expressive, wholehearted, and creatively visible."
        case .virgo: "Discerning, practical, and attentive to refinement."
        case .libra: "Relational, balancing, and sensitive to proportion."
        case .scorpio: "Intense, private, and willing to transform."
        case .sagittarius: "Expansive, candid, and oriented toward meaning."
        case .capricorn: "Structured, deliberate, and committed to durable results."
        case .aquarius: "Independent, systemic, and alert to future possibility."
        case .pisces: "Imaginative, porous, and responsive to subtle feeling."
        }
    }
}
