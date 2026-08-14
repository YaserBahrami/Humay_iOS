import SwiftUI

struct ChartView: View {
    let input: D4FeatureInput
    let profileName: String
    let openProfile: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    D2WordmarkHeader(
                        title: "Chart",
                        profileName: profileName,
                        profileAction: openProfile
                    )

                    stateSurface
                }
                .frame(maxWidth: HumayContentWidth.readable.rawValue, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.large)
            }
            .background(Color.humayGround.ignoresSafeArea())
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier("chart.screen")
    }

    @ViewBuilder
    private var stateSurface: some View {
        switch input.chart {
        case .loading(let context):
            ChartLoadingState(context: context)

        case .freePreview(let readiness):
            ChartFreeEntry(readiness: readiness)

        case .precisionLocked(let offer, let readiness):
            ChartAccessState(
                stateIdentifier: "precision-locked",
                offer: offer,
                readiness: readiness,
                detail: "More precise chart details need the right birth information and access."
            )

        case .generationAvailable(let offer, let readiness):
            ChartAccessState(
                stateIdentifier: "generation-available",
                offer: offer,
                readiness: readiness,
                detail: "Your birth details are ready for a more precise chart."
            )

        case .loaded(let payload):
            ChartReadyEntry(payload: payload, source: input.source, status: nil)

        case .cached(let payload, let savedAt):
            ChartReadyEntry(
                payload: payload,
                source: input.source,
                status: ChartStateBannerModel(
                    identifier: "cached",
                    symbol: "clock.arrow.circlepath",
                    title: "Saved chart",
                    detail: "Showing the last saved chart from \(savedAt.chartDateLabel).",
                    accent: .blue
                )
            )

        case .offlineCached(let payload, let savedAt):
            ChartReadyEntry(
                payload: payload,
                source: input.source,
                status: ChartStateBannerModel(
                    identifier: "offline.cached",
                    symbol: "wifi.slash",
                    title: "Offline · saved chart",
                    detail: "Showing the last saved chart from \(savedAt.chartDateLabel).",
                    accent: .sage
                )
            )

        case .offlineNoCache(let context):
            ChartOfflineNoCacheState(context: context)

        case .unsupportedMethodology(let context):
            ChartUnavailableState(
                identifier: "unsupported",
                symbol: "scope",
                title: context.title,
                detail: context.detail
            )

        case .insufficientBirthPrecision(let context, _):
            switch context {
            case .unknownTime(let unknownTime):
                ChartUnknownTimeState(
                    context: unknownTime,
                    readiness: unknownTime.readiness
                )
            case .missingPlace(let detail):
                ChartUnavailableState(
                    identifier: "insufficient-precision",
                    symbol: "mappin.and.ellipse",
                    title: "A little more precision is needed",
                    detail: detail
                )
            }

        case .failed(let failure):
            ChartUnavailableState(
                identifier: "failed",
                symbol: "exclamationmark.triangle",
                title: failure.title,
                detail: failure.detail
            )
        }
    }
}

private struct ChartFreeEntry: View {
    let readiness: ChartReadiness

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text(ChartProductCopy.freeTitle)
                    .font(HumayTypography.heroTitle)
                    .foregroundStyle(Color.humayTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(ChartProductCopy.freeDescription)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("chart.state.free")

            HumaySurface(level: .raised, padding: HumaySpacing.large) {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    HumayIllustration(name: "IllustrationWesternChart")
                        .frame(maxWidth: .infinity)
                        .frame(height: 176)

                    Text("Illustrative preview · not your chart")
                        .font(HumayTypography.utility)
                        .foregroundStyle(Color.humayTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityIdentifier("chart.free.preview.disclosure")
                }
            }

            ChartReadinessView(readiness: readiness)

            HumayCosmicSurface {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    Text(ChartProductCopy.precisionTitle)
                        .font(HumayTypography.sectionTitle)
                        .foregroundStyle(Color.humayGround)

                    Text(ChartProductCopy.precisionDescription)
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayGround.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityIdentifier("chart.precision-path")
            }

            ChartStateBanner(
                model: ChartStateBannerModel(
                    identifier: "free",
                    symbol: "sparkles",
                    title: ChartProductCopy.freeBannerTitle,
                    detail: ChartProductCopy.freeBannerDetail,
                    accent: .lavender
                )
            )
        }
    }
}

private struct ChartReadyEntry: View {
    let payload: ChartPayload
    let source: D4ContentSource
    let status: ChartStateBannerModel?

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            ChartDevelopmentNotice(source: source)

            if let status {
                ChartStateBanner(model: status)
                    .accessibilityIdentifier("chart.state.\(status.identifier)")
            }

            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Text("Your personal sky map")
                    .font(HumayTypography.heroTitle)
                    .foregroundStyle(Color.humayTextPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(ChartProductCopy.loadedDescription)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
            }
            .accessibilityIdentifier("chart.state.\(status?.identifier ?? "loaded")")

            if let western = payload.western {
                HumaySurface(level: .raised) {
                    VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                        Label("Western · Tropical", systemImage: "circle.hexagongrid")
                            .font(HumayTypography.sectionTitle)

                        Text("Open the chart overview to see the wheel, Big Three, and placement facts in order.")
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        NavigationLink {
                            WesternChartView(model: western, source: source)
                        } label: {
                            Text("Open Western chart")
                        }
                        .buttonStyle(.humayPrimary)
                        .accessibilityIdentifier("chart.western.open")
                    }
                }
            } else {
                ChartUnavailableState(
                    identifier: "loaded",
                    symbol: "questionmark.circle",
                    title: "Chart method unavailable",
                    detail: "This chart method is not available right now."
                )
            }
        }
    }
}

private struct ChartAccessState: View {
    let stateIdentifier: String
    let offer: ChartAccessOffer
    let readiness: ChartReadiness
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            ChartStateBanner(
                model: ChartStateBannerModel(
                    identifier: stateIdentifier,
                    symbol: stateIdentifier == "precision-locked" ? "lock.fill" : "checkmark.seal",
                    title: offer.title,
                    detail: offer.detail,
                    accent: stateIdentifier == "precision-locked" ? .gold : .blue
                )
            )
            .accessibilityIdentifier("chart.state.\(stateIdentifier)")

            Text(detail)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            ChartReadinessView(readiness: readiness)

            HumaySurface {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    Text("No guessed facts")
                        .font(HumayTypography.sectionTitle)
                    Text("Humay shows only chart facts supported by the information you provide.")
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct ChartLoadingState: View {
    let context: ChartLoadingContext

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            ChartStateBanner(
                model: ChartStateBannerModel(
                    identifier: "loading",
                    symbol: "hourglass",
                    title: context.title,
                    detail: context.detail,
                    accent: .lavender
                )
            )
            .accessibilityIdentifier("chart.state.loading")

            HumaySurface {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    RoundedRectangle(cornerRadius: HumayRadius.compact)
                        .fill(Color.humayHairline.opacity(0.42))
                        .frame(height: 26)
                    RoundedRectangle(cornerRadius: HumayRadius.compact)
                        .fill(Color.humayHairline.opacity(0.30))
                        .frame(height: 128)
                    RoundedRectangle(cornerRadius: HumayRadius.compact)
                        .fill(Color.humayHairline.opacity(0.30))
                        .frame(height: 18)
                        .frame(maxWidth: 220)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Chart loading")
            }
        }
    }
}

private struct ChartOfflineNoCacheState: View {
    let context: ChartOfflineContext

    var body: some View {
        ChartUnavailableState(
            identifier: "offline.no-cache",
            symbol: "wifi.slash",
            title: context.title,
            detail: context.detail
        )
    }
}

private struct ChartUnavailableState: View {
    let identifier: String
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        D2UnavailableState(symbol: symbol, title: title, detail: detail)
            .accessibilityIdentifier("chart.state.\(identifier)")
    }
}

private struct ChartUnknownTimeState: View {
    let context: ChartUnknownTimeContext
    let readiness: ChartReadiness

    var body: some View {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    Text("Chart, with room for uncertainty")
                        .font(HumayTypography.heroTitle)
                        .foregroundStyle(Color.humayTextPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("chart.state.insufficient-precision")
                }
                HumaySurface(level: .raised, padding: HumaySpacing.large) {
                    VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                        HumayIllustration(name: "IllustrationUnknownBirthTime")
                            .frame(maxWidth: .infinity)
                            .frame(height: 142)

                        HStack(spacing: HumaySpacing.medium) {
                            Image(systemName: "questionmark.circle")
                                .font(HumayTypography.supportingEmphasized)
                                .foregroundStyle(Color.humayCoral)
                                .accessibilityHidden(true)
                            Text("Birth time unknown")
                                .font(HumayTypography.sectionTitle)
                                .foregroundStyle(Color.humayTextPrimary)
                                .accessibilityIdentifier("chart.unknown-time.warning")
                        }

                        Text("No noon, midnight, sunrise, or other default time was used.")
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityIdentifier("chart.unknown-time.warning")

                Text("A date can support some facts. Time-dependent facts stay open rather than becoming a guess.")
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HumaySurface {
                    VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                        Text("Known from the date")
                            .font(HumayTypography.sectionTitle)
                            .accessibilityIdentifier("chart.unknown-time.known-facts")
                        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                            Text("\(context.knownFact.point.label) in \(context.knownFact.sign.displayName)")
                                .font(HumayTypography.body)
                                .foregroundStyle(Color.humayTextPrimary)
                        }
                        .accessibilityElement(children: .combine)
                        Text("Date-valid fact · \(ChartReliabilityFormatter.string(for: context.knownFact.reliability))")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
                .accessibilityIdentifier("chart.unknown-time.known-facts")

                HumaySurface {
                    VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                        Text("Not available without more precision")
                            .font(HumayTypography.sectionTitle)
                            .accessibilityIdentifier("chart.unknown-time.withheld")
                        ForEach(context.withheldFacts, id: \.self) { fact in
                            Label(fact.label, systemImage: "minus.circle")
                                .font(HumayTypography.body)
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                        Text(context.explanation)
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityIdentifier("chart.unknown-time.withheld")

                ChartReadinessView(readiness: readiness)
                    .accessibilityIdentifier("chart.unknown-time.readiness")
            }
            .accessibilityIdentifier("chart.unknown-time.screen")
    }
}

struct ChartReadinessView: View {
    let readiness: ChartReadiness

    var body: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                Text("Chart readiness")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)

                ChartReadinessRow(
                    title: "Birth date",
                    value: readiness.birthDate.detail,
                    status: readiness.birthDate.label,
                    identifier: "chart.readiness.date"
                )
                ChartReadinessRow(
                    title: "Birth time",
                    value: readiness.birthTime.detail,
                    status: readiness.birthTime.label,
                    identifier: "chart.readiness.time"
                )
                ChartReadinessRow(
                    title: "Birth place",
                    value: readiness.birthPlace.detail,
                    status: readiness.birthPlace.label,
                    identifier: "chart.readiness.place"
                )
            }
        }
        .accessibilityIdentifier("chart.readiness")
    }
}

private struct ChartReadinessRow: View {
    let title: String
    let value: String
    let status: String
    let identifier: String

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(title)
                    .font(HumayTypography.bodyEmphasized)
                    .accessibilityIdentifier(identifier)
                Text(value)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: HumaySpacing.small)

            Text(status)
                .font(HumayTypography.utility)
                .foregroundStyle(Color.humayTextSecondary)
                .multilineTextAlignment(.trailing)
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget, alignment: .top)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

struct ChartDevelopmentNotice: View {
    let source: D4ContentSource

    var body: some View {
        if source.isDevelopmentSample {
            Label("Development sample · not calculated", systemImage: "hammer.fill")
                .font(HumayTypography.utility)
                .foregroundStyle(Color.humayTextSecondary)
                .padding(.horizontal, HumaySpacing.medium)
                .padding(.vertical, HumaySpacing.small)
                .background(Color.humayRaisedSurface, in: Capsule())
                .accessibilityIdentifier("chart.sample.notice")
        }
    }
}

struct ChartStateBannerModel: Sendable, Hashable {
    let identifier: String
    let symbol: String
    let title: String
    let detail: String
    let accent: HumayAccent
}

struct ChartStateBanner: View {
    let model: ChartStateBannerModel

    var body: some View {
        D2StatusBanner(
            symbol: model.symbol,
            title: model.title,
            detail: model.detail,
            accent: model.accent
        )
        .accessibilityIdentifier("chart.state.banner.\(model.identifier)")
    }
}

private extension Date {
    var chartDateLabel: String {
        formatted(.dateTime.day().month(.abbreviated).year())
    }
}
