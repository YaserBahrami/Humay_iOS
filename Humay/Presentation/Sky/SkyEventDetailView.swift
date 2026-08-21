import SwiftUI

/// Explanatory destination for one supplied Sky event. The view consumes the
/// immutable D3 detail state and observation context owned by its opening route.
struct SkyEventDetailView: View {
    let source: D3ContentSource
    let state: SkyEventDetailFeatureState
    let context: SkyObservationContext?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content(availableWidth: proxy.size.width)
                    .frame(maxWidth: HumayContentWidth.immersive.rawValue, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                    .padding(.top, HumaySpacing.large)
                    .padding(.bottom, HumaySpacing.expansive + HumaySpacing.extraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayCanvas.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationTitle("Event Detail")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("sky.event-detail.screen")
    }

    @ViewBuilder
    private func content(availableWidth: CGFloat) -> some View {
        switch state {
        case .loading:
            SkyLoadingPresentation(
                title: "Loading event detail…",
                message: "Waiting for supplied event facts and interpretation.",
                identifier: "sky.event-detail.state.loading"
            )

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
                    SkyOfflineBanner(
                        title: "Offline · saved event detail",
                        detail: "Showing the cached event detail supplied on this device.",
                        identifier: "sky.event-detail.offline.cached.notice"
                    )
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
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HStack(alignment: .center, spacing: HumaySpacing.medium) {
                SkyEventGlyph(event: detail.event, size: 20)
                HumayEyebrow(
                    text: SkyEventTypeFormatter.label(for: detail.event.type),
                    color: detail.event.style.accent
                )
            }

            Text(detail.event.title)
                .font(HumayTypography.displayTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.large) {
                    eventIdentityMetadata(detail.event)
                }
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    eventIdentityMetadata(detail.event)
                }
            }

            Divider()
                .overlay(Color.humaySeparator)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(heroAccessibilityLabel(for: detail))
        .accessibilityIdentifier("sky.event-detail.title")
    }

    @ViewBuilder
    private func eventIdentityMetadata(_ event: SkyEvent) -> some View {
        Label(
            SkyMethodologyFormatter.label(for: event.system),
            systemImage: "books.vertical"
        )
        .font(HumayTypography.supporting)
        .foregroundStyle(Color.humayTextSecondary)

        Label(
            timingText(for: event.timing),
            systemImage: "clock"
        )
        .font(HumayTypography.supporting)
        .monospacedDigit()
        .foregroundStyle(Color.humayTextSecondary)
    }

    private func meaningSection(_ meaning: String) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "Human interpretation", color: .humayAccentPrestige)
            sectionHeading("What this means")

            Text(meaning)
                .font(HumayTypography.body)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: HumayContentWidth.readable.rawValue, alignment: .leading)
        }
        .padding(.leading, HumaySpacing.large)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.humayAccentPrestige)
                .frame(width: 2)
        }
        .accessibilityIdentifier("sky.event-detail.meaning")
    }

    private func factualContext(_ detail: SkyEventDetail) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "Supplied information", color: .humayAccentCelestial)
            sectionHeading("Factual context")

            Divider()
                .overlay(Color.humaySeparator)

            VStack(spacing: 0) {
                factRow(label: "Timing", value: timingText(for: detail.event.timing), technical: true)
                factDivider
                factRow(label: "System", value: SkyMethodologyFormatter.label(for: detail.event.system))
                factDivider
                factRow(label: "Event type", value: SkyEventTypeFormatter.label(for: detail.event.type))
                factDivider
                factRow(label: "Relevance", value: SkyEventRelevanceFormatter.label(for: detail.event.relevance))
                factDivider
                factRow(label: "Reliability", value: SkyEventReliabilityFormatter.label(for: detail.event.reliability))

                if let context {
                    factDivider
                    factRow(label: "Timezone", value: context.timeZoneIdentifier, technical: true)

                    if let locationName = context.locationName {
                        factDivider
                        factRow(label: "Location", value: locationName)
                    }
                }
            }

            Divider()
                .overlay(Color.humaySeparator)
        }
        .accessibilityIdentifier("sky.event-detail.facts")
    }

    private func basisSection(_ basis: String) -> some View {
        HumayDisclosureGroup(
            eyebrow: "Technical context",
            title: "Astrological basis",
            summary: "How the supplied interpretation is framed"
        ) {
            Text(basis)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, HumaySpacing.small)
        .overlay(alignment: .top) {
            Divider().overlay(Color.humaySeparator)
        }
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.humaySeparator)
        }
        .accessibilityIdentifier("sky.event-detail.basis")
    }

    private func factRow(label: String, value: String, technical: Bool = false) -> some View {
        HumayFactRow(label: label, value: value, technical: technical)
            .padding(.vertical, HumaySpacing.small)
    }

    private var factDivider: some View {
        Divider().overlay(Color.humaySeparator)
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(HumayTypography.sectionTitle)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    private var detailDevelopmentNotice: some View {
        SkyDevelopmentNotice(identifier: "sky.event-detail.development-sample.notice")
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
        SkyStatePresentation(
            symbol: copy.symbol,
            title: copy.title,
            message: copy.detail,
            identifier: identifier,
            eyebrow: "Event detail",
            accent: .humayAccentCelestial
        )
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
