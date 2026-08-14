import SwiftUI

struct ChartPlacementDetailView: View {
    let placement: ChartPlacement
    let basis: ChartBasis
    let source: D4ContentSource

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    ChartDevelopmentNotice(source: source)

                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("\(placement.point.label) in \(placement.position.sign.displayName)")
                            .font(HumayTypography.detailTitle)
                            .foregroundStyle(Color.humayTextPrimary)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier("chart.placement-detail.title")
                        Text(placement.factText)
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if proxy.size.width >= 760 {
                        HumayAdaptiveTwoRegion {
                            factLayer
                            interpretationLayer
                        }
                    } else {
                        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                            factLayer
                            interpretationLayer
                        }
                    }

                    ChartBasisView(basis: basis)
                }
                .frame(maxWidth: HumayContentWidth.expanded.rawValue, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.large)
            }
            .background(Color.humayGround.ignoresSafeArea())
        }
        .navigationTitle(placement.point.label)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("chart.placement-detail.screen")
    }

    private var factLayer: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                Text("Fact")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)
                ChartFactRow(title: "Body", value: placement.point.label)
                ChartFactRow(title: "Sign", value: placement.position.sign.displayName)
                ChartFactRow(title: "Degree", value: placement.degreeText, technical: true)
                ChartFactRow(title: "House", value: placement.house?.label ?? "Not supplied")
                ChartFactRow(
                    title: "Reliability",
                    value: ChartReliabilityFormatter.string(for: placement.reliability)
                )
            }
        }
        .accessibilityIdentifier("chart.placement-detail.facts")
    }

    private var interpretationLayer: some View {
        HumayCosmicSurface {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text("Interpretation")
                    .font(HumayTypography.sectionTitle)
                    .foregroundStyle(Color.humayGround)
                    .accessibilityAddTraits(.isHeader)
                Text(placement.interpretationTitle)
                    .font(HumayTypography.cardTitle)
                    .foregroundStyle(Color.humayGround)
                Text(placement.interpretationBody)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayGround.opacity(0.80))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("chart.placement-detail.interpretation")
    }
}

private struct ChartFactRow: View {
    let title: String
    let value: String
    var technical = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
            Text(title)
                .font(HumayTypography.supportingEmphasized)
                .frame(width: 96, alignment: .leading)
            Text(value)
                .font(technical ? HumayTypography.technical : HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
