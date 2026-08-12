import SwiftUI

struct DailyHoroscopeView: View {
    let states: [HoroscopePeriod: DailyHoroscopeFeatureState]
    let precisePreview: DailyHoroscopeContent?
    let source: D2ContentSource

    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedPeriod: HoroscopePeriod = .today
    @State private var previewReading: DailyHoroscopeContent?
    @State private var showUnlockInfo = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    if let reading = currentReading {
                        zodiacIdentity(reading)
                    }

                    periodPicker
                    stateContent
                }
                .frame(maxWidth: HumayContentWidth.readable.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.top, HumaySpacing.small)
                .padding(.bottom, HumaySpacing.extraExtraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("Daily Horoscope")
                        .font(.headline)
                    if let reading = currentReading {
                        Text(reading.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if let reading = currentReading {
                    ShareLink(item: shareText(reading)) {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Share Daily Horoscope")
                }
            }
        }
        .alert("Precise readings are not connected", isPresented: $showUnlockInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Provider-backed precise readings will be connected with their access flow.")
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
             .cached(let reading, _): reading
        case .offline(let reading): reading
        case .loading, .failed: nil
        }
    }

    private var periodPicker: some View {
        Picker("Reading period", selection: $selectedPeriod) {
            ForEach(HoroscopePeriod.allCases) { period in
                Text(period.displayName).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedPeriod) {
            previewReading = nil
        }
        .accessibilityIdentifier("daily.period.picker")
    }

    @ViewBuilder
    private var stateContent: some View {
        switch activeState {
        case .loading:
            HumaySurface(level: .raised) {
                VStack(spacing: HumaySpacing.large) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayLavender)
                    Text("Opening your reading…")
                        .font(HumayTypography.cardTitle)
                    Text("Reading today’s sky.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HumaySpacing.extraExtraLarge)
            }

        case .free(let reading):
            readingCard(reading)
            dailyTip(reading)

        case .preciseLocked(let freeReading):
            readingCard(freeReading)
            dailyTip(freeReading)
            preciseAccessCard

        case .preciseLoaded(let reading):
            readingCard(reading)
            dailyTip(reading)

        case .cached(let reading, let savedAt):
            D2StatusBanner(
                symbol: "clock.arrow.circlepath",
                title: "Saved result reopened",
                detail: "Cached \(savedAt.formatted(date: .abbreviated, time: .shortened)).",
                accent: .sage
            )
            readingCard(reading)
            dailyTip(reading)

        case .offline(let cached):
            D2StatusBanner(
                symbol: "wifi.slash",
                title: "Offline",
                detail: cached == nil
                    ? "No saved reading can be reopened."
                    : "Showing your saved reading.",
                accent: .gold
            )
            if let cached {
                readingCard(cached)
                dailyTip(cached)
            } else {
                D2UnavailableState(
                    symbol: "wifi.slash",
                    title: "Reading unavailable offline",
                    detail: "Reconnect to load your reading."
                )
            }

        case .failed(_, let message):
            D2UnavailableState(
                symbol: "exclamationmark.bubble",
                title: "The stars went quiet",
                detail: message
            )
        }
    }

    private func zodiacIdentity(_ reading: DailyHoroscopeContent) -> some View {
        HStack(spacing: HumaySpacing.large) {
            Text(reading.sign.glyph)
                .font(.system(size: 34, weight: .medium, design: .rounded))
                .foregroundStyle(zodiacGlyphColor)
                .frame(width: 64, height: 64)
                .background(zodiacGlyphBackground, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(reading.sign.displayName)
                    .font(.title3.weight(.semibold))
                Text(reading.sign.dateRange)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZodiacSignArt(sign: reading.sign, size: 82)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reading.sign.displayName), \(reading.sign.dateRange)")
        .accessibilityIdentifier("daily.zodiac.identity")
    }

    private var zodiacGlyphBackground: Color {
        colorScheme == .light ? .humayTextPrimary : .humayLavender.opacity(0.34)
    }

    private var zodiacGlyphColor: Color {
        colorScheme == .light ? .humayGround : .humaySolarGold
    }

    private func readingCard(_ reading: DailyHoroscopeContent) -> some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                HStack(alignment: .top, spacing: HumaySpacing.medium) {
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        Text(reading.headline)
                            .font(HumayTypography.editorialTitle)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.humayCoral, Color.humayLavender],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 76, height: 2)
                            .accessibilityHidden(true)
                    }

                    Spacer(minLength: HumaySpacing.small)

                    Image(systemName: "moon.fill")
                        .font(.title)
                        .foregroundStyle(Color.humaySolarGold)
                        .accessibilityHidden(true)
                }

                Text(reading.body)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextPrimary.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)

                Divider().overlay(Color.humayHairline)

                ForEach(reading.highlights) { highlight in
                    HStack(alignment: .top, spacing: HumaySpacing.medium) {
                        HumayCategoryIcon(
                            symbol: highlight.category.symbol,
                            accent: highlight.category.accent,
                            size: 44
                        )

                        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                            Text(highlight.category.displayName)
                                .font(HumayTypography.bodyEmphasized)
                            Text(highlight.text)
                                .font(HumayTypography.supporting)
                                .foregroundStyle(Color.humayTextPrimary.opacity(0.86))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .accessibilityIdentifier("daily.reading.card")
    }

    private func dailyTip(_ reading: DailyHoroscopeContent) -> some View {
        HumayCosmicSurface {
            HStack(spacing: HumaySpacing.large) {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("Daily Tip")
                        .font(HumayTypography.utility)
                        .textCase(.uppercase)
                        .tracking(1.1)
                        .foregroundStyle(Color.humayLavender)
                    Text(reading.tip)
                        .font(HumayTypography.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CrystalBallArt()
            }
        }
    }

    private var preciseAccessCard: some View {
        HumaySurface(level: .raised) {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                Label("Precise Daily Horoscope", systemImage: "lock.fill")
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayLavender)

                Text("Unlock a personalized reading when precise generation is available.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Unlock Precise") {
                    showUnlockInfo = true
                }
                .buttonStyle(.humaySecondary)
                .accessibilityIdentifier("daily.precise.unlock")

                if source.isDevelopmentSample, let precisePreview {
                    Button("Preview precise layout") {
                        previewReading = precisePreview
                        selectedPeriod = precisePreview.period
                    }
                    .font(HumayTypography.control)
                    .frame(minHeight: HumayMetrics.minimumHitTarget)
                    .accessibilityIdentifier("daily.precise.preview")
                }
            }
        }
    }

    private func shareText(_ reading: DailyHoroscopeContent) -> String {
        "\(reading.sign.displayName) · \(reading.period.displayName)\n\(reading.headline)\n\(reading.body)"
    }
}
