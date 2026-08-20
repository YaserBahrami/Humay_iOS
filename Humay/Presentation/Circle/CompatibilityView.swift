import SwiftUI

struct CompatibilityView: View {
    let state: CompatibilityFeatureState
    let precisePreview: PreciseCompatibilityResult?
    let source: D2ContentSource

    @State private var previewOverride: PreciseCompatibilityResult?
    @State private var showUnlockInfo = false

    var body: some View {
        HumayPage(maximum: .immersive) {
            stateContent
        }
        .navigationTitle("Compatibility")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let result = displayResult {
                    ShareLink(item: shareText(result)) {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                    }
                    .accessibilityLabel("Share compatibility")
                }
            }
        }
        .alert("Precise compatibility is not connected", isPresented: $showUnlockInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Provider-backed synastry will be connected with its access flow.")
        }
    }

    private var activeState: CompatibilityFeatureState {
        if let previewOverride {
            return .preciseLoaded(previewOverride)
        }
        return state
    }

    @ViewBuilder
    private var stateContent: some View {
        switch activeState {
        case .entry:
            HumayStateView(
                title: "Choose two people",
                message: "Return to Connections and select a pair before opening compatibility.",
                symbol: .compatibility
            )

        case .loading(let pair):
            compactPairHeader(pair)
            HumayHairlineSurface(style: .raised) {
                HStack(spacing: HumaySpacing.extraLarge) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayAccentPrestige)
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text("Reading the connection…")
                            .font(HumayTypography.narrativeSectionTitle)
                        Text("Looking at how these two energies meet.")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
            }

        case .freeLoaded(let result):
            loaded(DisplayResult(free: result), showAccessCard: false)

        case .preciseLocked(let freeResult):
            loaded(DisplayResult(free: freeResult), showAccessCard: true)

        case .preciseLoaded(let result):
            loaded(DisplayResult(precise: result), showAccessCard: false)

        case .cached(let result, let savedAt):
            D2StatusBanner(
                symbol: "clock.arrow.circlepath",
                title: "Saved result reopened",
                detail: "Cached \(savedAt.formatted(date: .abbreviated, time: .shortened)).",
                accent: .sage
            )
            loaded(DisplayResult(precise: result), showAccessCard: false)

        case .offline(let cached):
            D2StatusBanner(
                symbol: "wifi.slash",
                title: "Offline",
                detail: cached == nil
                    ? "No saved compatibility result can be reopened."
                    : "Showing your saved compatibility result.",
                accent: .gold
            )
            if let cached {
                loaded(DisplayResult(precise: cached), showAccessCard: false)
            } else {
                HumayStateView(
                    title: "Compatibility unavailable offline",
                    message: "Reconnect to open an available result.",
                    symbol: .offline
                )
            }

        case .failed(let pair, let message):
            if let pair { compactPairHeader(pair) }
            HumayStateView(
                title: "Connection unavailable",
                message: message,
                symbol: .unavailable
            )
        }
    }

    @ViewBuilder
    private func loaded(_ result: DisplayResult, showAccessCard: Bool) -> some View {
        relationshipHero(result)

        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: HumaySpacing.hero) {
                dimensions(result.metrics)
                    .frame(minWidth: 420, maxWidth: 620, alignment: .topLeading)
                connectionNotes(result)
                    .frame(minWidth: 320, maxWidth: 430, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: HumaySpacing.section) {
                dimensions(result.metrics)
                connectionNotes(result)
            }
        }

        reading(result.ourTake)
        technicalDisclosure(result)

        if showAccessCard {
            preciseAccessCard
        }
    }

    private func relationshipHero(_ result: DisplayResult) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: HumaySpacing.hero) {
                pairIdentity(result.pair)
                    .frame(minWidth: 420, maxWidth: 560)
                relationshipCopy(result)
                    .frame(minWidth: 320, maxWidth: 460, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: HumaySpacing.extraExtraLarge) {
                pairIdentity(result.pair)
                relationshipCopy(result)
            }
        }
        .padding(.vertical, HumaySpacing.large)
    }

    private func pairIdentity(_ pair: CompatibilityPair) -> some View {
        VStack(spacing: HumaySpacing.extraLarge) {
            HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                relationshipPerson(pair.first, accent: .blue)
                    .frame(maxWidth: .infinity)

                HumaySystemSymbolImage(symbol: .love, size: .standard)
                    .foregroundStyle(Color.humayAccentPrestige)
                    .padding(.top, HumaySpacing.extraLarge)

                relationshipPerson(pair.second, accent: .gold)
                    .frame(maxWidth: .infinity)
            }

            Text("\(pair.first.name) & \(pair.second.name)")
                .font(HumayTypography.displayTitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        .accessibilityElement(children: .contain)
    }

    private func relationshipPerson(_ person: CirclePerson, accent: HumayAccent) -> some View {
        VStack(spacing: HumaySpacing.small) {
            CirclePersonMedallion(person: person, accent: accent, size: 82)
            if let sign = person.westernSunSign {
                HStack(spacing: HumaySpacing.small) {
                    HumayZodiacGlyph(
                        sign: sign,
                        size: .inline,
                        color: accent.color
                    )
                    Text("\(sign.displayName) Sun")
                        .font(HumayTypography.caption)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            } else {
                Text("Sign unavailable")
                    .font(HumayTypography.caption)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(person.name), \(person.westernSunSign?.displayName ?? "Sun sign unavailable")"
        )
    }

    private func relationshipCopy(_ result: DisplayResult) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumayEyebrow(text: result.basis.eyebrow)

            Text(result.relationshipLabel)
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)

            Text(result.shortSummary)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Overall context · \(result.overallScore.value)/100")
                .font(HumayTypography.technicalSmall)
                .foregroundStyle(Color.humayTextSecondary)
                .monospacedDigit()
                .accessibilityLabel("Overall compatibility context")
                .accessibilityValue("\(result.overallScore.value) out of 100")
                .accessibilityIdentifier("compatibility.score")
        }
    }

    private func dimensions(_ metrics: [CompatibilityMetric]) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumaySectionHeader(
                title: "How this connection moves",
                subtitle: "A relationship has texture. These dimensions matter more than one headline score."
            )

            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                ForEach(metrics) { metric in
                    HumayMetricBand(
                        label: metric.kind.premiumDisplayName,
                        score: metric.score.value,
                        detail: metric.kind.dimensionDetail,
                        accent: metric.kind.accent
                    )
                }
            }
        }
        .accessibilityIdentifier("compatibility.metrics")
    }

    private func connectionNotes(_ result: DisplayResult) -> some View {
        let strongest = result.metrics.max { $0.score < $1.score }
        let growthEdge = result.metrics.min { $0.score < $1.score }

        return HumayHairlineSurface(style: .celestial) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                HumayEyebrow(text: "Connection notes")

                if let strongest {
                    note(
                        title: "Where you connect",
                        detail: "\(strongest.kind.premiumDisplayName) carries the strongest signal in this reading."
                    )
                }

                if let growthEdge {
                    note(
                        title: "Where friction may appear",
                        detail: "\(growthEdge.kind.premiumDisplayName) asks for more conscious attention."
                    )
                    note(
                        title: "What each person needs",
                        detail: growthEdge.kind.practice(
                            firstName: result.pair.first.name,
                            secondName: result.pair.second.name
                        )
                    )
                }
            }
        }
    }

    private func note(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            Text(title)
                .font(HumayTypography.bodyEmphasized)
            Text(detail)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func reading(_ ourTake: String) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "Humay's reading")
            Text(ourTake)
                .font(HumayTypography.narrativeSectionTitle)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, HumaySpacing.extraLarge)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("compatibility.our-take")
    }

    private func technicalDisclosure(_ result: DisplayResult) -> some View {
        HumayDisclosureGroup(
            eyebrow: "Technical astrology",
            title: result.basis.title,
            summary: result.basis.summary
        ) {
            HumayHairlineSurface(style: .quiet) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    Text(result.basis.detail)
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    ForEach(result.metrics) { metric in
                        HumayFactRow(
                            label: metric.kind.premiumDisplayName,
                            value: "\(metric.score.value)%",
                            technical: true
                        )
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(result.basis.identifier)
    }

    private func compactPairHeader(_ pair: CompatibilityPair) -> some View {
        HStack(spacing: HumaySpacing.extraLarge) {
            HumaySystemSymbolImage(symbol: .compatibility, size: .feature)
                .foregroundStyle(Color.humayAccentPrestige)
            Text("\(pair.first.name) & \(pair.second.name)")
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var preciseAccessCard: some View {
        HumayHairlineSurface(style: .raised) {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                HumayEyebrow(text: "Deeper comparison", color: .humayAccentCelestial)
                Text("Precise compatibility")
                    .font(HumayTypography.narrativeSectionTitle)
                Text("Unlock precise synastry when personalized chart generation is available.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Unlock precise") { showUnlockInfo = true }
                    .buttonStyle(.humaySecondary)
                    .accessibilityIdentifier("compatibility.precise.unlock")

#if DEBUG
                if source.isDevelopmentSample, let precisePreview {
                    Button("Preview precise layout") { previewOverride = precisePreview }
                        .font(HumayTypography.control)
                        .frame(minHeight: HumayMetrics.minimumHitTarget)
                        .accessibilityIdentifier("compatibility.precise.preview")
                }
#endif
            }
        }
    }

    private var displayResult: DisplayResult? {
        switch activeState {
        case .freeLoaded(let result), .preciseLocked(let result): DisplayResult(free: result)
        case .preciseLoaded(let result), .cached(let result, _): DisplayResult(precise: result)
        case .offline(let result): result.map(DisplayResult.init(precise:))
        case .entry, .loading, .failed: nil
        }
    }

    private func shareText(_ result: DisplayResult) -> String {
        "\(result.pair.first.name) + \(result.pair.second.name)\n\(result.relationshipLabel)\n\(result.ourTake)"
    }
}

private struct DisplayResult {
    enum Basis {
        case free(WesternSunSignPairKey)
        case precise

        var eyebrow: String {
            switch self {
            case .free: "Sun-sign connection"
            case .precise: "Precise connection"
            }
        }

        var title: String {
            switch self {
            case .free: "Sun-sign basis"
            case .precise: "Precise presentation basis"
            }
        }

        var summary: String {
            switch self {
            case .free(let key): "\(key.first.displayName) × \(key.second.displayName) · not natal synastry"
            case .precise: "Development presentation sample · not provider-calculated"
            }
        }

        var detail: String {
            switch self {
            case .free(let key):
                "This reading comes from the \(key.first.displayName) Sun × \(key.second.displayName) Sun catalog. Natal aspects and orbs are not supplied, so Humay does not invent them."
            case .precise:
                "This is a development-only presentation sample. It contains no provider calculation or generated synastry aspects."
            }
        }

        var identifier: String {
            switch self {
            case .free: "compatibility.basis.free"
            case .precise: "compatibility.basis.precise"
            }
        }
    }

    let pair: CompatibilityPair
    let basis: Basis
    let overallScore: CompatibilityScore
    let relationshipLabel: String
    let shortSummary: String
    let metrics: [CompatibilityMetric]
    let ourTake: String

    init(free result: FreeCompatibilityResult) {
        pair = result.pair
        basis = .free(result.catalogKey)
        overallScore = result.overallScore
        relationshipLabel = result.relationshipLabel
        shortSummary = result.shortSummary
        metrics = result.metrics
        ourTake = result.ourTake
    }

    init(precise result: PreciseCompatibilityResult) {
        pair = result.pair
        basis = .precise
        overallScore = result.overallScore
        relationshipLabel = result.relationshipLabel
        shortSummary = result.shortSummary
        metrics = result.metrics
        ourTake = result.ourTake
    }
}

private extension CompatibilityMetricKind {
    var premiumDisplayName: String {
        switch self {
        case .chemistry: "Chemistry"
        case .communication: "Communication"
        case .emotionalConnection: "Emotional Safety"
        case .adventure: "Shared Rhythm"
        }
    }

    var dimensionDetail: String {
        switch self {
        case .chemistry: "Attraction, warmth, and the pull toward one another."
        case .communication: "How easily intent becomes shared understanding."
        case .emotionalConnection: "Room for vulnerability, reassurance, and repair."
        case .adventure: "The balance between novelty, pacing, and everyday cadence."
        }
    }

    var accent: Color {
        switch self {
        case .chemistry: .humayAccentRoast
        case .communication: .humayAccentPrestige
        case .emotionalConnection: .humayAccentCelestial
        case .adventure: .humayChartHarmonious
        }
    }

    func practice(firstName: String, secondName: String) -> String {
        switch self {
        case .chemistry:
            "\(firstName) and \(secondName) benefit from naming affection and desire instead of assuming it is understood."
        case .communication:
            "Both people benefit from checking what was heard before reacting to what was meant."
        case .emotionalConnection:
            "Make room for different emotional pacing; reassurance works best when it is specific."
        case .adventure:
            "Protect both novelty and routine so one person's momentum does not set the entire pace."
        }
    }
}
