import SwiftUI

struct CurrentSkyView: View {
    let state: CurrentSkyFeatureState
    let source: D3ContentSource
    let profileName: String
    let openProfile: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    D2WordmarkHeader(
                        title: "Sky",
                        profileName: profileName,
                        profileAction: openProfile
                    )
                    .accessibilityIdentifier("sky.current.header")

                    if source.isDevelopmentSample {
                        SkyDevelopmentNotice()
                    }

                    stateContent(availableWidth: proxy.size.width)
                }
                .frame(maxWidth: 1_120, alignment: .top)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.top, HumaySpacing.large)
                .padding(.bottom, HumaySpacing.extraExtraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func stateContent(availableWidth: CGFloat) -> some View {
        switch state {
        case .loading:
            SkyLoadingState()

        case .loaded(let snapshot):
            loadedContent(snapshot, availableWidth: availableWidth)

        case .empty:
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                SkyMessageCard(
                    symbol: "moon.stars",
                    title: "Quiet sky right now",
                    detail: "No notable events are available for this period.",
                    identifier: "sky.current.state.empty",
                    accent: .gold
                )
                SkyCalendarEntry()
            }

        case .unavailable(let reason):
            let copy = SkyUnavailableCopy(reason: reason)
            SkyMessageCard(
                symbol: copy.symbol,
                title: copy.title,
                detail: copy.detail,
                identifier: "sky.current.state.unavailable",
                accent: .lavender
            )

        case .offline(let cached):
            if let cached {
                cachedContent(cached, availableWidth: availableWidth)
            } else {
                SkyMessageCard(
                    symbol: "wifi.slash",
                    title: "No saved sky available",
                    detail: "Reconnect to view current events.",
                    identifier: "sky.current.state.offline.no-cache",
                    accent: .gold
                )
            }

        case .failed:
            SkyMessageCard(
                symbol: "exclamationmark.triangle",
                title: "Sky couldn’t load",
                detail: "The current sky couldn’t be loaded.",
                identifier: "sky.current.state.failed",
                accent: .coral
            )
        }
    }

    @ViewBuilder
    private func loadedContent(
        _ snapshot: SkySnapshot,
        availableWidth: CGFloat
    ) -> some View {
        let wide = usesWideLayout(availableWidth)
        let currentEvents = Array(snapshot.events.prefix(3))
        let upcomingEvents = Array(snapshot.events.dropFirst(3).prefix(3))

        Group {
            if wide {
                HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        CurrentSkyHero(snapshot: snapshot, showsObservation: false)
                        SkyObservationFooter(snapshot: snapshot)
                        SkyCalendarEntry()
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        CurrentSkyEventSection(
                            events: currentEvents,
                            snapshot: snapshot
                        )
                        CurrentSkyTimeline(
                            events: upcomingEvents,
                            snapshot: snapshot,
                            usesPanel: true
                        )
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
            } else {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    CurrentSkyHero(snapshot: snapshot, showsObservation: true)
                    CurrentSkyEventSection(
                        events: currentEvents,
                        snapshot: snapshot
                    )
                    SkyCalendarEntry()
                    CurrentSkyTimeline(
                        events: upcomingEvents,
                        snapshot: snapshot,
                        usesPanel: false
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func cachedContent(
        _ snapshot: SkySnapshot,
        availableWidth: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            SkyOfflineNotice(snapshot: snapshot)
            loadedContent(snapshot, availableWidth: availableWidth)
        }
    }

    private func usesWideLayout(_ availableWidth: CGFloat) -> Bool {
        availableWidth >= 820 && !dynamicTypeSize.isAccessibilitySize
    }
}

private struct SkyDevelopmentNotice: View {
    var body: some View {
        Label("Development sample · not calculated", systemImage: "hammer.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.humayTextSecondary)
            .padding(.horizontal, HumaySpacing.medium)
            .padding(.vertical, HumaySpacing.small)
            .background(Color.humayRaisedSurface, in: Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("sky.current.development-sample.notice")
    }
}

private struct SkyOfflineNotice: View {
    let snapshot: SkySnapshot

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: "wifi.slash")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.humaySolarGold)
                .frame(width: 32, height: 32)
                .background(Color.humaySolarGold.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text("Offline · saved sky")
                    .font(HumayTypography.bodyEmphasized)
                Text(
                    "Showing cached content · "
                        + SkyEventTimingFormatter.observationText(
                            for: snapshot.observedAt,
                            context: snapshot.context
                        ).lowercased()
                )
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
        .accessibilityIdentifier("sky.current.offline.cached.notice")
    }
}

private struct CurrentSkyHero: View {
    let snapshot: SkySnapshot
    let showsObservation: Bool

    @Environment(\.colorScheme) private var colorScheme

    private var leadEvent: SkyEvent { snapshot.events[0] }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            heroContent(horizontal: true)
            heroContent(horizontal: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HumaySpacing.extraLarge)
        .background(heroBackground, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline.opacity(colorScheme == .light ? 0.32 : 0.85))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current celestial sky")
        .accessibilityValue(heroAccessibilityValue)
        .accessibilityIdentifier("sky.current.hero")
    }

    @ViewBuilder
    private func heroContent(horizontal: Bool) -> some View {
        if horizontal {
            HStack(alignment: .center, spacing: HumaySpacing.medium) {
                heroText
                Spacer(minLength: HumaySpacing.small)
                LunarMeridianArt()
                    .frame(width: 148, height: 132)
            }
        } else {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                heroText
                HStack {
                    Spacer(minLength: 0)
                    LunarMeridianArt()
                        .frame(width: 148, height: 132)
                }
            }
        }
    }

    private var heroText: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text("A closer look at the sky")
                    .font(HumayTypography.editorialTitle)
                    .foregroundStyle(heroForeground)
                    .fixedSize(horizontal: false, vertical: true)

            if showsObservation {
                Text(
                    "\(SkyMethodologyFormatter.label(for: leadEvent.system)) · "
                        + SkyEventTimingFormatter.contextText(for: snapshot.context)
                )
                .font(HumayTypography.supporting)
                .foregroundStyle(heroForeground.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

                Text(
                    SkyEventTimingFormatter.observationText(
                        for: snapshot.observedAt,
                        context: snapshot.context
                    )
                )
                .font(HumayTypography.technical)
                .foregroundStyle(heroForeground.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroBackground: some ShapeStyle {
        LinearGradient(
            colors: colorScheme == .light
                ? [Color.humayTextPrimary, Color.humayTextPrimary.opacity(0.92)]
                : [Color.humayRaisedSurface, Color.humaySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var heroForeground: Color {
        colorScheme == .light ? Color.humayGround : Color.humayTextPrimary
    }

    private var heroAccessibilityValue: String {
        let observation = SkyEventTimingFormatter.observationText(
            for: snapshot.observedAt,
            context: snapshot.context
        )
        return "\(SkyMethodologyFormatter.label(for: leadEvent.system)), "
            + "\(SkyEventTimingFormatter.contextText(for: snapshot.context)), \(observation)"
    }

}

private struct LunarMeridianArt: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.humayLavender.opacity(0.14))
                .frame(width: 126, height: 126)

            Ellipse()
                .stroke(Color.humayCelestialBlue.opacity(0.62), lineWidth: 2)
                .frame(width: 150, height: 58)
                .rotationEffect(.degrees(-16))

            Ellipse()
                .stroke(Color.humaySolarGold, lineWidth: 2.5)
                .frame(width: 164, height: 70)
                .rotationEffect(.degrees(14))

            ZStack {
                Circle()
                    .fill(colorScheme == .light ? Color.humayGround : Color.humaySolarGold)
                Circle()
                    .fill(colorScheme == .light ? Color.humayRaisedSurface : Color.humaySurface)
                    .offset(x: 16, y: -5)
            }
            .frame(width: 78, height: 78)

            Circle()
                .fill(Color.humayCoral)
                .frame(width: 10, height: 10)
                .offset(x: -72, y: -12)

            Circle()
                .fill(Color.humayLavender)
                .frame(width: 12, height: 12)
                .offset(x: 72, y: 22)

            Image(systemName: "sparkle")
                .font(.system(size: 21, weight: .light))
                .foregroundStyle(Color.humayCoral)
                .offset(x: -43, y: -44)

            Image(systemName: "sparkle")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(Color.humaySolarGold)
                .offset(x: 45, y: 47)
        }
        .accessibilityHidden(true)
    }
}

private struct SkyObservationFooter: View {
    let snapshot: SkySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Divider()
                .overlay(Color.humayHairline)
            Text(
                "\(SkyEventTimingFormatter.contextText(for: snapshot.context)) · "
                    + SkyEventTimingFormatter.observationText(
                        for: snapshot.observedAt,
                        context: snapshot.context
                    )
            )
            .font(HumayTypography.supporting)
            .foregroundStyle(Color.humayTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("sky.current.observation-context")
    }
}

private struct CurrentSkyEventSection: View {
    let events: [SkyEvent]
    let snapshot: SkySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HStack(alignment: .lastTextBaseline) {
                Text("Happening now")
                    .font(HumayTypography.editorialTitle)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("sky.current.happening-now.heading")
                Spacer(minLength: HumaySpacing.small)
                Text(eventCount)
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)
                    .textCase(.uppercase)
            }

            CurrentSkyPanel {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        CurrentSkyEventRow(
                            event: event,
                            context: snapshot.context,
                            observedAt: snapshot.observedAt
                        )
                        .padding(.vertical, HumaySpacing.medium)

                        if index < events.count - 1 {
                            Divider()
                                .overlay(Color.humayHairline)
                        }
                    }
                }
            }
            .accessibilityIdentifier("sky.current.happening-now")
        }
    }

    private var eventCount: String {
        "\(events.count) event\(events.count == 1 ? "" : "s")"
    }
}

private struct CurrentSkyEventRow: View {
    let event: SkyEvent
    let context: SkyObservationContext
    let observedAt: Date

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            SkyEventGlyph(event: event)
                .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(event.title)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let summary = event.summary {
                    Text(summary)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ViewThatFits(in: .horizontal) {
                    timingAndMethodology(horizontal: true)
                    timingAndMethodology(horizontal: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("sky.current.event.\(event.id.rawValue)")
    }

    @ViewBuilder
    private func timingAndMethodology(horizontal: Bool) -> some View {
        if horizontal {
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.small) {
                timingText
                Spacer(minLength: HumaySpacing.small)
                SkyMethodologyPill(event: event)
            }
        } else {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                timingText
                SkyMethodologyPill(event: event)
            }
        }
    }

    private var timingText: some View {
        Text(
            SkyEventTimingFormatter.text(
                for: event.timing,
                context: context,
                observedAt: observedAt
            )
        )
        .font(HumayTypography.technical.weight(.semibold))
        .foregroundStyle(Color.humayTextSecondary)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var accessibilityLabel: String {
        "\(event.title), \(SkyEventTypeFormatter.label(for: event.type)), "
            + "\(SkyMethodologyFormatter.label(for: event.system))"
    }

    private var accessibilityValue: String {
        let timing = SkyEventTimingFormatter.accessibilityText(
            for: event.timing,
            context: context,
            observedAt: observedAt
        )
        let reliability = event.reliability.accessibilityLabel
        return reliability.map { "\(timing), \($0)" } ?? timing
    }
}

private struct SkyMethodologyPill: View {
    let event: SkyEvent

    var body: some View {
        Text(SkyMethodologyFormatter.label(for: event.system))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.humayTextPrimary)
            .padding(.horizontal, HumaySpacing.medium)
            .padding(.vertical, HumaySpacing.extraSmall)
            .background(event.style.accent.opacity(0.14), in: Capsule())
            .fixedSize(horizontal: true, vertical: false)
    }
}

private struct SkyEventGlyph: View {
    let event: SkyEvent

    var body: some View {
        Image(systemName: event.style.symbol)
            .font(.system(size: 21, weight: .medium))
            .foregroundStyle(event.style.accent)
            .frame(width: 44, height: 44)
            .background(event.style.accent.opacity(0.12), in: Circle())
            .accessibilityHidden(true)
    }
}

private struct CurrentSkyTimeline: View {
    let events: [SkyEvent]
    let snapshot: SkySnapshot
    let usesPanel: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HStack(alignment: .lastTextBaseline) {
                Text("Coming up")
                    .font(HumayTypography.editorialTitle)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("sky.current.coming-up.heading")
                Spacer(minLength: HumaySpacing.small)
                Text(events.isEmpty ? "" : "NEXT \(events.count)")
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)
                    .textCase(.uppercase)
            }

            Group {
                if usesPanel {
                    CurrentSkyPanel {
                        timelineRows
                    }
                } else {
                    timelineRows
                }
            }
            .accessibilityIdentifier("sky.current.coming-up")
        }
    }

    @ViewBuilder
    private var timelineRows: some View {
        if events.isEmpty {
            Text("No additional events supplied.")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .padding(.vertical, HumaySpacing.medium)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    SkyTimelineRow(
                        event: event,
                        context: snapshot.context,
                        observedAt: snapshot.observedAt
                    )
                    .padding(.vertical, HumaySpacing.medium)

                    if index < events.count - 1 {
                        Divider()
                            .overlay(Color.humayHairline)
                    }
                }
            }
        }
    }
}

private struct SkyTimelineRow: View {
    let event: SkyEvent
    let context: SkyObservationContext
    let observedAt: Date

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            dateBadge

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(event.title)
                    .font(HumayTypography.bodyEmphasized)
                    .fixedSize(horizontal: false, vertical: true)

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.small) {
                        timingText
                        Spacer(minLength: HumaySpacing.small)
                        SkyMethodologyPill(event: event)
                    }
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        timingText
                        SkyMethodologyPill(event: event)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(event.title), \(SkyEventTypeFormatter.label(for: event.type)), "
                + "\(SkyMethodologyFormatter.label(for: event.system))"
        )
        .accessibilityValue(
            SkyEventTimingFormatter.accessibilityText(
                for: event.timing,
                context: context,
                observedAt: observedAt
            )
        )
        .accessibilityIdentifier("sky.current.event.timeline.\(event.id.rawValue)")
    }

    @ViewBuilder
    private var dateBadge: some View {
        if let components = SkyEventTimingFormatter.civilDateComponents(
            for: event.timing,
            context: context
        ) {
            VStack(spacing: HumaySpacing.extraSmall) {
                Text(components.month)
                    .font(.caption2.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(event.style.accent)
                Text(components.day)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.humayTextPrimary)
            }
            .frame(width: 46)
            .frame(minHeight: 48)
            .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.compact))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.compact)
                    .stroke(Color.humayHairline)
            }
            .accessibilityHidden(true)
        } else {
            Circle()
                .fill(event.style.accent)
                .frame(width: 18, height: 18)
                .frame(width: 46)
                .frame(minHeight: 48)
                .accessibilityHidden(true)
        }
    }

    private var timingText: some View {
        Text(
            SkyEventTimingFormatter.text(
                for: event.timing,
                context: context,
                observedAt: observedAt
            )
        )
        .font(HumayTypography.technical)
        .foregroundStyle(Color.humayTextSecondary)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SkyCalendarEntry: View {
    var body: some View {
        Button(action: {}) {
            HStack(spacing: HumaySpacing.medium) {
                Image("IllustrationCalendarCelestial")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text("Calendar")
                        .font(HumayTypography.bodyEmphasized)
                    Text("Month, week, and full timeline")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.humayTextPrimary)
                    .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                    .background(Color.humaySurface.opacity(0.76), in: Circle())
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, HumaySpacing.small)
            .padding(.vertical, HumaySpacing.small)
            .frame(minHeight: 76, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(calendarBackground, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface)
                    .stroke(Color.humayHairline)
            }
        }
        .buttonStyle(.plain)
        .disabled(true)
        .accessibilityLabel("Calendar")
        .accessibilityValue("Month, week, and full timeline")
        .accessibilityHint("Calendar will be available in a future Sky update")
        .accessibilityIdentifier("sky.current.calendar-entry")
    }

    private var calendarBackground: some ShapeStyle {
        LinearGradient(
            colors: [Color.humayCoral.opacity(0.16), Color.humayLavender.opacity(0.14)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct CurrentSkyPanel<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, HumaySpacing.large)
            .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface)
                    .strokeBorder(
                        Color.humayHairline,
                        lineWidth: HumayMetrics.hairline(displayScale: displayScale)
                    )
            }
            .shadow(
                color: colorScheme == .light ? .black.opacity(HumayElevation.subtleShadowOpacity) : .clear,
                radius: colorScheme == .light ? HumayElevation.subtleShadowRadius : 0,
                y: colorScheme == .light ? HumayElevation.subtleShadowY : 0
            )
    }
}

private struct SkyLoadingState: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                skeleton(width: 210, height: 18)
                skeleton(width: 160, height: 12)
            }

            HStack(alignment: .center, spacing: HumaySpacing.medium) {
                if reduceMotion {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(Color.humayLavender)
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)
                } else {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayLavender)
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)
                }

                Text("Reading the current sky…")
                    .font(HumayTypography.bodyEmphasized)
            }

            skeleton(width: .infinity, height: 12)
            skeleton(width: 220, height: 10)
        }
        .padding(HumaySpacing.extraLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reading the current sky")
        .accessibilityIdentifier("sky.current.state.loading")
    }

    private func skeleton(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color.humayRaisedSurface)
            .frame(maxWidth: width == .infinity ? .infinity : nil)
            .frame(width: width == .infinity ? nil : width, height: height)
            .accessibilityHidden(true)
    }
}

private struct SkyMessageCard: View {
    let symbol: String
    let title: String
    let detail: String
    let identifier: String
    let accent: HumayAccent

    var body: some View {
        VStack(spacing: HumaySpacing.large) {
            Image(systemName: symbol)
                .font(.system(.largeTitle, design: .rounded, weight: .medium))
                .foregroundStyle(accent.color)
                .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: HumayMetrics.minimumHitTarget)
                .accessibilityHidden(true)

            Text(title)
                .font(HumayTypography.cardTitle)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(detail)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, HumaySpacing.extraLarge)
        .padding(.vertical, HumaySpacing.extraExtraLarge)
        .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

private struct SkyUnavailableCopy {
    let symbol: String
    let title: String
    let detail: String

    init(reason: D3FeatureUnavailability) {
        switch reason {
        case .dataSourceNotConnected:
            symbol = "exclamationmark.circle"
            title = "Current Sky unavailable"
            detail = "This source isn’t connected yet."
        case .unsupportedMethodology:
            symbol = "exclamationmark.circle"
            title = "Methodology unavailable"
            detail = "This methodology isn’t available yet."
        case .missingTimeZone:
            symbol = "clock.badge.exclamationmark"
            title = "Timezone needed"
            detail = "Current Sky needs a valid observation timezone."
        case .missingLocation:
            symbol = "location.slash"
            title = "Location needed"
            detail = "This sky event requires an observation location."
        case .eventNotFound:
            symbol = "questionmark.circle"
            title = "Event unavailable"
            detail = "This event is no longer available."
        }
    }
}

private extension SkyEvent {
    var style: SkyEventStyle {
        SkyEventStyle(type: type, system: system)
    }
}

private struct SkyEventStyle {
    let accent: Color
    let symbol: String

    init(type: SkyEventType, system: SkyEventSystem) {
        switch type {
        case .lunarPhase:
            accent = .humaySolarGold
            symbol = "moon.fill"
        case .planetaryIngress:
            accent = .humayCoral
            symbol = "arrow.up.right.circle"
        case .planetaryAspect:
            accent = .humayLavender
            symbol = "triangle"
        case .planetaryStation:
            accent = .humayCelestialBlue
            symbol = "pause.circle"
        case .seasonalTransition:
            accent = .humaySolarGold
            symbol = "sun.max.fill"
        case .traditionSpecific:
            accent = system == .astrological(.vedic) ? .humayLavender : .humayCoral
            symbol = "sparkles"
        }
    }
}

private extension SkyEventReliability {
    var accessibilityLabel: String? {
        switch self {
        case .reliable:
            "Reliable"
        case .approximate:
            "Approximate"
        case .unverified:
            nil
        }
    }
}
