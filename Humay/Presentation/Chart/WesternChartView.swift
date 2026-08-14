import SwiftUI

struct WesternChartView: View {
    let model: ChartWesternModel
    let source: D4ContentSource

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    ChartDevelopmentNotice(source: source)

                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("Western chart")
                            .font(HumayTypography.detailTitle)
                            .foregroundStyle(Color.humayTextPrimary)
                            .accessibilityAddTraits(.isHeader)
                        Text("Facts first. Meaning stays in its own layer.")
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayTextSecondary)
                    }

                    if proxy.size.width >= 760 {
                        iPadLayout
                    } else {
                        iPhoneLayout
                    }
                }
                .frame(maxWidth: HumayContentWidth.expanded.rawValue, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.large)
            }
            .background(Color.humayGround.ignoresSafeArea())
        }
        .navigationTitle("Western chart")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("chart.western.screen")
    }

    private var iPhoneLayout: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            ChartWheelSection(model: model)
            ChartBigThreeView(placements: model.bigThree)
            ChartHighlightView(model: model, source: source)
            ChartPlacementsLink(model: model, source: source)
            ChartBasisView(basis: model.basis)
        }
    }

    private var iPadLayout: some View {
        HumayAdaptiveTwoRegion {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                ChartWheelSection(model: model)
                ChartBasisView(basis: model.basis)
            }
            .frame(maxWidth: 440, alignment: .leading)

            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                ChartBigThreeView(placements: model.bigThree)
                ChartHighlightView(model: model, source: source)
                ChartPlacementsLink(model: model, source: source)
            }
            .frame(maxWidth: 520, alignment: .leading)
        }
    }
}

struct HumayAdaptiveTwoRegion<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct ChartWheelSection: View {
    let model: ChartWesternModel

    var body: some View {
        HumaySurface(level: .raised, padding: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text("Sky map")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)

                ChartWheelView(model: model.wheel)
                    .frame(maxWidth: 410)
                    .frame(maxWidth: .infinity)

                Text("Selected: Moon in Libra · \(ChartDegreeFormatter.string(for: model.placement(for: .moon)?.position.degreeWithinSign ?? 0))")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("chart.wheel")
    }
}

private struct ChartBigThreeView: View {
    let placements: [ChartPlacement]

    var body: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                Text("Big Three")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 110), spacing: HumaySpacing.medium),
                        GridItem(.flexible(minimum: 110), spacing: HumaySpacing.medium)
                    ],
                    spacing: HumaySpacing.medium
                ) {
                    ForEach(placements) { placement in
                        ChartPlacementSummary(placement: placement, compact: true)
                    }
                }
            }
        }
        .accessibilityIdentifier("chart.big-three")
    }
}

private struct ChartHighlightView: View {
    let model: ChartWesternModel
    let source: D4ContentSource

    var body: some View {
        if let moon = model.placement(for: .moon) {
            HumayCosmicSurface(padding: HumaySpacing.large) {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    Label("Placement highlight", systemImage: "moon.fill")
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humayGround.opacity(0.72))

                    Text("Moon in \(moon.position.sign.displayName)")
                        .font(HumayTypography.cardTitle)
                        .foregroundStyle(Color.humayGround)

                    HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.small) {
                        Text(moon.degreeText)
                            .font(HumayTypography.technical)
                        Text("·")
                        Text(moon.house?.label ?? "House withheld")
                            .font(HumayTypography.supporting)
                    }
                    .foregroundStyle(Color.humayGround.opacity(0.88))

                    Text("Open the placement for a fact-first detail and a separate interpretation layer.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayGround.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)

                    NavigationLink {
                        ChartPlacementDetailView(
                            placement: moon,
                            basis: model.basis,
                            source: source
                        )
                    } label: {
                        Text("Open Moon detail")
                    }
                    .buttonStyle(.humaySecondary)
                    .accessibilityIdentifier("chart.placement.moon.open")
                }
            }
            .accessibilityIdentifier("chart.highlight.moon")
        }
    }
}

private struct ChartPlacementsLink: View {
    let model: ChartWesternModel
    let source: D4ContentSource

    var body: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text("Placements")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)
                Text("The wheel is a map; the ordered list is the accessible reading path.")
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                NavigationLink {
                    ChartPlacementsView(model: model, source: source)
                } label: {
                    Text("See all placements")
                }
                .buttonStyle(.humayPrimary)
                .accessibilityIdentifier("chart.placements.open")
            }
        }
    }
}

struct ChartPlacementsView: View {
    let model: ChartWesternModel
    let source: D4ContentSource

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                ChartDevelopmentNotice(source: source)

                Text("All placements")
                    .font(HumayTypography.detailTitle)
                    .foregroundStyle(Color.humayTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                HumaySurface {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(model.placements) { placement in
                            NavigationLink {
                                ChartPlacementDetailView(
                                    placement: placement,
                                    basis: model.basis,
                                    source: source
                                )
                            } label: {
                                ChartPlacementSummary(placement: placement)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("chart.placement.\(placement.point.rawValue)")

                            if placement.id != model.placements.last?.id {
                                Divider()
                                    .overlay(Color.humayHairline)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("chart.placements.list")
            }
            .frame(maxWidth: HumayContentWidth.readable.rawValue, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, HumaySpacing.extraLarge)
            .padding(.vertical, HumaySpacing.large)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .navigationTitle("Placements")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("chart.placements.screen")
    }
}

private struct ChartPlacementSummary: View {
    let placement: ChartPlacement
    var compact = false

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: placement.point.symbol)
                .font(HumayTypography.supportingEmphasized)
                .foregroundStyle(pointAccent)
                .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                .background(pointAccent.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(placement.point.label)
                    .font(compact ? HumayTypography.supportingEmphasized : HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)
                Text("\(placement.position.sign.displayName) · \(placement.degreeText)")
                    .font(compact ? HumayTypography.supporting : HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                if !compact, let house = placement.house {
                    Text(house.label)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }

            if !compact {
                Spacer(minLength: HumaySpacing.small)

                Image(systemName: "chevron.right")
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)
                    .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: HumayMetrics.minimumHitTarget)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .frame(minHeight: HumayMetrics.minimumHitTarget)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("chart.placement.\(placement.point.rawValue)")
    }

    private var pointAccent: Color {
        switch placement.point {
        case .sun: .humaySolarGold
        case .moon: .humayLavender
        case .ascendant: .humayCoral
        default: .humayCelestialBlue
        }
    }
}

struct ChartBasisView: View {
    let basis: ChartBasis

    var body: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text("Chart basis")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)
                ChartBasisRow(title: "Method", value: "\(basis.methodology) · \(basis.zodiac)")
                ChartBasisRow(title: "Date", value: basis.date)
                ChartBasisRow(title: "Time", value: basis.time)
                ChartBasisRow(title: "Place", value: basis.place)
            }
        }
        .accessibilityIdentifier("chart.basis")
    }
}

private struct ChartBasisRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
            Text(title)
                .font(HumayTypography.supportingEmphasized)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
