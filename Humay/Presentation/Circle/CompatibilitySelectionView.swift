import SwiftUI

struct CompatibilitySelectionView: View {
    let people: [CirclePerson]
    let state: CompatibilityFeatureState
    let precisePreview: PreciseCompatibilityResult?
    let source: D2ContentSource

    @State private var selectedIDs: Set<CirclePerson.ID>

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
        _selectedIDs = State(initialValue: Set(people.prefix(2).map(\.id)))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    HStack(alignment: .center, spacing: HumaySpacing.large) {
                        VStack(alignment: .leading, spacing: HumaySpacing.small) {
                            Text("Choose two people")
                                .font(HumayTypography.heroTitle)
                                .accessibilityAddTraits(.isHeader)
                            Text("Start with a simple Sun-sign connection. Precise compatibility can go deeper when enough birth details are available.")
                                .font(HumayTypography.body)
                                .foregroundStyle(Color.humayTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        HumayIllustration(name: "IllustrationCompatibilityPair")
                            .frame(width: 118, height: 88)
                    }

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 170), spacing: HumaySpacing.medium)],
                        spacing: HumaySpacing.medium
                    ) {
                        ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                            selectionCard(
                                person,
                                accent: index.isMultiple(of: 2) ? .lavender : .coral
                            )
                        }
                    }

                    if selectedPeople.count == 2 {
                        NavigationLink {
                            CompatibilityView(
                                state: resolvedState,
                                precisePreview: precisePreview,
                                source: source
                            )
                        } label: {
                            Label("See Compatibility", systemImage: "heart.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.humayPrimary)
                        .accessibilityIdentifier("compatibility.selection.continue")
                    } else {
                        Text("Select exactly two people to continue.")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
                .frame(maxWidth: HumayContentWidth.readable.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.vertical, HumaySpacing.extraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationTitle("Compatibility")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectedPeople: [CirclePerson] {
        people.filter { selectedIDs.contains($0.id) }
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

    private func selectionCard(_ person: CirclePerson, accent: HumayAccent) -> some View {
        let selected = selectedIDs.contains(person.id)

        return Button {
            if selected {
                selectedIDs.remove(person.id)
            } else if selectedIDs.count < 2 {
                selectedIDs.insert(person.id)
            }
        } label: {
            HStack(spacing: HumaySpacing.medium) {
                CirclePersonMedallion(person: person, accent: accent, size: 62)

                VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                    Text(person.name)
                        .font(HumayTypography.bodyEmphasized)
                    Text(person.westernSunSign?.displayName ?? "Sign unavailable")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(selected ? Color.humayCoral : Color.humayTextSecondary)
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)
            }
            .padding(HumaySpacing.large)
            .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface)
                    .stroke(selected ? Color.humayCoral : Color.humayHairline, lineWidth: selected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(person.name), \(person.westernSunSign?.displayName ?? "Sign unavailable")")
        .accessibilityValue(selected ? "Selected" : "Not selected")
    }
}
