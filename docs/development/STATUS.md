# Development Status

Last updated: **2026-08-13**

## Active priorities

1. Keep Calendar/Event Detail work behind their approved references and task gates; Calendar Month/Week is implemented over the Debug sample.
2. Review the captured D2 Today + Circle implementation evidence and close the documented portrait-asset/iPad-reference discrepancies only when approved assets/references exist.
3. Keep D2 and D3 development content behind explicit Debug composition; Release must expose only safe unavailable/empty states until real owning providers exist.
4. Defer backend/API/provider and monetization work; ARCH-007 entitlement, ARCH-008 privacy/security and methodology validation remain prerequisites for production precision rollout.
5. Do not begin Event Detail, D4 Chart or D5 Ask without their approved visual references and task gates.

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

The new UI-first workflow does **not** restore that deleted mock-provider architecture. Approved screens may use explicit development sample data through Humay-owned contracts until real Data/API adapters are connected.

Details: [`../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md).

## Engineering track

### Phase 01 — Apple Platform Foundation

**DONE. IOS-001 through IOS-007 are complete and the post-D2 local verification passed on 2026-08-12.**

Current foundation:

- the current verification run passed representative iPhone/iPad Debug builds, the complete 69-test Swift Testing target, all 9 XCUITests on both representative devices, layering, nomenclature, diagnostics and `git diff --check`;
- Swift 6 complete strict concurrency, iOS/iPadOS 18.0 and device families `1,2` remain effective;
- Humay naming, shared scheme and centralized Debug/Release xcconfig inheritance remain intact;
- `HumayApp` explicitly owns the small `AppEnvironment` composition boundary;
- `HumayApp` explicitly composes the transient `AppNavigationState` root/route boundary without persisting routing state;
- Domain remains independent of UI and persistence frameworks;
- DesignSystem contains the approved semantic Light/Dark tokens, Dynamic Type typography, adaptive layout, generic surfaces and primary/quiet button foundations;
- Data contains only the production-owned local persistence slice justified by IOS-005/PROFILE-005;
- IOS-006 centralizes privacy-safe OSLog diagnostics behind finite typed application/persistence events;
- IOS-007 provides `Scripts/verify-foundation.sh` and [`VERIFICATION.md`](VERIFICATION.md) as the canonical repository/local Xcode verification contract; the canonical script passed after the D2 implementation commit;
- no third-party dependency or CI workflow is configured.

### Phase 00 — Technical Architecture

Phase 00 remains **IN PROGRESS**, but **ARCH-001 through ARCH-006 are now complete**.

Frozen architecture:

- **ARCH-001:** [`../architecture/SYSTEM_ARCHITECTURE.md`](../architecture/SYSTEM_ARCHITECTURE.md) — separate Free and precision trust/cost paths.
- **ARCH-002:** [`../architecture/IOS_ARCHITECTURE.md`](../architecture/IOS_ARCHITECTURE.md) — Apple `App → Presentation → Domain ← Data` boundary.
- **ARCH-003:** [`../architecture/ASTROLOGY_ENGINE.md`](../architecture/ASTROLOGY_ENGINE.md) — provider-independent Western/Vedic/BaZi calculation contracts, reliability/provenance/versioning and validated fallback rules.
- **ARCH-004:** [`../architecture/RESULT_CACHE_OFFLINE.md`](../architecture/RESULT_CACHE_OFFLINE.md) — separate calculation/interpretation cache identities, authoritative server precision cache/idempotency and explicit offline behavior.
- **ARCH-005:** [`../architecture/INTERPRETATION_LAYER.md`](../architecture/INTERPRETATION_LAYER.md) — structured interpretation input/output, prompt/model/safety provenance, retries/idempotency and the rule that LLMs never invent calculation facts.
- **ARCH-006:** [`../architecture/BACKEND.md`](../architecture/BACKEND.md) — Free catalog generation/publishing/serving, precision orchestration, reference data, provider adapter and observability responsibilities.

Still open:

- ARCH-007 — Rewarded/Premium entitlement architecture;
- ARCH-008 — privacy/security/retention/deletion/provider transmission;
- ARCH-009 — provider/cache/idempotency/cost validation completion;
- ARCH-010 — final roadmap/repo closure after those remaining contracts.

No concrete calculation provider, interpretation provider, database or hosting vendor is frozen yet.

### Phase 02 — Astrology Calculation Foundation

**IN PROGRESS. ASTRO-001 and ASTRO-002 contracts are implemented; ASTRO-003 has a partial provider-independent Western normalization/validation foundation.**

Current implementation:

- `BirthCalculationInput` reuses `BirthDetails` and validates date/time/place semantics without fake defaults;
- typed calculation result, reliability, provenance and finite failure contracts exist;
- independent Western, Vedic and BaZi adapter protocols exist;
- the initial Western ten-body/tropical longitude/major-aspect vocabulary and structural result validation exist;
- Ascendant/houses remain gated by unresolved METHOD-001 rather than inheriting a provider default;
- focused Swift Testing covers current contracts;
- no concrete provider, API client, endpoint, secret or networking runtime is present.

ASTRO-001/002 remain verification-pending. ASTRO-003 remains **PARTIAL** until a real server-side engine/provider is independently validated with golden fixtures and methodology-sensitive outputs are approved.

Under the new implementation order, that provider work is intentionally deferred while the core UI is designed/implemented against development sample data.

See [`phases/02-astrology-engine-foundation.md`](phases/02-astrology-engine-foundation.md).

### Phase 03 — Onboarding & Local Profile

The approved D1 onboarding slice PROFILE-001 through PROFILE-005 is implemented:

- Welcome → Birth Date → Tradition → Profile Reveal;
- completion durably stores local `UserProfile`/`AppSettings` schema v1;
- onboarding does not ask for birth time/location;
- restore resolves completed state to the real adaptive primary navigation shell;
- no provider, networking, CloudKit or account flow is present.

Birth-time/place editing remains a later Profile/Settings UI task and requires its own UI approval.

## UI-first development plan

The next development emphasis is user-facing UI, not backend provider code.

For each core family:

1. generate iPhone Light/Dark + iPad Light/Dark design references;
2. obtain approval;
3. implement the real SwiftUI hierarchy and feature state model;
4. inject explicit **development sample data** conforming to Humay-owned contracts;
5. cover the approved loaded/loading/cache/offline/limited/error/access states;
6. capture real cross-device simulator screenshots and reconcile;
7. only later replace the development source with real Data/API adapters.

Development sample data is never production truth, methodology evidence or a shipping provider fallback. Release runtime must not present sample personalized astrology as real output.

### D2 implementation

**D2 — Today + Circle** is implemented as a UI-first presentation slice using Debug-only development sample data.

It establishes:

- the first real main-root Today experience;
- Free/coarse vs precision Today states;
- Circle/Saved People foundations;
- coarse compatibility vs precise-upgrade states;
- cache/reopen/loading/offline/error states needed by the new architecture;
- iPhone/iPad Light/Dark and adaptive behavior;
- Today, Daily Horoscope, Circle, minimal Add Person and Compatibility presentation;
- explicit loading, loaded, Free, precise-locked, precise-loaded, cached, offline, failed and empty states where applicable;
- a Release composition that exposes no development astrology sample payload.

The implementation is under `Humay/Presentation/Today/`, `Humay/Presentation/Circle/` and `Humay/Presentation/Main/`. Evidence is under [`../design/implementation-evidence/d2-today-circle/`](../design/implementation-evidence/d2-today-circle/README.md).

Production Free catalog/backend/provider, precision generation, entitlement, monetization and Saved People persistence remain deferred. Phase 05 and Phase 07 therefore remain partial rather than DONE.

### D3 engineering foundation

**D3 — Sky + Calendar is PARTIAL: Current Sky, Calendar Month/Week, and Event Detail are implemented over a Debug-only sample; production data and methodology work remain pending.**

Implemented:

- Humay-owned `SkySnapshot`, `SkyEvent`, event type/system/relevance/reliability and mutually exclusive timing contracts;
- validated civil calendar dates, month selections, seven-day weeks and event-bearing month/week content;
- separate event meaning and astrological-basis fields for future detail presentation;
- explicit Current Sky, month, week and event-detail loading/loaded/empty/unavailable/offline/failed states;
- `D3FeatureInput.productionUnavailable` with no sample payload;
- Debug-only `DevelopmentD3Sample` with deterministic, unverified values and launch-argument state variants;
- Current Sky SwiftUI for compact iPhone and wide iPad layouts, including loaded, loading, empty, unavailable, cached-offline, offline-without-cache and failed states;
- Calendar Month/Week SwiftUI nested under Sky, with Monday-first civil grids, selected/today/quiet/event semantics, typed loading/loaded/empty/unavailable/offline/failed states, timezone-safe timing, and adaptive iPhone/iPad composition;
- Event Detail SwiftUI under Sky with loaded, loading, unavailable, event-not-found, offline cached/no-cache, and failed states; Current Sky and Calendar Month/Week native routes preserve origin context;
- actual iPhone/iPad Light/Dark simulator evidence and hierarchy/state UI coverage under `docs/design/implementation-evidence/d3-sky-calendar/`;
- focused Swift Testing and XCUITest coverage for validation, state semantics, deterministic sample composition, detail navigation/back preservation, and Release-safe composition.

Not implemented:

- a calculation/provider pipeline, networking, caching, persistence or personalization;
- methodology approval or production event provenance.

D3.1 Current Sky, D3.2 Calendar and D3.3 Event Detail approved visual references exist under `docs/design/soulful-reference/`. `SKY-003`, `SKY-004`, and `SKY-005` are implemented over the Debug-only sample; `SKY-002` remains pending for production data and `SKY-006` remains TODO.

## Backend/API timing

Backend/API implementation follows the UI-first pass for the relevant feature contracts.

When it begins, it must:

- use Humay-owned API contracts rather than vendor-shaped UI models;
- implement Free catalog and precision paths separately;
- use authoritative server cache/idempotency;
- keep provider secrets server-side;
- finish ARCH-007/008 before production rewarded/Premium provider rollout;
- validate real calculation providers independently from mock/design values;
- replace sample sources at the app Data/composition boundary without redesigning Presentation.

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
- actual Light/Dark simulator evidence captured under `docs/design/implementation-evidence/d1-onboarding/`;
- compact iPad windows collapse toward the compact hierarchy and iPad landscape uses adaptive two-region compositions where defined.

Birth time and birth location are not onboarding steps.

### D2

Current status:

- approved Light/Dark iPhone composites are committed under [`../design/soulful-reference/today-circle/`](../design/soulful-reference/today-circle/README.md);
- production SwiftUI hierarchy is implemented with explicit feature states and Debug-only development sample composition;
- real iPhone/iPad Light/Dark portrait simulator evidence is committed under [`../design/implementation-evidence/d2-today-circle/`](../design/implementation-evidence/d2-today-circle/README.md);
- adaptive iPad portrait/landscape paths pass UI tests; iOS 26.5 exports the landscape framebuffer rotated/cropped, so raw artifacts are labeled and no pixel-perfect landscape claim is made;
- formal static D2 iPad references and approved portrait assets remain visual-reconciliation gaps.

## Implementation gate

Non-visual architecture/domain/foundation work may proceed without a visual mock. **Every user-facing UI must be designed and approved before implementation.**

Cadence for user-facing work:

**UI design → approve → implement with real state structure + development sample data → capture real cross-device screenshots → reconcile → continue.**

## Binding product decisions

- Product/repository/internal name is Humay.
- Primary IA is Today / Circle / Sky / Chart / Ask.
- Ordinary Free usage must not trigger paid astrology or LLM calls.
- Free Western daily horoscope uses finite Sun-sign catalog content.
- Free Western compatibility uses 12 × 12 sign-pair catalog keys.
- Free has no natal-chart calculation.
- Personalized/precision features use Rewarded Access or Premium.
- Precision is cache-first and server-side.
- Numeric compatibility presentation is allowed, but visual/sample scores do not define methodology.
- Roast changes expression, not calculated facts.
- Unknown birth time is never replaced with a fake time.
- Humay V1 requires no Humay user account, registration, Sign in with Apple or login UI.
- User-owned data is local-first, with private iCloud/CloudKit sync/restore planned but not implemented; private profile/astrology data does not use public CloudKit.

## Current runtime

The app restores the local user-state snapshot before resolving a meaningful root. A missing file produces fresh four-beat onboarding. `Enter Humay` saves the profile/settings aggregate atomically before resolving the root to the adaptive Today / Circle / Sky / Chart / Ask shell. Terminating and relaunching a completed app restores that shell. Profile/Settings remains auxiliary from the header. Current Sky and Calendar Month/Week are implemented over the Debug-only sample; Chart and Ask remain minimal destination placeholders. Save failures leave the onboarding draft intact and expose a retry alert; restore failures remain distinct from fresh onboarding.

Debug builds inject `DevelopmentD2Sample` and `DevelopmentD3Sample` into the implemented D2/Current Sky runtime. Both development sample types are excluded by `#if DEBUG`; their Release compositions contain no sample astrology payload. The local snapshot remains the device source of truth only for current profile/settings; D2-added people and all D3 samples are transient and do not expand the persistence schema.

The ASTRO-001/002/003 types remain provider-independent Domain contracts and are not wired to D2 sample presentation or a calculation provider. No production astrology provider, interpretation provider, backend API, CloudKit sync/restore, authentication, StoreKit, ads, analytics or notification delivery is wired yet.
