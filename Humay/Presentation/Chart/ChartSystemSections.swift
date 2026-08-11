import SwiftUI

/// The Western chart.
///
/// The only section with a wheel, houses and aspects. These are not withheld from the
/// other two systems — they do not exist there.
struct WesternChartSection: View {
    let chart: WesternChart
    let onSelectPlacement: (String) -> Void

    @Environment(\.humayTheme) private var theme
    /// Width of the "H1" / "B1" notation gutter. Scales so the notation is not clipped.
    @ScaledMetric(relativeTo: .caption) private var notationColumn: CGFloat = 28

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            AdaptiveRow {
                MonoKicker(text: ChartSystem.western.displayName)
            } trailing: {
                SampleContentMarker(provenance: chart.provenance)
            }

            Text(chart.headline)
                .humayFont(.displayL)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            ChartTriadView(triad: chart.triad)

            if !chart.rising.isAvailable, let reason = chart.rising.unavailability {
                UnavailableFactView(reason: reason)
            }

            ChartWheelView(model: ChartWheelModelBuilder.build(from: chart))
                .padding(.vertical, HumaySpacing.s)

            ChartFeatureView(feature: chart.feature)

            VStack(spacing: 0) {
                SectionHeader(title: "Placements")
                ForEach(chart.placements) { placement in
                    PlacementRow(
                        glyph: placement.planet.glyph,
                        glyphSpokenName: placement.planet.spokenName,
                        title: placement.planet.spokenName,
                        subtitle: placement.position.sign.spokenName,
                        detail: placement.position.degreeFormatted,
                        trailingNote: placement.house.value.map { "H\($0)" },
                        isRetrograde: placement.isRetrograde,
                        spokenLabel: placement.spokenSummary
                    ) {
                        onSelectPlacement(placement.id)
                    }
                    HairlineRule()
                }
            }

            if !chart.aspects.isEmpty {
                VStack(spacing: 0) {
                    SectionHeader(title: "Aspects", trailing: "\(chart.aspects.count)")
                    ForEach(chart.aspects.prefix(8)) { aspect in
                        AdaptiveRow {
                            Text("\(aspect.first.glyph) \(aspect.kind.glyph) \(aspect.second.glyph)")
                                .humayFont(.titleS)
                                .foregroundStyle(theme.colors.textPrimary)
                        } trailing: {
                            MonoFact(text: aspect.orbFormatted, emphasised: aspect.orbDegrees < 1)
                        }
                        .padding(.vertical, HumaySpacing.xs)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(aspect.spokenDescription)
                        HairlineRule()
                    }
                }
            }

            switch chart.houses {
            case .available(let houses):
                VStack(spacing: 0) {
                    SectionHeader(title: "Houses")
                    ForEach(houses) { house in
                        AdaptiveRow(horizontalAlignment: .top) {
                            HStack(alignment: .top, spacing: HumaySpacing.s) {
                                MonoFact(text: "H\(house.id)", emphasised: true)
                                    .frame(width: notationColumn, alignment: .leading)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(house.title)
                                        .humayFont(.callout)
                                        .foregroundStyle(theme.colors.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(house.summary)
                                        .humayFont(.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        } trailing: {
                            MonoFact(text: house.cusp.formatted)
                        }
                        .padding(.vertical, HumaySpacing.xs)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(house.spokenDescription)
                        HairlineRule()
                    }
                }
            case .unavailable(let reason):
                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "Houses")
                    UnavailableFactView(reason: reason)
                }
            case .uncertain:
                EmptyView()
            }
        }
    }
}

/// The Vedic chart.
///
/// Bhavas rather than houses, grahas rather than planets, and a dasha period rather
/// than a transit. Terms that have no Western counterpart carry a glossary trigger.
struct VedicChartSection: View {
    let chart: VedicChart
    let onGlossaryTerm: (String) -> Void
    let onSelectPlacement: (String) -> Void

    @Environment(\.humayTheme) private var theme
    @ScaledMetric(relativeTo: .caption) private var notationColumn: CGFloat = 28

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            AdaptiveRow {
                MonoKicker(text: ChartSystem.vedic.displayName)
            } trailing: {
                SampleContentMarker(provenance: chart.provenance)
            }

            Text(chart.headline)
                .humayFont(.displayL)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            ChartTriadView(triad: chart.triad, onGlossaryTerm: onGlossaryTerm)

            if !chart.lagna.isAvailable, let reason = chart.lagna.unavailability {
                UnavailableFactView(reason: reason)
            }

            ChartFeatureView(feature: chart.feature)

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                SectionHeader(
                    title: "Current period",
                    glossaryTerm: (id: "mahadasha", name: "Mahadasha"),
                    onGlossaryTerm: onGlossaryTerm
                )
                switch chart.currentDasha {
                case .available(let dasha), .uncertain(let dasha, _):
                    VStack(alignment: .leading, spacing: 3) {
                        Text(dasha.displayName)
                            .humayFont(.titleM)
                            .foregroundStyle(theme.colors.textPrimary)
                        MonoFact(text: "AGE \(dasha.startedAtAge) – \(dasha.endsAtAge)")
                        Text(dasha.summary)
                            .humayFont(.callout)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                case .unavailable(let reason):
                    UnavailableFactView(reason: reason)
                }
            }

            VStack(spacing: 0) {
                SectionHeader(title: "Grahas")
                ForEach(chart.placements) { placement in
                    PlacementRow(
                        glyph: "☽",
                        glyphSpokenName: placement.graha.spokenName,
                        title: placement.graha.spokenName,
                        subtitle: placement.rashi.spokenName,
                        detail: placement.degreeFormatted,
                        trailingNote: placement.bhava.value.map { "B\($0)" },
                        isRetrograde: false,
                        spokenLabel: placement.spokenSummary
                    ) {
                        onSelectPlacement(placement.id)
                    }
                    HairlineRule()
                }
            }

            switch chart.bhavas {
            case .available(let bhavas):
                VStack(spacing: 0) {
                    SectionHeader(
                        title: "Bhavas",
                        glossaryTerm: (id: "bhava", name: "Bhava"),
                        onGlossaryTerm: onGlossaryTerm
                    )
                    ForEach(bhavas) { bhava in
                        HStack(alignment: .top, spacing: HumaySpacing.s) {
                            MonoFact(text: bhava.notation, emphasised: true)
                                .frame(width: notationColumn, alignment: .leading)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(bhava.title)
                                    .humayFont(.callout)
                                    .foregroundStyle(theme.colors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(bhava.summary)
                                    .humayFont(.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, HumaySpacing.xs)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(bhava.spokenDescription)
                        HairlineRule()
                    }
                }
            case .unavailable(let reason):
                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "Bhavas")
                    UnavailableFactView(reason: reason)
                }
            case .uncertain:
                EmptyView()
            }

            VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                HairlineRule()
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(chart.ayanamsaNote)
                        .humayFont(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    InfoTrigger(termID: "ayanamsa", termName: "Ayanamsa", action: onGlossaryTerm)
                }
                .padding(.top, HumaySpacing.xs)
            }
        }
    }
}

/// The BaZi chart.
///
/// Four pillars and an element balance. There is no wheel here and no houses section,
/// because the system has neither — it reads element interactions between pillars
/// rather than bodies moving through a sky.
struct ChineseChartSection: View {
    /// Pairs a pillar position with its value so the four can be laid out as columns.
    struct PillarSlot: Identifiable {
        let position: PillarPosition
        let value: FactValue<Pillar>

        var id: PillarPosition { position }

        init(_ pair: (PillarPosition, FactValue<Pillar>)) {
            position = pair.0
            value = pair.1
        }
    }

    let chart: ChineseChart
    let onGlossaryTerm: (String) -> Void
    let onSelectPlacement: (String) -> Void

    @Environment(\.humayTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .headline) private var elementColumn: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            AdaptiveRow {
                MonoKicker(text: ChartSystem.chinese.displayName)
            } trailing: {
                SampleContentMarker(provenance: chart.provenance)
            }

            Text(chart.headline)
                .humayFont(.displayL)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            ChartTriadView(triad: chart.triad, onGlossaryTerm: onGlossaryTerm)

            ChartFeatureView(feature: chart.feature)

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                SectionHeader(
                    title: "Four pillars",
                    glossaryTerm: (id: "pillar", name: "Pillar"),
                    onGlossaryTerm: onGlossaryTerm
                )
                AdaptiveColumns(items: Array(zip(PillarPosition.allCases, chart.pillars).map(PillarSlot.init))) { slot in
                    pillarColumn(position: slot.position, value: slot.value)
                }
                HairlineRule()
            }

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                SectionHeader(
                    title: "Element balance",
                    glossaryTerm: (id: "wu-xing", name: "Five Elements"),
                    onGlossaryTerm: onGlossaryTerm
                )
                ForEach(WuXing.allCases) { element in
                    AdaptiveRow {
                        HStack(spacing: HumaySpacing.s) {
                            GlyphLabel(
                                glyph: element.han,
                                spokenName: element.spokenName,
                                role: .titleS,
                                color: theme.colors.accentMark
                            )
                            .frame(width: elementColumn, alignment: .leading)
                            Text(element.spokenName)
                                .humayFont(.callout)
                                .foregroundStyle(theme.colors.textPrimary)
                        }
                    } trailing: {
                        HStack(spacing: HumaySpacing.xs) {
                            MonoFact(
                                text: String(repeating: "▪", count: chart.elementBalance[element] ?? 0),
                                emphasised: (chart.elementBalance[element] ?? 0) > 1
                            )
                            MonoFact(text: "\(chart.elementBalance[element] ?? 0)")
                        }
                    }
                    .padding(.vertical, HumaySpacing.xs)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(element.spokenName), \(chart.elementBalance[element] ?? 0) of four pillars")
                }
            }

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                SectionHeader(
                    title: "Luck cycle",
                    glossaryTerm: (id: "luck-cycle", name: "Luck Cycle"),
                    onGlossaryTerm: onGlossaryTerm
                )
                switch chart.luckCycle {
                case .available(let cycles), .uncertain(let cycles, _):
                    ForEach(cycles) { cycle in
                        HStack(spacing: HumaySpacing.s) {
                            MonoFact(text: "FROM \(cycle.startAge)", emphasised: true)
                            Text(cycle.pillar.han)
                                .humayFont(.titleS)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, HumaySpacing.xs)
                    }
                case .unavailable(let reason):
                    UnavailableFactView(reason: reason)
                }
            }

            VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                HairlineRule()
                Text(chart.calendarNote)
                    .humayFont(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, HumaySpacing.xs)
            }
        }
    }

    @ViewBuilder
    private func pillarColumn(position: PillarPosition, value: FactValue<Pillar>) -> some View {
        // Four columns become four rows once the text is large enough that they cannot
        // sit side by side; the reading order is the same either way.
        let stacked = dynamicTypeSize.isAccessibilitySize
        let alignment: HorizontalAlignment = stacked ? .leading : .center

        Button {
            if value.value != nil { onSelectPlacement(position.rawValue) }
        } label: {
            VStack(alignment: alignment, spacing: HumaySpacing.xs) {
                MonoKicker(text: position.rawValue)
                if let pillar = value.value {
                    Text(pillar.han)
                        .humayFont(.displayM)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(pillar.element.spokenName)
                        .humayFont(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    Text("—")
                        .humayFont(.displayM)
                        .foregroundStyle(theme.colors.textDisabled)
                    Text("Needs time")
                        .humayFont(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .multilineTextAlignment(stacked ? .leading : .center)
                }
            }
            .frame(maxWidth: .infinity, alignment: stacked ? .leading : .center)
            .frame(minHeight: HumayHitTarget.minimum)
            .padding(.vertical, HumaySpacing.s)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            value.value.map(\.spokenDescription) ?? "\(position.displayName), needs a birth time"
        )
    }
}

/// A row for one placement, shared in shape across systems but never in content.
struct PlacementRow: View {
    let glyph: String
    let glyphSpokenName: String
    let title: String
    let subtitle: String
    let detail: String?
    let trailingNote: String?
    let isRetrograde: Bool
    let spokenLabel: String
    let action: () -> Void

    @Environment(\.humayTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .headline) private var glyphColumn: CGFloat = 22

    var body: some View {
        Button(action: action) {
            HStack(spacing: HumaySpacing.s) {
                AdaptiveRow(horizontalAlignment: .center) {
                    HStack(spacing: HumaySpacing.s) {
                        GlyphLabel(
                            glyph: glyph,
                            spokenName: glyphSpokenName,
                            role: .titleS,
                            color: theme.colors.accentMark
                        )
                        .frame(width: glyphColumn, alignment: .leading)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(title)
                                .humayFont(.titleS)
                                .foregroundStyle(theme.colors.textPrimary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(subtitle)
                                .humayFont(.callout)
                                .foregroundStyle(theme.colors.textSecondary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } trailing: {
                    HStack(spacing: HumaySpacing.xs) {
                        if isRetrograde { MonoFact(text: "Rx", emphasised: true) }
                        if let detail { MonoFact(text: detail) }
                        if let trailingNote { MonoFact(text: trailingNote, emphasised: true) }
                    }
                }

                DisclosureChevron()
            }
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? HumaySpacing.xs : 0)
            .frame(minHeight: HumayHitTarget.minimum)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(.isButton)
    }
}
