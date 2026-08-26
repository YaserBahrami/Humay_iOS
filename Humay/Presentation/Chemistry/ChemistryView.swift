import SwiftUI

/// Chemistry — saved people and compatibility entertainment.
/// A private relationship playground; there is no social network here.
struct ChemistryView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation

    @State private var showAddPerson = false
    @State private var detailPerson: ConnectionPerson?
    @State private var selection: [ConnectionPerson] = []
    @State private var activePair: (ConnectionPerson, ConnectionPerson)?

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    HumayWordmarkHeader(
                        title: "Chemistry",
                        profileName: profileDisplayName,
                        profileAction: { navigation.auxiliaryRoute = .profileSettings }
                    )

                    intro

                    if people.isEmpty {
                        emptyState
                    } else {
                        peopleGrid
                    }
                }
                .padding(.top, HumaySpacing.medium)
                .padding(.bottom, 120)
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                compareBar
                    .padding(.horizontal, HumaySpacing.extraLarge)
                    .padding(.bottom, HumaySpacing.large)
            }
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddPerson) {
            AddPersonSheet()
                .environment(environment)
        }
        .sheet(item: $detailPerson) { person in
            PersonDetailSheet(person: person)
                .environment(environment)
        }
        .fullScreenCover(item: activePairWrapper) { pair in
            CompatibilityCollisionView(first: pair.first, second: pair.second)
        }
    }

    private struct PairBox: Identifiable {
        let first: ConnectionPerson
        let second: ConnectionPerson
        var id: String { first.id.uuidString + second.id.uuidString }
    }

    private var activePairWrapper: Binding<PairBox?> {
        Binding(
            get: {
                guard let pair = activePair else { return nil }
                return PairBox(first: pair.0, second: pair.1)
            },
            set: { newValue in
                if let newValue {
                    activePair = (newValue.first, newValue.second)
                } else {
                    activePair = nil
                    selection = []
                }
            }
        )
    }

    private var people: [ConnectionPerson] { environment.people }

    private var profileDisplayName: String {
        let persisted = environment.profile?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let persisted, !persisted.isEmpty {
            return persisted
        }
        return "friend"
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Text("Who's in your orbit?")
                .font(HumayTypography.heroTitle)
                .accessibilityAddTraits(.isHeader)

            Text("Add a partner, a crush, an ex you're definitely over, or whoever keeps the group chat interesting.")
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var emptyState: some View {
        HumaySurface(level: .raised) {
            VStack(spacing: HumaySpacing.large) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(HumayTypography.statusSymbol)
                    .foregroundStyle(Color.humayLavender)
                    .frame(minHeight: 44)

                Text("No one to analyze yet.")
                    .font(HumayTypography.cardTitle)

                Text("Add someone and let the analysis begin. It's affectionate. Mostly.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    showAddPerson = true
                } label: {
                    Label("Add Person", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: HumayMetrics.primaryControlMinimumHeight - 12)
                }
                .buttonStyle(.humayPrimary)
                .accessibilityIdentifier("chemistry.empty.add-person")
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var peopleGrid: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HStack(spacing: HumaySpacing.medium) {
                Text("People")
                    .font(HumayTypography.sectionTitle)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    showAddPerson = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(HumayTypography.control)
                        .frame(minHeight: HumayMetrics.minimumHitTarget)
                }
                .accessibilityIdentifier("chemistry.add-person")
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150), spacing: HumaySpacing.medium)],
                spacing: HumaySpacing.medium
            ) {
                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                    PersonCard(
                        person: person,
                        accent: index.isMultiple(of: 2) ? .lavender : .coral,
                        selectionRank: selectionRank(of: person),
                        onTap: { toggleSelection(person) },
                        onDetail: { detailPerson = person }
                    )
                }
            }

            if selection.count == 2 {
                Text("Two selected. See what the universe thinks.")
                    .font(HumayTypography.caption)
                    .foregroundStyle(Color.humayTextSecondary)
            }
        }
    }

    /// Sticky call-to-action once two people are selected.
    @ViewBuilder
    private var compareBar: some View {
        if let first = selection.first, let second = selection.last, selection.count == 2 {
            Button {
                HumayHaptics.thump()
                activePair = (first, second)
            } label: {
                Label("See your chemistry", systemImage: "sparkles.rectangle.stack.fill")
                    .font(HumayTypography.control)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: HumayMetrics.primaryControlMinimumHeight)
            }
            .buttonStyle(.humayPrimary)
            .shadow(color: .black.opacity(0.18), radius: 16, y: 6)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .accessibilityIdentifier("chemistry.compare.run")
        }
    }

    private func selectionRank(of person: ConnectionPerson) -> Int? {
        selection.firstIndex(where: { $0.id == person.id }).map { $0 + 1 }
    }

    private func toggleSelection(_ person: ConnectionPerson) {
        if let index = selection.firstIndex(where: { $0.id == person.id }) {
            selection.remove(at: index)
            HumayHaptics.tap()
        } else if selection.count < 2 {
            selection.append(person)
            HumayHaptics.tap()
        } else {
            selection = [selection[1], person]
            HumayHaptics.thump()
        }
    }
}

// MARK: - Person card

private struct PersonCard: View {
    let person: ConnectionPerson
    let accent: HumayAccent
    let selectionRank: Int?
    let onTap: () -> Void
    let onDetail: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            selectionCard

            Button {
                onDetail()
            } label: {
                Label("Details", systemImage: "info.circle")
                    .font(HumayTypography.caption.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.humayTextSecondary)
            .accessibilityLabel("Details about \(person.name)")
            .accessibilityIdentifier("chemistry.person.detail.\(person.id.uuidString)")
        }
        .accessibilityElement(children: .contain)
    }

    /// Selection target. Plain-style Button keeps synthetic taps reliable.
    private var selectionCard: some View {
        Button(action: onTap) {
            VStack(spacing: HumaySpacing.small) {
                ZStack(alignment: .topTrailing) {
                    PersonMedallion(person: person, accent: accent, size: 78)
                        .frame(maxWidth: .infinity)

                    if let rank = selectionRank {
                        Circle()
                            .fill(Color.humayCoral)
                            .frame(width: 24, height: 24)
                            .overlay {
                                Text("\(rank)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color.humayGround)
                            }
                            .offset(x: 6, y: -4)
                    }
                }

                Text(person.name)
                    .font(HumayTypography.bodyEmphasized)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(person.westernSunSign.map { "\($0.displayName) · \(person.displayLabel)" } ?? person.displayLabel)
                    .font(HumayTypography.caption)
                    .foregroundStyle(Color.humayTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(HumaySpacing.large)
            .background(
                selectionRank != nil ? Color.humaySurface : Color.humaySurface.opacity(0.85),
                in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                    .strokeBorder(selectionRank != nil ? Color.humayCoral : Color.humayHairline, lineWidth: selectionRank != nil ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
    }
}

// MARK: - Add person

struct AddPersonSheet: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var kind: RelationshipKind = .friend
    @State private var customLabel = ""
    @State private var pickerDate = Date.now
    @State private var errorMessage: String?

    private var validDateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let earliest = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? .now
        let today = min(calendar.startOfDay(for: .now), .now)
        return earliest...today
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .accessibilityIdentifier("chemistry.add.name")

                    Picker("Relationship", selection: $kind) {
                        ForEach(RelationshipKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }

                    if kind == .custom {
                        TextField("What are they, exactly?", text: $customLabel)
                    }
                } header: {
                    Text("Who is it?")
                }

                Section {
                    DatePicker(
                        "Birth date",
                        selection: $pickerDate,
                        in: validDateRange,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxHeight: 180)
                    .clipped()
                    .accessibilityLabel("Birth date")
                } header: {
                    Text("When did they arrive?")
                } footer: {
                    Text("Date only. The fun parts don't need their exact minute — and Humay never fakes one.")
                }

                Section {
                    Button("Save") {
                        save()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(HumayTypography.caption)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("New person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Even mystery people need a name."
            return
        }

        let components = Calendar.current.dateComponents([.year, .month, .day], from: pickerDate)
        guard let year = components.year, let month = components.month, let day = components.day else {
            errorMessage = "That date didn't parse. Try again?"
            return
        }

        let person = ConnectionPerson(
            name: trimmedName,
            relationshipKind: kind,
            customLabel: kind == .custom ? customLabel.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            birth: BirthDetails(year: year, month: month, day: day)
        )

        Task { @MainActor in
            do {
                try await environment.addPerson(person)
                HumayHaptics.success()
                dismiss()
            } catch {
                HumayHaptics.warning()
                errorMessage = "Couldn't save them. Try again?"
            }
        }
    }
}

// MARK: - Person detail

struct PersonDetailSheet: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss

    let person: ConnectionPerson
    @State private var removalFailed = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: HumaySpacing.large) {
                        PersonMedallion(person: person, accent: .lavender, size: 72)
                        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                            Text(person.name)
                                .font(HumayTypography.sectionTitle)
                            Text(person.displayLabel)
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
                    Text("Birth time and place stay optional. Humay only uses them when something genuinely depends on them — and says so when something does.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }

                Section {
                    Button(role: .destructive) {
                        remove()
                    } label: {
                        Text("Remove \(person.name)")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Couldn't remove them", isPresented: $removalFailed) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("They're still here. Try again in a moment.")
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func remove() {
        Task { @MainActor in
            do {
                try await environment.removePerson(id: person.id)
                HumayHaptics.thump()
                dismiss()
            } catch {
                removalFailed = true
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
