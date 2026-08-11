import SwiftUI

/// Birth details.
///
/// The date is required; the time and place are genuinely optional and the copy says
/// what each one buys rather than nagging for completeness.
struct BirthDetailsView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var date = Date.now
    @State private var timeKnown = false
    @State private var time = Date.now
    @State private var placeName = ""
    @State private var loaded = false

    var body: some View {
        SettingsPageScaffold(title: "Birth details") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                section("Date") {
                    DatePicker("Date of birth", selection: $date, in: Self.earliest...Date.now, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                section("Time") {
                    VStack(alignment: .leading, spacing: HumaySpacing.s) {
                        Toggle("I know my birth time", isOn: $timeKnown)
                            .humayFont(.body)
                            .tint(theme.colors.accentText)

                        if timeKnown {
                            DatePicker("Time of birth", selection: $time, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }

                        Text(timeKnown
                            ? "A birth time makes the Rising sign, the houses, the Lagna and the hour pillar calculable."
                            : "Without a time, anything that depends on it stays hidden rather than being guessed. Nothing is filled in with a default.")
                            .humayFont(.callout)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                section("Place") {
                    VStack(alignment: .leading, spacing: HumaySpacing.s) {
                        TextField("City of birth", text: $placeName)
                            .humayFont(.body)
                            .textFieldStyle(.plain)
                            .frame(minHeight: HumayHitTarget.minimum)
                            .accessibilityLabel("City of birth")
                        HairlineRule()
                        Text("Longitude sets the houses, and the time zone in force on the day sets almost everything else — which is why the historical zone matters, not today's.")
                            .humayFont(.callout)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button("Save", action: save)
                    .buttonStyle(.humayPrimary)

                Text("Stored only on this device. There is no sign-in and nothing is uploaded.")
                    .humayFont(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .onAppear(perform: loadIfNeeded)
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            SectionHeader(title: title)
            content()
        }
    }

    private func loadIfNeeded() {
        guard !loaded, let profile = environment.profile else { return }
        loaded = true
        let calendar = Calendar(identifier: .gregorian)
        date = calendar.date(from: profile.birth.dateComponents) ?? .now
        if let minutes = profile.birth.time.minutesFromMidnight {
            timeKnown = true
            time = calendar.date(from: DateComponents(hour: minutes / 60, minute: minutes % 60)) ?? .now
        }
        placeName = profile.birth.place.name ?? ""
    }

    private func save() {
        guard var profile = environment.profile else { return }
        let calendar = Calendar(identifier: .gregorian)
        let dateParts = calendar.dateComponents([.year, .month, .day], from: date)
        let timeParts = calendar.dateComponents([.hour, .minute], from: time)

        profile.birth.year = dateParts.year ?? profile.birth.year
        profile.birth.month = dateParts.month ?? profile.birth.month
        profile.birth.day = dateParts.day ?? profile.birth.day

        // The unknown case is written explicitly. Nothing here can produce a
        // substituted midnight from an absent value.
        profile.birth.time = timeKnown
            ? .exact(minutesFromMidnight: (timeParts.hour ?? 0) * 60 + (timeParts.minute ?? 0))
            : .unknown

        let trimmed = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            profile.birth.place = .notProvided
        } else if case .known(_, let latitude, let longitude, let zone) = profile.birth.place {
            profile.birth.place = .known(name: trimmed, latitude: latitude, longitude: longitude, timeZoneIdentifier: zone)
        } else {
            // Geocoding is a later concern; the coordinates below are a placeholder so
            // that a named place still exercises the place-known path.
            profile.birth.place = .known(
                name: trimmed,
                latitude: 38.7167,
                longitude: -9.1333,
                timeZoneIdentifier: TimeZone.current.identifier
            )
        }

        environment.updateProfile(profile)
    }

    private static var earliest: Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? .distantPast
    }
}

struct TraditionSettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    var body: some View {
        SettingsPageScaffold(title: "Astrology tradition") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                Text("All three stay available. This sets the default vocabulary for Today and Chart.")
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 0) {
                    HairlineRule()
                    ForEach(AstrologyTradition.allCases) { tradition in
                        TraditionRow(
                            tradition: tradition,
                            isSelected: tradition == environment.settings.leadingTradition
                        ) {
                            var updated = environment.settings
                            updated.leadingTradition = tradition
                            environment.updateSettings(updated)
                        }
                        HairlineRule()
                    }
                }

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "What each one uses")
                    ForEach(AstrologyTradition.allCases) { tradition in
                        VStack(alignment: .leading, spacing: 2) {
                            MonoKicker(text: tradition.shortName)
                            Text(tradition.concepts.joined(separator: " · "))
                                .humayFont(.callout)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        .padding(.vertical, 4)
                        .accessibilityElement(children: .combine)
                    }
                    Text("Chinese astrology has no houses and no transits, and the application does not pretend otherwise.")
                        .humayFont(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

/// Tone, with both registers shown at once.
///
/// This is the only place the choice can be made informed, which is why it lives here
/// rather than in onboarding — the same day, written twice, is the whole explanation.
struct ToneSettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme
    @State private var sampleNormal: String = ""
    @State private var sampleRoast: String = ""

    var body: some View {
        SettingsPageScaffold(title: "Tone") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                Text("The same chart and the same reasoning, in a different register. Roast changes how it is said, never what it says.")
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 0) {
                    HairlineRule()
                    ForEach(Tone.allCases) { tone in
                        ToneOptionRow(
                            tone: tone,
                            sample: tone == .normal ? sampleNormal : sampleRoast,
                            isSelected: tone == environment.settings.tone
                        ) {
                            var updated = environment.settings
                            updated.tone = tone
                            environment.updateSettings(updated)
                        }
                        HairlineRule()
                    }
                }

                Text("Notifications are always written in the Normal register, whatever this is set to. Roast has no context on a lock screen and no way to be opted out of in the moment.")
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task(id: environment.sunSign?.rawValue) { await loadSamples() }
    }

    private func loadSamples() async {
        guard let sign = environment.sunSign else { return }
        let date = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        sampleNormal = (try? await environment.horoscopeService.generalReading(sign: sign, date: date, tone: .normal))?.headline ?? ""
        sampleRoast = (try? await environment.horoscopeService.generalReading(sign: sign, date: date, tone: .roast))?.headline ?? ""
    }
}

struct ToneOptionRow: View {
    let tone: Tone
    let sample: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                HStack {
                    Text(tone.displayName)
                        .humayFont(.titleS)
                        .foregroundStyle(tone == .roast && isSelected ? theme.colors.roast : theme.colors.textPrimary)
                    Spacer(minLength: HumaySpacing.xs)
                    Image(systemName: "checkmark")
                        .font(.system(size: HumayIconSize.inline, weight: .medium))
                        .foregroundStyle(theme.colors.accentText)
                        .opacity(isSelected ? 1 : 0)
                }
                Text(tone.descriptor)
                    .humayFont(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                if !sample.isEmpty {
                    Text("“\(sample)”")
                        .humayFont(.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, HumaySpacing.s)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tone.displayName). \(tone.descriptor). Example: \(sample)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

struct NotificationSettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    var body: some View {
        @Bindable var environmentBinding = environment

        SettingsPageScaffold(title: "Notifications") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                Text("Notifications are always in the Normal register, whatever your in-app tone is set to. There is no engagement loop here — nothing is sent to bring you back.")
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 0) {
                    HairlineRule()
                    toggle("Your morning reading", "Once a day.", keyPath: \.morningReading)
                    toggle("Someone in your Circle", "Only when something significant touches both charts.", keyPath: \.todayTogether)
                    toggle("A meaningful transit begins", "Not every transit. The ones that reach your chart.", keyPath: \.meaningfulTransit)
                    toggle("New and Full Moons", "Twice a month.", keyPath: \.lunarPhases)
                    toggle("Quiet hours", "10 PM to 7 AM.", keyPath: \.quietHoursEnabled)
                }

                Text("Delivery is not implemented yet — these preferences are stored, but no notification is scheduled.")
                    .humayFont(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func toggle(
        _ title: String,
        _ detail: String,
        keyPath: WritableKeyPath<NotificationSettings, Bool>
    ) -> some View {
        VStack(spacing: 0) {
            Toggle(isOn: Binding(
                get: { environment.settings.notifications[keyPath: keyPath] },
                set: { newValue in
                    var updated = environment.settings
                    updated.notifications[keyPath: keyPath] = newValue
                    environment.updateSettings(updated)
                }
            )) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .humayFont(.body)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(detail)
                        .humayFont(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
            .tint(theme.colors.accentText)
            .frame(minHeight: HumayHitTarget.minimum)
            HairlineRule()
        }
    }
}

struct SubscriptionPlaceholderView: View {
    @Environment(\.humayTheme) private var theme

    var body: some View {
        SettingsPageScaffold(title: "Premium") {
            VStack(alignment: .leading, spacing: HumaySpacing.m) {
                Text("Not available yet.")
                    .humayFont(.displayM)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("Humay Premium is planned but not built. There is no purchase flow in this version, nothing is gated, and every reading in the application is open.")
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HairlineRule()

                Text("When it does arrive it will be a subscription rather than a one-off unlock, and the wording here will say so plainly.")
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct PrivacyDataView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme
    @State private var confirmingDeleteAll = false
    @State private var confirmingDeleteAstrology = false

    var body: some View {
        SettingsPageScaffold(title: "Privacy & data") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                Text("There is no sign-in here. Humay keeps a local profile on this device, and this is exactly what it is used for.")
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: HumaySpacing.m) {
                    dataRow(
                        "Your birth date, time and place",
                        "Used to work out your chart. Nothing is uploaded and nobody else can see it."
                    )
                    dataRow(
                        "Birth data for people in your Circle",
                        "Entered by you, for relationship readings. Those people have no profile here and cannot see this."
                    )
                    dataRow(
                        "Never sold, never shared",
                        "No advertisers, no data brokers, no analytics. This version has no network code at all."
                    )
                }

                VStack(spacing: 0) {
                    HairlineRule()
                    destructiveRow("Delete astrology data") { confirmingDeleteAstrology = true }
                    destructiveRow("Delete everything") { confirmingDeleteAll = true }
                }
            }
        }
        .confirmationDialog(
            "Delete your birth details, your Circle and your conversations?",
            isPresented: $confirmingDeleteAstrology,
            titleVisibility: .visible
        ) {
            Button("Delete astrology data", role: .destructive) {
                environment.deleteAstrologyData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your preferences are kept. This cannot be undone.")
        }
        .confirmationDialog(
            "Delete everything and start over?",
            isPresented: $confirmingDeleteAll,
            titleVisibility: .visible
        ) {
            Button("Delete everything", role: .destructive) {
                environment.deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Removes your profile, your Circle, your conversations and your preferences. This cannot be undone.")
        }
    }

    @ViewBuilder
    private func dataRow(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .humayFont(.titleS)
                .foregroundStyle(theme.colors.textPrimary)
            Text(detail)
                .humayFont(.callout)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func destructiveRow(_ title: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Text(title)
                        .humayFont(.body)
                        .foregroundStyle(theme.colors.roast)
                    Spacer()
                }
                .frame(minHeight: HumayHitTarget.minimum)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            HairlineRule()
        }
    }
}

struct HelpSupportView: View {
    @Environment(\.humayTheme) private var theme

    var body: some View {
        SettingsPageScaffold(title: "Help & support") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                helpItem(
                    "Why is some of my chart missing?",
                    "Anything that depends on your birth time — the Rising sign, the houses, the Lagna, the hour pillar — is withheld rather than estimated when the time is unknown. A placement with the wrong time is worse than no placement, so nothing is filled in with a default."
                )
                helpItem(
                    "How do I find my birth time?",
                    "A birth certificate is the usual source; in some countries the long-form version carries it while the short one does not. Hospital records and a parent's memory are the next best options — and an approximate time is genuinely useful, because the application can show what does and does not depend on the difference."
                )
                helpItem(
                    "Why do the three traditions disagree?",
                    "They are not measuring the same thing. Western reads the sky against the seasons, Vedic against the fixed stars, and Chinese astrology reads element interactions across four pillars and has no houses or transits at all. Humay keeps them separate rather than blending them into a single verdict."
                )
                helpItem(
                    "Where is my data?",
                    "On this device. There is no sign-in, no server and no network code in this version."
                )
            }
        }
    }

    @ViewBuilder
    private func helpItem(_ question: String, _ answer: String) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            HairlineRule()
            Text(question)
                .humayFont(.titleS)
                .foregroundStyle(theme.colors.textPrimary)
                .padding(.top, HumaySpacing.xs)
                .fixedSize(horizontal: false, vertical: true)
            Text(answer)
                .humayFont(.bodySmall)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct AboutHumayView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    var body: some View {
        SettingsPageScaffold(title: "About Humay") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                HStack(spacing: HumaySpacing.s) {
                    OccultationMark(size: 30)
                    Wordmark(size: 17)
                }

                Text("Humay reads the sky in three traditions and shows the reasoning behind every reading, rather than asserting.")
                    .humayFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "This version")
                    Text("Every astrological value in this build is illustrative sample content. Nothing is calculated from an ephemeris, no reading is generated, and no astrology or interpretation service is connected. Treat the placements, degrees, pillars and transits you see as placeholders for a real calculation layer.")
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "Version")
                    MonoFact(text: Self.versionLine)
                    MonoFact(text: "CONTENT · \(environment.contentMode == .mock ? "SAMPLE FIXTURES" : "LIVE")")
                }

                VStack(alignment: .leading, spacing: HumaySpacing.s) {
                    SectionHeader(title: "Typeface")
                    Text("Cormorant Garamond by Christian Thalmann, used under the SIL Open Font License 1.1. Everything else is set in the system typefaces.")
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private static var versionLine: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "0"
        let build = info?["CFBundleVersion"] as? String ?? "0"
        return "HUMAY \(version) (\(build))"
    }
}
