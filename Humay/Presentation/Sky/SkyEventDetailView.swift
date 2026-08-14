import SwiftUI

/// Explanatory destination for one supplied Sky event. The view consumes the
/// immutable D3 detail state and observation context owned by its opening route.
struct SkyEventDetailView: View {
    let source: D3ContentSource
    let state: SkyEventDetailFeatureState
    let context: SkyObservationContext?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content(availableWidth: proxy.size.width)
                    .frame(maxWidth: 1_120, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                    .padding(.top, HumaySpacing.large)
                    .padding(.bottom, HumaySpacing.extraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationTitle("Event Detail")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("sky.event-detail.screen")
    }

    @ViewBuilder
    private func content(availableWidth: CGFloat) -> some View {
        switch state {
        case .loading:
            SkyEventDetailLoadingState(reduceMotion: reduceMotion)

        case .loaded(let detail):
            loadedContent(detail, availableWidth: availableWidth)

        case .unavailable(_, let reason):
            let copy = SkyEventDetailStateFormatter.unavailableCopy(for: reason)
            stateMessage(
                copy,
                identifier: reason == .eventNotFound
                    ? "sky.event-detail.state.event-not-found"
                    : "sky.event-detail.state.unavailable"
            )

        case .offline(_, let cached):
            if let cached {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    SkyEventDetailOfflineNotice()
                    loadedContent(cached, availableWidth: availableWidth)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("sky.event-detail.state.offline.cached")
            } else {
                stateMessage(
                    SkyEventDetailStateCopy(
                        symbol: "wifi.slash",
                        title: "No saved event detail",
                        detail: "Reconnect to load this event’s supplied facts."
                    ),
                    identifier: "sky.event-detail.state.offline.no-cache"
                )
            }

        case .failed(_, let failure):
            stateMessage(
                SkyEventDetailStateFormatter.failureCopy(for: failure),
                identifier: "sky.event-detail.state.failed"
            )
        }
    }

    @ViewBuilder
    private func loadedContent(
        _ detail: SkyEventDetail,
        availableWidth: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            if source.isDevelopmentSample {
                detailDevelopmentNotice
            }

            if usesWideLayout(availableWidth) {
                HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
                    identityColumn(detail)
                        .frame(maxWidth: 480, alignment: .topLeading)

                    factsColumn(detail)
                        .frame(maxWidth: 560, alignment: .topLeading)
                }
                .frame(maxWidth: 1_100, alignment: .topLeading)
            } else {
                identityColumn(detail)
                factsColumn(detail)
            }
        }
    }

    private func usesWideLayout(_ width: CGFloat) -> Bool {
        width >= 820 && !dynamicTypeSize.isAccessibilitySize
    }

    private func identityColumn(_ detail: SkyEventDetail) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            eventHero(detail)

            if let meaning = nonemptyText(detail.meaning) {
                meaningSection(meaning)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func factsColumn(_ detail: SkyEventDetail) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            factualContext(detail)

            if let basis = nonemptyText(detail.astrologicalBasis) {
                basisSection(basis)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func eventHero(_ detail: SkyEventDetail) -> some View {
        HumaySurface(level: .raised, padding: HumaySpacing.large) {
            HStack(alignment: .top, spacing: HumaySpacing.medium) {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text(SkyEventTypeFormatter.label(for: detail.event.type))
                        .font(HumayTypography.utility)
                        .textCase(.uppercase)
                        .tracking(1.1)
                        .foregroundStyle(detail.event.style.accent)

                    Text(detail.event.title)
                        .font(HumayTypography.detailTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text(SkyMethodologyFormatter.label(for: detail.event.system))
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.small) {
                        Image(systemName: "clock")
                            .font(.system(size: 13, weight: .semibold))
                            .accessibilityHidden(true)

                        Text(timingText(for: detail.event.timing))
                            .font(HumayTypography.supportingEmphasized)
                            .monospacedDigit()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(Color.humayTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: detail.event.style.symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(detail.event.style.accent)
                    .frame(width: 36, height: 36)
                    .background(detail.event.style.accent.opacity(0.12), in: Circle())
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(heroAccessibilityLabel(for: detail))
        .accessibilityIdentifier("sky.event-detail.title")
    }

    private func meaningSection(_ meaning: String) -> some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                sectionHeading("What this means")

                Text(meaning)
                    .font(HumayTypography.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("sky.event-detail.meaning")
    }

    private func factualContext(_ detail: SkyEventDetail) -> some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                sectionHeading("Factual context")

                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    factRow(
                        label: "Timing",
                        value: timingText(for: detail.event.timing),
                        monospaced: true
                    )
                    factRow(
                        label: "System",
                        value: SkyMethodologyFormatter.label(for: detail.event.system)
                    )
                    factRow(
                        label: "Event type",
                        value: SkyEventTypeFormatter.label(for: detail.event.type)
                    )
                    factRow(
                        label: "Relevance",
                        value: SkyEventRelevanceFormatter.label(for: detail.event.relevance)
                    )
                    factRow(
                        label: "Reliability",
                        value: SkyEventReliabilityFormatter.label(for: detail.event.reliability)
                    )
                }
            }
        }
        .accessibilityIdentifier("sky.event-detail.facts")
    }

    private func basisSection(_ basis: String) -> some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                sectionHeading("Astrological basis")

                Text(basis)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("sky.event-detail.basis")
    }

    private func factRow(label: String, value: String, monospaced: Bool = false) -> some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Text(label)
                .font(HumayTypography.utility)
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(Color.humayTextSecondary)
                .frame(width: 112, alignment: .leading)

            factValue(value, monospaced: monospaced)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }

    @ViewBuilder
    private func factValue(_ value: String, monospaced: Bool) -> some View {
        if monospaced {
            Text(value)
                .font(HumayTypography.supporting)
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(value)
                .font(HumayTypography.supporting)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(HumayTypography.sectionTitle)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    private var detailDevelopmentNotice: some View {
        Label("Development sample · not calculated", systemImage: "hammer")
            .font(HumayTypography.caption)
            .foregroundStyle(Color.humayTextSecondary)
            .frame(minHeight: 22, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("sky.event-detail.development-sample.notice")
    }

    private func timingText(for timing: SkyEventTiming) -> String {
        guard let context else { return "Timing unavailable" }
        return SkyEventTimingFormatter.text(for: timing, context: context)
    }

    private func timingAccessibilityText(for timing: SkyEventTiming) -> String {
        guard let context else { return "Timing unavailable" }
        return SkyEventTimingFormatter.accessibilityText(for: timing, context: context)
    }

    private func nonemptyText(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func heroAccessibilityLabel(for detail: SkyEventDetail) -> String {
        "\(SkyEventTypeFormatter.label(for: detail.event.type)), \(detail.event.title), "
            + "\(SkyMethodologyFormatter.label(for: detail.event.system)), "
            + timingAccessibilityText(for: detail.event.timing)
    }

    private func stateMessage(
        _ copy: SkyEventDetailStateCopy,
        identifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            Image(systemName: copy.symbol)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.humayLavender)
                .frame(width: 56, height: 56)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(copy.title)
                    .font(HumayTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(copy.detail)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240, alignment: .center)
        .padding(HumaySpacing.extraLarge)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

private struct SkyEventDetailOfflineNotice: View {
    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: "wifi.slash")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.humaySolarGold)
                .frame(width: 32, height: 32)
                .background(Color.humaySolarGold.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text("Offline · saved event detail")
                    .font(HumayTypography.bodyEmphasized)
                Text("Showing the cached event detail supplied on this device.")
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
        .accessibilityIdentifier("sky.event-detail.offline.cached.notice")
    }
}

private struct SkyEventDetailLoadingState: View {
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            skeleton(width: 170, height: 14)
            skeleton(width: .infinity, height: 44)
            skeleton(width: 220, height: 14)

            HStack(spacing: HumaySpacing.medium) {
                if reduceMotion {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(Color.humayLavender)
                        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                        .accessibilityHidden(true)
                } else {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayLavender)
                        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                }

                Text("Loading event detail…")
                    .font(HumayTypography.bodyEmphasized)
            }

            skeleton(width: .infinity, height: 120)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading event detail")
        .accessibilityIdentifier("sky.event-detail.state.loading")
    }

    private func skeleton(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.humayRaisedSurface)
            .frame(maxWidth: width == .infinity ? .infinity : nil)
            .frame(width: width == .infinity ? nil : width, height: height)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Event Detail") {
    SkyEventDetailView(
        source: .developmentSample,
        state: .loaded(DevelopmentD3Sample.ingressDetail),
        context: DevelopmentD3Sample.context
    )
}
#endif
