import SwiftUI

/// Profile and settings.
///
/// A full-screen cover reached from the header, not a sixth tab. Five tabs is the
/// information architecture; settings is somewhere you go and come back from.
struct SettingsCoverView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.settingsPath) {
            SettingsHomeView()
                .navigationDestination(for: SettingsPage.self) { page in
                    destination(for: page)
                }
        }
        .tint(theme.colors.accentText)
    }

    @ViewBuilder
    private func destination(for page: SettingsPage) -> some View {
        switch page {
        case .home: SettingsHomeView()
        case .birthDetails: BirthDetailsView()
        case .tradition: TraditionSettingsView()
        case .tone: ToneSettingsView()
        case .notifications: NotificationSettingsView()
        case .subscription: SubscriptionPlaceholderView()
        case .privacy: PrivacyDataView()
        case .help: HelpSupportView()
        case .about: AboutHumayView()
        }
    }
}

struct SettingsHomeView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    var body: some View {
        SettingsPageScaffold(title: "Profile & settings", showsClose: true) {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                identity

                settingsGroup {
                    NavigationLink(value: SettingsPage.birthDetails) {
                        SettingsRowLabel(title: "Birth details", detail: birthDetailLabel)
                    }
                    NavigationLink(value: SettingsPage.tradition) {
                        SettingsRowLabel(
                            title: "Astrology tradition",
                            detail: environment.settings.leadingTradition.displayName
                        )
                    }
                    NavigationLink(value: SettingsPage.tone) {
                        SettingsRowLabel(title: "Tone", detail: environment.settings.tone.displayName)
                    }
                    NavigationLink(value: SettingsPage.notifications) {
                        SettingsRowLabel(title: "Notifications", detail: nil)
                    }
                }

                settingsGroup {
                    NavigationLink(value: SettingsPage.subscription) {
                        SettingsRowLabel(title: "Premium", detail: "Not available yet")
                    }
                    NavigationLink(value: SettingsPage.privacy) {
                        SettingsRowLabel(title: "Privacy & data", detail: nil)
                    }
                }

                settingsGroup {
                    NavigationLink(value: SettingsPage.help) {
                        SettingsRowLabel(title: "Help & support", detail: nil)
                    }
                    NavigationLink(value: SettingsPage.about) {
                        SettingsRowLabel(title: "About Humay", detail: nil)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var identity: some View {
        VStack(alignment: .leading, spacing: HumaySpacing.xs) {
            Text(environment.profile?.birth.dateFormatted() ?? "No birth date")
                .humayFont(.displayM)
                .foregroundStyle(theme.colors.textPrimary)
            MonoKicker(text: identityLine)
        }
        .padding(.bottom, HumaySpacing.xs)
        .accessibilityElement(children: .combine)
    }

    /// States what is and is not known, rather than showing placeholders for the rest.
    private var identityLine: String {
        guard let profile = environment.profile, let sign = environment.sunSign else {
            return "Birth date not set"
        }
        if profile.birth.supportsPrecision {
            return "Sun in \(sign.spokenName) · chart available"
        }
        return "Sun in \(sign.spokenName) · Moon & Rising need a birth time"
    }

    private var birthDetailLabel: String {
        guard let profile = environment.profile else { return "Not set" }
        let time = profile.birth.time.formatted()
        let place = profile.birth.place.name
        switch (time, place) {
        case (let time?, let place?): return "\(time) · \(place)"
        case (let time?, nil): return time
        case (nil, let place?): return place
        default: return "Not set — add anytime"
        }
    }

    @ViewBuilder
    private func settingsGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            HairlineRule()
            content()
        }
    }
}

/// A settings row. Kept as a plain label so `NavigationLink` supplies the chevron and
/// the tap behaviour, rather than reimplementing either.
struct SettingsRowLabel: View {
    let title: String
    let detail: String?

    @Environment(\.humayTheme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: HumaySpacing.s) {
                Text(title)
                    .humayFont(.body)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer(minLength: HumaySpacing.s)
                if let detail {
                    Text(detail)
                        .humayFont(.callout)
                        .foregroundStyle(theme.colors.textTertiary)
                        .multilineTextAlignment(.trailing)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.colors.textLabel)
            }
            .frame(minHeight: HumayHitTarget.minimum)
            HairlineRule()
        }
        .contentShape(Rectangle())
    }
}

/// Shared chrome for a settings page.
struct SettingsPageScaffold<Content: View>: View {
    let title: String
    var showsClose: Bool = false
    @ViewBuilder var content: Content

    @Environment(AppRouter.self) private var router
    @Environment(\.humayTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                content
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, HumaySpacing.m)
            .padding(.bottom, HumaySpacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showsClose {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.closeSettings()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .regular))
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}

#Preview {
    SettingsCoverView()
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
}
