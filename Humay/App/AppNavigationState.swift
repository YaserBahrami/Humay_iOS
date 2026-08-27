import Observation

/// Logical application roots and bootstrap states. This is derived from
/// `AppEnvironment` and is never persisted as user data.
enum AppRootState: String, CaseIterable, Hashable, Sendable {
    case restoring
    case onboarding
    case main
    case persistenceFailure

    @MainActor
    static func resolve(from environment: AppEnvironment) -> Self {
        switch environment.restorationState {
        case .restoring:
            .restoring
        case .failed:
            .persistenceFailure
        case .ready:
            environment.hasCompletedOnboarding ? .main : .onboarding
        }
    }
}

/// Canonical onboarding ownership. Presentation renders exactly these routes (I.2.1 adds birthTime/Place).
enum OnboardingRoute: String, CaseIterable, Hashable, Sendable {
    case welcome
    case birthDate
    case birthTime
    case birthPlace
    case name
    case tradition
    case profileReveal

    static let canonicalSequence: [OnboardingRoute] = [
        .welcome,
        .birthDate,
        .birthTime,
        .birthPlace,
        .name,
        .tradition,
        .profileReveal
    ]

    var next: Self? {
        switch self {
        case .welcome: .birthDate
        case .birthDate: .birthTime
        case .birthTime: .birthPlace
        case .birthPlace: .name
        case .name: .tradition
        case .tradition: .profileReveal
        case .profileReveal: nil
        }
    }

    var previous: Self? {
        switch self {
        case .welcome: nil
        case .birthDate: .welcome
        case .birthTime: .birthDate
        case .birthPlace: .birthTime
        case .name: .birthPlace
        case .tradition: .name
        case .profileReveal: .tradition
        }
    }
}

/// Canonical primary information architecture for the entertainment-first app.
///
/// Today = Cosmic Feed · Chemistry = people + compatibility · You = identity +
/// year timeline · Sky = cosmic events + calendar. Profile/settings stay an
/// auxiliary sheet and can never become a fifth tab by accident.
enum MainDestination: String, CaseIterable, Hashable, Sendable {
    case today
    case chemistry
    case you
    case sky

    static let canonicalOrder: [MainDestination] = [
        .today,
        .chemistry,
        .you,
        .sky
    ]
}

/// Auxiliary routes opened from the profile/header entry. This is deliberately a
/// separate type from `MainDestination`.
enum AppAuxiliaryRoute: String, CaseIterable, Hashable, Sendable, Identifiable {
    case profileSettings

    var id: String { rawValue }
}

/// App-owned, non-persistent route selection state.
///
/// Root resolution reads the restoration state and authoritative
/// `AppEnvironment.hasCompletedOnboarding` value. The route selections below are
/// transient presentation state and contain no profile/settings truth, provider state,
/// persistence dependency or feature data.
@Observable
@MainActor
final class AppNavigationState {
    private let environment: AppEnvironment

    var onboardingRoute: OnboardingRoute = .welcome
    var mainDestination: MainDestination = .today
    var auxiliaryRoute: AppAuxiliaryRoute?

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    var root: AppRootState {
        AppRootState.resolve(from: environment)
    }

    func resetRoutes() {
        onboardingRoute = .welcome
        mainDestination = .today
        auxiliaryRoute = nil
    }
}
