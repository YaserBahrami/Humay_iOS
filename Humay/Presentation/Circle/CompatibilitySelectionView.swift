import SwiftUI

struct CompatibilityPairSelection: Equatable {
    private(set) var selectedIDs: [CirclePerson.ID]

    init(people: [CirclePerson]) {
        selectedIDs = Array(people.prefix(2).map(\.id))
    }

    var isComplete: Bool { selectedIDs.count == 2 }

    func contains(_ id: CirclePerson.ID) -> Bool {
        selectedIDs.contains(id)
    }

    mutating func toggle(_ id: CirclePerson.ID) {
        if let index = selectedIDs.firstIndex(of: id) {
            selectedIDs.remove(at: index)
        } else if selectedIDs.count < 2 {
            selectedIDs.append(id)
        }
    }
}

struct CompatibilitySelectionView: View {
    let people: [CirclePerson]
    let state: CompatibilityFeatureState
    let precisePreview: PreciseCompatibilityResult?
    let source: D2ContentSource

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var selectionRowHeight: CGFloat = 96
    @State private var selection: CompatibilityPairSelection

    init(
        people: [CirclePerson],
        state: CompatibilityFeatureState,
        precisePreview: PreciseCompatibilityResult?,
        source: D2ContentSource
    ) {
        self.people = people
        self.state = state
        self.precisePreview = precisePreview
        self.source = source
        _selection = State(initialValue: CompatibilityPairSelection(people: people))
    }

    var body: some View {
        GeometryReader { proxy in
            let regularLayout = proxy.size.width >= 900

            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    pageIntroduction(regularLayout: regularLayout)

                    if regularLayout {
                        HStack(alignment: .top, spacing: HumaySpacing.extraExtraLarge) {
                            pairContext(includeAction: true)
                                .frame(minWidth: 360, maxWidth: 430, alignment: .top)

                            savedPeopleList(showSelectedLabels: true)
                                .frame(minWidth: 420, maxWidth: .infinity, alignment: .top)
                        }
                    } else {
                        pairContext(includeAction: false)
                        savedPeopleList(showSelectedLabels: false)
                    }
                }
                .frame(maxWidth: 1_180)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.top, HumaySpacing.extraLarge)
                .padding(.bottom, regularLayout ? HumaySpacing.extraLarge : HumaySpacing.small)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !regularLayout {
                    compactActionTray
                }
            }
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationTitle("Compatibility")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pageIntroduction(regularLayout: Bool) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text("Choose your connection")
                .font(regularLayout ? HumayTypography.heroTitle : HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(
                regularLayout
                    ? "Select two people. The pair stays visible while you browse your Circle."
                    : "Select two people to compare."
            )
            .font(HumayTypography.body)
            .foregroundStyle(Color.humayTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func pairContext(includeAction: Bool) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            CompatibilityPairComposer(people: selectedPeople)

            if includeAction {
                Text(selectionGuidance)
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                continueLink

                D2StatusBanner(
                    symbol: "exclamationmark",
                    title: "Simple first, precise when available",
                    detail: "The next screen states whether the result is Free or Precise. Birth details never appear in this picker.",
                    accent: .gold
                )
            }
        }
    }

    private func savedPeopleList(showSelectedLabels: Bool) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    savedPeopleTitle
                    savedPeopleCount
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.medium) {
                    savedPeopleTitle
                    Spacer(minLength: HumaySpacing.medium)
                    savedPeopleCount
                }
            }

            VStack(spacing: HumaySpacing.medium) {
                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                    selectionRow(
                        person,
                        index: index,
                        showSelectedLabel: showSelectedLabels
                    )
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var savedPeopleTitle: some View {
        Text("Saved people")
            .font(HumayTypography.sectionTitle)
            .accessibilityAddTraits(.isHeader)
    }

    private var savedPeopleCount: some View {
        Text("\(selection.selectedIDs.count) selected · \(people.count) total")
            .font(HumayTypography.supporting)
            .foregroundStyle(Color.humayTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("compatibility.selection.count")
    }

    private func selectionRow(
        _ person: CirclePerson,
        index: Int,
        showSelectedLabel: Bool
    ) -> some View {
        let selected = selection.contains(person.id)
        let accent = accent(for: person, fallbackIndex: index)

        return Button {
            selection.toggle(person.id)
        } label: {
            HStack(spacing: HumaySpacing.large) {
                CirclePersonMedallion(person: person, accent: accent, size: 58)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text(person.name)
                        .font(HumayTypography.bodyEmphasized)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(person.westernSunSign?.displayName ?? "Sign unavailable") Sun")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                if selected, showSelectedLabel {
                    Text("Selected")
                        .font(HumayTypography.utility)
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(accent.color)
                        .accessibilityHidden(true)
                }

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(selected ? accent.color : Color.humayTextSecondary)
                    .frame(width: HumayMetrics.minimumHitTarget, height: HumayMetrics.minimumHitTarget)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, HumaySpacing.large)
            .padding(.vertical, HumaySpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: selectionRowHeight, alignment: .leading)
            .background(
                selected ? accent.color.opacity(0.10) : Color.humaySurface,
                in: RoundedRectangle(cornerRadius: HumayRadius.compact, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.compact, style: .continuous)
                    .stroke(
                        selected ? accent.color : Color.humayHairline,
                        lineWidth: selected ? 2 : 1
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: HumayRadius.compact, style: .continuous))
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: false, vertical: true)
        .hoverEffect(.lift)
        .accessibilityLabel("\(person.name), \(person.westernSunSign?.displayName ?? "Sign unavailable")")
        .accessibilityValue(selected ? "Selected" : "Not selected")
        .accessibilityHint(selectionHint(for: person))
        .accessibilityIdentifier("compatibility.selection.person.\(index)")
    }

    private var compactActionTray: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text(selectionGuidance)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            continueLink
        }
        .padding(.horizontal, HumaySpacing.large)
        .padding(.top, HumaySpacing.medium)
        .padding(.bottom, HumaySpacing.small)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var continueLink: some View {
        NavigationLink {
            CompatibilityView(
                state: resolvedState,
                precisePreview: precisePreview,
                source: source
            )
        } label: {
            Label(continueTitle, systemImage: selection.isComplete ? "heart.fill" : "person.2")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.humayPrimary)
        .disabled(!selection.isComplete)
        .accessibilityHint(selection.isComplete ? "Shows compatibility for the selected pair" : selectionGuidance)
        .accessibilityIdentifier("compatibility.selection.continue")
    }

    private var selectedPeople: [CirclePerson] {
        selection.selectedIDs.compactMap { id in
            people.first { $0.id == id }
        }
    }

    private var continueTitle: String {
        switch selection.selectedIDs.count {
        case 2: "See Compatibility"
        case 1: "Choose one more person"
        default: "Select two people"
        }
    }

    private var selectionGuidance: String {
        switch selectedPeople.count {
        case 2: "\(selectedPeople[0].name) + \(selectedPeople[1].name)"
        case 1: "Choose one more person."
        default: "Choose two people to compare."
        }
    }

    private func selectionHint(for person: CirclePerson) -> String {
        if selection.contains(person.id) {
            return "Removes this person from the comparison"
        }
        if selection.isComplete {
            return "Two people are already selected. Remove one before adding this person."
        }
        return "Adds this person to the comparison"
    }

    private func accent(for person: CirclePerson, fallbackIndex: Int) -> HumayAccent {
        if let selectedIndex = selection.selectedIDs.firstIndex(of: person.id) {
            return selectedIndex == 0 ? .lavender : .coral
        }
        return fallbackIndex.isMultiple(of: 2) ? .gold : .blue
    }

    private var resolvedState: CompatibilityFeatureState {
        guard selectedPeople.count == 2 else { return .entry }
        let selected = Set(selectedPeople.map(\.id))
        guard selected == Set(pairFromState?.ids ?? []) else {
            return .failed(
                pair: CompatibilityPair(first: selectedPeople[0], second: selectedPeople[1]),
                message: "Compatibility is not available for this pair yet."
            )
        }
        return state
    }

    private var pairFromState: (ids: [CirclePerson.ID], pair: CompatibilityPair)? {
        let pair: CompatibilityPair?
        switch state {
        case .entry:
            pair = precisePreview?.pair
        case .loading(let value):
            pair = value
        case .freeLoaded(let result), .preciseLocked(let result):
            pair = result.pair
        case .preciseLoaded(let result), .cached(let result, _):
            pair = result.pair
        case .offline(let result):
            pair = result?.pair
        case .failed(let value, _):
            pair = value
        }
        guard let pair else { return nil }
        return ([pair.first.id, pair.second.id], pair)
    }
}

private struct CompatibilityPairComposer: View {
    let people: [CirclePerson]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    composerTitle
                    statusBadge
                }
            } else {
                HStack(alignment: .center, spacing: HumaySpacing.medium) {
                    composerTitle
                    Spacer(minLength: HumaySpacing.small)
                    statusBadge
                }
            }

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: HumaySpacing.medium) {
                    slot(for: people.first, index: 0)
                    CompatibilityConnector(state: connectorState, orientation: .vertical)
                        .frame(width: 52, height: 58)
                    slot(for: people.dropFirst().first, index: 1)
                }
                .frame(maxWidth: .infinity)
            } else {
                HStack(alignment: .top, spacing: HumaySpacing.small) {
                    slot(for: people.first, index: 0)
                        .frame(maxWidth: .infinity)
                    CompatibilityConnector(state: connectorState)
                        .frame(minWidth: 54, maxWidth: 84, minHeight: 78)
                        .padding(.top, HumaySpacing.small)
                    slot(for: people.dropFirst().first, index: 1)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(HumaySpacing.extraLarge)
        .background(pairBackground, in: RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous)
                .stroke(Color.humayHairline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("compatibility.pair-composer")
    }

    private var composerTitle: some View {
        Text("Your connection")
            .font(HumayTypography.utility)
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(Color.humayCoral)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var statusBadge: some View {
        Label(statusLabel, systemImage: statusSymbol)
            .font(HumayTypography.utility)
            .padding(.horizontal, HumaySpacing.medium)
            .padding(.vertical, HumaySpacing.small)
            .background(Color.humayRaisedSurface, in: Capsule())
            .overlay(Capsule().stroke(Color.humayHairline))
    }

    private func slot(for person: CirclePerson?, index: Int) -> some View {
        VStack(spacing: HumaySpacing.small) {
            if let person {
                CirclePersonMedallion(
                    person: person,
                    accent: index == 0 ? .lavender : .coral,
                    size: 72
                )
                Text(person.name)
                    .font(HumayTypography.bodyEmphasized)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(person.westernSunSign?.displayName ?? "Sign unavailable")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ZStack {
                    Circle()
                        .stroke(
                            Color.humayTextSecondary,
                            style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                        )
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(width: 72, height: 72)
                .accessibilityHidden(true)

                Text(emptyTitle(for: index))
                    .font(HumayTypography.bodyEmphasized)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Open slot")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
    }

    private var pairBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.humayLavender.opacity(0.12),
                Color.humaySurface,
                Color.humayCoral.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var connectorState: CompatibilityConnector.State {
        switch people.count {
        case 2...: .active
        case 1: .waiting
        default: .empty
        }
    }

    private var statusLabel: String {
        switch people.count {
        case 2...: "2 selected"
        case 1: "1 selected"
        default: "0 selected"
        }
    }

    private var statusSymbol: String {
        people.count == 2 ? "checkmark" : "person.2"
    }

    private func emptyTitle(for index: Int) -> String {
        if people.count == 1, index == 1 { return "Choose one more person" }
        return index == 0 ? "Choose first person" : "Choose second person"
    }

    private var accessibilitySummary: String {
        switch people.count {
        case 2...:
            return "Selected pair, \(personDescription(people[0])) and \(personDescription(people[1])). Two people selected."
        case 1:
            return "Selected pair, \(personDescription(people[0])). Choose one more person."
        default:
            return "No people selected. Choose two people to compare."
        }
    }

    private func personDescription(_ person: CirclePerson) -> String {
        "\(person.name), \(person.westernSunSign?.displayName ?? "sign unavailable")"
    }
}

struct CompatibilityConnector: View {
    enum State {
        case empty
        case waiting
        case active
    }

    enum Orientation {
        case horizontal
        case vertical
    }

    let state: State
    var orientation: Orientation = .horizontal

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                CompatibilityOrbitShape(orientation: orientation)
                    .trim(from: 0, to: state == .waiting ? 0.62 : 1)
                    .stroke(
                        connectorGradient,
                        style: StrokeStyle(
                            lineWidth: state == .empty ? 1.5 : 2.5,
                            lineCap: .round,
                            dash: state == .active ? [] : [6, 6]
                        )
                    )

                endpoint(at: startPoint(in: size))
                if state != .waiting {
                    endpoint(at: endPoint(in: size))
                }

                Image(systemName: state == .active ? "heart.fill" : "heart")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(state == .active ? Color.humayCoral : Color.humayTextSecondary)
                    .position(heartPoint(in: size))
            }
        }
        .accessibilityHidden(true)
    }

    private var connectorGradient: LinearGradient {
        LinearGradient(
            colors: state == .active
                ? [Color.humayLavender, Color.humayCoral, Color.humaySolarGold]
                : [Color.humayTextSecondary.opacity(0.55), Color.humayTextSecondary.opacity(0.30)],
            startPoint: orientation == .horizontal ? .leading : .top,
            endPoint: orientation == .horizontal ? .trailing : .bottom
        )
    }

    private func endpoint(at point: CGPoint) -> some View {
        Circle()
            .fill(state == .active ? Color.humayCoral : Color.humayTextSecondary)
            .frame(width: 7, height: 7)
            .position(point)
    }

    private func startPoint(in size: CGSize) -> CGPoint {
        orientation == .horizontal
            ? CGPoint(x: 3.5, y: size.height * 0.70)
            : CGPoint(x: size.width * 0.30, y: 3.5)
    }

    private func endPoint(in size: CGSize) -> CGPoint {
        orientation == .horizontal
            ? CGPoint(x: size.width - 3.5, y: size.height * 0.70)
            : CGPoint(x: size.width * 0.70, y: size.height - 3.5)
    }

    private func heartPoint(in size: CGSize) -> CGPoint {
        orientation == .horizontal
            ? CGPoint(x: size.width * 0.50, y: size.height * 0.24)
            : CGPoint(x: size.width * 0.70, y: size.height * 0.50)
    }
}

private struct CompatibilityOrbitShape: Shape {
    let orientation: CompatibilityConnector.Orientation

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch orientation {
        case .horizontal:
            path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.70))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: rect.height * 0.70),
                control1: CGPoint(x: rect.width * 0.26, y: rect.height * 0.12),
                control2: CGPoint(x: rect.width * 0.74, y: rect.height * 0.12)
            )
        case .vertical:
            path.move(to: CGPoint(x: rect.width * 0.30, y: rect.minY))
            path.addCurve(
                to: CGPoint(x: rect.width * 0.70, y: rect.maxY),
                control1: CGPoint(x: rect.width * 0.92, y: rect.height * 0.26),
                control2: CGPoint(x: rect.width * 0.08, y: rect.height * 0.74)
            )
        }
        return path
    }
}
