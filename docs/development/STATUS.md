# Development Status

Last updated: **2026-08-12**

## Active priorities

1. Verify and reconcile the implemented D1 onboarding slice PROFILE-001 through PROFILE-004.
2. Keep **IOS-005 / PROFILE-005 persistence unstarted**; relaunch is intentionally volatile for this slice.
3. Preserve the completed Soulful Celestial DesignSystem foundation while later feature families remain behind their cross-device design gates.
4. Continue Phase 00 provider/cache/access architecture in parallel where it does not block the app foundation.

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

**IN PROGRESS. IOS-001 through IOS-004 are complete; IOS-005 is not started.**

Current verified foundation:

- representative iPhone and iPad Debug simulator builds pass;
- Swift 6 complete strict concurrency, iOS/iPadOS 18.0 and device families `1,2` remain effective;
- Humay naming, shared scheme and centralized Debug/Release xcconfig inheritance remain intact;
- `HumayApp` explicitly owns the small `AppEnvironment` composition boundary;
- `HumayApp` explicitly composes the transient `AppNavigationState` root/route
  boundary without persisting routing state or adding later feature UI;
- Domain remains independent of UI and persistence frameworks;
- DesignSystem contains the approved semantic Light/Dark tokens, Dynamic Type typography, adaptive layout, generic surfaces and primary/quiet button foundations;
- the DesignSystem showcase exists only in Debug previews for representative iPhone/iPad Light/Dark verification and is not a runtime route;
- no Data structure exists without current production behavior; the approved D1
  onboarding Presentation structure is now present;
- Swift Testing, the UI launch test and architecture/nomenclature checks pass;
- no third-party dependency or provider-backed feature UI was added.

The first production feature slice is now implemented separately under Phase 03:

- D1 onboarding is the root experience when `AppNavigationState.root == .onboarding`;
- the main root remains the minimal Humay foundation placeholder;
- completion creates an in-memory `UserProfile` with unknown birth time and no birth place;
- no persistence, provider, networking or account flow is present.

Foundation scope:

- SwiftUI application shell;
- Clean Architecture boundaries: `App → Presentation → Domain ← Data`;
- explicit dependency composition;
- production Soulful Celestial semantic design tokens/primitives;
- iPhone + iPad adaptive layout foundations;
- Light + Dark from the start;
- root routing/state boundaries without speculative feature UI;
- persistence/configuration/testing boundaries prepared without premature feature schemas.

See [`phases/01-ios-foundation.md`](phases/01-ios-foundation.md).

### Phase 00 — Technical Architecture

Provider/cache/backend/privacy architecture remains **IN PROGRESS in parallel**. Phase 01 foundation does not require every provider-specific Phase 00 document to be finished first; it does require the current product-access, iOS architecture, clean-baseline and design-authority contracts.

See [`phases/00-technical-architecture.md`](phases/00-technical-architecture.md).

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

Shared architecture/design-system foundation may proceed now. A feature-specific production screen is not visually frozen until its repository package contains iPhone Light/Dark + iPad Light/Dark references and required adaptive notes.

Cadence:

**design → approve → implement → capture real cross-device screenshots → reconcile → continue**.

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

The app launches the production four-beat onboarding flow for a fresh `AppEnvironment`. `Enter Humay` completes onboarding only in current in-memory state and resolves the root to the existing minimal semantic Light/Dark Humay placeholder. After terminating/relaunching, onboarding begins again because PROFILE-005 persistence is not implemented.

No production astrology provider, interpretation provider, persistence/CloudKit schema, authentication/account flow, backend identity, StoreKit, ads, analytics, notification delivery or post-onboarding feature runtime is wired yet. Profile Reveal uses no provider-backed astrology and displays only the entered birth date, selected leading tradition and date-only/non-precise state.
