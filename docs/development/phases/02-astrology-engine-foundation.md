# Phase 02 — Astrology Calculation Foundation

Status: **TODO — ARCH-003 complete; Phase 01 verification remains the start gate**

Depends on:
- Phase 01 Apple Platform Foundation;
- relevant Phase 00 provider/privacy/cache contracts for the calculation path being implemented.

Architecture authority:
- [`../../architecture/SYSTEM_ARCHITECTURE.md`](../../architecture/SYSTEM_ARCHITECTURE.md)
- [`../../architecture/ASTROLOGY_ENGINE.md`](../../architecture/ASTROLOGY_ENGINE.md)
- [`../../architecture/DATA_MODEL.md`](../../architecture/DATA_MODEL.md)

Goal: establish trustworthy deterministic astrology facts and validation infrastructure before production features depend on them.

The calculation-provider strategy is now frozen at the Humay-contract level: provider adapters are server-side/vendor-independent, normalized facts retain reliability/provenance/versioning, and interpretation remains a separate downstream boundary. No concrete provider vendor is selected by this phase plan.

## Tasks

### ASTRO-001 — Confirm shared birth/location/time calculation inputs
Status: TODO
Depends on: Phase 01 completion

Acceptance:
- reuses current `BirthDetails` semantics where appropriate rather than inventing a parallel user model;
- date, exact/unknown/approximate time, timezone and location are modeled explicitly;
- unknown-time uncertainty propagates rather than collapsing to a fake default time;
- concrete Swift/domain types reconcile with `ASTROLOGY_ENGINE.md` instead of provider-native input models.

### ASTRO-002 — Implement calculation adapter/protocol layer
Status: TODO  
Depends on: ASTRO-001, ARCH-003

Acceptance:
- Western, Vedic and Chinese/BaZi calculations can have independent adapters;
- app features consume typed Humay calculation results, not vendor/API response shapes;
- calculation reliability, provenance and version are retained;
- provider secrets and paid calls remain server-side under the current architecture;
- fallback is not permitted unless the candidate adapter passes the contract/methodology validation requirements defined by `ASTROLOGY_ENGINE.md`.

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

## Start rule

Do not begin Phase 02 source/runtime work until Phase 01 is actually closed by the IOS-007 post-change verification run. Architecture/documentation may continue in parallel.

Once Phase 01 closes, ASTRO-001 is the next calculation-source task. ASTRO-002 may use the already-complete ARCH-003 contract, but provider-backed feature runtime must still wait for every additional relevant Phase 00 cache/backend/access/privacy contract.

## Exit criteria

- initial Western precision calculations are validated and testable;
- Vedic/BaZi adapters respect methodology gates;
- features have stable typed contracts for deterministic facts;
- no LLM/interpretation component calculates astrological positions.
