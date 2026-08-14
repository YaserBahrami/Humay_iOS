import SwiftUI

struct CompatibilityView: View {
    let state: CompatibilityFeatureState
    let precisePreview: PreciseCompatibilityResult?
    let source: D2ContentSource

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var previewOverride: PreciseCompatibilityResult?
    @State private var showUnlockInfo = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    stateContent(availableWidth: proxy.size.width)
                }
                .frame(maxWidth: 1_180)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.large)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationTitle("Compatibility")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let result = displayResult {
                    ShareLink(item: shareText(result)) {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Share Compatibility")
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
    private func stateContent(availableWidth: CGFloat) -> some View {
        switch activeState {
        case .entry:
            D2UnavailableState(
                symbol: "person.2",
                title: "Choose two people",
                detail: "Return to Circle and select a pair before opening compatibility."
            )

        case .loading(let pair):
            pairHeader(pair)
            HumaySurface(level: .raised) {
                VStack(spacing: HumaySpacing.large) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayLavender)
                    Text("Reading the connection…")
                        .font(HumayTypography.cardTitle)
                    Text("Looking at how these two energies meet.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HumaySpacing.extraExtraLarge)
            }

        case .freeLoaded(let result):
            loaded(
                DisplayResult(free: result),
                availableWidth: availableWidth,
                showAccessCard: false
            )

        case .preciseLocked(let freeResult):
            loaded(
                DisplayResult(free: freeResult),
                availableWidth: availableWidth,
                showAccessCard: true
            )

        case .preciseLoaded(let result):
            loaded(
                DisplayResult(precise: result),
                availableWidth: availableWidth,
                showAccessCard: false
            )

        case .cached(let result, let savedAt):
            D2StatusBanner(
                symbol: "clock.arrow.circlepath",
                title: "Saved result reopened",
                detail: "Cached \(savedAt.formatted(date: .abbreviated, time: .shortened)).",
                accent: .sage
            )
            loaded(
                DisplayResult(precise: result),
                availableWidth: availableWidth,
                showAccessCard: false
            )

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
                loaded(
                    DisplayResult(precise: cached),
                    availableWidth: availableWidth,
                    showAccessCard: false
                )
            } else {
                D2UnavailableState(
                    symbol: "wifi.slash",
                    title: "Compatibility unavailable offline",
                    detail: "Reconnect to open an available result."
                )
            }

        case .failed(let pair, let message):
            if let pair { pairHeader(pair) }
            D2UnavailableState(
                symbol: "heart.slash",
                title: "Connection unavailable",
                detail: message
            )
        }
    }

    @ViewBuilder
    private func loaded(
        _ result: DisplayResult,
        availableWidth: CGFloat,
        showAccessCard: Bool
    ) -> some View {
        relationshipField(result, useWideLayout: availableWidth >= 900)

        if availableWidth >= 900 {
            HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
                metricsCard(result.metrics)
                    .frame(maxWidth: .infinity, alignment: .top)

                VStack(spacing: HumaySpacing.extraLarge) {
                    ourTakeCard(result.ourTake)
                    if showAccessCard { preciseAccessCard }
                }
                .frame(minWidth: 320, maxWidth: 420, alignment: .top)
            }
        } else {
            metricsCard(result.metrics)
            ourTakeCard(result.ourTake)
            if showAccessCard { preciseAccessCard }
        }
    }

    @ViewBuilder
    private func basisDisclosure(_ result: DisplayResult) -> some View {
        switch result.basis {
        case .free(let key):
            basisRow(
                symbol: "sun.max.fill",
                title: "Free · Sun-sign pair",
                detail: "\(key.first.displayName) × \(key.second.displayName) catalog · not natal synastry.",
                accent: .gold
            )
            .accessibilityIdentifier("compatibility.basis.free")

        case .precise:
            basisRow(
                symbol: "scope",
                title: "Precise presentation sample",
                detail: "Development only · no provider calculation or synastry generation.",
                accent: .lavender
            )
            .accessibilityIdentifier("compatibility.basis.precise")
        }
    }

    private func basisRow(
        symbol: String,
        title: String,
        detail: String,
        accent: HumayAccent
    ) -> some View {
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    private func pairHeader(_ pair: CompatibilityPair) -> some View {
        VStack(spacing: HumaySpacing.large) {
            Text("\(pair.first.name) & \(pair.second.name)")
                .font(HumayTypography.editorialTitle)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            pairAxis(pair)
        }
        .frame(maxWidth: .infinity)
        .padding(HumaySpacing.extraLarge)
        .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(pair.first.name) and \(pair.second.name)")
    }

    private func relationshipField(_ result: DisplayResult, useWideLayout: Bool) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            basisDisclosure(result)

            Divider()

            if useWideLayout, !dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .center, spacing: HumaySpacing.extraExtraLarge) {
                    relationshipIdentity(result.pair)
                        .frame(maxWidth: .infinity)

                    Divider()
                        .frame(minHeight: 280)

                    relationshipResult(result)
                        .frame(minWidth: 330, maxWidth: 420)
                }
            } else {
                VStack(spacing: HumaySpacing.extraLarge) {
                    relationshipIdentity(result.pair)
                    Divider()
                    relationshipResult(result)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(useWideLayout ? HumaySpacing.extraExtraLarge : HumaySpacing.extraLarge)
        .background(relationshipBackground, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.humayHairline)
        }
        .shadow(
            color: colorScheme == .light ? .black.opacity(0.06) : .clear,
            radius: 16,
            y: 6
        )
    }

    private func relationshipIdentity(_ pair: CompatibilityPair) -> some View {
        VStack(spacing: HumaySpacing.extraLarge) {
            Text("\(pair.first.name) & \(pair.second.name)")
                .font(HumayTypography.editorialTitle)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(pair.first.name) and \(pair.second.name)")

            pairAxis(pair)
        }
        .frame(maxWidth: .infinity)
    }

    private func pairAxis(_ pair: CompatibilityPair) -> some View {
        HStack(alignment: .top, spacing: HumaySpacing.small) {
            relationshipPerson(pair.first, accent: .lavender)
                .frame(maxWidth: .infinity)

            CompatibilityConnector(state: .active)
                .frame(minWidth: 58, maxWidth: 130, minHeight: 90)

            relationshipPerson(pair.second, accent: .coral)
                .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(pair.first.westernSunSign?.displayName ?? "Sign unavailable") Sun and "
                + "\(pair.second.westernSunSign?.displayName ?? "Sign unavailable") Sun"
        )
    }

    private func relationshipPerson(_ person: CirclePerson, accent: HumayAccent) -> some View {
        VStack(spacing: HumaySpacing.small) {
            CirclePersonMedallion(person: person, accent: accent, size: 88)
            Text("\(person.westernSunSign?.displayName ?? "Sign unavailable") Sun")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func relationshipResult(_ result: DisplayResult) -> some View {
        VStack(spacing: HumaySpacing.medium) {
            Text("\(result.overallScore.value)%")
                .font(HumayTypography.compatibilityScore)
                .tracking(-2)
                .monospacedDigit()
                .foregroundStyle(scoreGradient)
                .accessibilityLabel("Compatibility score")
                .accessibilityValue("\(result.overallScore.value) percent")
                .accessibilityIdentifier("compatibility.score")

            Text(result.relationshipLabel)
                .font(HumayTypography.sectionTitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(result.shortSummary)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var relationshipBackground: LinearGradient {
        LinearGradient(
            colors: colorScheme == .light
                ? [
                    Color.humaySurface,
                    Color.humayLavender.opacity(0.10),
                    Color.humayCoral.opacity(0.10),
                    Color.humaySurface
                ]
                : [
                    Color.humayRaisedSurface,
                    Color.humayLavender.opacity(0.16),
                    Color.humayCoral.opacity(0.12),
                    Color.humayRaisedSurface
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var scoreGradient: LinearGradient {
        LinearGradient(
            colors: [Color.humayLavender, Color.humayCoral, Color.humaySolarGold],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func metricsCard(_ metrics: [CompatibilityMetric]) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            ForEach(metrics) { metric in
                HStack(spacing: HumaySpacing.medium) {
                    Image(systemName: metric.kind.symbol)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(metric.kind.accent.color)
                        .frame(width: 28, height: 28)
                        .accessibilityHidden(true)

                    Text(metric.kind.displayName)
                        .font(HumayTypography.supporting)
                        .frame(minWidth: 112, alignment: .leading)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.humayHairline.opacity(0.80))

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [metric.kind.accent.color, Color.humayCoral],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * CGFloat(metric.score.value) / 100
                                )
                        }
                    }
                    .frame(height: 6)

                    Text("\(metric.score.value)%")
                        .font(HumayTypography.supportingEmphasized)
                        .monospacedDigit()
                        .frame(width: 42, alignment: .trailing)
                }
                .frame(minHeight: 38)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(metric.kind.displayName)
                .accessibilityValue("\(metric.score.value) percent")
            }
        }
        .padding(.vertical, HumaySpacing.small)
        .accessibilityIdentifier("compatibility.metrics")
    }

    private func ourTakeCard(_ ourTake: String) -> some View {
        HStack(alignment: .center, spacing: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text("Our Take")
                    .font(HumayTypography.utility)
                    .textCase(.uppercase)
                    .tracking(1.1)
                    .foregroundStyle(Color.humayCoral)
                Text(ourTake)
                    .font(HumayTypography.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RoastPlanetArt()
        }
        .padding(HumaySpacing.extraLarge)
        .background(
            LinearGradient(
                colors: colorScheme == .light
                    ? [Color.humaySurface, Color.humaySolarGold.opacity(0.12)]
                    : [Color.humayRaisedSurface, Color.humayCoral.opacity(0.12)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: HumayRadius.surface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("compatibility.our-take")
    }

    private var preciseAccessCard: some View {
        HumaySurface(level: .raised) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Label("Precise Compatibility", systemImage: "lock.fill")
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayLavender)
                Text("Unlock precise synastry when personalized chart generation is available.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Unlock Precise") {
                    showUnlockInfo = true
                }
                .buttonStyle(.humaySecondary)
                .accessibilityIdentifier("compatibility.precise.unlock")

                if source.isDevelopmentSample, let precisePreview {
                    Button("Preview precise layout") {
                        previewOverride = precisePreview
                    }
                    .font(HumayTypography.control)
                    .frame(minHeight: HumayMetrics.minimumHitTarget)
                    .accessibilityIdentifier("compatibility.precise.preview")
                }
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
        "\(result.pair.first.name) + \(result.pair.second.name)\n\(result.overallScore.value)% · \(result.relationshipLabel)\n\(result.ourTake)"
    }
}

private struct DisplayResult {
    enum Basis {
        case free(WesternSunSignPairKey)
        case precise
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

extension CompatibilityMetricKind {
    var symbol: String {
        switch self {
        case .chemistry: "heart"
        case .communication: "message"
        case .emotionalConnection: "face.smiling"
        case .adventure: "paperplane"
        }
    }

    var accent: HumayAccent {
        switch self {
        case .chemistry: .coral
        case .communication: .gold
        case .emotionalConnection: .lavender
        case .adventure: .blue
        }
    }
}
