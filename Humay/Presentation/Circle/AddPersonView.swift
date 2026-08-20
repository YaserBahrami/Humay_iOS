import SwiftUI

struct AddPersonView: View {
    private enum TimeKnowledge: String, CaseIterable, Identifiable {
        case unknown
        case approximate
        case exact

        var id: String { rawValue }

        var label: String {
            switch self {
            case .unknown: "Unknown"
            case .approximate: "Approximate"
            case .exact: "Exact"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var birthDate = Date.now
    @State private var timeKnowledge: TimeKnowledge = .unknown
    @State private var birthTime = Date.now
    @State private var validationMessage: String?
    @FocusState private var nameIsFocused: Bool
    @AccessibilityFocusState private var validationIsFocused: Bool

    let onSave: (CirclePerson) -> Void

    var body: some View {
        NavigationStack {
            Form {
                introduction
                validationSection
                identitySection
                birthDateSection
                birthTimeSection
                locationSection
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .frame(maxWidth: HumayContentWidth.form.rawValue)
            .frame(maxWidth: .infinity)
            .background(Color.humayCanvas)
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .accessibilityHint("Adds this person with the entered birth information")
                        .accessibilityIdentifier("circle.add-person.save")
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        nameIsFocused = false
                    }
                }
            }
        }
    }

    private var introduction: some View {
        Section {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                HumayEyebrow(text: "Known details only", color: .humayAccentCelestial)
                Text("Add what you know")
                    .font(HumayTypography.narrativeSectionTitle)
                    .accessibilityAddTraits(.isHeader)
                Text("A name and birth date are used in this flow. Birth time may stay unknown, and location is not requested here.")
                    .font(HumayTypography.supporting)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, HumaySpacing.small)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("circle.add-person.screen")
        }
        .listRowBackground(Color.humaySurface)
    }

    private var identitySection: some View {
        Section {
            TextField("Name", text: $name)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .focused($nameIsFocused)
                .onSubmit {
                    nameIsFocused = false
                }
                .onChange(of: name) {
                    if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        validationMessage = nil
                    }
                }
                .accessibilityLabel("Name")
                .accessibilityIdentifier("circle.add-person.name")
        } header: {
            Text("Person")
        } footer: {
            Text("Use the name you want to recognize in Connections.")
        }
    }

    private var birthDateSection: some View {
        Section {
            DatePicker(
                "Birth date",
                selection: $birthDate,
                in: earliestDate...Date.now,
                displayedComponents: .date
            )
            .accessibilityIdentifier("circle.add-person.birth-date")
        } header: {
            Text("Birth date")
        } footer: {
            Text("This existing form requires a valid date between 1900 and today.")
        }
    }

    private var birthTimeSection: some View {
        Section {
            Picker("What do you know?", selection: $timeKnowledge) {
                ForEach(TimeKnowledge.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Birth time knowledge")
            .accessibilityIdentifier("circle.add-person.time-knowledge")

            if timeKnowledge != .unknown {
                DatePicker(
                    timeKnowledge == .exact ? "Exact time" : "Approximate time",
                    selection: $birthTime,
                    displayedComponents: .hourAndMinute
                )
                .accessibilityIdentifier("circle.add-person.birth-time")
            }
        } header: {
            Text("Birth time")
        } footer: {
            Text(timeKnowledgeFooter)
        }
    }

    private var locationSection: some View {
        Section {
            Label("Not provided in this flow", systemImage: "mappin.slash")
                .foregroundStyle(Color.humayTextSecondary)
                .accessibilityIdentifier("circle.add-person.location-unavailable")
        } header: {
            Text("Birth location")
        } footer: {
            Text("Location is not required to add a person. A future precision-dependent flow may request it explicitly.")
        }
    }

    @ViewBuilder
    private var validationSection: some View {
        if let validationMessage {
            Section {
                HStack(alignment: .top, spacing: HumaySpacing.medium) {
                    Image(systemName: "exclamationmark.circle")
                        .accessibilityHidden(true)
                    Text(validationMessage)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityFocused($validationIsFocused)
                        .accessibilityIdentifier("circle.add-person.error")
                }
                    .foregroundStyle(.red)
            }
        }
    }

    private var timeKnowledgeFooter: String {
        switch timeKnowledge {
        case .unknown:
            "Unknown is a valid answer. Humay will not substitute a hidden time."
        case .approximate:
            "Approximate time is stored with the existing one-hour tolerance."
        case .exact:
            "Use Exact only when the clock time is known."
        }
    }

    private var earliestDate: Date {
        Calendar(identifier: .gregorian).date(
            from: DateComponents(year: 1900, month: 1, day: 1)
        )!
    }

    private func save() {
        nameIsFocused = false
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Enter a name to add this person."
            validationIsFocused = true
            return
        }

        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        guard let year = dateComponents.year,
              let month = dateComponents.month,
              let day = dateComponents.day else {
            validationMessage = "Choose a valid birth date."
            validationIsFocused = true
            return
        }

        let time: BirthTime
        switch timeKnowledge {
        case .unknown:
            time = .unknown
        case .approximate, .exact:
            let components = calendar.dateComponents([.hour, .minute], from: birthTime)
            let minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            time = timeKnowledge == .exact
                ? .exact(minutesFromMidnight: minutes)
                : .approximate(minutesFromMidnight: minutes, toleranceMinutes: 60)
        }

        onSave(
            CirclePerson(
                name: trimmedName,
                birth: BirthDetails(
                    year: year,
                    month: month,
                    day: day,
                    time: time,
                    place: .notProvided
                )
            )
        )
        dismiss()
    }
}
