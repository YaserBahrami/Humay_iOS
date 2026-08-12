import Observation

/// The two logical application roots. This is derived from `AppEnvironment` and is
/// never persisted as user data.
enum AppRootState: String, CaseIterable, Hashable, Sendable {
    case onboarding
    case main

    @MainActor
    static func resolve(from environment: AppEnvironment) -> Self {
        environment.hasCompletedOnboarding ? .main : .onboarding
    }
}

/// Canonical onboarding ownership. These values establish sequence only; they do not
/// imply that any onboarding screen has been implemented.
enum OnboardingRoute: String, CaseIterable, Hashable, Sendable {
    case welcome
    case birthDate
    case tradition
    case profileReveal

    static let canonicalSequence: [OnboardingRoute] = [
        .welcome,
        .birthDate,
        .tradition,
        .profileReveal
    ]
}

/// Canonical primary information architecture. Feature-specific child routes are
/// intentionally owned by their feature and are not modeled here.
enum MainDestination: String, CaseIterable, Hashable, Sendable {
    case today
    case circle
    case sky
    case chart
    case ask

    static let canonicalOrder: [MainDestination] = [
        .today,
        .circle,
        .sky,
        .chart,
        .ask
    ]
}

/// Circle-owned child route boundary. Compatibility belongs to Circle/people flows.
enum CircleRoute: String, Hashable, Sendable {
    case compatibility

    var owningDestination: MainDestination { .circle }
}

/// Sky-owned child route boundary. Calendar belongs under Sky.
enum SkyRoute: String, Hashable, Sendable {
    case calendar

    var owningDestination: MainDestination { .sky }
}

/// Auxiliary routes opened from the profile/header entry. This is deliberately a
/// separate type from `MainDestination`, so Profile/Settings cannot become a sixth
/// primary destination by accident.
enum AppAuxiliaryRoute: String, CaseIterable, Hashable, Sendable {
    case profileSettings
}

/// App-owned, non-persistent route selection state.
///
/// Root resolution reads only the authoritative `AppEnvironment.hasCompletedOnboarding`
/// value. The route selections below are transient presentation state and contain no
/// profile/settings truth, provider state, persistence dependency or feature data.
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
