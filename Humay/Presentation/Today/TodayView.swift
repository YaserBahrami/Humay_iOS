import SwiftUI

/// The general daily reading.
///
/// The basis line is not a disclaimer bolted on — it is the honest description of what
/// this content is. A sign-wide reading is true of a great many people at once, and the
/// screen says so before offering the precise alternative.
struct TodayView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    @State private var reading: HoroscopeReading?
    @State private var failure: String?

    var body: some View {
        ScreenScaffold(title: "Today") {
            if let reading {
                content(reading)
            } else if let failure {
                ErrorStateView(message: failure) { Task { await load() } }
            } else {
                LoadingState(message: "Reading today…")
            }
        }
        .task(id: taskKey) { await load() }
    }

    /// Re-reads when the day, the sign or the register changes.
    private var taskKey: String {
        "\(environment.sunSign?.rawValue ?? "none")-\(environment.settings.tone.rawValue)-\(Self.today.day ?? 0)"
    }

    @ViewBuilder
    private func content(_ reading: HoroscopeReading) -> some View {
        VStack(alignment: .leading, spacing: HumaySpacing.l) {
            HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.xs) {
                MonoKicker(text: "\(Self.dateLabel) · \(reading.subjectLabel)")
                Spacer(minLength: HumaySpacing.xs)
                TierBadge(tier: reading.tier)
            }

            ReadingHeadline(text: reading.headline)

            if let overview = reading.overview {
                ReadingBody(text: overview)
            }

            BasisDisclosure(basis: reading.basis, provenance: reading.provenance)

            VStack(alignment: .leading, spacing: HumaySpacing.s) {
                ForEach(ReadingCategory.allCases) { category in
                    if let text = reading.text(for: category) {
                        ReadingCategoryRow(category: category, text: text)
                    }
                }
            }
            .padding(.top, HumaySpacing.s)

            PreciseEntryPoint(
                title: "Precise Today",
                message: "Read from your Moon, your houses and today's transits — not from your Sun sign.",
                actionTitle: "Open precise Today"
            ) {
                router.push(.todayPrecise, on: .today)
            }
            .padding(.top, HumaySpacing.m)
        }
    }

    private func load() async {
        guard let profile = environment.profile, let sign = environment.sunSign else { return }
        failure = nil
        do {
            reading = try await environment.horoscopeService.generalReading(
                sign: sign,
                date: Self.today,
                tone: environment.settings.tone
            )
        } catch {
            _ = profile
            failure = "Today's reading could not be loaded."
            HumayLog.contentFailure("Today general reading failed: \(error)")
        }
    }

    private static var today: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: .now)
    }

    private static var dateLabel: String {
        Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }
}

/// The precise daily reading.
///
/// Reachable directly. There is deliberately no gate, no simulated ad and no
/// entitlement flag here — access is a separate concern with its own design, and a stub
/// version would be an architecture to delete later rather than a head start.
struct TodayPreciseView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme

    @State private var reading: HoroscopeReading?
    @State private var failure: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                if let reading {
                    content(reading)
                } else if let failure {
                    ErrorStateView(message: failure) { Task { await load() } }
                } else {
                    LoadingState(message: "Reading your placements…")
                }
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, HumaySpacing.m)
            .padding(.bottom, HumaySpacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle("Precise Today")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    @ViewBuilder
    private func content(_ reading: HoroscopeReading) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: HumaySpacing.xs) {
            MonoKicker(text: Self.dateLabel)
            Spacer(minLength: HumaySpacing.xs)
            TierBadge(tier: .precise)
        }

        ReadingHeadline(text: reading.headline)

        if let overview = reading.overview {
            ReadingBody(text: overview)
        }

        BasisDisclosure(basis: reading.basis, provenance: reading.provenance)

        if !environment.supportsPrecision {
            VStack(alignment: .leading, spacing: HumaySpacing.xs) {
                HairlineRule()
                UnavailableFactView(reason: environment.profile?.birth.time.isKnown == true
                    ? .requiresBirthPlace
                    : .requiresBirthTime)
                    .padding(.top, HumaySpacing.xs)
            }
            .padding(.top, HumaySpacing.s)
        }

        VStack(alignment: .leading, spacing: HumaySpacing.s) {
            ForEach(ReadingCategory.allCases) { category in
                if let text = reading.text(for: category) {
                    ReadingCategoryRow(category: category, text: text)
                }
            }
        }
        .padding(.top, HumaySpacing.s)
    }

    private func load() async {
        guard let profile = environment.profile else { return }
        failure = nil
        do {
            reading = try await environment.horoscopeService.preciseReading(
                profile: profile,
                date: Calendar.current.dateComponents([.year, .month, .day], from: .now),
                tone: environment.settings.tone
            )
        } catch {
            failure = "This reading could not be loaded."
            HumayLog.contentFailure("Today precise reading failed: \(error)")
        }
    }

    private static var dateLabel: String {
        Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
    .environment(AppEnvironment.preview())
    .environment(AppRouter())
}
