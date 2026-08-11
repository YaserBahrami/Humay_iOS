import SwiftUI

/// The sky, in two registers.
///
/// "In the sky" is what is happening, impersonally — it reads the same for everyone
/// looking up. "For you" relates it to a chart. Keeping the two apart is what stops the
/// screen implying that an eclipse happened *at* someone.
struct SkyView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    enum Segment: String, CaseIterable, Hashable {
        case transits, calendar, events

        var title: String {
            switch self {
            case .transits: "Transits"
            case .calendar: "Calendar"
            case .events: "Events"
            }
        }
    }

    @State private var segment: Segment = .transits
    @State private var register: SkyRegister = .inTheSky
    @State private var snapshot: SkySnapshot?
    @State private var failure: String?

    var body: some View {
        ScreenScaffold(title: "Sky") {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                HumaySegmentedControl(
                    options: Segment.allCases,
                    title: \.title,
                    selection: $segment
                )

                if let snapshot {
                    switch segment {
                    case .transits:
                        transits(snapshot)
                    case .calendar:
                        SkyCalendarContent(events: snapshot.upcoming) { id in
                            router.push(.skyEvent(id), on: .sky)
                        }
                    case .events:
                        events(snapshot)
                    }
                } else if let failure {
                    ErrorStateView(message: failure) { Task { await load() } }
                } else {
                    LoadingState(message: "Reading the sky…")
                }
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private func transits(_ snapshot: SkySnapshot) -> some View {
        MonoKicker(text: snapshot.locationLabel)

        // The Moon leads: it is the fastest thing on the screen and the only one that
        // changes character within a day.
        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            SampleContentMarker(provenance: snapshot.provenance)
            Text(snapshot.moon.name)
                .humayFont(.displayM)
                .foregroundStyle(theme.colors.textPrimary)
            HStack(spacing: HumaySpacing.m) {
                MonoFact(text: snapshot.moon.ageFormatted)
                MonoFact(text: snapshot.moon.illuminationFormatted)
            }
            if let ingress = snapshot.moon.ingress {
                MonoFact(text: ingress.formatted, emphasised: true)
                    .accessibilityLabel(ingress.spokenDescription)
            }
        }

        registerToggle

        Group {
            switch register {
            case .inTheSky:
                ReadingBody(text: snapshot.moonInTheSky, role: .bodySmall)
            case .forYou:
                switch snapshot.moonForYou {
                case .available(let text), .uncertain(let text, _):
                    ReadingBody(text: text, role: .bodySmall)
                case .unavailable(let reason):
                    UnavailableFactView(reason: reason)
                }
            }
        }

        VStack(spacing: 0) {
            SectionHeader(title: "Where things are")
            ForEach(snapshot.positions) { position in
                SkyPositionRow(position: position)
                HairlineRule()
            }
        }
        .padding(.top, HumaySpacing.s)
    }

    @ViewBuilder
    private var registerToggle: some View {
        HumaySegmentedControl(
            options: SkyRegister.allCases,
            title: \.displayName,
            selection: $register
        )
        .padding(.top, HumaySpacing.xs)
    }

    @ViewBuilder
    private func events(_ snapshot: SkySnapshot) -> some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Upcoming")
            ForEach(snapshot.upcoming) { event in
                SkyEventRow(event: event) {
                    router.push(.skyEvent(event.id), on: .sky)
                }
                HairlineRule()
            }
        }
    }

    private func load() async {
        failure = nil
        do {
            snapshot = try await environment.skyService.snapshot(
                for: Calendar.current.dateComponents([.year, .month, .day], from: .now),
                profile: environment.profile
            )
        } catch {
            failure = "The sky could not be loaded."
            HumayLog.contentFailure("Sky snapshot failed: \(error)")
        }
    }
}

struct SkyPositionRow: View {
    let position: SkyPosition

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: HumaySpacing.s) {
                GlyphLabel(
                    glyph: position.planet.glyph,
                    spokenName: position.planet.spokenName,
                    role: .titleS,
                    color: theme.colors.accentMark
                )
                .frame(width: 22, alignment: .leading)

                Text(position.planet.spokenName)
                    .humayFont(.titleS)
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: HumaySpacing.xs)

                if position.isRetrograde {
                    MonoFact(text: "Rx", emphasised: true)
                }
                MonoFact(text: position.position.formatted)
            }
            if !position.note.isEmpty {
                Text(position.note)
                    .humayFont(.callout)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 22 + HumaySpacing.s)
            }
        }
        .padding(.vertical, HumaySpacing.xs)
        .frame(minHeight: HumayHitTarget.minimum)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(position.spokenSummary). \(position.note)")
    }
}

struct SkyEventRow: View {
    let event: SkyEvent
    let action: () -> Void

    @Environment(\.humayTheme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: HumaySpacing.s) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .humayFont(.titleS)
                        .foregroundStyle(theme.colors.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(event.inTheSky)
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: HumaySpacing.s)
                VStack(alignment: .trailing, spacing: 2) {
                    MonoFact(text: event.shortDateFormatted, emphasised: event.relevance == .high)
                    if event.relevance == .high {
                        MonoKicker(text: "High", color: theme.colors.accentText)
                    }
                }
            }
            .padding(.vertical, HumaySpacing.s)
            .frame(minHeight: HumayHitTarget.minimum)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title), \(event.shortDateFormatted), \(event.relevance.displayName)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    NavigationStack { SkyView() }
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
