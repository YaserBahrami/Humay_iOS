import SwiftUI

/// Adding someone.
///
/// A birth date is the only requirement, and the copy says why: sign-to-sign
/// compatibility follows from dates. Time and place are offered without being asked for.
struct AddPersonSheet: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.humayTheme) private var theme

    @State private var name = ""
    @State private var role: RelationshipRole = .friend
    @State private var birthDate = Self.defaultDate
    @State private var timeKnown = false
    @State private var birthTime = Date.now
    @State private var placeName = ""

    var body: some View {
        NavigationStack {
            DetailScaffold(title: "Add someone") {
                field("Name") {
                    TextField("Their name", text: $name)
                        .humayFont(.body)
                        .textFieldStyle(.plain)
                        .textContentType(.givenName)
                        .frame(minHeight: HumayHitTarget.minimum)
                }

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "And to you, they are")
                    Picker("Relationship", selection: $role) {
                        ForEach(RelationshipRole.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(theme.colors.accentText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                field("Birth date") {
                    DatePicker("Birth date", selection: $birthDate, in: Self.earliest...Date.now, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "Optional")
                    Toggle("I know their birth time", isOn: $timeKnown)
                        .humayFont(.body)
                        .tint(theme.colors.accentText)
                    if timeKnown {
                        DatePicker("Birth time", selection: $birthTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    TextField("City of birth", text: $placeName)
                        .humayFont(.body)
                        .textFieldStyle(.plain)
                        .frame(minHeight: HumayHitTarget.minimum)
                    HairlineRule()
                    Text("Only their birth date is needed for a sign-to-sign reading. A time and place add what a full chart comparison needs.")
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Only you can see this. The person you are adding has no profile here.")
                    .humayFont(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    @ViewBuilder
    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            SectionHeader(title: title)
            content()
        }
    }

    private func save() {
        let calendar = Calendar(identifier: .gregorian)
        let dateParts = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let timeParts = calendar.dateComponents([.hour, .minute], from: birthTime)
        let trimmedPlace = placeName.trimmingCharacters(in: .whitespacesAndNewlines)

        let person = CirclePerson(
            name: name.trimmingCharacters(in: .whitespaces),
            role: role,
            birth: BirthDetails(
                year: dateParts.year ?? 1990,
                month: dateParts.month ?? 1,
                day: dateParts.day ?? 1,
                time: timeKnown
                    ? .exact(minutesFromMidnight: (timeParts.hour ?? 0) * 60 + (timeParts.minute ?? 0))
                    : .unknown,
                place: trimmedPlace.isEmpty
                    ? .notProvided
                    : .known(
                        name: trimmedPlace,
                        latitude: 38.7167,
                        longitude: -9.1333,
                        timeZoneIdentifier: TimeZone.current.identifier
                    )
            )
        )
        environment.savePerson(person)
        dismiss()
    }

    private static var defaultDate: Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: 1995, month: 6, day: 15)) ?? .now
    }

    private static var earliest: Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? .distantPast
    }
}

/// One person, and the ways into a reading about the two of you.
struct PersonDetailView: View {
    let personID: UUID

    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var confirmingRemoval = false

    private var person: CirclePerson? {
        environment.people.first { $0.id == personID }
    }

    var body: some View {
        DetailScaffold(title: person?.name ?? "Person") {
            if let person {
                content(person)
            } else {
                EmptyStateView(title: "Not found", message: "This person is no longer in your Circle.")
            }
        }
        .confirmationDialog(
            "Remove \(person?.name ?? "this person") from your Circle?",
            isPresented: $confirmingRemoval,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                environment.deletePerson(id: personID)
                router.popToRoot(.circle)
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func content(_ person: CirclePerson) -> some View {
        let sign = MockAstrology.sunSign(for: person.birth)

        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            MonoKicker(text: person.role.displayName)
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.xs) {
                Text(person.name)
                    .humayFont(.displayL)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                GlyphLabel(
                    glyph: sign.glyph,
                    spokenName: sign.spokenName,
                    role: .titleM,
                    color: theme.colors.accentMark
                )
            }
        }

        VStack(spacing: 0) {
            HairlineRule()
            detailRow("Born", person.birth.dateFormatted())
            detailRow("Sun", sign.spokenName)
            detailRow("Birth time", person.birth.time.formatted() ?? "Not set")
            detailRow("Birth place", person.birth.place.name ?? "Not set")
        }

        if !person.birth.supportsPrecision {
            UnavailableFactView(reason: person.birth.time.isKnown ? .requiresBirthPlace : .requiresBirthTime, compact: true)
        }

        VStack(alignment: .leading, spacing: HumaySpacing.m) {
            SectionHeader(title: "Together")

            HumayDisclosureRow(
                title: "Compatibility",
                detail: "A general reading, from the two of your birth dates."
            ) {
                router.push(.compatibility(personID: person.id, tier: .general), on: .circle)
            }
            HairlineRule()

            PreciseEntryPoint(
                title: "Precise compatibility",
                message: "Both charts read against each other — what a pair of dates cannot reach.",
                actionTitle: "Open precise compatibility"
            ) {
                router.push(.compatibility(personID: person.id, tier: .precise), on: .circle)
            }
        }

        Button("Remove from Circle") { confirmingRemoval = true }
            .buttonStyle(.humayQuiet)
            .foregroundStyle(theme.colors.roast)
            .padding(.top, HumaySpacing.m)
    }

    @ViewBuilder
    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(spacing: 0) {
            AdaptiveRow {
                Text(label)
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } trailing: {
                Text(value)
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(dynamicTypeSize.rowTrailingAlignment)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, HumaySpacing.s)
            HairlineRule()
        }
        .accessibilityElement(children: .combine)
    }
}
