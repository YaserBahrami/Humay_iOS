# Development Status

Last updated: **2026-08-12**

## Active priorities

1. Run the post-change IOS-007 foundation verification and the ASTRO-001/ASTRO-002 Swift tests on the latest branch.
2. Close IOS-007/Phase 01 and mark the implemented ASTRO-001/002 contracts DONE only if that verification is green.
3. Continue Phase 00 with the cache/offline and interpretation boundaries now that ARCH-001/ARCH-003 are frozen.
4. Preserve local durable profile/settings behavior and the approved Soulful Celestial UI while later feature families remain behind their design gates.

## Repository authority

`main` is the current product, architecture, roadmap and design source of truth.

Start each engineering session with [`../START_HERE.md`](../START_HERE.md).

Historical feature/design branches are not authority after merge.

## Production baseline

The old mock-first application implementation was removed on 2026-08-12 before production UI work.

Retained:

- Xcode project/scheme/configuration;
- Swift 6 strict-concurrency foundation;
- bundle/signing settings;
- core profile/birth semantics;
- fonts/assets shell;
- test targets;
- current design/product/methodology documentation.

Removed:

- old Presentation layer;
- old Paper-only DesignSystem;
- mock astrology runtime and fixture catalogs;
- premature persistence schema/repositories;
- speculative Chart/Sky/Circle/Ask implementation;
- prototype navigation and tests tied to removed screens.

Details: [`../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md).

## Engineering track

### Phase 01 — Apple Platform Foundation

**IN PROGRESS. IOS-001 through IOS-006 are complete; IOS-007 is implemented and awaiting post-change local verification.**

Current foundation:

- the most recent completed verification run (IOS-006) passed representative iPhone/iPad Debug builds, Swift Testing, XCUITest, layering, nomenclature, diagnostics and `git diff --check`;
- Swift 6 complete strict concurrency, iOS/iPadOS 18.0 and device families `1,2` remain effective;
- Humay naming, shared scheme and centralized Debug/Release xcconfig inheritance remain intact;
- `HumayApp` explicitly owns the small `AppEnvironment` composition boundary;
- `HumayApp` explicitly composes the transient `AppNavigationState` root/route boundary without persisting routing state or adding later feature UI;
- Domain remains independent of UI and persistence frameworks;
- DesignSystem contains the approved semantic Light/Dark tokens, Dynamic Type typography, adaptive layout, generic surfaces and primary/quiet button foundations;
- the DesignSystem showcase exists only in Debug previews for representative iPhone/iPad Light/Dark verification and is not a runtime route;
- Data contains only the production-owned local persistence slice justified by IOS-005/PROFILE-005;
- IOS-005 persistence errors are implementation-neutral and its local snapshot validates semantic payload invariants;
- IOS-006 keeps build/deployment/version ownership in xcconfig/Xcode metadata and adds no runtime backend/provider configuration or `AppConfiguration` container;
- IOS-006 centralizes privacy-safe OSLog diagnostics behind finite typed application and persistence events; birth/profile/provider payloads, raw errors and secrets are not logged;
- IOS-007 adds `Scripts/verify-foundation.sh` and [`VERIFICATION.md`](VERIFICATION.md) as the canonical repository/local Xcode verification contract;
- the IOS-007 coverage audit found the persistence-failure root already covered by persistence tests, so no duplicate navigation test was added; the only new IOS-007 test invariant is the approved 56 pt primary-control minimum height, with rendered UI unchanged;
- no third-party dependency, CI workflow or provider-backed feature UI was added.

Because IOS-007 changed production/test source, its local verification must be rerun after the latest commit before IOS-007 or Phase 01 is marked DONE. The GitHub editing environment used for implementation cannot run Xcode/simulator commands, so earlier passes are not treated as proof for the current branch.

The first production feature slice is implemented separately under Phase 03:

- D1 onboarding is the root experience when `AppNavigationState.root == .onboarding`;
- the main root remains the minimal Humay foundation placeholder;
- completion durably saves a version-1 local `UserProfile`/`AppSettings` snapshot with unknown birth time and no birth place;
- restore resolves a completed state to the main placeholder; fresh installs and incomplete state resolve to onboarding;
- no provider, networking, CloudKit or account flow is present.

Foundation scope:

- SwiftUI application shell;
- Clean Architecture boundaries: `App → Presentation → Domain ← Data`;
- explicit dependency composition;
- production Soulful Celestial semantic design tokens/primitives;
- iPhone + iPad adaptive layout foundations;
- Light + Dark from the start;
- root routing/state boundaries without speculative feature UI;
- durable local profile/settings persistence;
- privacy-safe diagnostics;
- deterministic test and verification ownership.

See [`phases/01-ios-foundation.md`](phases/01-ios-foundation.md) and [`VERIFICATION.md`](VERIFICATION.md).

### Phase 00 — Technical Architecture

Phase 00 remains **IN PROGRESS**, but its first three architecture gates are frozen:

- **ARCH-001 complete:** [`../architecture/SYSTEM_ARCHITECTURE.md`](../architecture/SYSTEM_ARCHITECTURE.md) defines separate Free and precision flows, trust boundaries and explicit failure behavior; a missing Free catalog item can never fall through to paid generation.
- **ARCH-002 complete:** `IOS_ARCHITECTURE.md` owns the Apple `App → Presentation → Domain ← Data` boundary.
- **ARCH-003 complete:** [`../architecture/ASTROLOGY_ENGINE.md`](../architecture/ASTROLOGY_ENGINE.md) defines provider-independent Western/Vedic/BaZi calculation adapters, normalized facts, reliability/provenance/versioning and validated fallback rules.

The calculation provider remains vendor-neutral. Astrologer/RapidAPI, Swiss Ephemeris or another engine may later implement an adapter, but no vendor is frozen and no backend/provider runtime integration was added in this architecture step. Calculation facts remain separate from interpretation text, and ordinary Free serving never invokes the calculation engine.

Next Phase 00 architecture ownership is ARCH-004 result-cache/offline behavior and ARCH-005 interpretation/LLM boundary. Provider-backed feature runtime remains blocked on the relevant unfinished cache/access/privacy/backend contracts.

See [`phases/00-technical-architecture.md`](phases/00-technical-architecture.md).

### Phase 02 — Astrology Calculation Foundation

**IN PROGRESS. ASTRO-001 and ASTRO-002 source contracts are implemented; post-change verification is pending.**

Current implementation:

- `Humay/Domain/Astrology/BirthCalculationInput.swift` introduces the provider-independent calculation-input boundary and wraps the existing `BirthDetails` model instead of creating a parallel user/birth model;
- exact, approximate and unknown birth time remain explicit and unchanged; approximate time requires positive uncertainty rather than being silently treated as exact;
- missing place remains explicit; known place validation requires a nonblank name, finite bounded coordinates and a real timezone identifier;
- impossible, pre-1900 and future birth dates are rejected at the calculation boundary;
- `Humay/Domain/Astrology/AstrologyCalculationContracts.swift` defines typed Humay calculation results, fact reliability/availability, provenance and a finite payload-free calculation failure model;
- `Humay/Domain/Astrology/AstrologyCalculationAdapter.swift` defines independent Western, Vedic and BaZi adapter protocols with explicit tradition ownership and a shared mismatch guard;
- concrete fact schemas remain deferred to their owning validated calculation tasks instead of being guessed in ASTRO-002;
- `HumayTests/BirthCalculationInputTests.swift` and `HumayTests/AstrologyCalculationContractTests.swift` cover the calculation input and adapter/result contracts;
- no concrete provider, API client, endpoint, secret, networking, fallback runtime or UI was added.

ASTRO-001 and ASTRO-002 are not marked DONE until the latest branch passes the canonical foundation verification and complete Swift Testing after these source changes. ASTRO-003 must not silently adopt vendor defaults; it requires validated Western methodology and golden-fixture evidence.

See [`phases/02-astrology-engine-foundation.md`](phases/02-astrology-engine-foundation.md).

## Device scope

Humay targets **iPhone + iPad** from the start.

- Minimum: iOS / iPadOS 18.0.
- iPhone: portrait-first.
- iPad: portrait + landscape.
- Adaptive layouts support compact/regular widths and narrower multitasking windows where applicable.
- `TARGETED_DEVICE_FAMILY = 1,2`.

## Visual design authority

Current and exclusive authority:

- [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md)
- [`../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
- [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md)
- [`../design/soulful-reference/`](../design/soulful-reference/README.md)

### D0

iPhone Light/Dark anchors approved for Today, Daily Horoscope and Compatibility. iPad companion anchors are pending.

### D1

Canonical onboarding:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Current status:

- complete cross-device D1 package approved 2026-08-12;
- Welcome, Birth Date, Tradition and Profile Reveal production UI implemented;
- actual Light/Dark simulator evidence captured under `docs/design/implementation-evidence/d1-onboarding/`; the iPad landscape screenshot-export limitation is documented there;
- compact iPad windows collapse toward the compact hierarchy and iPad landscape uses adaptive two-region compositions where defined.

Birth time and birth location are not onboarding steps.

## Implementation gate

Shared architecture/design-system/foundation work may proceed without a visual mock when it has no user-facing UI. User-facing UI must be designed and approved before implementation. A feature-specific production screen is not visually frozen until its repository package contains iPhone Light/Dark + iPad Light/Dark references and required adaptive notes.

Cadence for user-facing work:

**UI design → approve → implement → capture real cross-device screenshots → reconcile → continue**.

## Binding product decisions

- Product/repository/internal name is Humay.
- Primary IA is Today / Circle / Sky / Chart / Ask.
- Ordinary Free usage must not trigger paid astrology or LLM calls.
- Free Western daily horoscope uses finite Sun-sign catalog content.
- Free Western compatibility uses 12 × 12 sign-pair catalog keys.
- Free has no natal-chart calculation.
- Personalized/precision features use Rewarded Access or Premium.
- Precision is cache-first and server-side.
- Numeric compatibility presentation is allowed, but visual mock scores do not define methodology.
- Roast changes expression, not calculated facts.
- Unknown birth time is never replaced with a fake time.
- Humay V1 requires no Humay user account, registration, Sign in with Apple or login UI.
- User-owned data is local-first, with private iCloud/CloudKit sync/restore planned but not implemented; private profile/astrology data does not use public CloudKit.

## Current runtime

The app restores the local user-state snapshot before resolving a meaningful root. A missing file produces fresh four-beat onboarding. `Enter Humay` saves the profile/settings aggregate atomically before resolving the root to the existing minimal semantic Light/Dark Humay placeholder. Terminating and relaunching a completed app restores the main placeholder. Save failures leave the onboarding draft intact and expose a retry alert; restore failures remain distinct from fresh onboarding.

The local snapshot is the device source of truth for this slice. It stores only profile/settings, including date components, explicit unknown/not-provided birth values, leading tradition, tone and completion timestamp. The ASTRO-001/002 types are currently validated Domain contracts only and are not wired to a calculation provider. No production astrology provider, interpretation provider, CloudKit sync/restore, authentication/account flow, backend identity, StoreKit, ads, analytics, notification delivery or post-onboarding feature runtime is wired yet. Profile Reveal uses no provider-backed astrology and displays only the entered birth date, selected leading tradition and date-only/non-precise state.
