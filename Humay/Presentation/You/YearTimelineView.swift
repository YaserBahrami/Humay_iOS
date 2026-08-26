import SwiftUI

/// The rolling one-year mood timeline: an explorable, scrubbable year of
/// entertainment data. Playful and exploratory by design — never analytics-flavored.
struct YearTimelineSection: View {
    let profileID: UUID
    let birth: BirthDetails

    @Environment(\.calendar) private var calendar
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shareActivity: ShareActivity?

    @State private var forecast: YearlyForecast?
    @State private var anchor: ForecastAnchor?
    @State private var dimension: MoodDimension = .overall
    @State private var selectedOffset = 0

    private var todayOffset: Int {
        guard let anchor else { return 0 }
        return max(0, min(YearlyForecast.dayCount - 1, anchor.dayOffset(for: .now, calendar: calendar) ?? 0))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayKickerLabel(text: "Your year")

            Text("Three hundred sixty-five days of questionable guidance.")
                .font(HumayTypography.cardTitle)
                .fixedSize(horizontal: false, vertical: true)

            if let forecast, let anchor {
                dimensionChips

                GeometryReader { proxy in
                    TimelineCanvas(
                        values: forecast.days.map { Double($0.scores[dimension]) },
                        selectedIndex: selectedOffset,
                        accent: Color.humay(accent(for: dimension))
                    )
                    .onAppear { canvasWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { _, newWidth in
                        canvasWidth = newWidth
                    }
                }
                .frame(height: 180)
                .gesture(scrubGesture)

                monthLabels

                quickJumps

                dayCard(forecast, anchor: anchor)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .task { load() }
            }
        }
        .sheet(item: $shareActivity) { activity in
            ShareSheet(activity: activity)
        }
        .accessibilityElement(children: .contain)
    }

    private func load() {
        anchor = ForecastAnchor(date: .now, calendar: calendar)
        forecast = HumayContentEngine.yearlyForecast(profileID: profileID, birth: birth)
        selectedOffset = todayOffset
    }

    // MARK: - Controls

    private var dimensionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HumaySpacing.small) {
                ForEach(MoodDimension.allCases) { candidate in
                    chip(candidate)
                }
            }
            .padding(.horizontal, 2)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Forecast dimension")
    }

    private func chip(_ candidate: MoodDimension) -> some View {
        let isSelected = candidate == dimension
        return Button {
            withAnimation(reduceMotion ? nil : HumayMotion.snappy) {
                dimension = candidate
            }
            HumayHaptics.tap()
        } label: {
            Label(candidate.displayName, systemImage: candidate.symbol)
                .font(HumayTypography.supportingEmphasized)
                .padding(.horizontal, HumaySpacing.medium)
                .padding(.vertical, 8)
                .background(isSelected ? Color.humay(accent(for: candidate)).opacity(0.22) : Color.humayRaisedSurface, in: Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? Color.humay(accent(for: candidate)) : Color.humayHairline))
                .foregroundStyle(isSelected ? Color.humayTextPrimary : Color.humayTextSecondary)
        }
        .buttonStyle(.humayPressable)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var quickJumps: some View {
        HStack(spacing: HumaySpacing.small) {
            jumpChip("Best day", symbol: "crown") { jumpToExtreme(maximizing: true, dimension: .overall) }
            jumpChip("Chaos peak", symbol: "tornado") { jumpToExtreme(maximizing: true, dimension: .chaos) }
            jumpChip("Peak romance", symbol: "heart") { jumpToExtreme(maximizing: true, dimension: .romance) }
            jumpChip("Today", symbol: "location.fill") { moveTo(todayOffset) }
        }
    }

    private func jumpChip(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(HumayTypography.caption.weight(.semibold))
                .padding(.horizontal, HumaySpacing.medium)
                .padding(.vertical, 8)
                .background(Color.humayRaisedSurface, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.humayHairline))
        }
        .buttonStyle(.humayPressable)
    }

    // MARK: - Scrubbing

    private var scrubGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let width = canvasWidth, width > 0 else { return }
                let fraction = min(max(value.location.x / width, 0), 1)
                let offset = Int((fraction * Double(YearlyForecast.dayCount - 1)).rounded())
                if offset != selectedOffset {
                    moveTo(offset)
                }
            }
    }

    @State private var canvasWidth: CGFloat?

    /// Moves the scrubber with a light haptic tick. Cheap enough to call per-day.
    private func moveTo(_ offset: Int) {
        let clamped = max(0, min(YearlyForecast.dayCount - 1, offset))
        if clamped != selectedOffset {
            selectedOffset = clamped
            HumayHaptics.tap()
        }
    }

    private func jumpToExtreme(maximizing: Bool, dimension target: MoodDimension) {
        guard let forecast else { return }
        let days = maximizing
            ? forecast.topDays(in: target, count: 1)
            : forecast.bottomDays(in: target, count: 1)
        if let day = days.first {
            withAnimation(reduceMotion ? nil : HumayMotion.smooth) {
                selectedOffset = day.dayOffset
                dimension = target
            }
            HumayHaptics.thump()
        }
    }

    // MARK: - Day detail

    private func dayCard(_ forecast: YearlyForecast, anchor: ForecastAnchor) -> some View {
        Group {
            if let day = forecast.mood(atDayOffset: selectedOffset) {
                VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(anchor.date(forDayOffset: day.dayOffset)?
                            .formatted(.dateTime.weekday(.wide).day().month().year()) ?? "")
                            .font(HumayTypography.bodyEmphasized)
                        Spacer()
                        Text(day.dayOffset == todayOffset ? "TODAY" : "\(abs(day.dayOffset - todayOffset))d away")
                            .font(HumayTypography.caption.weight(.bold))
                            .tracking(0.8)
                            .foregroundStyle(Color.humayCoral)
                    }

                    if let note = day.note {
                        Text(note)
                            .font(HumayTypography.bodyEmphasized)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    scoreRow("Overall", value: day.scores[.overall], tint: .sage)
                    scoreRow(dimension.displayName, value: day.scores[dimension], tint: accent(for: dimension))
                    scoreRow("Chaos", value: day.scores[.chaos], tint: .coral)

                    Button {
                        shareActivity = ShareActivity(kind: .dayCard(anchor: anchor, mood: day))
                    } label: {
                        Label("Share this day", systemImage: "square.and.arrow.up")
                            .font(HumayTypography.supportingEmphasized)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.humaySecondary)
                }
                .padding(HumaySpacing.large)
                .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                        .strokeBorder(Color.humayHairline)
                }
                .animation(reduceMotion ? nil : HumayMotion.snappy, value: selectedOffset)
            }
        }
    }

    private func scoreRow(_ label: String, value: Int, tint: FeedAccent) -> some View {
        HStack {
            Text(label)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
            Spacer()
            Text("\(value)%")
                .font(HumayTypography.meterValue.monospacedDigit())
                .foregroundStyle(Color.humay(tint))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value) percent")
    }

    private var monthLabels: some View {
        HStack {
            ForEach(0..<12, id: \.self) { index in
                Text(monthInitial(index))
                    .font(HumayTypography.micro.weight(.bold))
                    .foregroundStyle(Color.humayTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    private func monthInitial(_ index: Int) -> String {
        guard let anchor else { return "" }
        let name = anchor.monthName(index: index, calendar: calendar)
        return String(name.prefix(1))
    }

    private func accent(for dimension: MoodDimension) -> FeedAccent {
        switch dimension {
        case .overall: .sage
        case .romance: .coral
        case .social: .lavender
        case .career: .gold
        case .energy: .gold
        case .confidence: .sage
        case .patience: .gold
        case .chaos: .coral
        }
    }
}

// MARK: - Canvas

/// Fast, GPU-friendly curve renderer. Reads only plain values so it stays cheap
/// during scrubbing.
struct TimelineCanvas: View {
    let values: [Double]
    let selectedIndex: Int
    let accent: Color

    var body: some View {
        Canvas { context, size in
            guard !values.isEmpty else { return }

            let stepX = size.width / CGFloat(values.count - 1)
            let padding: CGFloat = 10
            let usableHeight = size.height - padding * 2

            func point(at index: Int) -> CGPoint {
                CGPoint(
                    x: CGFloat(index) * stepX,
                    y: padding + usableHeight * (1 - CGFloat(min(max(values[index], 0), 100)) / 100)
                )
            }

            // Area fill
            var fill = Path()
            fill.move(to: CGPoint(x: 0, y: size.height))
            for index in values.indices {
                fill.addLine(to: point(at: index))
            }
            fill.addLine(to: CGPoint(x: size.width, y: size.height))
            fill.closeSubpath()
            context.fill(fill, with: .linearGradient(
                Gradient(colors: [accent.opacity(0.30), accent.opacity(0.02)]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: size.height)
            ))

            // Curve
            var curve = Path()
            curve.move(to: point(at: 0))
            for index in values.indices.dropFirst() {
                curve.addLine(to: point(at: index))
            }
            context.stroke(curve, with: .color(accent), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

            // Selected marker
            let selected = point(at: selectedIndex)
            context.fill(
                Path(ellipseIn: CGRect(x: selected.x - 5, y: selected.y - 5, width: 10, height: 10)),
                with: .color(accent)
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: selected.x - 9, y: selected.y - 9, width: 18, height: 18)),
                with: .color(accent.opacity(0.4)),
                lineWidth: 2
            )
        }
        .background(Color.humaySurface.opacity(0.6), in: RoundedRectangle(cornerRadius: HumayRadius.compact, style: .continuous))
        .contentShape(Rectangle())
        .accessibilityLabel("Year timeline for the selected dimension")
        .accessibilityValue("Day \(selectedIndex + 1) of \(values.count)")
        .accessibilityHint("Drag to explore days")
    }
}

extension TimelineCanvas {
    fileprivate var canvasWidthBindingPassthrough: Void {}
}
