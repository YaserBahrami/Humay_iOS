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
            case .approximate: "Approx."
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

    let onSave: (CirclePerson) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Person") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .accessibilityLabel("Name")

                    DatePicker(
                        "Birth date",
                        selection: $birthDate,
                        in: earliestDate...Date.now,
                        displayedComponents: .date
                    )
                }

                Section("Birth time") {
                    Picker("Time precision", selection: $timeKnowledge) {
                        ForEach(TimeKnowledge.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    if timeKnowledge != .unknown {
                        DatePicker(
                            timeKnowledge == .exact ? "Exact time" : "Approximate time",
                            selection: $birthTime,
                            displayedComponents: .hourAndMinute
                        )
                    }

                    Text("Unknown remains unknown. Birth place is not requested in this minimal D2 form shell.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }

                if let validationMessage {
                    Section {
                        Label(validationMessage, systemImage: "exclamationmark.circle")
                            .foregroundStyle(Color.humayCoral)
                            .accessibilityIdentifier("circle.add-person.error")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.humayGround)
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .accessibilityIdentifier("circle.add-person.save")
                }
            }
        }
    }

    private var earliestDate: Date {
        Calendar(identifier: .gregorian).date(
            from: DateComponents(year: 1900, month: 1, day: 1)
        )!
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Enter a name to add this person."
            return
        }

        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        guard let year = dateComponents.year,
              let month = dateComponents.month,
              let day = dateComponents.day else {
            validationMessage = "Choose a valid birth date."
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
