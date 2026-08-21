import SwiftUI

/// Calendar is owned by Sky. It consumes the typed D3 boundary and keeps range
/// and selected-date state local to this nested route.
struct SkyCalendarView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case month = "Month"
        case week = "Week"

        var id: Self { self }
    }

    let source: D3ContentSource
    let monthState: SkyCalendarMonthFeatureState
    let weekState: SkyCalendarWeekFeatureState
    let today: SkyCalendarDate?
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var mode: Mode = .month
    @State private var selectedDate: SkyCalendarDate?
    @State private var monthSelection: SkyCalendarMonthID?
    @State private var weekStart: SkyCalendarDate?

    init(
        source: D3ContentSource,
        monthState: SkyCalendarMonthFeatureState,
        weekState: SkyCalendarWeekFeatureState,
        today: SkyCalendarDate? = nil,
        eventDetailState: @escaping (SkyEventID) -> SkyEventDetailFeatureState = { eventID in
            .unavailable(eventID: eventID, reason: .eventNotFound)
        }
    ) {
        self.source = source
        self.monthState = monthState
        self.weekState = weekState
        self.today = today
        self.eventDetailState = eventDetailState

        let month = Self.monthValue(from: monthState)
        let week = Self.weekValue(from: weekState)
        _monthSelection = State(initialValue: month?.selection)
        _weekStart = State(initialValue: week?.startDate ?? Self.weekStart(from: month))
        _selectedDate = State(initialValue: Self.initialSelection(month: month, fallback: today ?? week?.startDate))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    if source.isDevelopmentSample {
                        SkyDevelopmentNotice()
                    }

                    modePicker

                    content(availableWidth: proxy.size.width)
                }
                .frame(maxWidth: HumayContentWidth.immersive.rawValue, alignment: .top)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.top, HumaySpacing.medium)
                .padding(.bottom, HumaySpacing.expansive + HumaySpacing.extraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayCanvas.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Today", action: goToToday)
                    .font(HumayTypography.bodyEmphasized)
                    .foregroundStyle(Color.humayAccentPrestige)
                    .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: HumayMetrics.minimumHitTarget)
                    .accessibilityIdentifier("sky.calendar.today")
            }
        }
        .accessibilityIdentifier("sky.calendar.screen")
        .onAppear {
            normalizeSelection()
        }
        .onChange(of: mode) { _, newMode in
            switch newMode {
            case .month:
                alignMonthToSelection()
            case .week:
                alignWeekToSelection()
            }
        }
    }

    private var modePicker: some View {
        Picker("Calendar view", selection: $mode) {
            ForEach(Mode.allCases) { mode in
                Text(mode.rawValue)
                    .tag(mode)
                    .accessibilityIdentifier("sky.calendar.mode.\(mode.rawValue.lowercased())")
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 390)
        .controlSize(.large)
        .accessibilityIdentifier("sky.calendar.mode")
        .accessibilityValue(mode.rawValue)
    }

    @ViewBuilder
    private func content(availableWidth: CGFloat) -> some View {
        switch mode {
        case .month:
            SkyCalendarMonthView(
                source: source,
                state: monthState,
                selectedDate: $selectedDate,
                selection: $monthSelection,
                today: today,
                usesWideLayout: usesWideLayout(availableWidth),
                onNavigate: navigateMonth,
                eventDetailState: eventDetailState
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(monthStateIdentifier)

        case .week:
            SkyCalendarWeekView(
                source: source,
                state: weekState,
                selectedDate: $selectedDate,
                weekStart: $weekStart,
                today: today,
                usesWideLayout: usesWideLayout(availableWidth),
                onNavigate: navigateWeek,
                eventDetailState: eventDetailState
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(weekStateIdentifier)
        }
    }

    private var monthStateIdentifier: String {
        switch monthState {
        case .loading: "sky.calendar.month.state.loading"
        case .loaded: "sky.calendar.month.state.loaded"
        case .empty: "sky.calendar.month.state.empty"
        case .unavailable: "sky.calendar.month.state.unavailable"
        case .offline(_, let cached):
            cached == nil ? "sky.calendar.month.state.offline.no-cache" : "sky.calendar.month.state.offline.cached"
        case .failed: "sky.calendar.month.state.failed"
        }
    }

    private var weekStateIdentifier: String {
        switch weekState {
        case .loading: "sky.calendar.week.state.loading"
        case .loaded: "sky.calendar.week.state.loaded"
        case .empty: "sky.calendar.week.state.empty"
        case .unavailable: "sky.calendar.week.state.unavailable"
        case .offline(_, let cached):
            cached == nil ? "sky.calendar.week.state.offline.no-cache" : "sky.calendar.week.state.offline.cached"
        case .failed: "sky.calendar.week.state.failed"
        }
    }

    private func usesWideLayout(_ width: CGFloat) -> Bool {
        width >= 820 && !dynamicTypeSize.isAccessibilitySize
    }

    private func goToToday() {
        guard let today else { return }
        selectedDate = today

        switch mode {
        case .month:
            monthSelection = try? SkyCalendarMonthID(year: today.year, month: today.month)
        case .week:
            weekStart = SkyCalendarSupport.monday(of: today)
        }
    }

    private func navigateMonth(by offset: Int) {
        // Only the supplied August fixture is loaded. Keep controls visible for
        // the approved structure but disabled until a truthful adjacent payload exists.
        _ = offset
    }

    private func navigateWeek(by offset: Int) {
        _ = offset
    }

    private func normalizeSelection() {
        if selectedDate == nil {
            selectedDate = today ?? Self.firstEventDate(in: Self.monthValue(from: monthState))
        }
        alignMonthToSelection()
        alignWeekToSelection()
    }

    private func alignMonthToSelection() {
        guard let selectedDate else { return }
        monthSelection = try? SkyCalendarMonthID(year: selectedDate.year, month: selectedDate.month)
    }

    private func alignWeekToSelection() {
        guard let selectedDate else { return }
        weekStart = SkyCalendarSupport.monday(of: selectedDate)
    }

    private static func monthValue(from state: SkyCalendarMonthFeatureState) -> SkyCalendarMonth? {
        switch state {
        case .loaded(let month): month
        case .offline(_, let cached): cached
        default: nil
        }
    }

    private static func weekValue(from state: SkyCalendarWeekFeatureState) -> SkyCalendarWeek? {
        switch state {
        case .loaded(let week): week
        case .offline(_, let cached): cached
        default: nil
        }
    }

    private static func firstEventDate(in month: SkyCalendarMonth?) -> SkyCalendarDate? {
        month?.days.first(where: { !$0.events.isEmpty })?.date
    }

    private static func initialSelection(
        month: SkyCalendarMonth?,
        fallback: SkyCalendarDate?
    ) -> SkyCalendarDate? {
        month?.days.max { lhs, rhs in
            lhs.events.count < rhs.events.count
        }?.date ?? fallback ?? firstEventDate(in: month)
    }

    private static func weekStart(from month: SkyCalendarMonth?) -> SkyCalendarDate? {
        guard let month else { return nil }
        let firstDate = month.days.first?.date ?? SkyCalendarSupport.date(
            year: month.selection.year,
            month: month.selection.month,
            day: 1
        )
        return SkyCalendarSupport.monday(of: firstDate)
    }
}

#if DEBUG
#Preview("Calendar Month") {
    let input = DevelopmentD3Sample.makeInput()

    SkyCalendarView(
        source: .developmentSample,
        monthState: .loaded(DevelopmentD3Sample.month),
        weekState: .loaded(DevelopmentD3Sample.week),
        today: DevelopmentD3Sample.referenceToday,
        eventDetailState: input.eventDetailState
    )
}
#endif
