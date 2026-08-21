import SwiftUI

struct SkyCalendarMonthView: View {
    let source: D3ContentSource
    let state: SkyCalendarMonthFeatureState
    @Binding var selectedDate: SkyCalendarDate?
    @Binding var selection: SkyCalendarMonthID?
    let today: SkyCalendarDate?
    let usesWideLayout: Bool
    let onNavigate: (Int) -> Void
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    var body: some View {
        Group {
            switch state {
            case .loading:
                SkyLoadingPresentation(
                    title: "Loading Calendar…",
                    message: "Waiting for supplied month and event data.",
                    identifier: "sky.calendar.month.state.loading"
                )

            case .loaded(let month):
                loadedSurface(
                    monthID: month.selection,
                    context: month.context,
                    eventDays: Dictionary(uniqueKeysWithValues: month.days.map { ($0.date, $0.events) }),
                    showsEmptyMonthMessage: false
                )

            case .empty(let month):
                loadedSurface(
                    monthID: month,
                    context: nil,
                    eventDays: [:],
                    showsEmptyMonthMessage: true
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("sky.calendar.month.state.empty")

            case .unavailable(_, let reason):
                SkyStatePresentation(
                    symbol: unavailableSymbol(reason),
                    title: "Calendar unavailable",
                    message: unavailableDetail(reason),
                    identifier: "sky.calendar.month.state.unavailable",
                    eyebrow: "Month view",
                    accent: .humayAccentCelestial
                )

            case .offline(_, let cached):
                if let cached {
                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        SkyOfflineBanner(
                            title: "Offline · saved Calendar",
                            detail: "Showing saved civil dates and event metadata.",
                            identifier: "sky.calendar.offline.cached.notice"
                        )
                        loadedSurface(
                            monthID: cached.selection,
                            context: cached.context,
                            eventDays: Dictionary(uniqueKeysWithValues: cached.days.map { ($0.date, $0.events) }),
                            showsEmptyMonthMessage: false
                        )
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("sky.calendar.month.state.offline.cached")
                } else {
                    SkyStatePresentation(
                        symbol: "wifi.slash",
                        title: "No saved Calendar",
                        message: "Reconnect to load these dates.",
                        identifier: "sky.calendar.month.state.offline.no-cache",
                        eyebrow: "Month view"
                    )
                }

            case .failed:
                SkyStatePresentation(
                    symbol: "exclamationmark.triangle",
                    title: "Calendar couldn’t load",
                    message: "The source could not be loaded.",
                    identifier: "sky.calendar.month.state.failed",
                    eyebrow: "Month view",
                    accent: .humayAccentRoast
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(stateAccessibilityIdentifier)
    }

    private var stateAccessibilityIdentifier: String {
        switch state {
        case .loading: "sky.calendar.month.state.loading"
        case .loaded: "sky.calendar.month.state.loaded"
        case .empty: "sky.calendar.month.state.empty"
        case .unavailable: "sky.calendar.month.state.unavailable"
        case .offline(_, let cached):
            cached == nil ? "sky.calendar.month.state.offline.no-cache" : "sky.calendar.month.state.offline.cached"
        case .failed: "sky.calendar.month.state.failed"
        }
    }

    @ViewBuilder
    private func loadedSurface(
        monthID: SkyCalendarMonthID,
        context: SkyObservationContext?,
        eventDays: [SkyCalendarDate: [SkyEvent]],
        showsEmptyMonthMessage: Bool
    ) -> some View {
        let date = selectedDate ?? today ?? SkyCalendarSupport.date(year: monthID.year, month: monthID.month, day: 1)
        let agendaEvents = eventDays[date] ?? []

        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            SkyCalendarRangeHeader(
                title: SkyCalendarSupport.monthTitle(monthID),
                subtitle: nil,
                previousIdentifier: "sky.calendar.month.previous",
                nextIdentifier: "sky.calendar.month.next",
                onPrevious: { onNavigate(-1) },
                onNext: { onNavigate(1) },
                navigationIsAvailable: false
            )

            if usesWideLayout {
                HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        SkyCalendarCivilGrid(
                            monthID: monthID,
                            selectedDate: $selectedDate,
                            today: today,
                            eventDays: eventDays,
                            usesRegularRows: true
                        )

                        if showsEmptyMonthMessage {
                            SkyCalendarEmptyMonthNote()
                        }

                        if let context {
                            SkyCalendarObservationFooter(context: context)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    SkyCalendarAgenda(
                        selectedDate: date,
                        events: agendaEvents,
                        context: context,
                        identifier: "sky.calendar.agenda",
                        source: source,
                        eventDetailState: eventDetailState
                    )
                    .frame(maxWidth: 390, alignment: .topLeading)
                }
            } else {
                SkyCalendarCivilGrid(
                    monthID: monthID,
                    selectedDate: $selectedDate,
                    today: today,
                    eventDays: eventDays,
                    usesRegularRows: false
                )

                if showsEmptyMonthMessage {
                    SkyCalendarEmptyMonthNote()
                }

                SkyCalendarAgenda(
                    selectedDate: date,
                    events: agendaEvents,
                    context: context,
                    identifier: "sky.calendar.agenda",
                    source: source,
                    eventDetailState: eventDetailState
                )

                if let context {
                    SkyCalendarObservationFooter(context: context)
                }
            }
        }
        .onChange(of: selectedDate) { _, newDate in
            guard let newDate else { return }
            selection = try? SkyCalendarMonthID(year: newDate.year, month: newDate.month)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.calendar.month.state.loaded")
    }

    private func unavailableSymbol(_ reason: D3FeatureUnavailability) -> String {
        switch reason {
        case .dataSourceNotConnected: "externaldrive.badge.questionmark"
        case .unsupportedMethodology: "exclamationmark.circle"
        case .missingTimeZone: "clock.badge.exclamationmark"
        case .missingLocation: "location.slash"
        case .eventNotFound: "questionmark.circle"
        }
    }

    private func unavailableDetail(_ reason: D3FeatureUnavailability) -> String {
        switch reason {
        case .dataSourceNotConnected: "This source isn’t available yet."
        case .unsupportedMethodology: "This methodology isn’t available yet."
        case .missingTimeZone: "Calendar needs a valid observation timezone."
        case .missingLocation: "This Calendar content requires an observation location."
        case .eventNotFound: "This Calendar content is no longer available."
        }
    }
}

struct SkyCalendarWeekView: View {
    let source: D3ContentSource
    let state: SkyCalendarWeekFeatureState
    @Binding var selectedDate: SkyCalendarDate?
    @Binding var weekStart: SkyCalendarDate?
    let today: SkyCalendarDate?
    let usesWideLayout: Bool
    let onNavigate: (Int) -> Void
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    var body: some View {
        Group {
            switch state {
            case .loading:
                SkyLoadingPresentation(
                    title: "Loading Calendar…",
                    message: "Waiting for supplied week and event data.",
                    identifier: "sky.calendar.week.state.loading"
                )

            case .loaded(let week):
                loadedSurface(
                    startDate: week.startDate,
                    context: week.context,
                    eventDays: Dictionary(uniqueKeysWithValues: week.days.map { ($0.date, $0.events) }),
                    showsEmptyWeekMessage: false
                )

            case .empty(let startDate):
                loadedSurface(
                    startDate: startDate,
                    context: nil,
                    eventDays: [:],
                    showsEmptyWeekMessage: true
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("sky.calendar.week.state.empty")

            case .unavailable(_, let reason):
                SkyStatePresentation(
                    symbol: unavailableSymbol(reason),
                    title: "Calendar unavailable",
                    message: unavailableDetail(reason),
                    identifier: "sky.calendar.week.state.unavailable",
                    eyebrow: "Week view",
                    accent: .humayAccentCelestial
                )

            case .offline(_, let cached):
                if let cached {
                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        SkyOfflineBanner(
                            title: "Offline · saved Calendar",
                            detail: "Showing saved civil dates and event metadata.",
                            identifier: "sky.calendar.offline.cached.notice"
                        )
                        loadedSurface(
                            startDate: cached.startDate,
                            context: cached.context,
                            eventDays: Dictionary(uniqueKeysWithValues: cached.days.map { ($0.date, $0.events) }),
                            showsEmptyWeekMessage: false
                        )
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("sky.calendar.week.state.offline.cached")
                } else {
                    SkyStatePresentation(
                        symbol: "wifi.slash",
                        title: "No saved Calendar",
                        message: "Reconnect to load these dates.",
                        identifier: "sky.calendar.week.state.offline.no-cache",
                        eyebrow: "Week view"
                    )
                }

            case .failed:
                SkyStatePresentation(
                    symbol: "exclamationmark.triangle",
                    title: "Calendar couldn’t load",
                    message: "The source could not be loaded.",
                    identifier: "sky.calendar.week.state.failed",
                    eyebrow: "Week view",
                    accent: .humayAccentRoast
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(stateAccessibilityIdentifier)
    }

    private var stateAccessibilityIdentifier: String {
        switch state {
        case .loading: "sky.calendar.week.state.loading"
        case .loaded: "sky.calendar.week.state.loaded"
        case .empty: "sky.calendar.week.state.empty"
        case .unavailable: "sky.calendar.week.state.unavailable"
        case .offline(_, let cached):
            cached == nil ? "sky.calendar.week.state.offline.no-cache" : "sky.calendar.week.state.offline.cached"
        case .failed: "sky.calendar.week.state.failed"
        }
    }

    @ViewBuilder
    private func loadedSurface(
        startDate: SkyCalendarDate,
        context: SkyObservationContext?,
        eventDays: [SkyCalendarDate: [SkyEvent]],
        showsEmptyWeekMessage: Bool
    ) -> some View {
        let dates = SkyCalendarSupport.weekDates(starting: startDate)
        let date = selectedDate.flatMap { dates.contains($0) ? $0 : nil } ?? dates.first ?? startDate
        let agendaEvents = eventDays[date] ?? []

        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            SkyCalendarRangeHeader(
                title: SkyCalendarSupport.weekTitle(startDate: startDate),
                subtitle: "Week begins Monday",
                previousIdentifier: "sky.calendar.week.previous",
                nextIdentifier: "sky.calendar.week.next",
                onPrevious: { onNavigate(-1) },
                onNext: { onNavigate(1) },
                navigationIsAvailable: false
            )

            SkyCalendarWeekRail(
                dates: dates,
                selectedDate: $selectedDate,
                today: today,
                eventDays: eventDays
            )

            if showsEmptyWeekMessage {
                SkyCalendarEmptyMonthNote(text: "No notable events this week")
            }

            if usesWideLayout {
                HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                    SkyCalendarAgenda(
                        selectedDate: date,
                        events: agendaEvents,
                        context: context,
                        identifier: "sky.calendar.agenda",
                        source: source,
                        eventDetailState: eventDetailState
                    )
                    .frame(maxWidth: 660, alignment: .topLeading)

                    SkyCalendarWeekContext(
                        dates: dates,
                        selectedDate: date,
                        eventDays: eventDays,
                        context: context
                    )
                    .frame(maxWidth: 390, alignment: .topLeading)
                }
            } else {
                SkyCalendarAgenda(
                    selectedDate: date,
                    events: agendaEvents,
                    context: context,
                    identifier: "sky.calendar.agenda",
                    source: source,
                    eventDetailState: eventDetailState
                )
            }

            if let context {
                SkyCalendarObservationFooter(context: context, suffix: "Civil week begins Monday")
            }
        }
        .onChange(of: selectedDate) { _, newDate in
            guard let newDate else { return }
            weekStart = SkyCalendarSupport.monday(of: newDate)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.calendar.week.state.loaded")
    }

    private func unavailableSymbol(_ reason: D3FeatureUnavailability) -> String {
        switch reason {
        case .dataSourceNotConnected: "externaldrive.badge.questionmark"
        case .unsupportedMethodology: "exclamationmark.circle"
        case .missingTimeZone: "clock.badge.exclamationmark"
        case .missingLocation: "location.slash"
        case .eventNotFound: "questionmark.circle"
        }
    }

    private func unavailableDetail(_ reason: D3FeatureUnavailability) -> String {
        switch reason {
        case .dataSourceNotConnected: "This source isn’t available yet."
        case .unsupportedMethodology: "This methodology isn’t available yet."
        case .missingTimeZone: "Calendar needs a valid observation timezone."
        case .missingLocation: "This Calendar content requires an observation location."
        case .eventNotFound: "This Calendar content is no longer available."
        }
    }
}

private struct SkyCalendarRangeHeader: View {
    let title: String
    let subtitle: String?
    let previousIdentifier: String
    let nextIdentifier: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let navigationIsAvailable: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: HumaySpacing.medium) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(title)
                    .font(HumayTypography.editorialTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                if let subtitle {
                    Text(subtitle)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: HumaySpacing.small) {
                rangeButton(
                    systemImage: "chevron.left",
                    identifier: previousIdentifier,
                    action: onPrevious
                )
                rangeButton(
                    systemImage: "chevron.right",
                    identifier: nextIdentifier,
                    action: onNext
                )
            }
        }
    }

    private func rangeButton(
        systemImage: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!navigationIsAvailable)
        .opacity(navigationIsAvailable ? 1 : 0.45)
        .accessibilityLabel(systemImage == "chevron.left" ? "Previous range" : "Next range")
        .accessibilityHint(navigationIsAvailable ? "Changes the visible range" : "More Calendar content is not supplied")
        .accessibilityIdentifier(identifier)
    }
}

private struct SkyCalendarCivilGrid: View {
    let monthID: SkyCalendarMonthID
    @Binding var selectedDate: SkyCalendarDate?
    let today: SkyCalendarDate?
    let eventDays: [SkyCalendarDate: [SkyEvent]]
    let usesRegularRows: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var dates: [SkyCalendarDate] {
        SkyCalendarSupport.monthGridDates(for: monthID)
    }

    private var rowHeight: CGFloat {
        if dynamicTypeSize.isAccessibilitySize { return 72 }
        return usesRegularRows ? 50 : HumayMetrics.minimumHitTarget
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(SkyCalendarSupport.weekdaySymbols, id: \.self) { weekday in
                    Text(dynamicTypeSize.isAccessibilitySize ? String(weekday.prefix(1)) : weekday)
                        .font(HumayTypography.calendarWeekday)
                        .tracking(1.1)
                        .foregroundStyle(Color.humayTextSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: dynamicTypeSize.isAccessibilitySize ? 44 : 30)
                        .accessibilityLabel(SkyCalendarSupport.fullWeekdayName(for: weekday))
                }
            }

            Divider().overlay(Color.humayHairline)

            ForEach(Array(dates.chunked(into: 7).enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { date in
                        SkyCalendarDateCell(
                            date: date,
                            monthID: monthID,
                            showsBoundaryLabel: date == dates.first || date.day == 1,
                            selectedDate: selectedDate,
                            today: today,
                            events: eventDays[date] ?? [],
                            rowHeight: rowHeight,
                            action: { selectedDate = date }
                        )
                        .frame(maxWidth: .infinity)
                    }
                }

                if rowIndex < dates.count / 7 - 1 {
                    Divider().overlay(Color.humayHairline)
                }
            }
        }
        .padding(.horizontal, HumaySpacing.small)
        .padding(.vertical, HumaySpacing.small)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface)
                .stroke(Color.humaySeparator)
        }
        .accessibilityElement(children: .contain)
    }
}

private struct SkyCalendarDateCell: View {
    let date: SkyCalendarDate
    let monthID: SkyCalendarMonthID
    let showsBoundaryLabel: Bool
    let selectedDate: SkyCalendarDate?
    let today: SkyCalendarDate?
    let events: [SkyEvent]
    let rowHeight: CGFloat
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isSelected: Bool { selectedDate == date }
    private var isToday: Bool { today == date }
    private var isOutsideMonth: Bool { date.month != monthID.month || date.year != monthID.year }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.humayAccentPrestige)
                        .frame(width: 32, height: 32)
                } else if isToday {
                    Circle()
                        .stroke(Color.humayAccentCelestial, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }

                Text(String(date.day))
                    .font(isToday || isSelected ? HumayTypography.calendarDateSelected : HumayTypography.calendarDate)
                    .monospacedDigit()
                    .foregroundStyle(textColor)

                marker
                    .offset(y: (rowHeight / 2) - 4)

                if isOutsideMonth && showsBoundaryLabel && !dynamicTypeSize.isAccessibilitySize {
                    Text(SkyCalendarSupport.shortMonth(date))
                        .font(HumayTypography.calendarBoundary)
                        .tracking(0.6)
                        .foregroundStyle(Color.humayTextSecondary)
                        .offset(y: -(rowHeight / 2) + 5)
                }
            }
            .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: rowHeight)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("sky.calendar.month.date.\(SkyCalendarSupport.identifier(for: date))")
    }

    @ViewBuilder
    private var marker: some View {
        if events.count == 1, events[0].type == .lunarPhase {
            Image(systemName: "moon.fill")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Color.humayAccentPrestige)
                .accessibilityHidden(true)
        } else if !events.isEmpty {
            Capsule()
                .fill(markerColor)
                .frame(width: events.count > 1 ? 14 : 6, height: 3)
            .accessibilityHidden(true)
        } else {
            Color.clear
                .accessibilityHidden(true)
        }
    }

    private var textColor: Color {
        if isSelected {
            return selectedForeground
        }
        return isOutsideMonth ? Color.humayTextSecondary.opacity(0.62) : Color.humayTextPrimary
    }

    private var markerColor: Color {
        if isSelected { return Color.humayAccentPrestige }
        return Color.humayAccentCelestial
    }

    private var selectedForeground: Color {
        Color.humayInkOnGold
    }

    private var accessibilityLabel: String {
        let weekday = SkyCalendarSupport.fullWeekday(date)
        let month = SkyCalendarSupport.fullMonth(date)
        let outside = isOutsideMonth
            ? ", outside \(SkyCalendarSupport.fullMonth(SkyCalendarSupport.date(year: monthID.year, month: monthID.month, day: 1)))"
            : ""
        let todayText = isToday ? ", today" : ""
        let selectedText = isSelected ? ", selected" : ""
        let eventText = "\(events.count) celestial event\(events.count == 1 ? "" : "s")"
        return "\(weekday), \(month) \(date.day)\(outside)\(todayText)\(selectedText), \(eventText)."
    }
}

private struct SkyCalendarWeekRail: View {
    let dates: [SkyCalendarDate]
    @Binding var selectedDate: SkyCalendarDate?
    let today: SkyCalendarDate?
    let eventDays: [SkyCalendarDate: [SkyEvent]]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        weekCells(fixedWidth: 88)
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                HStack(spacing: 0) {
                    weekCells(fixedWidth: nil)
                }
            }
        }
        .padding(.horizontal, HumaySpacing.small)
        .padding(.vertical, HumaySpacing.small)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface)
                .stroke(Color.humaySeparator)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.calendar.week.rail")
    }

    @ViewBuilder
    private func weekCells(fixedWidth: CGFloat?) -> some View {
        ForEach(dates, id: \.self) { date in
            SkyCalendarWeekDateCell(
                date: date,
                selectedDate: selectedDate,
                today: today,
                events: eventDays[date] ?? [],
                action: { selectedDate = date }
            )
            .frame(width: fixedWidth)
            .frame(maxWidth: fixedWidth == nil ? .infinity : nil)
        }
    }
}

private struct SkyCalendarWeekDateCell: View {
    let date: SkyCalendarDate
    let selectedDate: SkyCalendarDate?
    let today: SkyCalendarDate?
    let events: [SkyEvent]
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isSelected: Bool { selectedDate == date }
    private var isToday: Bool { today == date }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(SkyCalendarSupport.shortWeekday(date))
                    .font(HumayTypography.calendarWeekday)
                    .tracking(0.9)
                    .foregroundStyle(Color.humayTextSecondary)

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.humayAccentPrestige)
                    } else if isToday {
                        Circle()
                            .stroke(Color.humayAccentCelestial, lineWidth: 2)
                    }

                    Text(String(date.day))
                        .font(HumayTypography.calendarDate)
                        .monospacedDigit()
                        .foregroundStyle(isSelected ? selectedForeground : Color.humayTextPrimary)
                }
                .frame(width: 40, height: 40)

                marker
                    .frame(height: 6)
            }
            .frame(
                minWidth: HumayMetrics.minimumHitTarget,
                minHeight: dynamicTypeSize.isAccessibilitySize ? 96 : 60
            )
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("sky.calendar.week.date.\(SkyCalendarSupport.identifier(for: date))")
    }

    @ViewBuilder
    private var marker: some View {
        if events.count == 1, events[0].type == .lunarPhase {
            Image(systemName: "moon.fill")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Color.humayAccentPrestige)
                .accessibilityHidden(true)
        } else if !events.isEmpty {
            Capsule()
                .fill(isSelected ? Color.humayAccentPrestige : Color.humayAccentCelestial)
                .frame(width: events.count > 1 ? 14 : 6, height: 3)
            .accessibilityHidden(true)
        } else {
            Color.clear.frame(width: 5, height: 5)
                .accessibilityHidden(true)
        }
    }

    private var selectedForeground: Color {
        Color.humayInkOnGold
    }

    private var accessibilityLabel: String {
        let todayText = isToday ? ", today" : ""
        let selectedText = isSelected ? ", selected" : ""
        let eventText = "\(events.count) celestial event\(events.count == 1 ? "" : "s")"
        return "\(SkyCalendarSupport.fullWeekday(date)), \(SkyCalendarSupport.fullMonth(date)) \(date.day)\(todayText)\(selectedText), \(eventText)."
    }
}

private struct SkyCalendarAgenda: View {
    let selectedDate: SkyCalendarDate
    let events: [SkyEvent]
    let context: SkyObservationContext?
    let identifier: String
    let source: D3ContentSource
    let eventDetailState: (SkyEventID) -> SkyEventDetailFeatureState

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            SkySelectedDateHeader(date: selectedDate, eventCount: events.count)

            Divider()
                .overlay(Color.humaySeparator)

            if events.isEmpty {
                SkyCalendarQuietDay()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        NavigationLink {
                            SkyEventDetailView(
                                source: source,
                                state: eventDetailState(event.id),
                                context: context
                            )
                        } label: {
                            SkyEventRow(
                                event: event,
                                context: context,
                                timingPresentation: .calendar
                            )
                            .padding(.vertical, HumaySpacing.small)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens Event Detail")
                        .accessibilityIdentifier("sky.calendar.event.\(event.id.rawValue)")

                        if index < events.count - 1 {
                            Divider().overlay(Color.humaySeparator)
                        }
                    }
                }
            }

            Divider()
                .overlay(Color.humaySeparator)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(events.isEmpty ? "sky.calendar.agenda.quiet" : identifier)
    }
}

private struct SkyCalendarQuietDay: View {
    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: "minus")
                .font(.body.weight(.medium))
                .foregroundStyle(Color.humayAccentPrestige)
                .frame(
                    width: HumayMetrics.minimumHitTarget,
                    height: HumayMetrics.minimumHitTarget
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text("Quiet sky this day")
                    .font(HumayTypography.bodyEmphasized)
                Text("No notable events are supplied.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HumaySpacing.medium)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("sky.calendar.agenda.quiet")
    }
}

private struct SkyCalendarWeekContext: View {
    let dates: [SkyCalendarDate]
    let selectedDate: SkyCalendarDate
    let eventDays: [SkyCalendarDate: [SkyEvent]]
    let context: SkyObservationContext?

    private var contextDates: [SkyCalendarDate] {
        var result = dates.filter { !(eventDays[$0] ?? []).isEmpty }
        if let last = dates.last, !result.contains(last) {
            result.append(last)
        }
        return result.sorted().prefix(3).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            Text("Across the week")
                .font(HumayTypography.editorialTitle)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(Array(contextDates.enumerated()), id: \.element) { index, date in
                    contextRow(for: date)
                        .padding(.vertical, HumaySpacing.medium)

                    if index < contextDates.count - 1 {
                        Divider()
                            .overlay(Color.humaySeparator)
                    }
                }
            }
            .overlay(alignment: .top) {
                Divider()
                    .overlay(Color.humaySeparator)
            }
            .overlay(alignment: .bottom) {
                Divider()
                    .overlay(Color.humaySeparator)
            }
        }
        .accessibilityIdentifier("sky.calendar.week.context")
    }

    @ViewBuilder
    private func contextRow(for date: SkyCalendarDate) -> some View {
        let events = eventDays[date] ?? []
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: events.first?.style.symbol ?? "minus")
                .font(.body.weight(.regular))
                .foregroundStyle(events.first?.style.accent ?? Color.humayTextSecondary)
                .frame(
                    width: HumayMetrics.minimumHitTarget,
                    height: HumayMetrics.minimumHitTarget
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(SkyCalendarSupport.contextDateTitle(date))
                    .font(HumayTypography.utility)
                    .tracking(1.1)
                    .foregroundStyle(events.isEmpty ? Color.humayTextSecondary : Color.humayAccentPrestige)

                if events.isEmpty {
                    Text("Quiet sky this day")
                        .font(HumayTypography.bodyEmphasized)
                    Text("Navigation remains available.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                } else if events.count == 1, let event = events.first {
                    Text(event.title)
                        .font(HumayTypography.bodyEmphasized)
                        .fixedSize(horizontal: false, vertical: true)
                    if let context {
                        Text(SkyEventTimingFormatter.calendarText(for: event.timing, context: context))
                            .font(HumayTypography.supporting)
                            .monospacedDigit()
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                } else {
                    Text("\(events.count) celestial events")
                        .font(HumayTypography.bodyEmphasized)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(contextAccessibilityLabel(date: date, events: events))
    }

    private func contextAccessibilityLabel(date: SkyCalendarDate, events: [SkyEvent]) -> String {
        if events.isEmpty {
            return "\(SkyCalendarSupport.fullWeekday(date)), \(SkyCalendarSupport.fullMonth(date)) \(date.day), quiet sky this day."
        }
        return "\(SkyCalendarSupport.fullWeekday(date)), \(SkyCalendarSupport.fullMonth(date)) \(date.day), \(events.count) celestial event\(events.count == 1 ? "" : "s")."
    }
}

private struct SkyCalendarObservationFooter: View {
    let context: SkyObservationContext
    var suffix: String = "Civil dates"

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Divider().overlay(Color.humaySeparator)
            SkyObservationMetadata(
                context: context,
                note: suffix
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.calendar.observation-context")
    }
}

private struct SkyCalendarEmptyMonthNote: View {
    let text: String

    init(text: String = "No notable events this month") {
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            Text(text)
                .font(HumayTypography.bodyEmphasized)
            Text("Civil navigation remains available.")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
        }
        .padding(.horizontal, HumaySpacing.small)
        .accessibilityIdentifier("sky.calendar.empty-content-note")
    }
}

enum SkyCalendarSupport {
    static let weekdaySymbols = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    static func fullWeekdayName(for symbol: String) -> String {
        switch symbol {
        case "MON": "Monday"
        case "TUE": "Tuesday"
        case "WED": "Wednesday"
        case "THU": "Thursday"
        case "FRI": "Friday"
        case "SAT": "Saturday"
        case "SUN": "Sunday"
        default: symbol
        }
    }

    static func date(year: Int, month: Int, day: Int) -> SkyCalendarDate {
        guard let date = try? SkyCalendarDate(year: year, month: month, day: day) else {
            preconditionFailure("Invalid Calendar fixture date")
        }
        return date
    }

    static func foundationDate(_ date: SkyCalendarDate) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar.date(from: DateComponents(year: date.year, month: date.month, day: date.day))
    }

    static func calendarDate(_ date: Date) -> SkyCalendarDate? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else {
            return nil
        }
        return try? SkyCalendarDate(year: year, month: month, day: day)
    }

    static func adding(days: Int, to date: SkyCalendarDate) -> SkyCalendarDate? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        guard let foundationDate = foundationDate(date),
              let shifted = calendar.date(byAdding: .day, value: days, to: foundationDate) else {
            return nil
        }
        return calendarDate(shifted)
    }

    static func monday(of date: SkyCalendarDate) -> SkyCalendarDate? {
        guard let foundationDate = foundationDate(date) else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let weekday = calendar.component(.weekday, from: foundationDate)
        let mondayOffset = (weekday + 5) % 7
        return adding(days: -mondayOffset, to: date)
    }

    static func monthGridDates(for month: SkyCalendarMonthID) -> [SkyCalendarDate] {
        let first = date(year: month.year, month: month.month, day: 1)
        guard let firstFoundationDate = foundationDate(first) else { return [] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let weekday = calendar.component(.weekday, from: firstFoundationDate)
        let leadingDays = (weekday + 5) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstFoundationDate)?.count ?? 30
        let totalDays = leadingDays + daysInMonth
        let gridCount = totalDays <= 35 ? 35 : 42

        return (0..<gridCount).compactMap { offset in
            adding(days: offset - leadingDays, to: first)
        }
    }

    static func weekDates(starting startDate: SkyCalendarDate) -> [SkyCalendarDate] {
        (0..<7).compactMap { adding(days: $0, to: startDate) }
    }

    static func currentDate() -> SkyCalendarDate? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = components.year, let month = components.month, let day = components.day else {
            return nil
        }
        return try? SkyCalendarDate(year: year, month: month, day: day)
    }

    static func monthTitle(_ month: SkyCalendarMonthID) -> String {
        "\(fullMonth(date(year: month.year, month: month.month, day: 1))) \(month.year)"
    }

    static func weekTitle(startDate: SkyCalendarDate) -> String {
        guard let endDate = adding(days: 6, to: startDate) else { return fullMonth(startDate) }
        if startDate.year != endDate.year {
            return "\(startDate.day) \(shortMonth(startDate)) \u{2013} \(endDate.day) \(shortMonth(endDate)) \(endDate.year)"
        }
        if startDate.month != endDate.month {
            return "\(startDate.day) \(shortMonth(startDate)) \u{2013} \(endDate.day) \(shortMonth(endDate)) \(endDate.year)"
        }
        return "\(startDate.day)\u{2013}\(endDate.day) \(fullMonth(startDate)) \(startDate.year)"
    }

    static func selectedDateTitle(_ date: SkyCalendarDate) -> String {
        "\(fullWeekday(date)) · \(date.day) \(fullMonth(date))"
    }

    static func contextDateTitle(_ date: SkyCalendarDate) -> String {
        "\(shortWeekday(date)) · \(date.day) \(shortMonth(date))"
    }

    static func fullMonth(_ date: SkyCalendarDate) -> String {
        formatter("MMMM").string(from: foundationDate(date) ?? .distantPast)
    }

    static func shortMonth(_ date: SkyCalendarDate) -> String {
        formatter("MMM").string(from: foundationDate(date) ?? .distantPast).uppercased()
    }

    static func fullWeekday(_ date: SkyCalendarDate) -> String {
        formatter("EEEE").string(from: foundationDate(date) ?? .distantPast)
    }

    static func shortWeekday(_ date: SkyCalendarDate) -> String {
        formatter("EEE").string(from: foundationDate(date) ?? .distantPast).uppercased()
    }

    static func identifier(for date: SkyCalendarDate) -> String {
        String(format: "%04d-%02d-%02d", date.year, date.month, date.day)
    }

    private static func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .gmt
        formatter.dateFormat = format
        return formatter
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { start in
            Array(self[start..<Swift.min(start + size, count)])
        }
    }
}
