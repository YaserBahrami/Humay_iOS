import SwiftUI

struct WesternChartView: View {
    let model: ChartWesternModel
    let source: D4ContentSource

    @State private var focus: ChartWheelFocus

    init(model: ChartWesternModel, source: D4ContentSource) {
        self.model = model
        self.source = source
        _focus = State(initialValue: .point(model.wheel.selectedPoint ?? model.placements.first?.point ?? .sun))
    }

    var body: some View {
        HumayPage(maximum: .immersive) {
            ChartDevelopmentNotice(source: source)
            introduction
            chartHero
            bigThree
            aspectIndex
            ChartPlacementsLink(model: model, source: source)
            ChartBasisView(basis: model.basis)
        }
        .navigationTitle("Natal chart")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: focus)
        .accessibilityIdentifier("chart.western.screen")
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "Your birth sky")
            Text("Natal chart")
                .font(HumayTypography.heroTitle)
                .accessibilityAddTraits(.isHeader)
            Text("Begin with meaning. Touch a planet or house to change focus; open the mechanics only when you want them.")
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 620, alignment: .leading)
        }
    }

    private var chartHero: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: HumaySpacing.hero) {
                wheelStage
                    .frame(minWidth: 440, maxWidth: 570)
                focusPanel
                    .frame(minWidth: 320, maxWidth: 430)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: HumaySpacing.extraExtraLarge) {
                wheelStage
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                focusPanel
            }
        }
    }

    private var wheelStage: some View {
        VStack(spacing: HumaySpacing.large) {
            ChartWheelView(model: model.wheel, focus: focus) { focus = $0 }

            Text("Planets and house numbers are interactive")
                .font(HumayTypography.caption)
                .foregroundStyle(Color.humayTextSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityIdentifier("chart.wheel")
        }
        .padding(HumaySpacing.large)
        .background(Color.humaySurface.opacity(0.54), in: RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous)
                .stroke(Color.humaySeparator, lineWidth: 0.7)
        }
    }

    @ViewBuilder
    private var focusPanel: some View {
        HumayHairlineSurface(style: .raised) {
            switch focus {
            case .point(let point):
                pointFocus(point)
            case .house(let house):
                houseFocus(house)
            case .aspect(let id):
                if let aspect = model.wheel.aspects.first(where: { $0.id == id }) {
                    aspectFocus(aspect)
                } else {
                    Text("Choose a chart feature")
                        .font(HumayTypography.editorialTitle)
                }
            }
        }
    }

    @ViewBuilder
    private func pointFocus(_ point: ChartPoint) -> some View {
        if let placement = model.placement(for: point) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                HStack(spacing: HumaySpacing.medium) {
                    HumayChartPointGlyph(point: point)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(point.accent)
                    HumayEyebrow(text: "Placement", color: point.accent)
                }

                Text(placement.interpretationTitle)
                    .font(HumayTypography.editorialTitle)
                    .fixedSize(horizontal: false, vertical: true)

                Text(placement.interpretationBody)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HumayDisclosureGroup(
                    eyebrow: "Why",
                    title: "\(point.label) in \(placement.position.sign.displayName)",
                    summary: placement.house.map { "This placement falls in the \($0.label)." }
                        ?? "A house was not supplied for this placement."
                ) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        HumayFactRow(label: "Position", value: placement.degreeText, technical: true)
                        HumayFactRow(label: "House", value: placement.house?.label ?? "Not supplied")
                        HumayFactRow(
                            label: "Reliability",
                            value: ChartReliabilityFormatter.string(for: placement.reliability)
                        )
                    }
                }

                NavigationLink {
                    ChartPlacementDetailView(
                        placement: placement,
                        basis: model.basis,
                        source: source
                    )
                } label: {
                    Text("Open \(point.label) detail")
                }
                .buttonStyle(.humayPrimary)
                .accessibilityIdentifier("chart.placement.\(point.rawValue).open")
            }
        }
    }

    private func houseFocus(_ house: ChartHouse) -> some View {
        let placements = model.placements.filter { $0.house == house }

        return VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumayEyebrow(text: house.label)

            Text(house.editorialTitle)
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)

            Text(house.interpretation(placements: placements))
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HumayDisclosureGroup(
                eyebrow: "Technical astrology",
                title: "What is placed here",
                summary: placements.isEmpty
                    ? "No displayed chart point occupies this house."
                    : placements.map(\.point.label).joined(separator: ", ")
            ) {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    ForEach(placements) { placement in
                        HumayFactRow(
                            label: placement.point.label,
                            value: "\(placement.position.sign.displayName) · \(placement.degreeText)",
                            technical: true
                        )
                    }
                }
            }
        }
    }

    private func aspectFocus(_ aspect: ChartWheelAspect) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumayEyebrow(text: "Aspect", color: aspect.kind.accent)

            Text(aspect.kind.editorialTitle)
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(aspect.firstPoint.label) and \(aspect.secondPoint.label) \(aspect.kind.humanMeaning)")
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HumayDisclosureGroup(
                eyebrow: "Technical astrology",
                title: "\(aspect.firstPoint.label) \(aspect.kind.displayName.lowercased()) \(aspect.secondPoint.label)",
                summary: "Orb: \(ChartDegreeFormatter.string(for: aspect.orbDegrees))"
            ) {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    HumayFactRow(label: "Aspect", value: aspect.kind.displayName)
                    HumayFactRow(
                        label: "Orb",
                        value: ChartDegreeFormatter.string(for: aspect.orbDegrees),
                        technical: true
                    )
                    HumayFactRow(
                        label: "Reliability",
                        value: ChartReliabilityFormatter.string(for: aspect.reliability)
                    )
                }
            }
        }
    }

    private var bigThree: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text("Your Big Three")
                    .font(HumayTypography.narrativeSectionTitle)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("chart.big-three")
                Text("Identity, emotional nature, and the way you meet the world.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 220), spacing: HumaySpacing.large)],
                spacing: HumaySpacing.large
            ) {
                ForEach(model.bigThree) { placement in
                    Button {
                        focus = .point(placement.point)
                    } label: {
                        ChartPlacementSummary(placement: placement, compact: true)
                            .padding(.vertical, HumaySpacing.large)
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(placement.point.accent.opacity(0.72))
                                    .frame(height: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var aspectIndex: some View {
        if !model.wheel.aspects.isEmpty {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                HumaySectionHeader(
                    title: "Aspect lines",
                    subtitle: "Select a relationship between two chart points. Dynamic aspects are dashed; flowing aspects are solid."
                )

                VStack(spacing: 0) {
                    ForEach(model.wheel.aspects) { aspect in
                        Button {
                            focus = .aspect(aspect.id)
                        } label: {
                            HStack(spacing: HumaySpacing.large) {
                                HStack(spacing: HumaySpacing.small) {
                                    HumayChartPointGlyph(point: aspect.firstPoint)
                                    HumayChartPointGlyph(point: aspect.secondPoint)
                                }
                                .frame(width: 64, height: 30)
                                .foregroundStyle(aspect.kind.accent)

                                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                                    Text("\(aspect.firstPoint.label) · \(aspect.secondPoint.label)")
                                        .font(HumayTypography.bodyEmphasized)
                                    Text("\(aspect.kind.displayName) · orb \(ChartDegreeFormatter.string(for: aspect.orbDegrees))")
                                        .font(HumayTypography.supporting)
                                        .foregroundStyle(Color.humayTextSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color.humayTextSecondary)
                                    .accessibilityHidden(true)
                            }
                            .frame(minHeight: HumayMetrics.minimumHitTarget)
                            .padding(.vertical, HumaySpacing.medium)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Shows the aspect interpretation")

                        if aspect.id != model.wheel.aspects.last?.id {
                            Rectangle().fill(Color.humaySeparator).frame(height: 1)
                        }
                    }
                }
            }
            .accessibilityIdentifier("chart.aspects")
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

private struct ChartPlacementsLink: View {
    let model: ChartWesternModel
    let source: D4ContentSource

    var body: some View {
        HumayHairlineSurface(style: .celestial) {
            HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
                HumaySystemSymbolImage(symbol: .placements, size: .feature)
                    .foregroundStyle(Color.humayAccentPrestige)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("All placements")
                        .font(HumayTypography.narrativeSectionTitle)
                    Text("Use the ordered list for a complete, accessible reading path.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink {
                    ChartPlacementsView(model: model, source: source)
                } label: {
                    Image(systemName: "arrow.right")
                        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See all placements")
                .accessibilityIdentifier("chart.placements.open")
            }
        }
    }
}

struct ChartPlacementsView: View {
    let model: ChartWesternModel
    let source: D4ContentSource

    var body: some View {
        HumayPage(maximum: .readable) {
            ChartDevelopmentNotice(source: source)
            HumayEyebrow(text: "Natal chart")
            Text("All placements")
                .font(HumayTypography.displayTitle)
                .accessibilityAddTraits(.isHeader)

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
                        Rectangle().fill(Color.humaySeparator).frame(height: 1)
                    }
                }
            }
            .accessibilityIdentifier("chart.placements.list")
        }
        .navigationTitle("Placements")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("chart.placements.screen")
    }
}

private struct ChartPlacementSummary: View {
    let placement: ChartPlacement
    var compact = false

    var body: some View {
        HStack(alignment: .center, spacing: HumaySpacing.large) {
            HumayChartPointGlyph(point: placement.point)
                .foregroundStyle(placement.point.accent)
                .frame(width: 32, height: 32)
                .padding(6)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(placement.point.label)
                    .font(compact ? HumayTypography.supportingEmphasized : HumayTypography.bodyEmphasized)
                Text("\(placement.position.sign.displayName) · \(placement.degreeText)")
                    .font(compact ? HumayTypography.supporting : HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                if !compact, let house = placement.house {
                    Text(house.label)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }

            Spacer(minLength: HumaySpacing.small)

            if !compact {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.humayTextSecondary)
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget)
        .padding(.vertical, HumaySpacing.medium)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("chart.placement.\(placement.point.rawValue)")
    }
}

struct ChartBasisView: View {
    let basis: ChartBasis

    var body: some View {
        HumayDisclosureGroup(
            eyebrow: "Technical astrology",
            title: "Chart basis",
            summary: "\(basis.methodology) · \(basis.zodiac)"
        ) {
            HumayHairlineSurface(style: .quiet) {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    HumayFactRow(label: "Method", value: "\(basis.methodology) · \(basis.zodiac)")
                    HumayFactRow(label: "Date", value: basis.date)
                    HumayFactRow(label: "Time", value: basis.time)
                    HumayFactRow(label: "Place", value: basis.place)
                }
            }
        }
        .accessibilityIdentifier("chart.basis")
    }
}

private extension ChartPoint {
    var accent: Color {
        switch self {
        case .sun: .humayAccentPrestige
        case .moon: .humayAccentCelestial
        case .ascendant: .humayAccentRoast
        default: .humayChartHarmonious
        }
    }
}

private extension ChartHouse {
    var editorialTitle: String {
        switch self {
        case .first: "How you arrive"
        case .second: "What you value"
        case .third: "How you exchange ideas"
        case .fourth: "Where you belong"
        case .fifth: "What you create"
        case .sixth: "How you tend daily life"
        case .seventh: "How you meet another"
        case .eighth: "What transforms you"
        case .ninth: "What widens your world"
        case .tenth: "What you build in public"
        case .eleventh: "Where you find community"
        case .twelfth: "What moves beneath words"
        }
    }

    func interpretation(placements: [ChartPlacement]) -> String {
        guard !placements.isEmpty else {
            return "This life arena remains part of the chart, even when no displayed point occupies it."
        }
        let names = placements.map(\.point.label).joined(separator: " and ")
        return "\(names) brings attention to this life arena. Open a placement to understand how that energy is expressed."
    }
}

private extension WesternAspectKind {
    var displayName: String { rawValue.capitalized }

    var editorialTitle: String {
        switch self {
        case .conjunction: "Energies working as one"
        case .opposition: "A polarity to integrate"
        case .trine: "A natural current"
        case .square: "Productive friction"
        case .sextile: "An opening to use"
        }
    }

    var humanMeaning: String {
        switch self {
        case .conjunction: "combine closely, amplifying one another."
        case .opposition: "pull from opposite ends and ask for conscious balance."
        case .trine: "move with an easier flow that can feel instinctive."
        case .square: "create tension that can become momentum when handled deliberately."
        case .sextile: "offer an opportunity that grows through participation."
        }
    }

    var accent: Color {
        switch self {
        case .trine, .sextile: .humayChartHarmonious
        case .square, .opposition: .humayChartDynamic
        case .conjunction: .humayAccentPrestige
        }
    }
}
