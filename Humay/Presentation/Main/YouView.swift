import SwiftUI

struct YouView: View {
    @Environment(AppEnvironment.self) private var environment

    let people: [CirclePerson]
    let profileName: String

    var body: some View {
        HumayPage(maximum: .readable) {
            HumayScreenHeader(
                section: "You",
                profileName: profileName,
                profileAction: {},
                showsProfileButton: false
            )

            identity
            birthDetails
            preferences
            savedPeople
            privacyNote
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier("you.screen")
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
            HumayEyebrow(text: "Your Humay")

            HStack(alignment: .center, spacing: HumaySpacing.extraLarge) {
                ZStack {
                    Circle()
                        .fill(Color.humaySurfaceElevated)
                    Circle()
                        .stroke(Color.humayAccentPrestige, lineWidth: 1)
                    HumayHumaMark()
                        .padding(18)
                }
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text(displayName)
                        .font(HumayTypography.displayTitle)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text(environment.settings.leadingTradition.displayName)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
        }
    }

    private var birthDetails: some View {
        HumayHairlineSurface(style: .quiet) {
            VStack(alignment: .leading, spacing: HumaySpacing.large) {
                HumaySectionHeader(title: "Birth details", editorial: false)

                if let profile = environment.profile {
                    HumayFactRow(label: "Date", value: profile.birth.dateFormatted())
                    HumayFactRow(label: "Time", value: birthTimeText(profile.birth.time))
                    HumayFactRow(label: "Place", value: profile.birth.place.name ?? "Not provided")
                    HumayFactRow(
                        label: "Precision",
                        value: profile.birth.supportsPrecision ? "Available" : "Limited by supplied details",
                        note: profile.birth.supportsPrecision
                            ? nil
                            : "Humay never substitutes a guessed birth time or place."
                    )
                } else {
                    Text("Profile details are not available.")
                        .font(HumayTypography.body)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
        }
    }

    private var preferences: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumaySectionHeader(title: "Preferences", editorial: false)
            preferenceRow(
                title: "Leading tradition",
                value: environment.settings.leadingTradition.displayName,
                glyph: .orbit
            )
            preferenceRow(
                title: "Reading tone",
                value: environment.settings.tone.displayName,
                glyph: environment.settings.tone == .roast ? .eye : .feather
            )
        }
    }

    private func preferenceRow(
        title: String,
        value: String,
        glyph: HumayGlyphKind
    ) -> some View {
        HStack(spacing: HumaySpacing.large) {
            HumayGlyph(kind: glyph)
                .frame(width: 34, height: 34)
                .foregroundStyle(Color.humayAccentPrestige)

            Text(title)
                .font(HumayTypography.bodyEmphasized)
            Spacer(minLength: HumaySpacing.small)
            Text(value)
                .font(HumayTypography.supporting)
                .foregroundStyle(Color.humayTextSecondary)
                .multilineTextAlignment(.trailing)
        }
        .frame(minHeight: HumayMetrics.minimumHitTarget)
        .padding(.vertical, HumaySpacing.small)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.humaySeparator).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var savedPeople: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumaySectionHeader(
                title: "Saved people",
                subtitle: people.isEmpty
                    ? "No saved people yet."
                    : "\(people.count) available in Connections.",
                editorial: false
            )

            ForEach(people.prefix(3)) { person in
                HStack(spacing: HumaySpacing.large) {
                    CirclePersonMedallion(person: person, accent: .gold, size: 48)
                    VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                        Text(person.name)
                            .font(HumayTypography.bodyEmphasized)
                        Text(person.westernSunSign.map { "\($0.displayName) Sun" } ?? "Sign unavailable")
                            .font(HumayTypography.supporting)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
                .frame(minHeight: HumayMetrics.minimumHitTarget)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var privacyNote: some View {
        HumayHairlineSurface(style: .celestial) {
            HStack(alignment: .top, spacing: HumaySpacing.large) {
                HumayGlyph(kind: .eye)
                    .frame(width: 38, height: 38)
                    .foregroundStyle(Color.humayAccentCelestial)

                VStack(alignment: .leading, spacing: HumaySpacing.small) {
                    Text("Your details stay explicit")
                        .font(HumayTypography.bodyEmphasized)
                    Text("Unknown time and place remain unknown. Humay uses them only when a feature genuinely needs more precision.")
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var displayName: String {
        let stored = environment.profile?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return stored.isEmpty ? profileName : stored
    }

    private func birthTimeText(_ birthTime: BirthTime) -> String {
        switch birthTime {
        case .unknown: "Unknown"
        case .exact: birthTime.formatted() ?? "Exact time"
        case .approximate: birthTime.formatted() ?? "Approximate time"
        }
    }
}
