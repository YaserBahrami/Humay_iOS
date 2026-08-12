# iOS / iPadOS Architecture

**Status:** production baseline after the 2026-08-12 reset; IOS-006 diagnostics complete.  
See [`PRODUCTION_BASELINE_RESET_2026-08-12.md`](PRODUCTION_BASELINE_RESET_2026-08-12.md).

## Platform

| | |
|---|---|
| Minimum deployment target | iOS / iPadOS 18.0 |
| Language | Swift 6, strict concurrency |
| UI | SwiftUI |
| Devices | iPhone + iPad |
| iPhone orientation | portrait-first |
| iPad orientation | portrait + landscape |
| Bundle identifier | `online.humay.ios` |
| Third-party dependencies | none in the clean baseline |

The application supports both device families from the start. iPad is not treated as a later stretched port.

## Current source layout

```text
Humay.xcodeproj/
Config/
Humay/
├── App/                  minimal composition/root
├── DesignSystem/         semantic SwiftUI presentation infrastructure
│   ├── Components/
│   ├── Layout/
│   ├── Preview/          Debug/preview-only showcase
│   ├── Tokens/
│   └── Typography/
├── Domain/
│   ├── Profile/          only stable, already-authoritative user facts/preferences
│   └── Persistence/      aggregate durable-state contract
├── Data/
│   └── Persistence/      versioned local profile/settings store
├── Presentation/
│   └── Onboarding/       D1 flow and transient draft state
└── Resources/
    ├── Assets.xcassets/
    └── Fonts/
HumayTests/
HumayUITests/
```

Feature and Data folders are added back deliberately as production slices are implemented. Data now contains only the local persistence slice justified by IOS-005/PROFILE-005. DesignSystem contains only the approved Soulful Celestial visual foundation. The repository should not recreate broad speculative architecture ahead of approved product work.

## Architecture direction

As real features arrive, use this dependency direction:

```text
App → Presentation → Domain ← Data
```

Rules:

- Domain remains framework-neutral where practical;
- views never depend directly on provider SDKs or persistence entities;
- provider/persistence implementations are wired at a composition boundary;
- preview/sample data is separate from production behavior;
- user-owned data persistence failures are explicit rather than silently becoming volatile storage;
- service interfaces are introduced only when a real use case needs them.

## Application state

`AppEnvironment` remains small and owns the current profile/settings state plus the
restore/save boundary injected by `HumayApp`. `AppNavigationState` is composed beside
it and derives the logical root from restoration state and
`AppEnvironment.hasCompletedOnboarding`; it owns only transient route selection and
does not persist or duplicate profile/settings truth. D1 onboarding owns its date
picker cursor, confirmed date draft and tradition selection inside Presentation.

Feature-specific state should remain feature-local unless multiple routes genuinely need to share it.

## Configuration and diagnostics

Current configuration ownership is deliberately small:

- deployment, build, Swift and device-family settings remain in `Config/Shared.xcconfig`;
- bundle/version metadata remains Xcode/project-owned;
- runtime endpoint, provider, feature-flag and credential configuration does not exist yet;
- no `AppConfiguration` container, secret value type, API-key field, mutable global configuration or speculative environment enum is needed by the current app.

`HumayLog` is App/application infrastructure and uses OSLog through finite typed
events. `HumayApplicationLogEvent` currently contains only
`durableStorageUnavailable`. `HumayPersistenceLogEvent` contains only restore,
save, clear and unsupported-schema events. Events have no associated values, and
public operational logging APIs accept no arbitrary strings or raw errors.

The current categories are intentionally limited to application/bootstrap and
persistence. Categories for future features or providers are added only with a
real owning runtime. Static operational text is logged without profile, birth,
UUID, location, timezone, serialized persistence, provider payload, prompt,
generated reading, token or API-key values. Domain remains independent of OSLog
and Bundle; Presentation does not own logging infrastructure.

`Scripts/check-diagnostics.sh` checks only production Swift source under `Humay/`
for `print`, `debugPrint` and narrow obvious client-secret declarations. It does
not scan tests, documentation or history; it is a focused guard, not a general
secret scanner.

## Persistence

IOS-005/PROFILE-005 establish the first real local durable slice. The Domain
`UserStateStore` contract exposes one aggregate containing `UserProfile?` and
`AppSettings`; Data maps it to a provider-independent Codable document and owns all
file details.

`FileUserStateStore` stores schema version 1 at
`Application Support/Humay/user-state.json`. The document preserves UUID through
Codable, calendar birth year/month/day components, explicit unknown/not-provided
birth values, stable enum raw values and the onboarding timestamp. Writes create the
directory and use Foundation's atomic write option. An actor serializes reads,
writes and clears.

Missing file means no persisted state. Read, malformed-payload, unsupported-schema,
write and clear failures are explicit; a failed restore does not become onboarding,
and a failed completion does not mutate authoritative in-memory state. The app uses
an explicit unavailable store if Application Support cannot be composed, never an
in-memory production fallback.

Version-1 migration logic belongs in the Data decoding boundary when a later schema
is shipped. No legacy migration is invented because no previous production schema
shipped. SwiftData, Core Data, UserDefaults and CloudKit are not used here. Private
iCloud/CloudKit sync and restore remain a later Data-layer concern.

### Accountless Apple persistence direction

Humay V1 does not require a Humay user account or authentication UI. User-owned profile, preferences and saved-person data are local-first: local app storage remains the immediate runtime source, with private iCloud/CloudKit-backed persistence planned for Apple-device sync and restore.

Private astrology/profile data must not use the public CloudKit database. Transient, non-sync caches may remain local. Precision features may later use an anonymous app/backend identity that is separate from user-facing login. A Humay account boundary is deferred unless cross-platform or server-account features later require it.

This is an architecture direction, not current sync capability. The local
Application Support adapter is implemented by IOS-005; CloudKit containers,
entitlements, sync/restore adapters and backend identity are not implemented yet;
their owning later tasks define them.

## Provider boundaries

The former mock astrology runtime was removed. Production horoscope, compatibility, chart, sky and interpretation services are added when the corresponding product methodology/backend phase is ready.

A production service must not be named `Mock*`, and sample output must never be indistinguishable from real calculated/provider output.

## Navigation

Canonical product IA remains:

**Today / Circle / Sky / Chart / Ask**

The App layer now owns a small non-visual route boundary:

- root exposes restoring/persistence-failure bootstrap states, then resolves to
  onboarding or main from `AppEnvironment.hasCompletedOnboarding`;
- onboarding route ownership is Welcome, Birth Date, Tradition and Profile Reveal;
- primary destination ownership is Today, Circle, Sky, Chart and Ask in that order;
- Calendar is a Sky-owned child route and Compatibility is a Circle-owned child route;
- Profile/Settings is an auxiliary profile/header route, not a primary destination.

`AppNavigationState` is transient, `@MainActor` and Observation-based. It has no
provider, Data or persistence dependency. iPad may later use platform-appropriate
stack/tab/sidebar presentation while preserving this same route hierarchy; main
destination presenters and all later feature screens remain unimplemented. D1
onboarding is the implemented production root flow.

## Appearance

Humay follows the system appearance. Light and Dark are first-class compositions.

The previous forced-Light `UIUserInterfaceStyle` and compatibility-mode override were removed. The semantic Soulful Celestial foundation now provides intentional Light/Dark colors, Dynamic Type typography, adaptive layout, generic surfaces and approved button treatments without changing the main-root placeholder.

## Responsive layout requirements

Production components must be size-class aware without scattering device checks through views.

Prefer:

- bounded content widths for reading-heavy iPad screens;
- adaptive stacks/grids based on available width;
- two-region layouts on iPad only when content benefits;
- collapse to compact composition in split view;
- geometry derived from containers, not fixed device dimensions;
- native keyboard, pointer and focus behavior where available.

Avoid `UIDevice.current.userInterfaceIdiom` as the primary layout mechanism when size classes/container width express the real requirement.

## Design-to-code gate

A user-facing screen should not be considered final until its reference package includes iPhone Light/Dark and iPad Light/Dark, plus adaptive landscape notes where required.

See:

- [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md)
- [`../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
- [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md)

## Testing direction

Use Swift Testing for unit/domain behavior and XCTest for UI tests. Each implemented screen family should eventually be exercised on representative iPhone and iPad destinations, with Light/Dark and accessibility coverage appropriate to the feature.

## Not yet built in the clean baseline

CloudKit sync/restore, authentication, backend identity, networking, astrology
provider adapters, interpretation provider, visual post-onboarding navigation
presenters, StoreKit, advertising, analytics, notification delivery, widgets and
feature-specific screens remain unbuilt. The approved D1 onboarding implementation
and local profile/settings persistence are the current production slices.
