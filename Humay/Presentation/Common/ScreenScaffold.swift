import SwiftUI

/// The scrolling page every screen in the application is built on.
///
/// One gutter, one top inset per title style, one bottom inset, one ground colour. Before
/// this existed, twelve screens each repeated the same four modifiers and three of them
/// had drifted — which is exactly the inconsistency the minimal direction is least able
/// to absorb, because the layout is mostly space.
///
/// Uses the system navigation bar rather than drawing a header into the scroll content.
/// That is what gives the title its collapse-on-scroll behaviour and what keeps content
/// from passing behind the clock — a hand-drawn header inside a scroll view has neither.
///
/// The identity is carried by the editorial headline below the bar, which is Cormorant.
/// The bar itself is chrome and stays in the system face.
struct HumayPage<Content: View>: View {
    enum Kind {
        /// A tab root: large title, collapsing on scroll.
        case tabRoot
        /// A pushed screen, a settings page or a sheet: inline title.
        case detail

        var displayMode: NavigationBarItem.TitleDisplayMode {
            switch self {
            case .tabRoot: .large
            case .detail: .inline
            }
        }

        /// A large title already supplies most of the space above the first element; an
        /// inline title supplies almost none.
        var topInset: CGFloat {
            switch self {
            case .tabRoot: HumaySpacing.xs
            case .detail: HumaySpacing.m
            }
        }
    }

    let title: String
    var kind: Kind = .detail
    @ViewBuilder var content: Content

    @Environment(\.humayTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HumaySpacing.l) {
                content
            }
            .padding(.horizontal, HumaySpacing.gutter)
            .padding(.top, kind.topInset)
            .padding(.bottom, HumaySpacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(theme.colors.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(kind.displayMode)
        .toolbarBackground(theme.colors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

/// A tab root, with the header entry points into tone and settings.
struct ScreenScaffold<Content: View>: View {
    let title: String
    var showsSettingsEntry: Bool = true
    @ViewBuilder var content: Content

    @Environment(\.openHumaySettings) private var openSettings

    var body: some View {
        HumayPage(title: title, kind: .tabRoot) {
            content
        }
        .toolbar {
            if showsSettingsEntry {
                ToolbarItem(placement: .topBarTrailing) {
                    ToneChip()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        openSettings()
                    } label: {
                        Image(systemName: "person")
                            .font(.system(size: HumayIconSize.chrome, weight: .light))
                    }
                    .accessibilityLabel("Profile and settings")
                }
            }
        }
    }
}

/// A pushed screen.
///
/// The same page as a tab root, with an inline title and no header entry points — the way
/// back is the navigation bar's own control.
struct DetailScaffold<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        HumayPage(title: title, kind: .detail) {
            content
        }
    }
}

/// The tone indicator in the header.
///
/// Always visible, so the register the application is speaking in is never a surprise.
/// Tapping opens the setting rather than toggling in place — Roast is a change of voice,
/// not a switch worth flipping by accident.
struct ToneChip: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.humayTheme) private var theme
    @Environment(\.openHumaySettings) private var openSettings

    var body: some View {
        Button {
            openSettings(.tone)
        } label: {
            Text(environment.settings.tone.displayName.uppercased())
                .humayFont(.monoKicker)
                .foregroundStyle(
                    environment.settings.tone == .roast ? theme.colors.roast : theme.colors.textLabel
                )
                .padding(.horizontal, HumaySpacing.xs)
                .padding(.vertical, 4)
                .overlay(
                    Rectangle().stroke(
                        environment.settings.tone == .roast
                            ? theme.colors.roast.opacity(0.5)
                            : theme.colors.hairline,
                        lineWidth: HumayBorder.hairline
                    )
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Tone: \(environment.settings.tone.displayName)")
        .accessibilityHint("Opens tone settings")
    }
}

/// Applies the Humay treatment to the system bars.
///
/// The navigation bar carries the screen title, so it has to be styled rather than
/// merely tolerated: Cormorant for both the large and collapsed titles, an opaque Paper
/// ground and no shadow. The tab bar gets an opaque ground with a single hairline rule.
enum HumayNavigationAppearance {
    @MainActor
    static func apply(theme: HumayTheme = .paper) {
        let ink = UIColor(theme.colors.textPrimary)

        let navigation = UINavigationBarAppearance()
        navigation.configureWithOpaqueBackground()
        navigation.backgroundColor = UIColor(theme.colors.background)
        navigation.shadowColor = .clear
        // Navigation titles stay in the system face. Cormorant is reserved for the
        // wordmark, major titles and editorial headlines — a screen name in the bar is
        // chrome, and setting it in a display serif would make the application look
        // less native rather than more considered.
        navigation.largeTitleTextAttributes = [.foregroundColor: ink]
        navigation.titleTextAttributes = [.foregroundColor: ink]

        UINavigationBar.appearance().standardAppearance = navigation
        UINavigationBar.appearance().scrollEdgeAppearance = navigation
        UINavigationBar.appearance().compactAppearance = navigation
        UINavigationBar.appearance().tintColor = UIColor(theme.colors.accentText)

        let tabs = UITabBarAppearance()
        tabs.configureWithOpaqueBackground()
        tabs.backgroundColor = UIColor(theme.colors.background)
        // One hairline rule instead of the default shadow image.
        tabs.shadowColor = UIColor(theme.colors.hairline)

        let items = tabs.stackedLayoutAppearance
        items.normal.titleTextAttributes = [.foregroundColor: UIColor(theme.colors.textLabel)]
        items.selected.titleTextAttributes = [.foregroundColor: ink]
        items.normal.iconColor = UIColor(theme.colors.textLabel)
        items.selected.iconColor = ink

        UITabBar.appearance().standardAppearance = tabs
        UITabBar.appearance().scrollEdgeAppearance = tabs
    }
}

// MARK: - Settings entry point
//
// Settings is a full-screen cover owned by the root, not a tab and not a per-screen
// sheet. Passing the opener through the environment means any screen's header can
// reach it without every screen owning presentation state.

/// Opens the settings cover, optionally on a specific page.
///
/// A named `Sendable` type rather than a bare closure, so it can sit in the environment
/// under strict concurrency without the conformance reaching across an actor boundary.
struct SettingsOpener: Sendable {
    private let open: @Sendable @MainActor (SettingsPage) -> Void

    init(_ open: @escaping @Sendable @MainActor (SettingsPage) -> Void) {
        self.open = open
    }

    @MainActor
    func callAsFunction(_ page: SettingsPage = .home) {
        open(page)
    }

    static let inert = SettingsOpener { _ in }
}

extension EnvironmentValues {
    @Entry var openHumaySettings: SettingsOpener = .inert
}
