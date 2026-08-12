# Phase 01 — Apple Platform Foundation

Status: **IN PROGRESS — IOS-001 through IOS-004 complete; IOS-005 not started**

Depends on:
- current production baseline reset;
- Phase 00 foundation start gate in [`00-technical-architecture.md`](00-technical-architecture.md);
- current [`../../architecture/IOS_ARCHITECTURE.md`](../../architecture/IOS_ARCHITECTURE.md);
- current [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md).

Goal: establish a clean, buildable **SwiftUI + Clean Architecture** foundation for Humay on iPhone and iPad without restoring prototype feature code or inventing unapproved feature UI.

## Architecture rule

Dependency direction:

```text
App → Presentation → Domain ← Data
```

Concrete provider/persistence implementations are wired only at the composition boundary. Domain stays UI/persistence-framework neutral where practical. Presentation never imports vendor SDK models or persistence entities.

Do not create abstractions merely to satisfy a folder diagram; introduce protocols/use cases when they protect a real boundary or behavior.

## Tasks

### IOS-001 — Production project/build baseline
Status: **DONE — 2026-08-12**

Verified without changing signing or unrelated project settings:

- Swift 6 with complete strict concurrency remains centralized in `Config/Shared.xcconfig`;
- minimum deployment remains iOS/iPadOS 18.0 with `TARGETED_DEVICE_FAMILY = 1,2`;
- project, product, target and shared scheme naming remains Humay;
- Debug and Release continue to inherit the shared xcconfig baseline;
- no third-party package dependency was added;
- representative iPhone and iPad Debug simulator builds pass.

Acceptance:
- Debug build succeeds for a representative iPhone simulator.
- Debug build succeeds for a representative iPad simulator.
- iOS/iPadOS minimum target remains 18.0.
- `TARGETED_DEVICE_FAMILY = 1,2` remains effective.
- product, target, scheme and internal naming use **Humay**.
- Debug/Release configuration remains centralized and understandable.
- no third-party dependency is added without a current requirement.

### IOS-002 — Clean Architecture source structure and composition
Status: **DONE — 2026-08-12**
Depends on: IOS-001

Implemented foundation state:

- `HumayApp` remains the explicit App composition boundary and owns `AppEnvironment`;
- `RootView` remains the intentionally minimal App root surface;
- stable profile/birth/settings facts remain in Domain without UI or persistence-framework dependencies;
- Data, feature Presentation and DesignSystem directories remain absent until production behavior requires them;
- layer enforcement protects Domain independence, prevents UI dependencies in Data, prevents persistence/concrete boundary construction in Presentation and rejects global shared dependency singletons.

Target structure grows deliberately toward:

```text
Humay/
├── App/              composition root, root state/routing
├── Domain/           entities, value types, use-case/repository contracts
├── Data/             concrete persistence/network/provider implementations
├── Presentation/     SwiftUI feature presentation/state
├── DesignSystem/     semantic tokens + reusable visual primitives
└── Resources/
```

Acceptance:
- layering matches `IOS_ARCHITECTURE.md`;
- dependency creation is explicit at an App/composition boundary;
- Presentation cannot construct concrete Data/provider implementations;
- no service locator/global singleton is introduced as the primary DI mechanism;
- no feature-specific domain family is created before a real production use case needs it;
- existing layering checks are updated to enforce the actual structure.

### IOS-003 — Soulful Celestial design-system foundation
Status: **DONE — 2026-08-12**
Depends on: IOS-001

Implemented foundation state:

- semantic asset-catalog Light/Dark roles for ground, surface, raised surface, primary/secondary text, hairline, coral, lavender, solar gold, celestial blue and sage;
- Cormorant Garamond wordmark/editorial/expressive roles with Dynamic Type-relative scaling, plus semantic system UI and monospaced roles;
- approved spacing, compact/surface/feature/pill radii, pixel-aware hairline, subtle Light-only shadow metrics and 44 pt minimum interaction metric;
- bounded form/readable/expanded content widths, adaptive gutters and a fit-driven stack for iPhone, compact iPad windows and regular-width iPad compositions;
- native SwiftUI primary and quiet secondary button styles with disabled/pressed states, 56 pt minimum rendered height and Reduce Motion handling;
- generic standard/raised rounded surfaces using tonal Dark hierarchy;
- Debug/preview-only iPhone Light/Dark and iPad portrait-Light/landscape-Dark showcase coverage, with no runtime route or RootView change;
- focused tests for semantic asset availability, Light/Dark contrast, committed custom-font loading, hit-target/hairline metrics and adaptive width behavior.

Scope:
- semantic Light/Dark color roles from the approved tokens;
- typography roles using Cormorant Garamond + system UI typography;
- spacing, radius, hairline and elevation primitives;
- minimum hit-target/accessibility metrics;
- adaptive content-width/layout primitives for iPhone/iPad;
- reusable primary/secondary button foundations only where already established by approved references;
- motion/reduced-motion hooks when a concrete component needs them.

Acceptance:
- no old Paper/minimal tokens return;
- no global forced appearance;
- Light and Dark are intentionally composed;
- iPad layout uses container width/size class rather than stretched phone constants;
- Dynamic Type is supported from the component foundation;
- representative iPhone/iPad Light/Dark previews exist for tokens/primitives.

Do not prebuild every future feature card, access gate or settings row in this phase.

### IOS-004 — Root application state and navigation boundary
Status: **DONE — 2026-08-12**
Depends on: IOS-002

Implemented foundation state:

- `AppRootState` resolves to onboarding or main from the existing
  `AppEnvironment.hasCompletedOnboarding` semantics;
- `OnboardingRoute` owns exactly Welcome, Birth Date, Tradition and Profile Reveal;
- `MainDestination` owns Today, Circle, Sky, Chart and Ask in canonical order;
- `CircleRoute.compatibility` remains Circle-owned and `SkyRoute.calendar` remains
  Sky-owned;
- `AppAuxiliaryRoute.profileSettings` is separate from primary destinations and is
  reserved for the profile/header entry;
- `AppNavigationState` is an App-owned, `@MainActor`/Observation-based transient
  route selection boundary composed by `HumayApp` beside `AppEnvironment`;
- no route state is persisted and navigation has no Data, provider or persistence
  dependency;
- RootView remains the minimal system-background Humay placeholder. No onboarding,
  primary destination, auxiliary route or navigation presenter is rendered.

Acceptance:
- canonical IA remains Today / Circle / Sky / Chart / Ask;
- Calendar ownership remains under Sky;
- Profile/Settings remains a header/profile route;
- routing does not depend on concrete providers/persistence;
- iPad can choose platform-appropriate presentation without changing route ownership;
- no placeholder production content is presented as a completed feature.

### IOS-005 — Persistence boundary scaffolding
Status: TODO  
Depends on: IOS-002

Goal: prepare durable user-data ownership without freezing a speculative schema.

Acceptance:
- repository/storage contracts are introduced only for profile/settings behavior that is actually required by onboarding/profile implementation;
- persistence errors have explicit handling semantics;
- no silent production fallback from durable user data to volatile in-memory storage;
- persistence entities do not leak into Domain/Presentation;
- schema/versioning is added with the first real persisted slice, not as speculative empty infrastructure.

### IOS-006 — Configuration, diagnostics and privacy-safe logging
Status: TODO  
Depends on: IOS-002

Acceptance:
- privacy-safe structured logging remains centralized;
- environment/configuration boundary exists for app-owned endpoints/flags when needed;
- secrets are never committed or shipped in client configuration;
- birth/profile/provider payloads are not logged raw.

### IOS-007 — Test and verification foundation
Status: TODO  
Depends on: IOS-001 through IOS-006 as applicable

Acceptance:
- Swift Testing unit target builds/runs;
- XCUITest target builds/runs;
- layer/nomenclature scripts pass;
- representative iPhone and iPad build commands are documented;
- design-system primitives have focused behavior/accessibility tests where useful;
- no obsolete prototype test is restored merely for coverage count.

## Explicitly out of scope

Phase 01 does **not** implement:

- Today/Circle/Sky/Chart/Ask feature screens;
- provider-backed astrology;
- Free catalog runtime;
- monetization/ad/StoreKit behavior;
- feature-specific access-state UI;
- onboarding screen visuals before their required cross-device references are approved.

Shared architecture and design-system primitives may be built now. Feature-specific UI follows the design → approve → implement cadence.

## Exit criteria

- Humay builds and launches on representative iPhone and iPad simulators.
- SwiftUI + Clean Architecture boundaries are enforceable and documented.
- the production Soulful Celestial Light/Dark design-system foundation exists without old-design residue.
- root state/navigation composition is ready for approved onboarding work.
- persistence/configuration/testing boundaries are ready without speculative feature architecture.
- no deleted mock-first/provider/old-UI implementation has been reintroduced.
