import SwiftUI

struct CircleView: View {
    let state: CircleFeatureState
    let compatibilityState: CompatibilityFeatureState
    let precisePreview: PreciseCompatibilityResult?
    let source: D2ContentSource
    let profileName: String
    let openProfile: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var addedPeople: [CirclePerson] = []
    @State private var showAddPerson = false
    @State private var selectedPerson: CirclePerson?

    var body: some View {
        HumayPage(maximum: .immersive) {
            HumayScreenHeader(
                section: "Connections",
                profileName: profileName,
                profileAction: openProfile
            )

            stateContent
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddPerson) {
            AddPersonView { person in
                addedPeople.append(person)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedPerson) { person in
            CirclePersonDetailView(person: person)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .loading:
            ConnectionsLoadingView()
                .accessibilityIdentifier("connections.state.loading")

        case .loaded(let people):
            loadedContent(people: people + addedPeople)

        case .empty:
            if addedPeople.isEmpty {
                emptyContent
            } else {
                loadedContent(people: addedPeople)
            }

        case .offline(let cached):
            VStack(alignment: .leading, spacing: HumaySpacing.section) {
                D2StatusBanner(
                    symbol: "wifi.slash",
                    title: "Offline",
                    detail: cached.isEmpty
                        ? "No saved people are available on this device."
                        : "Showing people already available on this device.",
                    accent: .gold
                )

                if cached.isEmpty && addedPeople.isEmpty {
                    emptyContent
                } else {
                    loadedContent(people: cached + addedPeople)
                }
            }

        case .failed(let message):
            HumayStateView(
                title: "Connections are unavailable",
                message: message,
                symbol: .unavailable
            )
            .accessibilityIdentifier("connections.state.failed")
        }
    }

    private func loadedContent(people: [CirclePerson]) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.section) {
            connectionsIntroduction(
                detail: "The people you keep here come first. Relationship analysis starts only when you choose it."
            )

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: HumaySpacing.hero) {
                    peopleSection(people)
                        .frame(minWidth: 520, maxWidth: 720, alignment: .topLeading)
                    compatibilityEntry(people)
                        .frame(minWidth: 300, maxWidth: 380, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: HumaySpacing.section) {
                    peopleSection(people)
                    compatibilityEntry(people)
                }
            }
        }
    }

    private func connectionsIntroduction(detail: String) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayEyebrow(text: "People first", color: .humayAccentCelestial)
            Text("Your connections")
                .font(HumayTypography.displayTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(detail)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 600, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("connections.introduction")
    }

    private func peopleSection(_ people: [CirclePerson]) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    peopleHeading(count: people.count)
                    addPersonButton
                }
            } else {
                HStack(alignment: .center, spacing: HumaySpacing.large) {
                    peopleHeading(count: people.count)
                    Spacer(minLength: HumaySpacing.large)
                    addPersonButton
                }
            }

            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: 300, maximum: 420),
                        spacing: HumaySpacing.large,
                        alignment: .top
                    )
                ],
                alignment: .leading,
                spacing: HumaySpacing.large
            ) {
                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                    personRow(person, index: index)
                }
            }
        }
    }

    private func peopleHeading(count: Int) -> some View {
        HumaySectionHeader(
            title: "People",
            subtitle: "\(count) \(count == 1 ? "person" : "people") available",
            editorial: false
        )
    }

    private var addPersonButton: some View {
        Button {
            showAddPerson = true
        } label: {
            Label("Add Person", systemImage: "plus")
                .frame(minHeight: HumayMetrics.minimumHitTarget)
        }
        .buttonStyle(.humaySecondary)
        .accessibilityHint("Opens the Add Person form")
        .accessibilityIdentifier("circle.add-person")
    }

    private func personRow(_ person: CirclePerson, index: Int) -> some View {
        Button {
            selectedPerson = person
        } label: {
            HStack(spacing: HumaySpacing.medium) {
                HumayPersonIdentityRow(
                    person: person,
                    accent: index.isMultiple(of: 2) ? .blue : .gold,
                    metadata: person.birth.dateFormatted()
                )

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.humayTextSecondary)
                    .frame(
                        width: HumayMetrics.minimumHitTarget,
                        height: HumayMetrics.minimumHitTarget
                    )
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, HumaySpacing.large)
            .padding(.vertical, HumaySpacing.medium)
            .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
            .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.compact))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.compact)
                    .stroke(Color.humaySeparator)
            }
            .contentShape(RoundedRectangle(cornerRadius: HumayRadius.compact))
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(personAccessibilityLabel(person))
        .accessibilityHint("Opens person details")
        .accessibilityIdentifier("circle.person.row.\(index)")
    }

    private func compatibilityEntry(_ people: [CirclePerson]) -> some View {
        let eligiblePeople = people.filter { $0.westernSunSign != nil }

        return HumayHairlineSurface(style: .celestial) {
            VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                HumaySystemSymbolImage(symbol: .compatibility, size: .feature)
                    .foregroundStyle(Color.humayAccentCelestial)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    HumayEyebrow(text: "Relationship analysis", color: .humayAccentCelestial)
                    Text("Compatibility")
                        .font(HumayTypography.narrativeSectionTitle)
                    Text("Choose two people for the existing Sun-sign comparison. Precise synastry remains unavailable until provider-backed generation is connected.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(
                    eligiblePeople.count >= 2
                        ? "\(eligiblePeople.count) people have Sun-sign data."
                        : "Add at least two people with Sun-sign data to continue."
                )
                .font(HumayTypography.caption)
                .foregroundStyle(Color.humayTextSecondary)

                NavigationLink {
                    CompatibilitySelectionView(
                        people: eligiblePeople,
                        state: compatibilityState,
                        precisePreview: precisePreview,
                        source: source
                    )
                } label: {
                    Label(
                        eligiblePeople.count >= 2 ? "Choose two people" : "Compatibility unavailable",
                        systemImage: "arrow.right"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.humayPrimary)
                .disabled(eligiblePeople.count < 2)
                .accessibilityHint(
                    eligiblePeople.count >= 2
                        ? "Opens compatibility person selection"
                        : "Two people with Sun-sign data are required"
                )
                .accessibilityIdentifier("circle.compatibility.open")
            }
        }
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.section) {
            connectionsIntroduction(
                detail: "Add someone with the birth information you know. Unknown details stay explicitly unknown."
            )

            HumayHairlineSurface(style: .raised) {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    HumaySystemSymbolImage(symbol: .compatibility, size: .feature)
                        .foregroundStyle(Color.humayAccentCelestial)

                    Text("No people yet")
                        .font(HumayTypography.editorialTitle)
                        .accessibilityAddTraits(.isHeader)

                    Text("A name and birth date are enough for this form. Birth time and location are not required here.")
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button("Add Person") {
                        showAddPerson = true
                    }
                    .buttonStyle(.humayPrimary)
                    .accessibilityIdentifier("circle.empty.add-person")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: HumayContentWidth.readable.rawValue, alignment: .leading)
        }
    }

    private func personAccessibilityLabel(_ person: CirclePerson) -> String {
        let sign = person.westernSunSign.map { "\($0.displayName) Sun" } ?? "Sun sign unavailable"
        return "\(person.name), \(sign), born \(person.birth.dateFormatted())"
    }
}

private struct ConnectionsLoadingView: View {
    var body: some View {
        HumayHairlineSurface(style: .raised) {
            HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.humayAccentPrestige)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("Opening Connections…")
                        .font(HumayTypography.narrativeSectionTitle)
                    Text("Loading the people available to you.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading Connections")
    }
}

private struct CirclePersonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let person: CirclePerson

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: HumaySpacing.section) {
                        identity
                        birthInformation
                        availabilityNote
                    }
                    .frame(maxWidth: HumayContentWidth.readable.rawValue, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                    .padding(.top, HumaySpacing.extraLarge)
                    .padding(.bottom, HumaySpacing.expansive)
                }
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
            }
            .background(Color.humayCanvas.ignoresSafeArea())
            .foregroundStyle(Color.humayTextPrimary)
            .navigationTitle("Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }
            }
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumayEyebrow(text: "Person")
            HumayPersonIdentityRow(
                person: person,
                accent: .gold,
                medallionSize: 80,
                metadata: person.birth.dateFormatted()
            )
            Text(person.westernSunSign == nil
                ? "No Sun sign is stored for this person."
                : "Sun-sign identity is shown with Humay's verified technical zodiac glyph.")
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("circle.person-detail.screen")
    }

    private var birthInformation: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumaySectionHeader(
                title: "Birth information",
                subtitle: "Only information already available for this person is shown."
            )

            HumayHairlineSurface(style: .quiet) {
                VStack(spacing: HumaySpacing.small) {
                    HumayFactRow(label: "Date", value: person.birth.dateFormatted())
                    factDivider
                    HumayFactRow(
                        label: "Time",
                        value: timeText,
                        note: person.birth.time.isKnown ? nil : "Unknown remains unknown."
                    )
                    factDivider
                    HumayFactRow(
                        label: "Place",
                        value: placeText,
                        note: person.birth.place.isKnown ? nil : "No location is stored."
                    )
                    factDivider
                    HumayFactRow(
                        label: "Precision",
                        value: person.birth.supportsPrecision
                            ? "Time and place available"
                            : "More details would be needed"
                    )
                }
            }
        }
        .accessibilityIdentifier("circle.person-detail.birth")
    }

    private var factDivider: some View {
        Rectangle()
            .fill(Color.humaySeparator)
            .frame(height: 1)
            .accessibilityHidden(true)
    }

    private var availabilityNote: some View {
        HumayHairlineSurface(style: .celestial) {
            HStack(alignment: .top, spacing: HumaySpacing.large) {
                HumaySystemSymbolImage(symbol: .privacy, size: .standard)
                    .foregroundStyle(Color.humayAccentCelestial)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text(person.birth.supportsPrecision ? "Details available" : "Some details are unknown")
                        .font(HumayTypography.bodyEmphasized)
                    Text("This view currently supports reviewing birth information. Editing, natal analysis, and person-specific relationship readings are not connected here.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("circle.person-detail.availability")
    }

    private var timeText: String {
        switch person.birth.time {
        case .unknown:
            "Unknown"
        case .exact:
            person.birth.time.formatted() ?? "Exact time available"
        case .approximate:
            person.birth.time.formatted() ?? "Approximate time available"
        }
    }

    private var placeText: String {
        person.birth.place.name ?? "Not provided"
    }
}
