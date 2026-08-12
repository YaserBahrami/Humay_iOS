# Phase 02 — Astrology Calculation Foundation

Status: **IN PROGRESS — ASTRO-001 and ASTRO-002 implemented; verification pending**

Depends on:
- Phase 01 Apple Platform Foundation;
- relevant Phase 00 provider/privacy/cache contracts for the calculation path being implemented.

Architecture authority:
- [`../../architecture/SYSTEM_ARCHITECTURE.md`](../../architecture/SYSTEM_ARCHITECTURE.md)
- [`../../architecture/ASTROLOGY_ENGINE.md`](../../architecture/ASTROLOGY_ENGINE.md)
- [`../../architecture/DATA_MODEL.md`](../../architecture/DATA_MODEL.md)

Goal: establish trustworthy deterministic astrology facts and validation infrastructure before production features depend on them.

The calculation-provider strategy is frozen at the Humay-contract level: provider adapters are server-side/vendor-independent, normalized facts retain reliability/provenance/versioning, and interpretation remains a separate downstream boundary. No concrete provider vendor is selected by this phase plan.

## Tasks

### ASTRO-001 — Confirm shared birth/location/time calculation inputs
Status: **IMPLEMENTED — post-change verification pending**  
Depends on: Phase 01 completion for acceptance

Implemented:
- `BirthCalculationInput` wraps the existing `BirthDetails` model instead of copying profile facts into a parallel calculation-user model;
- the calculation boundary preserves explicit `.exact`, `.approximate` and `.unknown` birth-time states;
- approximate time must carry positive uncertainty and is never promoted to exact;
- `.notProvided` birth place remains valid for date-only/limited calculations;
- known place validation requires a nonblank name, finite bounded coordinates and a valid timezone identifier;
- birth-date validation rejects impossible dates, dates before the current product-supported 1900 lower bound and future dates;
- selected `AstrologyTradition` is carried explicitly without introducing vendor-native methodology fields;
- focused Swift Testing coverage verifies preservation and rejection rules.

Acceptance:
- reuses current `BirthDetails` semantics where appropriate rather than inventing a parallel user model;
- date, exact/unknown/approximate time, timezone and location are modeled explicitly;
- unknown-time uncertainty propagates rather than collapsing to a fake default time;
- concrete Swift/domain types reconcile with `ASTROLOGY_ENGINE.md` instead of provider-native input models.

ASTRO-001 is not marked DONE until the latest branch passes the local foundation verification plus the complete Swift Testing target after the current Phase 02 source changes.

### ASTRO-002 — Implement calculation adapter/protocol layer
Status: **IMPLEMENTED — post-change verification pending**  
Depends on: ASTRO-001, ARCH-003

Implemented:
- `AstrologyCalculationAdapter` is a framework-neutral Domain protocol with an associated typed Humay fact contract;
- `WesternCalculationAdapter`, `VedicCalculationAdapter` and `BaZiCalculationAdapter` provide independent methodology-family boundaries without choosing a vendor;
- each adapter has an explicit tradition and a shared guard that rejects cross-tradition reinterpretation;
- `AstrologyCalculationResult<Fact>` carries typed normalized facts, calculation time and Humay-owned provenance;
- `AstrologyCalculationFact` requires fact-level reliability without freezing the concrete Western/Vedic/BaZi fact schema before the owning tasks;
- reliability distinguishes reliable, uncertain and unavailable facts with typed reasons;
- provenance retains calculation-contract, methodology, adapter, engine and configuration version dimensions without exposing vendor-native response objects;
- `AstrologyCalculationError` is a finite Humay-owned payload-free failure surface rather than a raw vendor/network error passthrough;
- focused Swift Testing verifies typed results, provenance/reliability preservation, independent tradition boundaries, tradition mismatch rejection and the finite failure surface;
- no concrete provider, networking, endpoint, credential, backend client or UI was added.

Acceptance:
- Western, Vedic and Chinese/BaZi calculations can have independent adapters;
- app features consume typed Humay calculation results, not vendor/API response shapes;
- calculation reliability, provenance and version are retained;
- provider secrets and paid calls remain server-side under the current architecture;
- fallback is not permitted unless the candidate adapter passes the contract/methodology validation requirements defined by `ASTROLOGY_ENGINE.md`.

ASTRO-002 defines the adapter/result contracts only. It does not implement fallback selection: validated equivalence remains an adapter/runtime capability that cannot be claimed before ASTRO-006 evidence exists.

### ASTRO-003 — Implement validated Western calculation baseline
Status: TODO  
Depends on: ASTRO-002

Scope:
- planetary positions;
- Ascendant/houses when time permits;
- aspects;
- relevant event/transit facts required by initial precision features.

Acceptance:
- golden fixtures are independently validated;
- unknown-time reliability is represented per fact;
- unresolved METHOD items gate only facts that require them;
- vendor defaults do not silently become Humay methodology decisions.

### ASTRO-004 — Add Vedic calculation baseline behind methodology gates
Status: TODO  
Depends on: ASTRO-002, METHOD-003 where production sign-off is required

Acceptance:
- sidereal facts/nakshatra/time-dependent outputs carry methodology version/provenance;
- provisional settings are development-only until signed off.

### ASTRO-005 — Add BaZi engine boundary and disabled production gate
Status: TODO  
Depends on: ASTRO-002

Acceptance:
- Four-Pillars/Luck-Cycle interfaces do not pretend unresolved conventions are settled;
- production BaZi output remains gated until required METHOD items are signed off.

### ASTRO-006 — Build calculation fixture and validation suite
Status: TODO  
Depends on: ASTRO-003

Acceptance:
- multiple birth locations, DST/timezone cases, unknown-time cases and boundary cases are covered;
- fixtures record source/method/version;
- design artifact values are never accepted merely because they appear in mockups;
- any claimed fallback/cross-provider equivalence has fixture evidence.

### ASTRO-007 — Define stable feature-facing astrology fact contracts
Status: TODO  
Depends on: validated ASTRO paths

Acceptance:
- Chart, Today, Sky, compatibility and Ask consume immutable/typed Humay facts appropriate to their feature;
- Presentation does not know engine/vendor internals;
- unavailable/uncertain facts are typed explicitly.

## Start / verification rule

ASTRO-001 and ASTRO-002 source contracts are implemented because they are non-visual, provider-independent Domain work under the approved ARCH-003 boundary. Neither is marked DONE until the latest branch passes the IOS-007/foundation verification and complete Swift Testing after these source changes.

Do not start a concrete paid-provider/backend runtime from these protocols. Provider-backed runtime remains blocked on the relevant unfinished Phase 00 cache/backend/access/privacy contracts, and ASTRO-003 still requires validated Western methodology/fixture decisions rather than vendor defaults.

## Exit criteria

- initial Western precision calculations are validated and testable;
- Vedic/BaZi adapters respect methodology gates;
- features have stable typed contracts for deterministic facts;
- no LLM/interpretation component calculates astrological positions.
