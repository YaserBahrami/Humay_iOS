import SwiftUI

/// You — personal identity (Big Three + Humay archetype) and the rolling
/// one-year entertainment forecast.
struct YouView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppNavigationState.self) private var navigation
    @Environment(ForecastStore.self) private var forecasts

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: HumaySpacing.extraLarge) {
                    HumayWordmarkHeader(
                        title: "You",
                        profileName: profileDisplayName,
                        profileAction: { navigation.auxiliaryRoute = .profileSettings }
                    )

                    if let profile = environment.profile {
                        IdentitySection(profile: profile)

                        ArchetypeCard(archetype: HumayContentEngine.archetype(profileID: profile.id))
                            .accessibilityIdentifier("you.archetype")

                        YearTimelineSection(subject: profile.forecastSubject)
                            .accessibilityIdentifier("you.timeline")
                    } else {
                        Text("Add your birth date in Profile to unlock this.")
                            .font(HumayTypography.body)
                            .foregroundStyle(Color.humayTextSecondary)
                    }
                }
                .padding(.top, HumaySpacing.medium)
                .padding(.bottom, HumaySpacing.extraExtraLarge)
                .frame(maxWidth: HumayContentWidth.expanded.rawValue)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .padding(.horizontal, HumayLayout.screenGutter(for: proxy.size.width))
            .scrollIndicators(.hidden)
        }
        .background(Color.humayGround.ignoresSafeArea())
        .foregroundStyle(Color.humayTextPrimary)
        .navigationBarHidden(true)
        .task {
            if let profile = environment.profile {
                forecasts.ensureForecast(for: profile.forecastSubject)
            }
        }
    }

    private var profileDisplayName: String {
        let persisted = environment.profile?.displayName
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (persisted?.isEmpty == false ? persisted : nil) ?? "friend"
    }
}

// MARK: - Identity

/// Humay's one-liners per sign — Level 1 of the three-layer disclosure.
extension WesternZodiacSign {
    var humayTagline: String {
        switch self {
        case .aries: "The part of you that already hit send."
        case .taurus: "The part of you that already decided."
        case .gemini: "Your public beta version."
        case .cancer: "Feelings, but make them home."
        case .leo: "Assumes the spotlight is load-bearing."
        case .virgo: "Correctness as a lifestyle."
        case .libra: "The part of you still deciding."
        case .scorpio: "You know what you did."
        case .sagittarius: "Blunt instrument, excellent aim."
        case .capricorn: "Feelings, but with project management."
        case .aquarius: "Normal was never the assignment."
        case .pisces: "Streaming three realities simultaneously."
        }
    }
}

/// Three-layer disclosure: fun label → human explanation → traditional basis.
struct IdentitySection: View {
    let profile: UserProfile

    private var bigThree: BigThree? {
        profile.forecastSubject.bigThree()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.large) {
            HumayKickerLabel(text: "The big three")

            VStack(spacing: HumaySpacing.medium) {
                sunRow
                moonRow
                risingRow
            }

            #if DEBUG
            if let bt = bigThree, let json = BigThreeDebug.json(for: profile.birth) {
                BigThreeDebugView(json: json, birthUTC: bt.metadata.calculatedAt.formatted())
            }
            #endif
        }
    }

    // MARK: - Rows driven by deterministic BigThree

    @ViewBuilder
    private var sunRow: some View {
        if let bt = bigThree {
            switch bt.sun {
            case .available(let pos):
                DisclosureRow(
                    title: "\(pos.sign.displayName) Sun",
                    subtitle: pos.sign.humayTagline,
                    humanExplanation: "Your Sun sign is the zodiac season you were born into — the classic \"what's your sign\" answer. Astrologers treat it as your core character sheet.",
                    traditionalBasis: String(format: "Tropical Sun at %.1f° longitude — %.1f° %@. Deterministic, offline, no AI.", pos.longitudeDegrees, pos.degreeWithinSign, pos.sign.displayName)
                )
            case .ambiguous(let opts):
                let names = opts.map(\.sign.displayName).joined(separator: " or ")
                WithheldRow(
                    title: "Sun sign",
                    tease: "Could be \(names)",
                    detail: "Your birth date sits on a Sun cusp. Add your birth time and Humay can lock it in exactly."
                )
            case .unavailable:
                fallbackSunRow
            }
        } else {
            fallbackSunRow
        }
    }

    private var fallbackSunRow: some View {
        let sign = SunSignCalendar.westernSunSign(month: profile.birth.month, day: profile.birth.day)
        return Group {
            if let sign {
                DisclosureRow(
                    title: "\(sign.displayName) Sun",
                    subtitle: sign.humayTagline,
                    humanExplanation: "Your Sun sign is the zodiac season you were born into — the classic \"what's your sign\" answer.",
                    traditionalBasis: "Date-table Sun (no birth time). With time + place Humay upgrades to longitude-correct Sun."
                )
            } else {
                LabeledContent("Sun", value: "Add a birth date")
            }
        }
    }

    @ViewBuilder
    private var moonRow: some View {
        if let bt = bigThree {
            switch bt.moon {
            case .available(let pos):
                DisclosureRow(
                    title: "\(pos.sign.displayName) Moon",
                    subtitle: pos.sign.humayTagline,
                    humanExplanation: "The Moon moves fast; its sign colours your emotional weather. Astrologers read it as your inner life.",
                    traditionalBasis: String(format: "Tropical Moon at %.1f° longitude — %.1f° %@.", pos.longitudeDegrees, pos.degreeWithinSign, pos.sign.displayName)
                )
            case .ambiguous(let opts):
                let names = opts.map(\.sign.displayName).joined(separator: " or ")
                WithheldRow(
                    title: "Moon",
                    tease: "Could be \(names)",
                    detail: "Your birth time is needed to know for sure. The Moon changes signs every couple of days, so Humay won't guess."
                )
            case .unavailable(let reason):
                WithheldRow(
                    title: "Moon",
                    tease: reason == .missingBirthPlace ? "Add your birth place to see your Moon." : "This one needs to know what time you showed up.",
                    detail: "The Moon changes signs every couple of days, so Humay won't guess. Add your birth time anytime — no fake precision, ever."
                )
            }
        } else {
            WithheldRow(
                title: "Moon",
                tease: "This one needs to know what time you showed up.",
                detail: "The Moon changes signs every couple of days, so Humay won't guess. Add your birth time anytime — no fake precision, ever."
            )
        }
    }

    @ViewBuilder
    private var risingRow: some View {
        if let bt = bigThree {
            switch bt.rising {
            case .available(let pos):
                DisclosureRow(
                    title: "\(pos.sign.displayName) Rising",
                    subtitle: pos.sign.humayTagline,
                    humanExplanation: "Your Rising is the sign coming over the horizon when you were born — astrologers' shorthand for first impressions.",
                    traditionalBasis: String(format: "Ascendant at %.1f° longitude — %.1f° %@. Computed from exact time, latitude and historical timezone.", pos.longitudeDegrees, pos.degreeWithinSign, pos.sign.displayName)
                )
            case .ambiguous:
                WithheldRow(
                    title: "Rising",
                    tease: "Birth time needed",
                    detail: "The Rising sign depends on the minute and coordinates of your arrival. Humay would rather show nothing than invent something."
                )
            case .unavailable:
                WithheldRow(
                    title: "Rising",
                    tease: "Birth time needed",
                    detail: "The Rising sign depends on the minute and coordinates of your arrival. Humay would rather show nothing than invent something."
                )
            }
        } else {
            WithheldRow(
                title: "Rising",
                tease: "Needs your birth time and place. Call your mom if necessary.",
                detail: "The Rising sign depends on the minute and coordinates of your arrival. Humay would rather show nothing than invent something."
            )
        }
    }
}

#if DEBUG
private struct BigThreeDebugView: View {
    let json: String
    let birthUTC: String
    @State private var expanded = false
    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.small) {
            Button { withAnimation(HumayMotion.snappy) { expanded.toggle() } } label: {
                HStack {
                    Text("Big Three debug")
                        .font(HumayTypography.caption.weight(.bold))
                        .tracking(1.1)
                        .foregroundStyle(Color.humayLavender)
                    Spacer()
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.humayTextSecondary)
                }
            }
            .buttonStyle(.plain)
            if expanded {
                Text(json)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Color.humayTextSecondary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(HumaySpacing.small)
                    .background(Color.humayRaisedSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(HumaySpacing.medium)
        .background(Color.humaySurface.opacity(0.7), in: RoundedRectangle(cornerRadius: HumayRadius.surface))
        .overlay { RoundedRectangle(cornerRadius: HumayRadius.surface).strokeBorder(Color.humayHairline.opacity(0.6)) }
        .accessibilityIdentifier("debug.bigThree")
    }
}
#endif

/// Progressive-disclosure row: fun line collapsed; human + traditional layers expand.
struct DisclosureRow: View {
    let title: String
    let subtitle: String
    let humanExplanation: String
    let traditionalBasis: String

    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(HumayMotion.snappy) {
                expanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: HumaySpacing.small) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(HumayTypography.cardTitle)
                    Spacer()
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.humayTextSecondary)
                }

                Text(subtitle)
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if expanded {
                    Divider().overlay(Color.humayHairline)

                    layerLabel("What it means")
                    Text(humanExplanation)
                        .font(HumayTypography.supporting)
                        .fixedSize(horizontal: false, vertical: true)

                    layerLabel("The traditional bit")
                    Text(traditionalBasis)
                        .font(HumayTypography.supporting)
                        .foregroundStyle(Color.humayTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HumaySpacing.large)
            .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                    .strokeBorder(Color.humayHairline)
            }
        }
        .buttonStyle(.humayPressable)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint(expanded ? "Collapses details" : "Expands explanation and basis")
    }

    private func layerLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(HumayTypography.caption.weight(.bold))
            .tracking(1.1)
            .foregroundStyle(Color.humayLavender)
    }
}

/// An honestly withheld fact. No fabrication, clear invitation instead.
struct WithheldRow: View {
    let title: String
    let tease: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(HumayTypography.cardTitle)
                    .foregroundStyle(Color.humayTextSecondary)
                Spacer()
                Image(systemName: "moon.zzz")
                    .foregroundStyle(Color.humayTextSecondary.opacity(0.6))
            }

            Text(tease)
                .font(HumayTypography.body)
                .foregroundStyle(Color.humayTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(detail)
                .font(HumayTypography.caption)
                .foregroundStyle(Color.humayTextSecondary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HumaySpacing.large)
        .background(Color.humayRaisedSurface.opacity(0.5), in: RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.surface, style: .continuous)
                .strokeBorder(Color.humayHairline.opacity(0.7))
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Archetype

struct ArchetypeCard: View {
    let archetype: HumayArchetype

    var body: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.medium) {
            HumayKickerLabel(text: "Humay type", tint: .humayCoral)

            Text(archetype.name)
                .font(HumayTypography.editorialTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(archetype.summary)
                .font(HumayTypography.body)
                .fixedSize(horizontal: false, vertical: true)

            Divider().overlay(Color.humayHairline)

            VStack(alignment: .leading, spacing: HumaySpacing.extraSmall) {
                Label(archetype.superpower, systemImage: "bolt.fill")
                    .font(HumayTypography.bodyEmphasized)
                Label(archetype.growingEdge, systemImage: "leaf")
                    .font(HumayTypography.body)
                    .foregroundStyle(Color.humayTextSecondary)
            }

            Text("Invented by Humay. Surprisingly accurate anyway.")
                .font(HumayTypography.caption)
                .foregroundStyle(Color.humayTextSecondary)
        }
        .padding(HumaySpacing.extraLarge)
        .background(Color.humaySurface, in: RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HumayRadius.feature, style: .continuous)
                .strokeBorder(Color.humayHairline)
        }
    }
}
