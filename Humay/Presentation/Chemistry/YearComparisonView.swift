import SwiftUI

/// Two-person year comparison: two curves on one canvas, deterministic math,
/// playful editorial presentation. Validates the intelligence data model.
struct YearComparisonView: View {
    let firstSubject: ForecastSubject
    let secondSubject: ForecastSubject

    @Environment(ForecastStore.self) private var forecasts
    @Environment(\.calendar) private var calendar
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var dimension: MoodDimension = .overall
    @State private var selectedOffset = 0
    @State private var canvasWidth: CGFloat?

    private var firstEffective: EffectiveForecast {
        forecasts.effectiveForecast(for: firstSubject)
    }

    private var secondEffective: EffectiveForecast {
        forecasts.effectiveForecast(for: secondSubject)
    }

    private var comparator: ForecastComparator {
        let firstForecast = YearlyForecast(
            profileID: firstSubject.id,
            days: firstEffective.days,
            provenance: .fixture(generatorVersion: YearlyForecast.currentGeneratorVersion)
        )
        let secondForecast = YearlyForecast(
            profileID: secondSubject.id,
            days: secondEffective.days,
            provenance: .fixture(generatorVersion: YearlyForecast.currentGeneratorVersion)
        )
        return ForecastComparator(first: firstForecast, second: secondForecast)
    }

    private var todayOffset: Int {
        max(0, min(YearlyForecast.dayCount - 1, firstEffective.anchor.dayOffset(for: .now, calendar: calendar) ?? 0))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    header

                    dimensionChips

                    comparisonCanvas

                    monthLabels

                    quickJumps

                    selectedDayCard

                    insights
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
        .navigationTitle("Your year together")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedOffset = todayOffset
            forecasts.ensureForecast(for: firstSubject)
            forecasts.ensureForecast(for: secondSubject)
        }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text("\(firstSubject.name) + \(secondSubject.name)")
                .font(HumayTypography.editorialTitle)
                .accessibilityAddTraits(.isHeader)

            if let theme = firstEffective.yearContext?.yearTheme {
                Text(theme)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Overall alignment: \(comparator.overallAlignment())%")
                .font(HumayTypography.bodyEmphasized)
                .foregroundStyle(Color.humaySage)
                .accessibilityLabel("Overall alignment \(comparator.overallAlignment()) percent")
        }
    }

    private var dimensionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HumaySpacing.small) {
                ForEach(MoodDimension.allCases) { candidate in
                    let isSelected = candidate == dimension
                    Button {
                        withAnimation(reduceMotion ? nil : HumayMotion.snappy) { dimension = candidate }
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
            }
        }
        .accessibilityLabel("Comparison dimension")
    }

    private var comparisonCanvas: some View {
        GeometryReader { proxy in
            ComparisonCanvas(
                firstValues: firstEffective.days.map { Double($0.scores[dimension]) },
                secondValues: secondEffective.days.map { Double($0.scores[dimension]) },
                selectedIndex: selectedOffset,
                firstAccent: Color.humayCoral,
                secondAccent: Color.humayLavender
            )
            .onAppear { canvasWidth = proxy.size.width }
            .onChange(of: proxy.size.width) { _, w in canvasWidth = w }
        }
        .frame(height: 200)
        .gesture(scrubGesture)
        .accessibilityLabel("Two-person comparison for \(dimension.displayName)")
        .accessibilityValue("Day \(selectedOffset + 1) of \(YearlyForecast.dayCount)")
        .accessibilityHint("Drag to explore dates")
    }

    private var monthLabels: some View {
        HStack {
            ForEach(0..<12, id: \.self) { index in
                Text(String(firstEffective.anchor.monthName(index: index, calendar: calendar).prefix(1)))
                    .font(HumayTypography.micro.weight(.bold))
                    .foregroundStyle(Color.humayTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    private var quickJumps: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HumaySpacing.small) {
                jumpChip("Best alignment", symbol: "star") {
                    if let window = comparator.bestAlignmentWindows(dimension: dimension, windowLength: 3, count: 1).first {
                        moveTo(window.startDayOffset)
                    }
                }
                jumpChip("Romance peak", symbol: "heart") {
                    if let best = comparator.bestRomanceDays(limit: 1).first {
                        moveTo(best.offset)
                    }
                }
                jumpChip("Conflict", symbol: "tornado") {
                    if let conflict = comparator.conflictDays(limit: 1).first {
                        moveTo(conflict.offset)
                    }
                }
                jumpChip("Calm", symbol: "leaf") {
                    if let calm = comparator.calmWindows(windowLength: 3, count: 1).first {
                        moveTo(calm.startDayOffset)
                    }
                }
                jumpChip("Today", symbol: "location.fill") { moveTo(todayOffset) }
            }
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

    private var scrubGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let width = canvasWidth, width > 0 else { return }
                let fraction = min(max(value.location.x / width, 0), 1)
                let offset = Int((fraction * Double(YearlyForecast.dayCount - 1)).rounded())
                if offset != selectedOffset { moveTo(offset) }
            }
    }

    private func moveTo(_ offset: Int) {
        let clamped = max(0, min(YearlyForecast.dayCount - 1, offset))
        if clamped != selectedOffset {
            selectedOffset = clamped
            HumayHaptics.tap()
        }
    }

    // MARK: - Selected day detail (accessible text equivalents ensure no
    // information lives only in the curves).

    @ViewBuilder
    private var selectedDayCard: some View {
        let firstDay = firstEffective.day(atOffset: selectedOffset)
        let secondDay = secondEffective.day(atOffset: selectedOffset)
        let alignment = comparator.dayAlignment(dimension, at: selectedOffset) ?? 0

        if let firstDay, let secondDay {
            VStack(alignment: .leading, spacing: HumaySpacing.medium) {
                HStack(alignment: .firstTextBaseline) {
                    Text(firstEffective.anchor.date(forDayOffset: selectedOffset)?
                        .formatted(.dateTime.weekday(.wide).day().month(.wide)) ?? "")
                        .font(HumayTypography.bodyEmphasized)
                    Spacer()
                    Text(selectedOffset == todayOffset ? "TODAY" : "\(abs(selectedOffset - todayOffset))d away")
                        .font(HumayTypography.caption.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(Color.humayCoral)
                }

                Text(quip(for: firstDay, second: secondDay, alignment: alignment, dimension: dimension))
                    .font(HumayTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                scoreRow("\(firstSubject.name) · \(dimension.displayName)", value: firstDay.scores[dimension], tint: .coral)
                scoreRow("\(secondSubject.name) · \(dimension.displayName)", value: secondDay.scores[dimension], tint: .lavender)
                scoreRow("Alignment", value: alignment, tint: .sage)

                if let note = firstDay.note ?? secondDay.note {
                    Text(note)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
            .padding(HumaySpacing.large)
            .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous).strokeBorder(Color.humayHairline) }
            .animation(reduceMotion ? nil : HumayMotion.snappy, value: selectedOffset)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(dimension.displayName) on \(firstEffective.anchor.date(forDayOffset: selectedOffset)?.formatted(.dateTime.day().month()) ?? ""). \(quip(for: firstDay, second: secondDay, alignment: alignment, dimension: dimension))")
        }
    }

    private func quip(for first: DailyMood, second: DailyMood, alignment: Int, dimension: MoodDimension) -> String {
        let a = first.scores[dimension]
        let b = second.scores[dimension]
        switch dimension {
        case .romance where a >= 75 && b >= 75:
            return "Both of you are suspiciously charming today. Dangerous."
        case .romance where alignment >= 80:
            return a >= 60 ? "In sync on the heart stuff. Use the window." : "Equally lukewarm. Cozy on purpose."
        case .patience where a <= 30 && b <= 30:
            return "Potential issue: both of you have selected \"absolutely not\" as a communication strategy."
        case .chaos where a >= 75 && b >= 75:
            return "Double chaos day. Schedule nothing. Bring snacks."
        case .confidence where a >= 75 && b >= 75:
            return "Two main characters. One group chat. Good luck."
        case .overall where alignment >= 85:
            return "Annoyingly in sync. The universe is showing off."
        case .overall where alignment <= 35:
            return "Different wavelengths. Give each other space today."
        default:
            return alignment >= 70 ? "Solid alignment — easy day together." : "Mismatched energy. Short check-ins help."
        }
    }

    private func scoreRow(_ label: String, value: Int, tint: FeedAccent) -> some View {
        HStack {
            Text(label).font(HumayTypography.supporting).foregroundStyle(Color.humayTextSecondary)
            Spacer()
            Text("\(value)%").font(HumayTypography.meterValue.monospacedDigit()).foregroundStyle(Color.humay(tint))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value) percent")
    }

    // MARK: - Insights

    private var insights: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            if let best = comparator.bestRomanceDays(limit: 1).first {
                InsightCard(
                    symbol: "heart.fill",
                    tint: .humayCoral,
                    title: "Best romance window",
                    detail: "\(firstEffective.anchor.date(forDayOffset: best.offset)?.formatted(.dateTime.day().month(.wide)) ?? "") — joint romance \(best.score)% (averaged)."
                )
            }
            if let conflict = comparator.conflictDays(limit: 1).first {
                InsightCard(
                    symbol: "exclamationmark.triangle.fill",
                    tint: .humaySolarGold,
                    title: "Watch for friction",
                    detail: "\(firstEffective.anchor.date(forDayOffset: conflict.offset)?.formatted(.dateTime.day().month(.wide)) ?? "") — combined tension \(conflict.score)%."
                )
            }
            if let calm = comparator.calmWindows(windowLength: 3, count: 1).first {
                InsightCard(
                    symbol: "leaf.fill",
                    tint: .humaySage,
                    title: calm.label,
                    detail: "\(firstEffective.anchor.date(forDayOffset: calm.startDayOffset)?.formatted(.dateTime.day().month(.wide)) ?? "")–\(firstEffective.anchor.date(forDayOffset: calm.endDayOffset)?.formatted(.dateTime.day().month(.wide)) ?? "")."
                )
            }
        }
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

/// Canvas drawing two curves and a selected marker.
private struct ComparisonCanvas: View {
    let firstValues: [Double]
    let secondValues: [Double]
    let selectedIndex: Int
    let firstAccent: Color
    let secondAccent: Color

    var body: some View {
        Canvas { context, size in
            guard !firstValues.isEmpty else { return }
            let stepX = size.width / CGFloat(max(firstValues.count - 1, 1))
            let padding: CGFloat = 10
            let usableHeight = size.height - padding * 2

            func point(_ values: [Double], at index: Int) -> CGPoint {
                CGPoint(
                    x: CGFloat(index) * stepX,
                    y: padding + usableHeight * (1 - CGFloat(min(max(values[index], 0), 100)) / 100)
                )
            }

            func path(for values: [Double]) -> Path {
                var curve = Path()
                curve.move(to: point(values, at: 0))
                for i in values.indices.dropFirst() { curve.addLine(to: point(values, at: i)) }
                return curve
            }

            context.stroke(path(for: firstValues), with: .color(firstAccent.opacity(0.85)), lineWidth: 2)
            context.stroke(path(for: secondValues), with: .color(secondAccent.opacity(0.85)), lineWidth: 2)

            // Selected markers for both lines.
            for (values, accent) in [(firstValues, firstAccent), (secondValues, secondAccent)] as [([Double], Color)] {
                let p = point(values, at: selectedIndex)
                context.fill(Path(ellipseIn: CGRect(x: p.x - 5, y: p.y - 5, width: 10, height: 10)), with: .color(accent))
            }
        }
        .background(Color.humaySurface.opacity(0.6), in: RoundedRectangle(cornerRadius: HumayRadius.compact, style: .continuous))
        .contentShape(Rectangle())
    }
}

private struct InsightCard: View {
    let symbol: String
    let tint: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: HumaySpacing.medium) {
            Image(systemName: symbol).font(.body.weight(.semibold)).foregroundStyle(tint)
                .frame(width: 32, height: 32).background(tint.opacity(0.14), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(HumayTypography.bodyEmphasized)
                Text(detail).font(HumayTypography.supporting).foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HumaySpacing.large)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous).strokeBorder(Color.humayHairline) }
        .accessibilityElement(children: .combine)
    }
}
