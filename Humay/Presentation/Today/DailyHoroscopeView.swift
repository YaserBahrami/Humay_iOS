import SwiftUI

struct DailyHoroscopeView: View {
    let states: [HoroscopePeriod: DailyHoroscopeFeatureState]
    let precisePreview: DailyHoroscopeContent?
    let source: D2ContentSource

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedPeriod: HoroscopePeriod = .today
    @State private var previewReading: DailyHoroscopeContent?
    @State private var showPreciseInfo = false

    var body: some View {
        HumayPage(maximum: .immersive, spacing: HumaySpacing.extraLarge) {
            if let reading = currentReading {
                readingContext(reading)
            }

            periodPicker
            stateContent
        }
        .navigationTitle("Daily Horoscope")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let reading = currentReading {
                    ShareLink(item: shareText(reading)) {
                        Image(systemName: "square.and.arrow.up")
                            .frame(
                                width: HumayMetrics.minimumHitTarget,
                                height: HumayMetrics.minimumHitTarget
                            )
                    }
                    .accessibilityLabel("Share Daily Horoscope")
                    .accessibilityHint("Opens the system share sheet")
                }
            }
        }
        .alert("Precise readings are not connected", isPresented: $showPreciseInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Provider-backed generation and its access flow are not available yet. Your Free Sun-sign reading remains available.")
        }
    }

    private var activeState: DailyHoroscopeFeatureState {
        if let previewReading {
            return .preciseLoaded(previewReading)
        }
        return states[selectedPeriod] ?? .failed(
            period: selectedPeriod,
            message: "This reading is not available yet."
        )
    }

    private var currentReading: DailyHoroscopeContent? {
        switch activeState {
        case .free(let reading),
             .preciseLocked(let reading),
             .preciseLoaded(let reading),
             .cached(let reading, _):
            reading
        case .offline(let reading):
            reading
        case .loading, .failed:
            nil
        }
    }

    private var periodPicker: some View {
        Picker("Reading period", selection: $selectedPeriod) {
            ForEach(HoroscopePeriod.allCases) { period in
                Text(period.displayName)
                    .tag(period)
                    .accessibilityIdentifier("daily.period.\(period.rawValue)")
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 460, alignment: .leading)
        .onChange(of: selectedPeriod) {
            previewReading = nil
        }
        .accessibilityIdentifier("daily.period.picker")
        .accessibilityHint("Changes the displayed horoscope period")
    }

    @ViewBuilder
    private var stateContent: some View {
        switch activeState {
        case .loading:
            DailyHoroscopeLoadingView()
                .accessibilityIdentifier("daily.state.loading")

        case .free(let reading):
            readingExperience(reading)

        case .preciseLocked(let freeReading):
            VStack(alignment: .leading, spacing: HumaySpacing.section) {
                readingExperience(freeReading)
                preciseAccessBlock
            }

        case .preciseLoaded(let reading):
            readingExperience(reading)

        case .cached(let reading, let savedAt):
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                D2StatusBanner(
                    symbol: "clock.arrow.circlepath",
                    title: "Saved precise reading",
                    detail: "Reopened from \(savedAt.formatted(date: .abbreviated, time: .shortened)).",
                    accent: .sage
                )
                readingExperience(reading)
            }

        case .offline(let cached):
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                D2StatusBanner(
                    symbol: "wifi.slash",
                    title: "Offline",
                    detail: cached == nil
                        ? "No saved reading is available on this device."
                        : "Showing the saved reading available on this device.",
                    accent: .gold
                )

                if let cached {
                    readingExperience(cached)
                } else {
                    HumayStateView(
                        title: "Reading unavailable offline",
                        message: "Reconnect to load an available reading.",
                        symbol: .offline
                    )
                    .accessibilityIdentifier("daily.state.offline.no-cache")
                }
            }

        case .failed(_, let message):
            HumayStateView(
                title: "Daily Horoscope needs a moment",
                message: message,
                symbol: .unavailable
            )
            .accessibilityIdentifier("daily.state.failed")
        }
    }

    private func readingContext(_ reading: DailyHoroscopeContent) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
                zodiacContext(reading)
                Spacer(minLength: HumaySpacing.large)
                basisBadge(reading.basis)
            }

            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                zodiacContext(reading)
                basisBadge(reading.basis)
            }
        }
        .accessibilityIdentifier("daily.zodiac.identity")
    }

    private func zodiacContext(_ reading: DailyHoroscopeContent) -> some View {
        HumayZodiacIdentity(
            sign: reading.sign,
            subtitle: [
                reading.period.displayName,
                reading.date.formatted(date: .long, time: .omitted),
                reading.sign.dateRange
            ]
            .joined(separator: " · ")
        )
    }

    private func basisBadge(_ basis: DailyReadingBasis) -> some View {
        Label(basisStatus(basis), systemImage: basis.isPrecise ? "scope" : "sun.max")
            .font(HumayTypography.utility)
            .foregroundStyle(basis.isPrecise ? Color.humayAccentCelestial : Color.humayAccentPrestige)
            .padding(.horizontal, HumaySpacing.medium)
            .padding(.vertical, HumaySpacing.small)
            .background(Color.humaySurfaceElevated, in: Capsule())
            .overlay {
                Capsule().stroke(Color.humaySeparator)
            }
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func readingExperience(_ reading: DailyHoroscopeContent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.section) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: HumaySpacing.section) {
                    mainInterpretation(reading)
                    supportingReading(reading)
                }
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: HumaySpacing.hero) {
                        mainInterpretation(reading)
                            .frame(minWidth: 420, maxWidth: 600, alignment: .topLeading)
                        supportingReading(reading)
                            .frame(minWidth: 300, maxWidth: 420, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: HumaySpacing.section) {
                        mainInterpretation(reading)
                        supportingReading(reading)
                    }
                }
            }

            basisDisclosure(reading)
        }
    }

    private func mainInterpretation(_ reading: DailyHoroscopeContent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumayEyebrow(text: "Your reading")

            Text(reading.headline)
                .font(HumayTypography.displayTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(reading.body)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 580, alignment: .leading)
        }
        .padding(.vertical, HumaySpacing.large)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("daily.reading.card")
    }

    private func supportingReading(_ reading: DailyHoroscopeContent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.section) {
            lifeAreaInsights(reading.highlights)
            dailyTip(reading.tip)
        }
    }

    private func lifeAreaInsights(_ highlights: [DailyReadingHighlight]) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumaySectionHeader(
                title: "Life areas",
                subtitle: "Quiet signals for the parts of today you may want to notice."
            )

            VStack(spacing: 0) {
                ForEach(highlights) { highlight in
                    HStack(alignment: .top, spacing: HumaySpacing.large) {
                        HumaySystemSymbolImage(
                            symbol: highlight.category.premiumSymbol,
                            size: .compact
                        )
                        .foregroundStyle(highlight.category.premiumAccent)

                        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                            Text(highlight.category.displayName)
                                .font(HumayTypography.bodyEmphasized)
                            Text(highlight.text)
                                .font(HumayTypography.supporting)
                                .foregroundStyle(Color.humayTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, HumaySpacing.large)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.humaySeparator)
                            .frame(height: 1)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .accessibilityIdentifier("daily.insights")
    }

    private func dailyTip(_ tip: String) -> some View {
        HumayHairlineSurface(style: .celestial) {
            HStack(alignment: .top, spacing: HumaySpacing.large) {
                HumaySystemSymbolImage(symbol: .insight, size: .standard)
                    .foregroundStyle(Color.humayAccentCelestial)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    HumayEyebrow(text: "Daily tip", color: .humayAccentCelestial)
                    Text(tip)
                        .font(HumayTypography.narrativeSectionTitle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("daily.tip")
    }

    private func basisDisclosure(_ reading: DailyHoroscopeContent) -> some View {
        HumayDisclosureGroup(
            eyebrow: "Reading basis",
            title: "How this reading was prepared",
            summary: basisSummary(reading.basis)
        ) {
            HumayHairlineSurface(style: .quiet) {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    Text(basisDetail(reading.basis))
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HumayFactRow(label: "Period", value: reading.period.displayName)
                    HumayFactRow(label: "Sun sign", value: reading.sign.displayName)
                    HumayFactRow(label: "Access", value: basisStatus(reading.basis))
                    HumayFactRow(
                        label: "Source",
                        value: source.isDevelopmentSample
                            ? "Development sample · not calculated"
                            : "Humay content"
                    )
                }
            }
        }
        .accessibilityIdentifier("daily.basis")
    }

    private var preciseAccessBlock: some View {
        HumayHairlineSurface(style: .raised) {
            HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                Image(systemName: "lock")
                    .font(.title2)
                    .foregroundStyle(Color.humayAccentCelestial)
                    .frame(
                        width: HumayMetrics.minimumHitTarget,
                        height: HumayMetrics.minimumHitTarget
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    HumayEyebrow(text: "Precise reading", color: .humayAccentCelestial)
                    Text("Personalized generation is not connected yet")
                        .font(HumayTypography.narrativeSectionTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("daily.precise.availability")
                    Text("Provider-backed generation, Rewarded Access, and Premium entitlement are future work. This screen does not start a purchase or generation.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button("About precise availability") {
                        showPreciseInfo = true
                    }
                    .buttonStyle(.humaySecondary)
                    .accessibilityIdentifier("daily.precise.unlock")

#if DEBUG
                    if source.isDevelopmentSample, let precisePreview {
                        Button("Preview precise layout") {
                            previewReading = precisePreview
                            selectedPeriod = precisePreview.period
                        }
                        .font(HumayTypography.control)
                        .frame(minHeight: HumayMetrics.minimumHitTarget)
                        .accessibilityLabel("Preview precise development layout")
                        .accessibilityIdentifier("daily.precise.preview")
                    }
#endif
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func basisStatus(_ basis: DailyReadingBasis) -> String {
        switch basis {
        case .freeWesternSunSign:
            "Free · Sun-sign reading"
        case .precisePersonalized:
            "Precise"
        }
    }

    private func basisSummary(_ basis: DailyReadingBasis) -> String {
        switch basis {
        case .freeWesternSunSign(let sign):
            "A coarse \(sign.displayName) Sun-sign reading, not a natal transit interpretation."
        case .precisePersonalized:
            source.isDevelopmentSample
                ? "Development-only personalized layout; no provider calculation."
                : "Personalized content with calculation facts kept separate from interpretation."
        }
    }

    private func basisDetail(_ basis: DailyReadingBasis) -> String {
        switch basis {
        case .freeWesternSunSign(let sign):
            "Humay selected this entry from the \(sign.displayName) Sun-sign catalog. Birth time, birth place, transits, houses, and aspects are not inferred."
        case .precisePersonalized:
            source.isDevelopmentSample
                ? "This precise reading is a Debug-only presentation sample. It contains no provider-backed transits, aspects, or generated calculation facts."
                : "This presentation contract identifies a personalized reading without exposing or inventing technical facts it does not contain."
        }
    }

    private func shareText(_ reading: DailyHoroscopeContent) -> String {
        "\(reading.sign.displayName) · \(reading.period.displayName)\n\(reading.headline)\n\(reading.body)"
    }
}

private struct DailyHoroscopeLoadingView: View {
    var body: some View {
        HumayHairlineSurface(style: .raised) {
            HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.humayAccentPrestige)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("Opening your reading…")
                        .font(HumayTypography.narrativeSectionTitle)
                    Text("Loading the selected period.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading Daily Horoscope")
    }
}
