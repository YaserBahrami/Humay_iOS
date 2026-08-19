import SwiftUI

struct CircleView: View {
    let state: CircleFeatureState
    let compatibilityState: CompatibilityFeatureState
    let precisePreview: PreciseCompatibilityResult?
    let source: D2ContentSource
    let profileName: String
    let openProfile: () -> Void

    @State private var addedPeople: [CirclePerson] = []
    @State private var showAddPerson = false
    @State private var selectedPerson: CirclePerson?

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    HumayScreenHeader(
                        section: "Connections",
                        profileName: profileName,
                        profileAction: openProfile
                    )

                    stateContent(availableWidth: proxy.size.width)
                }
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
                .padding(.top, HumaySpacing.large)
                .padding(.bottom, HumaySpacing.extraExtraLarge)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddPerson) {
            AddPersonView { person in
                addedPeople.append(person)
            }
        }
        .sheet(item: $selectedPerson) { person in
            CirclePersonDetailView(person: person)
        }
    }

    @ViewBuilder
    private func stateContent(availableWidth: CGFloat) -> some View {
        switch state {
        case .loading:
            HumaySurface(level: .raised) {
                VStack(spacing: HumaySpacing.large) {
                    HumayIllustration(asset: .todayTogether)
                        .frame(width: 132, height: 98)
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayLavender)
                    Text("Opening your connections…")
                        .font(HumayTypography.cardTitle)
                    Text("Gathering the people you keep close.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HumaySpacing.extraExtraLarge)
            }

        case .loaded(let people):
            loadedContent(people: people + addedPeople, availableWidth: availableWidth)

        case .empty:
            if addedPeople.isEmpty {
                emptyState
            } else {
                loadedContent(people: addedPeople, availableWidth: availableWidth)
            }

        case .offline(let cached):
            D2StatusBanner(
                symbol: "wifi.slash",
                title: "Offline",
                detail: cached.isEmpty
                    ? "No saved people are available."
                    : "Showing people already available on this device.",
                accent: .gold
            )
            if cached.isEmpty && addedPeople.isEmpty {
                emptyState
            } else {
                loadedContent(people: cached + addedPeople, availableWidth: availableWidth)
            }

        case .failed(let message):
            D2UnavailableState(
                symbol: "person.2.slash",
                title: "Connections are unavailable",
                detail: message
            )
        }
    }

    @ViewBuilder
    private func loadedContent(people: [CirclePerson], availableWidth: CGFloat) -> some View {
        HStack(alignment: .center, spacing: HumaySpacing.large) {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                Text("Your connections")
                    .font(HumayTypography.heroTitle)
                    .accessibilityAddTraits(.isHeader)
                Text("Keep the people who matter close, then explore how your energies meet.")
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

        if availableWidth >= 820 {
            HStack(alignment: .top, spacing: HumaySpacing.extraLarge) {
                peopleSection(people)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                compatibilityEntry(people)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        } else {
            peopleSection(people)
            compatibilityEntry(people)
        }
    }

    private func peopleSection(_ people: [CirclePerson]) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HStack(spacing: HumaySpacing.medium) {
                Text("People")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Button {
                    showAddPerson = true
                } label: {
                    Label("Add Person", systemImage: "plus")
                        .font(HumayTypography.control)
                        .frame(minHeight: HumayMetrics.minimumHitTarget)
                }
                .accessibilityIdentifier("circle.add-person")
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 152), spacing: HumaySpacing.medium)],
                spacing: HumaySpacing.medium
            ) {
                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                    Button {
                        selectedPerson = person
                    } label: {
                        VStack(spacing: HumaySpacing.small) {
                            CirclePersonMedallion(
                                person: person,
                                accent: index.isMultiple(of: 2) ? .lavender : .coral,
                                size: 78
                            )

                            Text(person.name)
                                .font(HumayTypography.bodyEmphasized)
                                .foregroundStyle(Color.humayTextPrimary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)

                            Text(person.westernSunSign?.displayName ?? "Sign pending")
                                .font(HumayTypography.supporting)
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(HumaySpacing.large)
                        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface))
                        .overlay {
                            RoundedRectangle(cornerRadius: HumayRadius.surface)
                                .stroke(Color.humayHairline)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(person.name), \(person.westernSunSign?.displayName ?? "Sun sign unavailable")")
                    .accessibilityHint("Opens person details")
                }
            }
        }
    }

    private func compatibilityEntry(_ people: [CirclePerson]) -> some View {
        let eligiblePeople = people.filter { $0.westernSunSign != nil }

        return NavigationLink {
            CompatibilitySelectionView(
                people: eligiblePeople,
                state: compatibilityState,
                precisePreview: precisePreview,
                source: source
            )
        } label: {
            HumaySurface {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    HStack(alignment: .center, spacing: HumaySpacing.medium) {
                        VStack(alignment: .leading, spacing: HumaySpacing.small) {
                            Text("Compatibility")
                                .font(HumayTypography.utility)
                                .textCase(.uppercase)
                                .tracking(1.1)
                                .foregroundStyle(Color.humayCoral)
                            Text("See how two energies meet")
                                .font(HumayTypography.cardTitle)
                                .foregroundStyle(Color.humayTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        HumaySystemSymbolImage(symbol: .compatibility, size: .feature)
                            .foregroundStyle(Color.humayCoral)
                    }

                    Text("Start with a simple Sun-sign connection. Deeper compatibility can use precise birth details when they are available.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Label(
                        eligiblePeople.count >= 2 ? "Choose two people" : "Add two people with sign data",
                        systemImage: "arrow.right"
                    )
                    .font(HumayTypography.control)
                    .foregroundStyle(Color.humayCoral)
                    .frame(minHeight: HumayMetrics.minimumHitTarget)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(eligiblePeople.count < 2)
        .accessibilityHint("Opens compatibility person selection")
        .accessibilityIdentifier("circle.compatibility.open")
    }

    private var emptyState: some View {
        HumaySurface(level: .raised) {
            VStack(spacing: HumaySpacing.large) {
                HumaySystemSymbolImage(symbol: .compatibility, size: .feature)
                    .foregroundStyle(Color.humayCoral)
                Text("Your connections start here")
                    .font(HumayTypography.cardTitle)
                    .accessibilityAddTraits(.isHeader)
                Text("Add someone’s basic birth details. Exact time and location can stay unknown until a feature genuinely needs them.")
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Add Person") {
                    showAddPerson = true
                }
                .buttonStyle(.humayPrimary)
                .accessibilityIdentifier("circle.empty.add-person")
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct CirclePersonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let person: CirclePerson

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: HumaySpacing.large) {
                        CirclePersonMedallion(person: person, accent: .lavender, size: 72)
                        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                            Text(person.name)
                                .font(HumayTypography.sectionTitle)
                            Text(person.westernSunSign?.displayName ?? "Sun sign unavailable")
                                .foregroundStyle(Color.humayTextSecondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }

                Section("Birth details") {
                    LabeledContent("Date", value: person.birth.dateFormatted())
                    LabeledContent("Time", value: timeText)
                    LabeledContent("Place", value: person.birth.place.name ?? "Not provided")
                }

                Section {
                    Text("Birth time and place can remain unknown. Humay only needs them for features whose accuracy genuinely depends on them.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.humayGround)
            .navigationTitle("Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var timeText: String {
        switch person.birth.time {
        case .unknown: "Unknown"
        case .exact: person.birth.time.formatted() ?? "Exact"
        case .approximate: person.birth.time.formatted() ?? "Approximate"
        }
    }
}
