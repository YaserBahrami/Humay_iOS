import SwiftUI

/// Today — the personalized entertainment feed.
///
/// Content comes from `HumayContentEngine` (deterministic fixture generation today,
/// AI personalization later behind the same models). Composition rotates daily and
/// reacts to personality mode immediately.
struct CosmicFeedView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    @Environment(\.calendar) private var calendar
    @State private var shareActivity: ShareActivity?

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    header

                    ForEach(feedItems) { item in
                        FeedItemView(item: item) { activity in
                            shareActivity = activity
                        } openTab: { destination in
                            navigation.mainDestination = destination
                        }
                    }
                }
                .padding(.top, HumaySpacing.medium)
                .padding(.bottom, HumaySpacing.extraExtraLarge)
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
        .sheet(item: $shareActivity) { activity in
            ShareSheet(activity: activity)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HumayWordmarkHeader(
                title: nil,
                profileName: profileDisplayName,
                profileAction: { navigation.auxiliaryRoute = .profileSettings }
            )

            HStack(alignment: .center, spacing: HumaySpacing.small) {
                Text(dateLine)
                    .font(HumayTypography.utility)
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(Color.humayTextSecondary)

                Spacer()

                modeMenu
            }
        }
    }

    /// Compact tone control — changing mode re-speaks the whole feed instantly.
    private var modeMenu: some View {
        @Bindable var environment = environment

        return Menu {
            ForEach(PersonalityMode.allCases) { mode in
                Button {
                    Task { @MainActor in
                        try? await environment.setPersonalityMode(mode)
                    }
                } label: {
                    if mode == environment.settings.personalityMode {
                        Label(mode.displayName, systemImage: "checkmark")
                    } else {
                        Text(mode.displayName)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "quote.opening")
                    .font(.caption.weight(.semibold))
                Text(environment.settings.personalityMode.displayName)
                    .font(HumayTypography.supportingEmphasized)
            }
            .padding(.horizontal, HumaySpacing.medium)
            .padding(.vertical, 8)
            .background(Color.humayRaisedSurface, in: Capsule())
            .overlay(Capsule().stroke(Color.humayHairline))
        }
        .accessibilityLabel("Humay's tone, currently \(environment.settings.personalityMode.displayName)")
        .accessibilityHint("Changes how today's feed sounds")
    }

    private var dateLine: String {
        Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(calendar.locale ?? .current))
    }

    private var profileDisplayName: String {
        let persisted = environment.profile?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let persisted, !persisted.isEmpty {
            return persisted
        }
        return "friend"
    }

    private var feedItems: [FeedItem] {
        guard let profile = environment.profile else { return [] }

        let skyEvent = translatedSkyEvent()
        return HumayContentEngine.dailyFeed(
            profile: profile,
            date: .now,
            calendar: calendar,
            mode: environment.settings.personalityMode,
            skyEvent: skyEvent
        )
    }

    /// Translates the current sky snapshot's lead event into feed language.
    /// Fact line stays verbatim so Sky remains the source of truth.
    /// Production wiring arrives with the real sky provider; today the feed
    /// falls back to generic sky copy.
    private func translatedSkyEvent() -> CosmicEventSeed? {
#if DEBUG
        guard case .loaded(let snapshot) = DevelopmentD3Sample.makeInput().currentSky,
              let event = snapshot.events.first else {
            return nil
        }
        return SkyHeadlineTranslator.translate(event)
#else
        return nil
#endif
    }
}

// MARK: - Item dispatch

struct FeedItemView: View {
    let item: FeedItem
    let requestShare: (ShareActivity) -> Void
    let openTab: (MainDestination) -> Void

    var body: some View {
        switch item.kind {
        case .headline(let content):
            HeadlineCard(content: content)
                .accessibilityIdentifier("feed.headline")
        case .meterSet(let content):
            SurfaceCard {
                HumayMeterSet(content: content)
            }
            .accessibilityIdentifier("feed.meters")
        case .reveal(let content):
            RevealCard(content: content)
                .accessibilityIdentifier("feed.reveal")
        case .flagPair(let content):
            FlagPairCard(content: content, requestShare: requestShare)
                .accessibilityIdentifier("feed.flags")
        case .roast(let content):
            RoastCard(content: content, requestShare: requestShare)
                .accessibilityIdentifier("feed.roast")
        case .cosmicWeather(let content):
            CosmicWeatherCard(content: content, openSky: { openTab(.sky) })
                .accessibilityIdentifier("feed.weather")
        case .forecastTeaser(let content):
            ForecastTeaserCard(content: content, openTimeline: { openTab(.you) })
                .accessibilityIdentifier("feed.teaser")
        case .dailyReading(let content):
            DailyReadingCard(content: content, requestShare: requestShare)
                .accessibilityIdentifier("feed.reading")
        }
    }
}

// MARK: - Cards

/// Pure typography on the ground color. The opening statement needs no box.
struct HeadlineCard: View {
    let content: HeadlineContent

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text(content.kicker)
                .font(HumayTypography.utility)
                .textCase(.uppercase)
                .tracking(1.4)
                .foregroundStyle(Color.humayCoral)

            Text(content.headline)
                .font(HumayTypography.heroTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            if let supporting = content.supporting {
                Text(supporting)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Standard boxed content region.
struct SurfaceCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        HumaySurface(padding: HumaySpacing.extraLarge) {
            content
        }
    }
}

/// Hold-to-reveal secret prediction with haptic anticipation.
struct RevealCard: View {
    let content: RevealContent

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @GestureState private var isHolding = false
    @State private var revealed = false
    @State private var holdTask: Task<Void, Never>?

    private var revealProgress: Bool {
        revealed || (isHolding && !reduceMotion)
    }

    var body: some View {
        Button {
            guard !revealed else { return }
            completeReveal()
        } label: {
            label
        }
        .buttonStyle(.plain)
        .simultaneousGesture(holdGesture)
        .accessibilityLabel(revealed ? content.secret : "\(content.prompt). \(content.hint)")
        .accessibilityHint(revealed ? "" : "Double tap to reveal")
        .accessibilityAddTraits(revealed ? [] : .isButton)
    }

    private var label: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HStack {
                HumayKickerLabel(text: content.prompt)
                Spacer()
                if !revealed {
                    Image(systemName: "hand.tap")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.humayLavender)
                        .symbolEffect(.pulse, options: .repeating, isActive: !revealed)
                        .accessibilityHidden(true)
                }
            }

            ZStack(alignment: .leading) {
                // Hidden placeholder keeps layout stable during the hold.
                Text(content.secret)
                    .font(HumayTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(0)

                Text(content.secret)
                    .font(HumayTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .blur(radius: revealProgress ? 0 : 7)
                    .opacity(revealed ? 1 : (isHolding ? 0.85 : 0.25))
                    .scaleEffect(isHolding && !revealed && !reduceMotion ? 1.015 : 1)
            }

            if revealed {
                if let followUp = content.followUp {
                    Text(followUp)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                }
            } else {
                Text(content.hint)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HumaySpacing.extraLarge)
        .background(
            RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                .fill(Color.humaySurface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                .strokeBorder(revealed ? Color.humayLavender.opacity(0.55) : Color.humayHairline)
        }
        .animation(HumayMotion.animated(HumayMotion.bouncy, enabled: !reduceMotion), value: revealed)
        .animation(HumayMotion.animated(HumayMotion.snappy, enabled: !reduceMotion), value: isHolding)
    }

    private var holdGesture: some Gesture {
        LongPressGesture(minimumDuration: HumayMotion.revealHoldDuration)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .updating($isHolding) { _, state, _ in
                state = true
            }
            .onEnded { _ in
                completeReveal()
            }
    }

    private func completeReveal() {
        guard !revealed else { return }
        revealed = true
        HumayHaptics.success()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Red flag / green flag side by side. Meaning never rides on color alone —
/// each half carries its own symbol and label.
struct FlagPairCard: View {
    let content: FlagPairContent
    let requestShare: (ShareActivity) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HStack(alignment: .top, spacing: HumaySpacing.medium) {
                flagColumn(
                    title: "Red flag",
                    symbol: "exclamationmark.triangle.fill",
                    tint: Color.humayCoral,
                    text: content.redFlag
                )

                flagColumn(
                    title: "Green flag",
                    symbol: "leaf.fill",
                    tint: Color.humaySage,
                    text: content.greenFlag
                )
            }

            shareButton(label: "Share your flags")
        }
        .padding(HumaySpacing.extraLarge)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                .strokeBorder(Color.humayHairline)
        }
    }

    private func flagColumn(title: String, symbol: String, tint: Color, text: String) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            Label {
                Text(title)
                    .font(HumayTypography.utility)
                    .textCase(.uppercase)
                    .tracking(1.1)
            } icon: {
                Image(systemName: symbol)
            }
            .foregroundStyle(tint)

            Text(text)
                .font(HumayTypography.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private func shareButton(label: String) -> some View {
        Button {
            requestShare(ShareActivity(kind: .flags(content)))
        } label: {
            Label(label, systemImage: "square.and.arrow.up")
                .font(HumayTypography.control)
                .frame(maxWidth: .infinity)
                .frame(minHeight: HumayMetrics.minimumHitTarget - 12)
        }
        .buttonStyle(.humaySecondary)
    }
}

/// The roast. Coral-tinted, artful, expression-only.
struct RoastCard: View {
    let content: RoastContent
    let requestShare: (ShareActivity) -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HStack(alignment: .center, spacing: HumaySpacing.medium) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    HumayKickerLabel(text: content.title, tint: lightMode ? .humayGround : .humaySolarGold)
                    Text(content.body)
                        .font(HumayTypography.cardTitle)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                RoastFireArt()
                    .frame(maxWidth: 86)
            }

            shareButton
        }
        .foregroundStyle(lightMode ? Color.humayTextPrimary : Color.humayTextPrimary)
        .padding(HumaySpacing.extraLarge)
        .background(roastBackground, in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                .strokeBorder(lightMode ? Color.humayHairline : Color.humayCoral.opacity(0.4))
        }
    }

    private var lightMode: Bool { colorScheme == .light }

    private var roastBackground: some ShapeStyle {
        LinearGradient(
            colors: lightMode
                ? [Color.humayCoral.opacity(0.14), Color.humaySolarGold.opacity(0.08)]
                : [Color.humayCoral.opacity(0.30), Color.humaySolarGold.opacity(0.12)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var shareButton: some View {
        Button {
            requestShare(ShareActivity(kind: .roast(content)))
        } label: {
            Label("Send this to someone", systemImage: "paperplane")
                .font(HumayTypography.control)
                .frame(maxWidth: .infinity)
                .frame(minHeight: HumayMetrics.minimumHitTarget - 12)
        }
        .buttonStyle(.humaySecondary)
    }
}

/// Real sky events, humanized. Fact line preserved verbatim; interpretation is
/// clearly the fun part. Deep-links into Sky.
struct CosmicWeatherCard: View {
    let content: CosmicWeatherContent
    let openSky: () -> Void

    var body: some View {
        Button(action: openSky) {
            HumayCosmicSurface {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    HumayKickerLabel(text: "Cosmic weather", tint: lightMode ? .humayGround.opacity(0.6) : .humayLavender)

                    Text(content.headline)
                        .font(HumayTypography.cardTitle)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(content.factLine)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(lightMode ? Color.humayGround.opacity(0.72) : Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Label("See actual event", systemImage: "arrow.right")
                        .font(HumayTypography.control)
                }
            }
        }
        .buttonStyle(.humayPressable)
        .accessibilityLabel("Cosmic weather. \(content.headline)")
        .accessibilityHint("Opens Sky")
    }

    @Environment(\.colorScheme) private var colorScheme
    private var lightMode: Bool { colorScheme == .light }
}

/// Teaser rows pointing into the year timeline.
struct ForecastTeaserCard: View {
    let content: ForecastTeaserContent
    let openTimeline: () -> Void

    var body: some View {
        Button(action: openTimeline) {
            HumaySurface(padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(content.title)
                        .font(HumayTypography.sectionTitle)
                        .padding(.horizontal, HumaySpacing.extraLarge)
                        .padding(.top, HumaySpacing.extraLarge)
                        .padding(.bottom, HumaySpacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(Array(content.entries.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.label)
                                    .font(HumayTypography.bodyEmphasized)
                                Text(entry.detail)
                                    .font(HumayTypography.supporting)
                                    .foregroundStyle(Color.humayTextSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                        .padding(.horizontal, HumaySpacing.extraLarge)
                        .padding(.vertical, HumaySpacing.medium)
                        .background(index.isMultiple(of: 2) ? Color.clear : Color.humayRaisedSurface.opacity(0.5))

                        if index < content.entries.count - 1 {
                            Divider().overlay(Color.humayHairline)
                        }
                    }

                    Label("Open your year", systemImage: "calendar.badge.clock")
                        .font(HumayTypography.control)
                        .foregroundStyle(Color.humayCoral)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, HumaySpacing.extraLarge)
                        .padding(.vertical, HumaySpacing.medium)
                }
            }
        }
        .buttonStyle(.humayPressable)
        .accessibilityLabel("Next 30 days highlights. Opens your year timeline.")
    }
}

/// Expandable reading with variable-length sections (AI-ready shape).
struct DailyReadingCard: View {
    let content: DailyReadingContent
    let requestShare: (ShareActivity) -> Void

    var body: some View {
        HumaySurface {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                HumayKickerLabel(text: content.kicker)

                Text(content.headline)
                    .font(HumayTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                ForEach(content.sections) { section in
                    VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                        if let heading = section.heading {
                            Text(heading)
                                .font(HumayTypography.bodyEmphasized)
                        }
                        Text(section.text)
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let tip = content.tip {
                    Text(tip)
                        .font(HumayTypography.supportingEmphasized)
                        .foregroundStyle(Color.humayCoral)
                }

                Button {
                    requestShare(ShareActivity(kind: .reading(content)))
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(HumayTypography.control)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: HumayMetrics.minimumHitTarget - 12)
                }
                .buttonStyle(.humaySecondary)
            }
        }
    }
}
