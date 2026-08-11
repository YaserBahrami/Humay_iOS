import SwiftUI

/// The Western chart.
///
/// The only section with a wheel, houses and aspects. These are not withheld from the
/// other two systems — they do not exist there.
struct WesternChartSection: View {
    let chart: WesternChart
    let onSelectPlacement: (String) -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            HStack(alignment: .firstTextBaseline) {
                MonoKicker(text: ChartSystem.western.displayName)
                Spacer(minLength: HumaySpacing.xs)
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
                        HStack {
                            Text("\(aspect.first.glyph) \(aspect.kind.glyph) \(aspect.second.glyph)")
                                .humayFont(.titleS)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer(minLength: HumaySpacing.s)
                            MonoFact(text: aspect.orbFormatted, emphasised: aspect.orbDegrees < 1)
                        }
                        .frame(minHeight: 34)
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
                        HStack(alignment: .top, spacing: HumaySpacing.s) {
                            MonoFact(text: "H\(house.id)", emphasised: true)
                                .frame(width: 28, alignment: .leading)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(house.title)
                                    .humayFont(.callout)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(house.summary)
                                    .humayFont(.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: HumaySpacing.xs)
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

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            HStack(alignment: .firstTextBaseline) {
                MonoKicker(text: ChartSystem.vedic.displayName)
                Spacer(minLength: HumaySpacing.xs)
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
                HStack(spacing: 0) {
                    SectionHeader(title: "Current period")
                    InfoTrigger(termID: "mahadasha", termName: "Mahadasha", action: onGlossaryTerm)
                        .frame(width: 30, height: 30)
                }
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
                    HStack(spacing: 0) {
                        SectionHeader(title: "Bhavas")
                        InfoTrigger(termID: "bhava", termName: "Bhava", action: onGlossaryTerm)
                            .frame(width: 30, height: 30)
                    }
                    ForEach(bhavas) { bhava in
                        HStack(alignment: .top, spacing: HumaySpacing.s) {
                            MonoFact(text: bhava.notation, emphasised: true)
                                .frame(width: 28, alignment: .leading)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(bhava.title)
                                    .humayFont(.callout)
                                    .foregroundStyle(theme.colors.textPrimary)
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
                HStack(spacing: 0) {
                    Text(chart.ayanamsaNote)
                        .humayFont(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, HumaySpacing.xs)
                    InfoTrigger(termID: "ayanamsa", termName: "Ayanamsa", action: onGlossaryTerm)
                }
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
    let chart: ChineseChart
    let onGlossaryTerm: (String) -> Void
    let onSelectPlacement: (String) -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            HStack(alignment: .firstTextBaseline) {
                MonoKicker(text: ChartSystem.chinese.displayName)
                Spacer(minLength: HumaySpacing.xs)
                SampleContentMarker(provenance: chart.provenance)
            }

            Text(chart.headline)
                .humayFont(.displayL)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            ChartTriadView(triad: chart.triad, onGlossaryTerm: onGlossaryTerm)

            ChartFeatureView(feature: chart.feature)

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                HStack(spacing: 0) {
                    SectionHeader(title: "Four pillars")
                    InfoTrigger(termID: "pillar", termName: "Pillar", action: onGlossaryTerm)
                        .frame(width: 30, height: 30)
                }
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(zip(PillarPosition.allCases, chart.pillars)), id: \.0) { position, value in
                        pillarColumn(position: position, value: value)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                HairlineRule()
            }

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                HStack(spacing: 0) {
                    SectionHeader(title: "Element balance")
                    InfoTrigger(termID: "wu-xing", termName: "Five Elements", action: onGlossaryTerm)
                        .frame(width: 30, height: 30)
                }
                ForEach(WuXing.allCases) { element in
                    HStack(spacing: HumaySpacing.s) {
                        GlyphLabel(
                            glyph: element.han,
                            spokenName: element.spokenName,
                            role: .titleS,
                            color: theme.colors.accentMark
                        )
                        .frame(width: 24, alignment: .leading)
                        Text(element.spokenName)
                            .humayFont(.callout)
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer(minLength: HumaySpacing.s)
                        MonoFact(
                            text: String(repeating: "▪", count: chart.elementBalance[element] ?? 0),
                            emphasised: (chart.elementBalance[element] ?? 0) > 1
                        )
                        MonoFact(text: "\(chart.elementBalance[element] ?? 0)")
                    }
                    .frame(minHeight: 32)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(element.spokenName), \(chart.elementBalance[element] ?? 0) of four pillars")
                }
            }

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                HStack(spacing: 0) {
                    SectionHeader(title: "Luck cycle")
                    InfoTrigger(termID: "luck-cycle", termName: "Luck Cycle", action: onGlossaryTerm)
                        .frame(width: 30, height: 30)
                }
                switch chart.luckCycle {
                case .available(let cycles), .uncertain(let cycles, _):
                    ForEach(cycles) { cycle in
                        HStack {
                            MonoFact(text: "FROM \(cycle.startAge)", emphasised: true)
                            Text(cycle.pillar.han)
                                .humayFont(.titleS)
                                .foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                        }
                        .frame(minHeight: 32)
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
        Button {
            if value.value != nil { onSelectPlacement(position.rawValue) }
        } label: {
            VStack(spacing: HumaySpacing.xs) {
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
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
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

    var body: some View {
        Button(action: action) {
            HStack(spacing: HumaySpacing.s) {
                GlyphLabel(
                    glyph: glyph,
                    spokenName: glyphSpokenName,
                    role: .titleS,
                    color: theme.colors.accentMark
                )
                .frame(width: 22, alignment: .leading)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .humayFont(.titleS)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer(minLength: HumaySpacing.xs)

                if isRetrograde { MonoFact(text: "Rx", emphasised: true) }
                if let detail { MonoFact(text: detail) }
                if let trailingNote { MonoFact(text: trailingNote, emphasised: true) }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.colors.textLabel)
            }
            .frame(minHeight: HumayHitTarget.minimum)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(.isButton)
    }
}
