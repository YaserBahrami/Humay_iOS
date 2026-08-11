import SwiftUI

/// A month, with the days that carry something marked.
///
/// Nested inside Sky rather than promoted to its own tab. The legend distinguishes days
/// that reach your chart from days that are merely context, which is the only
/// distinction worth drawing on a grid this small.
struct SkyCalendarContent: View {
    let events: [SkyEvent]
    let onSelectEvent: (String) -> Void

    @Environment(\.humayTheme) private var theme
    @ScaledMetric(relativeTo: .callout) private var dayCellHeight: CGFloat = HumayHitTarget.minimum
    @State private var monthAnchor = Date.now
    @State private var selectedDay: Int?

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.m) {
            monthHeader

            weekdayHeader

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                ForEach(gridDays, id: \.self) { day in
                    dayCell(day)
                }
            }

            legend

            if let selectedDay, let event = event(on: selectedDay) {
                VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                    HairlineRule()
                    MonoKicker(
                        text: "\(monthLabel(short: true)) \(selectedDay) · \(event.relevance.displayName)",
                        color: event.relevance == .high ? theme.colors.accentText : theme.colors.textLabel
                    )
                    .padding(.top, HumaySpacing.xs)
                    Button {
                        onSelectEvent(event.id)
                    } label: {
                        HStack {
                            Text(event.title)
                                .humayFont(.titleS)
                                .foregroundStyle(theme.colors.textPrimary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: HumaySpacing.xs)
                            DisclosureChevron()
                        }
                        .frame(minHeight: HumayHitTarget.minimum)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(spacing: 0) {
                SectionHeader(title: "This month")
                ForEach(events) { event in
                    SkyEventRow(event: event) { onSelectEvent(event.id) }
                    HairlineRule()
                }
            }
        }
    }

    @ViewBuilder
    private var monthHeader: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: HumayIconSize.chrome, weight: .regular))
                    .frame(width: HumayHitTarget.minimum, height: HumayHitTarget.minimum)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityLabel("Previous month")

            Text(monthLabel())
                .humayFont(.titleM)
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: HumayIconSize.chrome, weight: .regular))
                    .frame(width: HumayHitTarget.minimum, height: HumayHitTarget.minimum)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityLabel("Next month")
        }
    }

    @ViewBuilder
    private var weekdayHeader: some View {
        HStack(spacing: 2) {
            ForEach(orderedWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .humayFont(.monoKicker)
                    .foregroundStyle(theme.colors.textLabel)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func dayCell(_ day: Int?) -> some View {
        if let day {
            let relevance = event(on: day)?.relevance
            Button {
                selectedDay = selectedDay == day ? nil : day
            } label: {
                VStack(spacing: 3) {
                    // A date is mono, per the typography lock, and mono is capped — which
                    // is what keeps seven columns readable. Set in the body face it grew
                    // uncapped and the tenth of the month wrapped to two lines.
                    Text("\(day)")
                        .humayFont(.monoDegree)
                        .monospacedDigit()
                        .lineLimit(1)
                        .foregroundStyle(
                            selectedDay == day ? theme.colors.textPrimary : theme.colors.textSecondary
                        )
                    Circle()
                        .fill(markColor(for: relevance))
                        .frame(width: 4, height: 4)
                        .opacity(relevance == nil ? 0 : 1)
                }
                .frame(maxWidth: .infinity, minHeight: dayCellHeight)
                .overlay(
                    Rectangle()
                        .stroke(theme.colors.hairlineStrong, lineWidth: selectedDay == day ? 1 : 0)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(dayAccessibilityLabel(day, relevance: relevance))
        } else {
            Color.clear.frame(minHeight: dayCellHeight)
        }
    }

    @ViewBuilder
    private var legend: some View {
        HStack(spacing: HumaySpacing.m) {
            legendItem(color: theme.colors.accentMark, label: "High relevance")
            legendItem(color: theme.colors.textLabel, label: "Context")
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 4, height: 4)
            MonoKicker(text: label)
        }
        .accessibilityElement(children: .combine)
    }

    private func markColor(for relevance: EventRelevance?) -> Color {
        switch relevance {
        case .high: theme.colors.accentMark
        case .context: theme.colors.textLabel
        case nil: .clear
        }
    }

    private func dayAccessibilityLabel(_ day: Int, relevance: EventRelevance?) -> String {
        var label = "\(monthLabel(short: true)) \(day)"
        if let relevance { label += ", \(relevance.displayName)" }
        if let event = event(on: day) { label += ", \(event.title)" }
        return label
    }

    private func event(on day: Int) -> SkyEvent? {
        events.first { $0.date.day == day && $0.date.month == calendar.component(.month, from: monthAnchor) }
            ?? events.first { $0.date.day == day }
    }

    private var gridDays: [Int?] {
        guard
            let interval = calendar.dateInterval(of: .month, for: monthAnchor),
            let range = calendar.range(of: .day, in: .month, for: monthAnchor)
        else { return [] }
        let leading = (calendar.component(.weekday, from: interval.start) - calendar.firstWeekday + 7) % 7
        return Array(repeating: nil, count: leading) + range.map { Optional($0) }
    }

    private var orderedWeekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...] + symbols[..<offset])
    }

    private func monthLabel(short: Bool = false) -> String {
        monthAnchor.formatted(short ? .dateTime.month(.abbreviated) : .dateTime.month(.wide).year())
    }

    private func shiftMonth(by value: Int) {
        guard let next = calendar.date(byAdding: .month, value: value, to: monthAnchor) else { return }
        monthAnchor = next
        selectedDay = nil
    }
}

/// The calendar as its own pushed screen, for deep links into it.
struct SkyCalendarView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router

    @State private var events: [SkyEvent] = []

    var body: some View {
        DetailScaffold(title: "Calendar") {
            SkyCalendarContent(events: events) { id in
                router.push(.skyEvent(id), on: .sky)
            }
        }
        .task {
            events = (try? await environment.skyService.events(
                in: Calendar.current.dateComponents([.year, .month], from: .now),
                profile: environment.profile
            )) ?? []
        }
    }
}

/// One event, in both registers, with its facts underneath.
struct SkyEventDetailView: View {
    let eventID: String

    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var event: SkyEvent?
    @State private var failure: String?

    var body: some View {
        DetailScaffold(title: event?.title ?? "Event") {
            if let event {
                content(event)
            } else if let failure {
                ErrorStateView(message: failure)
            } else {
                LoadingState(message: "Loading…")
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private func content(_ event: SkyEvent) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            Text(event.title)
                .humayFont(.displayL)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: HumaySpacing.xs) {
                MonoFact(text: event.shortDateFormatted, emphasised: true)
                if let time = event.time.formatted {
                    MonoFact(text: time)
                } else {
                    // No clock time is shown when one is not deterministically
                    // supported, rather than inventing a plausible-looking minute.
                    MonoFact(text: "TIME NOT DETERMINED")
                }
                SampleContentMarker(provenance: event.provenance)
            }
        }

        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            SectionHeader(title: SkyRegister.inTheSky.displayName)
            ReadingBody(text: event.inTheSky, role: .bodySmall)
        }

        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            SectionHeader(title: SkyRegister.forYou.displayName)
            switch event.forYou {
            case .available(let text), .uncertain(let text, _):
                ReadingBody(text: text, role: .bodySmall)
            case .unavailable(let reason):
                UnavailableFactView(reason: reason)
            }
        }

        if !event.basisFacts.isEmpty {
            VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                SectionHeader(title: "Astrological basis")
                ForEach(event.basisFacts, id: \.self) { fact in
                    MonoFact(text: fact)
                        .frame(minHeight: 24)
                }
            }
        }
    }

    private func load() async {
        do {
            event = try await environment.skyService.event(id: eventID, profile: environment.profile)
        } catch {
            failure = "This event could not be loaded."
        }
    }
}
