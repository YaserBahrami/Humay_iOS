# Phase 01 — Apple Platform Foundation

Status: **IN PROGRESS — IOS-001 through IOS-006 complete; IOS-007 implemented, local verification pending**

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
- Data contains only the current production-owned profile/settings persistence slice;
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
- focused tests for semantic asset availability, Light/Dark contrast, committed custom-font loading, hit-target/control-height/hairline metrics and adaptive width behavior.

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
- RootView renders the approved D1 onboarding presenter for the onboarding root and
  keeps the main root as the minimal system-background Humay placeholder. Later
  primary destinations and auxiliary presenters remain unimplemented.

Acceptance:
- canonical IA remains Today / Circle / Sky / Chart / Ask;
- Calendar ownership remains under Sky;
- Profile/Settings remains a header/profile route;
- routing does not depend on concrete providers/persistence;
- iPad can choose platform-appropriate presentation without changing route ownership;
- no placeholder production content is presented as a completed feature.

### IOS-005 — Persistence boundary scaffolding
Status: **DONE — 2026-08-12**
Depends on: IOS-002

Goal: establish durable local user-data ownership for the onboarding/profile slice.

Acceptance:
- `UserStateStore` covers only the profile/settings aggregate required by current
  onboarding behavior;
- `FileUserStateStore` owns a version-1 Codable DTO in Application Support/Humay;
- actor isolation serializes file IO and atomic writes establish durable ownership
  before application completion transitions to main;
- restore, decode, unsupported-schema, save and reset failures are explicit;
- no volatile production fallback, SwiftData, Core Data, UserDefaults or CloudKit.

### IOS-006 — Configuration, diagnostics and privacy-safe logging
Status: **DONE — 2026-08-12**  
Depends on: IOS-002, IOS-005

Implemented:

- stable deployment/build settings remain in `Config/Shared.xcconfig`, while bundle/version metadata remains Xcode/project-owned;
- no `AppConfiguration` container was added because the current app has no runtime endpoint, provider, feature or credential value to own;
- future runtime service configuration is intentionally deferred until its real feature/provider phase;
- `HumayLog` uses OSLog through finite typed application and persistence events;
- only application/bootstrap and persistence categories remain; unused content/navigation loggers and arbitrary public-string APIs were removed;
- persistence call sites distinguish restore, save, clear and unsupported-schema operations without logging raw errors or payloads;
- `Scripts/check-diagnostics.sh` checks only production Swift under `Humay/` for `print`, `debugPrint` and narrow obvious client-secret declarations;
- birth, profile, UUID, location, timezone, serialized persistence, provider, prompt and generated-reading data are not logged;
- no backend/provider endpoint, credential, secret, networking layer, dependency, runtime flag or UI was added.

Verification:

- representative iPhone Debug build passed;
- representative iPad Debug build passed;
- complete Swift Testing target passed;
- complete XCUITest suite passed on representative iPhone and iPad simulators;
- `Scripts/check-layering.sh`, `Scripts/check-nomenclature.sh` and `Scripts/check-diagnostics.sh` passed;
- `git diff --check` passed;
- production-source privacy search was manually reviewed; domain/model matches are legitimate and no logging call carries them.

### IOS-007 — Test and verification foundation
Status: **IMPLEMENTED — local verification pending**  
Depends on: IOS-001 through IOS-006 as applicable

Implemented:

- `Scripts/verify-foundation.sh` is the canonical repository-local verification entry point and orchestrates layering, nomenclature, diagnostics and `git diff --check` without simulator-specific assumptions;
- [`../VERIFICATION.md`](../VERIFICATION.md) documents representative iPhone/iPad Debug builds, Swift Testing, XCUITest, simulator destination selection and infrastructure-failure handling;
- the coverage audit confirmed that persistence-failure root resolution, onboarding semantics, durable restore/reset behavior, typed logging and terminate/relaunch behavior were already covered, so duplicate tests were not added merely for count;
- the approved 56 pt primary-control minimum height is represented as a DesignSystem metric and covered beside the 44 pt minimum interaction target without changing rendered UI;
- existing onboarding, persistence, logging and essential relaunch UI coverage remains the foundation suite;
- no screenshot/pixel tests, obsolete prototype tests, CI workflow or speculative feature tests were added.

Acceptance still requires verification after this latest source/test change:

- Swift Testing unit target builds/runs;
- XCUITest target builds/runs on representative iPhone and iPad destinations;
- layering, nomenclature, diagnostics and canonical foundation verification pass;
- representative iPhone and iPad Debug builds pass;
- `git diff --check` passes.

Phase 01 must remain IN PROGRESS until those post-change commands are run locally. The repository/GitHub editing environment used for this implementation cannot execute Xcode or simulator tests, so prior IOS-006 results are not represented as proof for the new IOS-007 commit.

## Explicitly out of scope

Phase 01 does **not** implement:

- Today/Circle/Sky/Chart/Ask feature screens;
- provider-backed astrology;
- Free catalog runtime;
- monetization/ad/StoreKit behavior;
- feature-specific access-state UI;
- D1 onboarding implementation beyond the approved Phase 03 slice; no later feature UI belongs here.

Shared architecture and design-system primitives may be built now. Feature-specific UI follows the design → approve → implement cadence. D1 onboarding is the approved production slice now owned by Phase 03; IOS-005 local persistence and IOS-006 diagnostics are complete, while IOS-007 awaits its post-change verification run.

## Exit criteria

- Humay builds and launches on representative iPhone and iPad simulators.
- SwiftUI + Clean Architecture boundaries are enforceable and documented.
- the production Soulful Celestial Light/Dark design-system foundation exists without old-design residue.
- root state/navigation composition presents the approved D1 onboarding work.
- local persistence/configuration/testing boundaries are implemented without speculative feature architecture.
- no deleted mock-first/provider/old-UI implementation has been reintroduced.

**Phase 01 closes only after the IOS-007 verification commands pass after the latest commit.**
