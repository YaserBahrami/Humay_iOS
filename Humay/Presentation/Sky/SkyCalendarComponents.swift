import SwiftUI

struct SkyCalendarMonthView: View {
    let state: SkyCalendarMonthFeatureState
    @Binding var selectedDate: SkyCalendarDate?
    @Binding var selection: SkyCalendarMonthID?
    let today: SkyCalendarDate?
    let usesWideLayout: Bool
    let onNavigate: (Int) -> Void

    var body: some View {
        Group {
            switch state {
            case .loading:
                SkyCalendarLoadingView(
                    title: "Loading Calendar…",
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
                SkyCalendarStateMessage(
                    symbol: unavailableSymbol(reason),
                    title: "Calendar unavailable",
                    detail: unavailableDetail(reason),
                    accent: .lavender,
                    identifier: "sky.calendar.month.state.unavailable"
                )

            case .offline(_, let cached):
                if let cached {
                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        SkyCalendarOfflineNotice()
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
                    SkyCalendarStateMessage(
                        symbol: "wifi.slash",
                        title: "No saved Calendar",
                        detail: "Reconnect to load these dates.",
                        accent: .solarGold,
                        identifier: "sky.calendar.month.state.offline.no-cache"
                    )
                }

            case .failed:
                SkyCalendarStateMessage(
                    symbol: "exclamationmark.triangle",
                    title: "Calendar couldn’t load",
                    detail: "The source could not be loaded.",
                    accent: .coral,
                    identifier: "sky.calendar.month.state.failed"
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
                            eventDays: eventDays
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
                        identifier: "sky.calendar.agenda"
                    )
                    .frame(maxWidth: 390, alignment: .topLeading)
                }
            } else {
                SkyCalendarCivilGrid(
                    monthID: monthID,
                    selectedDate: $selectedDate,
                    today: today,
                    eventDays: eventDays
                )

                if showsEmptyMonthMessage {
                    SkyCalendarEmptyMonthNote()
                }

                SkyCalendarAgenda(
                    selectedDate: date,
                    events: agendaEvents,
                    context: context,
                    identifier: "sky.calendar.agenda"
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
    let state: SkyCalendarWeekFeatureState
    @Binding var selectedDate: SkyCalendarDate?
    @Binding var weekStart: SkyCalendarDate?
    let today: SkyCalendarDate?
    let usesWideLayout: Bool
    let onNavigate: (Int) -> Void

    var body: some View {
        Group {
            switch state {
            case .loading:
                SkyCalendarLoadingView(
                    title: "Loading Calendar…",
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
                SkyCalendarStateMessage(
                    symbol: unavailableSymbol(reason),
                    title: "Calendar unavailable",
                    detail: unavailableDetail(reason),
                    accent: .lavender,
                    identifier: "sky.calendar.week.state.unavailable"
                )

            case .offline(_, let cached):
                if let cached {
                    VStack(alignment: .leading, spacing: HumaySpacing.large) {
                        SkyCalendarOfflineNotice()
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
                    SkyCalendarStateMessage(
                        symbol: "wifi.slash",
                        title: "No saved Calendar",
                        detail: "Reconnect to load these dates.",
                        accent: .solarGold,
                        identifier: "sky.calendar.week.state.offline.no-cache"
                    )
                }

            case .failed:
                SkyCalendarStateMessage(
                    symbol: "exclamationmark.triangle",
                    title: "Calendar couldn’t load",
                    detail: "The source could not be loaded.",
                    accent: .coral,
                    identifier: "sky.calendar.week.state.failed"
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
                        identifier: "sky.calendar.agenda"
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
                    identifier: "sky.calendar.agenda"
                )

                SkyCalendarWeekContext(
                    dates: dates,
                    selectedDate: date,
                    eventDays: eventDays,
                    context: context
                )
            }

            if let context {
                SkyCalendarObservationFooter(context: context, suffix: "civil week begins Monday")
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
                .font(.title3.weight(.semibold))
                .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                .background(Color.humayRaisedSurface, in: Circle())
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

    private var dates: [SkyCalendarDate] {
        SkyCalendarSupport.monthGridDates(for: monthID)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(SkyCalendarSupport.weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption.weight(.bold))
                        .tracking(1.1)
                        .foregroundStyle(Color.humayTextSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: HumayMetrics.minimumHitTarget)
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
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline)
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
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var isSelected: Bool { selectedDate == date }
    private var isToday: Bool { today == date }
    private var isOutsideMonth: Bool { date.month != monthID.month || date.year != monthID.year }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if isOutsideMonth && showsBoundaryLabel {
                    Text(SkyCalendarSupport.shortMonth(date))
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(Color.humayTextSecondary)
                } else {
                    Color.clear.frame(height: 12)
                }

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.humayCoral)
                            .frame(width: 40, height: 40)
                    } else if isToday {
                        Circle()
                            .stroke(Color.humayCoral, lineWidth: 2)
                            .frame(width: 40, height: 40)
                            .overlay(alignment: .top) {
                                Capsule()
                                    .fill(Color.humayCoral)
                                    .frame(width: 16, height: 3)
                                    .offset(y: -2)
                            }
                    }

                    Text(String(date.day))
                        .font(.body.weight(isToday || isSelected ? .bold : .semibold))
                        .italic(isOutsideMonth)
                        .foregroundStyle(textColor)
                }
                .frame(width: 44, height: 40)

                marker
                    .frame(height: 14)

                Text(isToday ? "TODAY" : " ")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Color.humayCoral)
                    .frame(height: 10)
                    .opacity(isToday ? 1 : 0)
            }
            .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: 64)
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
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.humaySolarGold)
                .accessibilityHidden(true)
        } else if !events.isEmpty {
            HStack(spacing: 5) {
                Circle()
                    .fill(markerColor)
                    .frame(width: 8, height: 8)
                if events.count > 1 {
                    Text(String(events.count))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(isSelected ? Color.humayTextPrimary : Color.humayTextSecondary)
                }
            }
            .accessibilityHidden(true)
        } else {
            Color.clear
                .accessibilityHidden(true)
        }
    }

    private var textColor: Color {
        if isSelected {
            return colorScheme == .light ? Color.humayGround : Color.humayTextPrimary
        }
        return isOutsideMonth ? Color.humayTextSecondary.opacity(0.62) : Color.humayTextPrimary
    }

    private var markerColor: Color {
        if events.contains(where: { $0.type == .planetaryAspect }) {
            return Color.humayLavender
        }
        if events.contains(where: { $0.system == .astrological(.vedic) }) {
            return Color.humayCelestialBlue
        }
        return Color.humayCoral
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

    var body: some View {
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                SkyCalendarWeekDateCell(
                    date: date,
                    selectedDate: selectedDate,
                    today: today,
                    events: eventDays[date] ?? [],
                    action: { selectedDate = date }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, HumaySpacing.small)
        .padding(.vertical, HumaySpacing.small)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sky.calendar.week.rail")
    }
}

private struct SkyCalendarWeekDateCell: View {
    let date: SkyCalendarDate
    let selectedDate: SkyCalendarDate?
    let today: SkyCalendarDate?
    let events: [SkyEvent]
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var isSelected: Bool { selectedDate == date }
    private var isToday: Bool { today == date }

    var body: some View {
        Button(action: action) {
            VStack(spacing: HumaySpacing.small) {
                Text(SkyCalendarSupport.shortWeekday(date))
                    .font(.caption.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(isSelected ? selectedForeground : Color.humayTextSecondary)

                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: HumayRadius.feature)
                            .fill(Color.humayCoral)
                    } else if isToday {
                        RoundedRectangle(cornerRadius: HumayRadius.feature)
                            .stroke(Color.humayCoral, lineWidth: 2)
                            .overlay(alignment: .top) {
                                Capsule()
                                    .fill(Color.humayCoral)
                                    .frame(width: 18, height: 3)
                                    .offset(y: -2)
                            }
                    }

                    VStack(spacing: HumaySpacing.small) {
                        Text(String(date.day))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(isSelected ? selectedForeground : Color.humayTextPrimary)

                        marker
                    }
                }
                .frame(minWidth: 44, minHeight: 92)

                Text(isToday ? "TODAY" : " ")
                    .font(.caption2.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(Color.humayCoral)
                    .frame(height: 10)
                    .opacity(isToday ? 1 : 0)
            }
            .frame(minWidth: HumayMetrics.minimumHitTarget, minHeight: 136)
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
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? selectedForeground : Color.humaySolarGold)
                .accessibilityHidden(true)
        } else if !events.isEmpty {
            HStack(spacing: 5) {
                Circle()
                    .fill(isSelected ? selectedForeground : Color.humayLavender)
                    .frame(width: 8, height: 8)
                if events.count > 1 {
                    Text(String(events.count))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(isSelected ? selectedForeground : Color.humayTextSecondary)
                }
            }
            .accessibilityHidden(true)
        } else {
            Color.clear.frame(height: 8)
                .accessibilityHidden(true)
        }
    }

    private var selectedForeground: Color {
        colorScheme == .light ? Color.humayGround : Color.humayTextPrimary
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

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text("Selected date")
                        .font(.caption.weight(.bold))
                        .tracking(1.1)
                        .foregroundStyle(Color.humayCoral)

                    Text(SkyCalendarSupport.selectedDateTitle(selectedDate))
                        .font(HumayTypography.editorialTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                }
                Spacer(minLength: HumaySpacing.small)
                Text(eventCount)
                    .font(HumayTypography.utility)
                    .foregroundStyle(Color.humayTextSecondary)
                    .textCase(.uppercase)
            }

            if events.isEmpty {
                SkyCalendarQuietDay()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        SkyCalendarEventRow(event: event, context: context)
                            .padding(.vertical, HumaySpacing.medium)

                        if index < events.count - 1 {
                            Divider().overlay(Color.humayHairline)
                        }
                    }
                }
                .padding(.horizontal, HumaySpacing.large)
                .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
                .overlay {
                    RoundedRectangle(cornerRadius: HumayRadius.feature)
                        .stroke(Color.humayHairline)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(events.isEmpty ? "sky.calendar.agenda.quiet" : identifier)
    }

    private var eventCount: String {
        "\(events.count) event\(events.count == 1 ? "" : "s")"
    }
}

private struct SkyCalendarEventRow: View {
    let event: SkyEvent
    let context: SkyObservationContext?

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            SkyCalendarEventGlyph(event: event)
                .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(event.title)
                    .font(HumayTypography.bodyEmphasized)
                    .fixedSize(horizontal: false, vertical: true)

                if let summary = event.summary {
                    Text(summary)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.small) {
                        timingText
                        Spacer(minLength: HumaySpacing.small)
                        methodologyText
                    }
                    VStack(alignment: .leading, spacing: HumaySpacing.small) {
                        timingText
                        methodologyText
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(event.title), \(SkyMethodologyFormatter.label(for: event.system))")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("sky.calendar.event.\(event.id.rawValue)")
    }

    private var timingText: some View {
        Text(timing)
            .font(HumayTypography.technical.weight(.semibold))
            .foregroundStyle(Color.humayTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var methodologyText: some View {
        HStack(spacing: HumaySpacing.extraSmall) {
            Circle()
                .fill(event.style.accent)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
            Text(SkyMethodologyFormatter.label(for: event.system))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.humayTextSecondary)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    private var timing: String {
        guard let context else { return "Timing unavailable" }
        return SkyEventTimingFormatter.calendarText(for: event.timing, context: context)
    }

    private var accessibilityValue: String {
        guard let context else { return "Timing unavailable" }
        return SkyEventTimingFormatter.calendarAccessibilityText(for: event.timing, context: context)
    }
}

private struct SkyCalendarEventGlyph: View {
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

private struct SkyCalendarQuietDay: View {
    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Image(systemName: "moon.stars")
                .font(.title2.weight(.light))
                .foregroundStyle(Color.humaySolarGold)
                .accessibilityHidden(true)
            Text("Quiet sky this day")
                .font(HumayTypography.cardTitle)
            Text("No notable events are supplied.")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HumaySpacing.extraLarge)
        .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface)
                .stroke(Color.humayHairline)
        }
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

            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                ForEach(contextDates, id: \.self) { date in
                    contextRow(for: date)
                }
            }
            .padding(.leading, HumaySpacing.large)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Color.humayHairline)
                    .frame(width: 2)
                    .padding(.vertical, HumaySpacing.small)
            }
        }
        .accessibilityIdentifier("sky.calendar.week.context")
    }

    @ViewBuilder
    private func contextRow(for date: SkyCalendarDate) -> some View {
        let events = eventDays[date] ?? []
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Circle()
                .fill(events.isEmpty ? Color.clear : (events.first?.style.accent ?? Color.humaySage))
                .frame(width: 14, height: 14)
                .overlay {
                    if events.isEmpty {
                        Circle().stroke(Color.humaySage, lineWidth: 2)
                    }
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text(SkyCalendarSupport.contextDateTitle(date))
                    .font(.caption.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(events.isEmpty ? Color.humaySage : Color.humayCoral)

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
                            .font(HumayTypography.technical)
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
    var suffix: String = "civil dates · sample not calculated"

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Divider().overlay(Color.humayHairline)
            Text("\(context.timeZoneIdentifier) · \(suffix)")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
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

struct SkyCalendarLoadingView: View {
    let title: String
    let identifier: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            skeleton(width: 220, height: 30)
            skeleton(width: 180, height: 14)

            VStack(spacing: HumaySpacing.medium) {
                ForEach(0..<6, id: \.self) { _ in
                    HStack(spacing: HumaySpacing.medium) {
                        ForEach(0..<7, id: \.self) { _ in
                            Circle()
                                .fill(Color.humayHairline.opacity(0.62))
                                .frame(width: 10, height: 10)
                                .frame(maxWidth: .infinity, minHeight: HumayMetrics.minimumHitTarget)
                        }
                    }
                }
            }
            .padding(HumaySpacing.large)
            .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.feature)
                    .stroke(Color.humayHairline)
            }

            HStack(spacing: HumaySpacing.medium) {
                if reduceMotion {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(Color.humayLavender)
                        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                } else {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayLavender)
                        .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                }
                Text(title)
                    .font(HumayTypography.bodyEmphasized)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier)
    }

    private func skeleton(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: HumayRadius.compact)
            .fill(Color.humayHairline.opacity(0.62))
            .frame(maxWidth: width == .infinity ? .infinity : width, minHeight: height, maxHeight: height)
            .redacted(reason: .placeholder)
    }
}

private struct SkyCalendarStateMessage: View {
    let symbol: String
    let title: String
    let detail: String
    let accent: HumayColorRole
    let identifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            Image(systemName: symbol)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(accent.color)
                .frame(width: 56, height: 56)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text(title)
                    .font(HumayTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240, alignment: .center)
        .padding(HumaySpacing.extraLarge)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

private struct SkyCalendarOfflineNotice: View {
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Text("Offline · saved Calendar")
                    .font(HumayTypography.bodyEmphasized)
                Text("Showing saved civil dates and event metadata.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } icon: {
            Image(systemName: "wifi.slash")
                .foregroundStyle(Color.humaySolarGold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HumaySpacing.large)
        .background(Color.humayRaisedSurface, in: RoundedRectangle(cornerRadius: HumayRadius.compact))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.compact)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("sky.calendar.offline.cached.notice")
    }
}

enum SkyCalendarSupport {
    static let weekdaySymbols = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

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
