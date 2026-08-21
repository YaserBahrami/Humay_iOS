import SwiftUI

struct CurrentSkyView: View {
    let state: CurrentSkyFeatureState
    let source: D3ContentSource
    let calendarMonth: SkyCalendarMonthFeatureState
    let calendarWeek: SkyCalendarWeekFeatureState
    let calendarToday: SkyCalendarDate?
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState
    let profileName: String
    let openProfile: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    HumayScreenHeader(
                        section: "Current Sky",
                        profileName: profileName,
                        profileAction: openProfile,
                        wordmarkIdentifier: "sky.current.header"
                    )

                    if source.isDevelopmentSample {
                        SkyDevelopmentNotice(
                            identifier: "sky.current.development-sample.notice"
                        )
                    }

                    stateContent(availableWidth: proxy.size.width)
                }
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
        .navigationTitle("Current Sky")
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func stateContent(availableWidth: CGFloat) -> some View {
        switch state {
        case .loading:
            SkyLoadingPresentation(
                title: "Reading the current sky…",
                message: "Waiting for supplied observation and event data.",
                identifier: "sky.current.state.loading"
            )

        case .loaded(let snapshot):
            loadedContent(snapshot, availableWidth: availableWidth)

        case .empty:
            VStack(alignment: .leading, spacing: HumaySpacing.section) {
                SkyStatePresentation(
                    symbol: "moon.stars",
                    title: "Quiet sky right now",
                    message: "No notable events are available for this period.",
                    identifier: "sky.current.state.empty",
                    eyebrow: "Current observation"
                )
                calendarEntry
            }

        case .unavailable(let reason):
            let copy = SkyUnavailableCopy(reason: reason)
            SkyStatePresentation(
                symbol: copy.symbol,
                title: copy.title,
                message: copy.detail,
                identifier: "sky.current.state.unavailable",
                eyebrow: "Current observation",
                accent: .humayAccentCelestial
            )

        case .offline(let cached):
            if let cached {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    SkyOfflineBanner(
                        title: "Offline · saved sky",
                        detail: "Showing cached content · "
                            + SkyEventTimingFormatter.observationText(
                                for: cached.observedAt,
                                context: cached.context
                            ).lowercased(),
                        identifier: "sky.current.offline.cached.notice"
                    )
                    loadedContent(cached, availableWidth: availableWidth)
                }
                .accessibilityElement(children: .contain)
            } else {
                SkyStatePresentation(
                    symbol: "wifi.slash",
                    title: "No saved sky available",
                    message: "Reconnect to view current events.",
                    identifier: "sky.current.state.offline.no-cache",
                    eyebrow: "Offline"
                )
            }

        case .failed:
            SkyStatePresentation(
                symbol: "exclamationmark.triangle",
                title: "Sky couldn’t load",
                message: "The current sky couldn’t be loaded.",
                identifier: "sky.current.state.failed",
                eyebrow: "Current observation",
                accent: .humayAccentRoast
            )
        }
    }

    @ViewBuilder
    private func loadedContent(
        _ snapshot: SkySnapshot,
        availableWidth: CGFloat
    ) -> some View {
        let currentEvents = Array(snapshot.events.dropFirst().prefix(2))
        let upcomingEvents = Array(snapshot.events.dropFirst(3).prefix(3))

        if usesWideLayout(availableWidth) {
            HStack(alignment: .top, spacing: HumaySpacing.section) {
                VStack(alignment: .leading, spacing: HumaySpacing.section) {
                    CurrentSkyBriefing(
                        snapshot: snapshot,
                        source: source,
                        eventDetailState: eventDetailState
                    )
                    calendarEntry
                }
                .frame(maxWidth: 480, alignment: .topLeading)

                VStack(alignment: .leading, spacing: HumaySpacing.section) {
                    CurrentSkyEventSection(
                        events: currentEvents,
                        snapshot: snapshot,
                        source: source,
                        eventDetailState: eventDetailState
                    )
                    CurrentSkyTimeline(
                        events: upcomingEvents,
                        snapshot: snapshot,
                        source: source,
                        eventDetailState: eventDetailState
                    )
                }
                .frame(maxWidth: 600, alignment: .topLeading)
            }
        } else {
            VStack(alignment: .leading, spacing: HumaySpacing.section) {
                CurrentSkyBriefing(
                    snapshot: snapshot,
                    source: source,
                    eventDetailState: eventDetailState
                )
                CurrentSkyEventSection(
                    events: currentEvents,
                    snapshot: snapshot,
                    source: source,
                    eventDetailState: eventDetailState
                )
                CurrentSkyTimeline(
                    events: upcomingEvents,
                    snapshot: snapshot,
                    source: source,
                    eventDetailState: eventDetailState
                )
                calendarEntry
            }
        }
    }

    private var calendarEntry: some View {
        SkyCalendarEntry(
            source: source,
            monthState: calendarMonth,
            weekState: calendarWeek,
            today: calendarToday,
            eventDetailState: eventDetailState
        )
    }

    private func usesWideLayout(_ availableWidth: CGFloat) -> Bool {
        availableWidth >= 820 && !dynamicTypeSize.isAccessibilitySize
    }
}

private struct CurrentSkyBriefing: View {
    let snapshot: SkySnapshot
    let source: D3ContentSource
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    private var leadEvent: SkyEvent { snapshot.events[0] }

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            SkyObservationMetadata(
                context: snapshot.context,
                observedAt: snapshot.observedAt,
                methodology: leadEvent.system
            )
            .accessibilityIdentifier("sky.current.observation-context")

            Divider()
                .overlay(Color.humaySeparator)

            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                Text("Current Sky")
                    .font(HumayTypography.displayTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                HumayEyebrow(text: "Lead event", color: leadEvent.style.accent)

                NavigationLink {
                    SkyEventDetailView(
                        source: source,
                        state: eventDetailState(leadEvent.id),
                        context: snapshot.context
                    )
                } label: {
                    SkyEventRow(
                        event: leadEvent,
                        context: snapshot.context,
                        timingPresentation: .current(observedAt: snapshot.observedAt)
                    )
                    .padding(.vertical, HumaySpacing.small)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens Event Detail")
                .accessibilityIdentifier("sky.current.event.\(leadEvent.id.rawValue)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.current.hero")
    }
}

private struct CurrentSkyEventSection: View {
    let events: [SkyEvent]
    let snapshot: SkySnapshot
    let source: D3ContentSource
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            sectionHeader

            Divider()
                .overlay(Color.humaySeparator)

            if events.isEmpty {
                Text("No additional current events supplied.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .padding(.vertical, HumaySpacing.small)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        NavigationLink {
                            SkyEventDetailView(
                                source: source,
                                state: eventDetailState(event.id),
                                context: snapshot.context
                            )
                        } label: {
                            SkyEventRow(
                                event: event,
                                context: snapshot.context,
                                timingPresentation: .current(observedAt: snapshot.observedAt)
                            )
                            .padding(.vertical, HumaySpacing.medium)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens Event Detail")
                        .accessibilityIdentifier("sky.current.event.\(event.id.rawValue)")

                        if index < events.count - 1 {
                            Divider()
                                .overlay(Color.humaySeparator)
                        }
                    }
                }
            }

            Divider()
                .overlay(Color.humaySeparator)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.current.happening-now")
    }

    private var sectionHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .lastTextBaseline, spacing: HumaySpacing.large) {
                title
                Spacer(minLength: HumaySpacing.small)
                count
            }
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                title
                count
            }
        }
    }

    private var title: some View {
        Text("Happening now")
            .font(HumayTypography.editorialTitle)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("sky.current.happening-now.heading")
    }

    private var count: some View {
        Text("\(events.count) event\(events.count == 1 ? "" : "s")")
            .font(HumayTypography.utility)
            .foregroundStyle(Color.humayTextSecondary)
            .textCase(.uppercase)
    }
}

private struct CurrentSkyTimeline: View {
    let events: [SkyEvent]
    let snapshot: SkySnapshot
    let source: D3ContentSource
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            Text("Coming up")
                .font(HumayTypography.editorialTitle)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("sky.current.coming-up.heading")

            Divider()
                .overlay(Color.humaySeparator)

            if events.isEmpty {
                Text("No additional events supplied.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .padding(.vertical, HumaySpacing.small)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        timelineRow(event)

                        if index < events.count - 1 {
                            Divider()
                                .overlay(Color.humaySeparator)
                        }
                    }
                }
            }

            Divider()
                .overlay(Color.humaySeparator)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.current.coming-up")
    }

    private func timelineRow(_ event: SkyEvent) -> some View {
        NavigationLink {
            SkyEventDetailView(
                source: source,
                state: eventDetailState(event.id),
                context: snapshot.context
            )
        } label: {
            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                HumayEyebrow(
                    text: dateLabel(for: event),
                    color: event.style.accent
                )

                SkyEventRow(
                    event: event,
                    context: snapshot.context,
                    timingPresentation: .current(observedAt: snapshot.observedAt),
                    showsSummary: false
                )
            }
            .padding(.vertical, HumaySpacing.medium)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens Event Detail")
        .accessibilityIdentifier("sky.current.event.timeline.\(event.id.rawValue)")
    }

    private func dateLabel(for event: SkyEvent) -> String {
        guard let components = SkyEventTimingFormatter.civilDateComponents(
            for: event.timing,
            context: snapshot.context
        ) else {
            return "Timing not supplied"
        }
        return "\(components.month) \(components.day)"
    }
}

private struct SkyCalendarEntry: View {
    let source: D3ContentSource
    let monthState: SkyCalendarMonthFeatureState
    let weekState: SkyCalendarWeekFeatureState
    let today: SkyCalendarDate?
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    var body: some View {
        NavigationLink {
            SkyCalendarView(
                source: source,
                monthState: monthState,
                weekState: weekState,
                today: today,
                eventDetailState: eventDetailState
            )
        } label: {
            HStack(alignment: .center, spacing: HumaySpacing.large) {
                Image(systemName: "calendar")
                    .font(.title3.weight(.regular))
                    .foregroundStyle(Color.humayAccentPrestige)
                    .frame(
                        width: HumayMetrics.minimumHitTarget,
                        height: HumayMetrics.minimumHitTarget
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    HumayEyebrow(text: "Continue in Sky", color: .humayAccentPrestige)
                    Text("Calendar")
                        .font(HumayTypography.bodyEmphasized)
                    Text("Browse supplied events by month or week")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.humayTextSecondary)
                    .frame(
                        width: HumayMetrics.minimumHitTarget,
                        height: HumayMetrics.minimumHitTarget
                    )
                    .accessibilityHidden(true)
            }
            .padding(.vertical, HumaySpacing.medium)
            .contentShape(Rectangle())
            .overlay(alignment: .top) {
                Divider()
                    .overlay(Color.humaySeparator)
            }
            .overlay(alignment: .bottom) {
                Divider()
                    .overlay(Color.humaySeparator)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Calendar")
        .accessibilityValue("Browse supplied events by month or week")
        .accessibilityHint("Opens Calendar")
        .accessibilityIdentifier("sky.current.calendar-entry")
    }
}

private struct SkyUnavailableCopy {
    let symbol: String
    let title: String
    let detail: String

    init(reason: D3FeatureUnavailability) {
        switch reason {
        case .dataSourceNotConnected:
            symbol = "externaldrive.badge.questionmark"
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
