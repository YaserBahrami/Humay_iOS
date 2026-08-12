import SwiftUI

struct DailyHoroscopeView: View {
    let states: [HoroscopePeriod: DailyHoroscopeFeatureState]
    let precisePreview: DailyHoroscopeContent?
    let source: D2ContentSource

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
        .navigationTitle("Daily Horoscope")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            Text("StoreKit, rewarded access and provider generation are intentionally outside this UI-first phase.")
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
                    Text("Development loading state. No network call is running.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HumaySpacing.extraExtraLarge)
            }

        case .free(let reading):
            basisBanner(for: reading)
            readingCard(reading)
            dailyTip(reading)
            preciseAccessCard
            D2SampleNotice(source: source)

        case .preciseLocked(let freeReading):
            D2StatusBanner(
                symbol: "lock.fill",
                title: "Precise reading locked",
                detail: "Provider-backed personalization will require Rewarded Access or Premium later.",
                accent: .lavender
            )
            basisBanner(for: freeReading)
            readingCard(freeReading)
            dailyTip(freeReading)
            preciseAccessCard
            D2SampleNotice(source: source)

        case .preciseLoaded(let reading):
            basisBanner(for: reading)
            readingCard(reading)
            dailyTip(reading)
            D2SampleNotice(source: source)

        case .cached(let reading, let savedAt):
            D2StatusBanner(
                symbol: "clock.arrow.circlepath",
                title: "Saved result reopened",
                detail: "Cached \(savedAt.formatted(date: .abbreviated, time: .shortened)); no new generation was started.",
                accent: .sage
            )
            basisBanner(for: reading)
            readingCard(reading)
            dailyTip(reading)
            D2SampleNotice(source: source)

        case .offline(let cached):
            D2StatusBanner(
                symbol: "wifi.slash",
                title: "Offline",
                detail: cached == nil
                    ? "No saved reading can be reopened."
                    : "Showing a saved development result. No generation is being attempted.",
                accent: .gold
            )
            if let cached {
                basisBanner(for: cached)
                readingCard(cached)
                dailyTip(cached)
                D2SampleNotice(source: source)
            } else {
                D2UnavailableState(
                    symbol: "wifi.slash",
                    title: "Reading unavailable offline",
                    detail: "Reconnect to load catalog content."
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
                .foregroundStyle(Color.humaySolarGold)
                .frame(width: 64, height: 64)
                .background(Color.humayLavender.opacity(0.24), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(reading.sign.displayName)
                    .font(.title3.weight(.semibold))
                Text(reading.sign.dateRange)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                Text(reading.date.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(Color.humayTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .stroke(Color.humaySolarGold.opacity(0.5), lineWidth: 2)
                    .frame(width: 64, height: 64)
                Image(systemName: "pawprint.fill")
                    .font(.title)
                    .foregroundStyle(Color.humaySolarGold)
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(Color.humayCoral)
                    .offset(x: 34, y: -25)
            }
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reading.sign.displayName), \(reading.sign.dateRange), \(reading.date.formatted(date: .long, time: .omitted))")
        .accessibilityIdentifier("daily.zodiac.identity")
    }

    private func basisBanner(for reading: DailyHoroscopeContent) -> some View {
        switch reading.basis {
        case .freeWesternSunSign(let sign):
            D2StatusBanner(
                symbol: "sun.max.fill",
                title: "Free · \(sign.displayName) Sun-sign reading",
                detail: "Coarse date-and-sign catalog. No natal chart calculation.",
                accent: .gold
            )
            .accessibilityIdentifier("daily.basis.free")

        case .precisePersonalized:
            D2StatusBanner(
                symbol: "scope",
                title: "Precise presentation sample",
                detail: "Development only · no provider calculation or generation.",
                accent: .lavender
            )
            .accessibilityIdentifier("daily.basis.precise")
        }
    }

    private func readingCard(_ reading: DailyHoroscopeContent) -> some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                HStack(alignment: .top) {
                    Text(reading.headline)
                        .font(HumayTypography.editorialTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Spacer(minLength: HumaySpacing.medium)

                    Image(systemName: "moon.fill")
                        .font(.title)
                        .foregroundStyle(Color.humaySolarGold)
                        .accessibilityHidden(true)
                }

                Text(reading.body)
                    .font(HumayTypography.body)
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
                                .foregroundStyle(Color.humayTextSecondary)
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
                    Text("Cosmic Tip")
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

                Text("A future provider-backed reading can use validated personal factors. It is separate from this Free Sun-sign catalog sample.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Unlock Precise") {
                    showUnlockInfo = true
                }
                .buttonStyle(.humaySecondary)
                .accessibilityIdentifier("daily.precise.unlock")

                if source.isDevelopmentSample, let precisePreview {
                    Button("Preview development result") {
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
