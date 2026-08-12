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
                    D2WordmarkHeader(
                        title: "Circle",
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
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.humayLavender)
                    Text("Opening your Circle…")
                        .font(HumayTypography.cardTitle)
                    Text("Development loading state. No data source is being contacted.")
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
                title: "Circle is unavailable",
                detail: message
            )
        }
    }

    @ViewBuilder
    private func loadedContent(people: [CirclePerson], availableWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text("Your cosmic circle")
                .font(HumayTypography.heroTitle)
                .accessibilityAddTraits(.isHeader)
            Text("Keep the people who matter close, then explore connection with honest precision labels.")
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
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

        D2SampleNotice(source: source)
    }

    private func peopleSection(_ people: [CirclePerson]) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HStack(spacing: HumaySpacing.medium) {
                Text("People")
                    .font(.title3.weight(.semibold))
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
            HumayCosmicSurface {
                VStack(alignment: .leading, spacing: HumaySpacing.large) {
                    HStack(alignment: .top, spacing: HumaySpacing.medium) {
                        VStack(alignment: .leading, spacing: HumaySpacing.small) {
                            Text("Compatibility")
                                .font(HumayTypography.utility)
                                .textCase(.uppercase)
                                .tracking(1.1)
                                .foregroundStyle(Color.humayCoral)
                            Text("See how two energies meet")
                                .font(HumayTypography.cardTitle)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: HumaySpacing.small)

                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.humayCoral)
                            .accessibilityHidden(true)
                    }

                    Text("Start with a coarse Western Sun-sign pair. Precise synastry stays a separate future provider-backed path.")
                        .font(HumayTypography.supporting)
                        .fixedSize(horizontal: false, vertical: true)

                    Label(
                        eligiblePeople.count >= 2 ? "Choose two people" : "Add two people with sign data",
                        systemImage: "arrow.right"
                    )
                    .font(HumayTypography.control)
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
                Image(systemName: "person.2.badge.plus")
                    .font(.largeTitle)
                    .foregroundStyle(Color.humayLavender)
                    .accessibilityHidden(true)
                Text("Your Circle starts here")
                    .font(HumayTypography.cardTitle)
                    .accessibilityAddTraits(.isHeader)
                Text("Add someone’s basic birth details. Exact time and location stay optional and unknown stays honest.")
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
                                .font(.title2.weight(.semibold))
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
                    Text("This D2 shell does not persist or calculate new person data. Full editing and storage remain owned by CIRCLE-001 and later approved UI.")
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
