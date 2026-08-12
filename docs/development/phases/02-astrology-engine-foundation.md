# Phase 02 — Astrology Calculation Foundation

Status: **TODO**

Depends on:
- Phase 01 Apple Platform Foundation;
- relevant Phase 00 provider/privacy/cache contracts for the calculation path being implemented.

Goal: establish trustworthy deterministic astrology facts and validation infrastructure before production features depend on them.

## Tasks

### ASTRO-001 — Confirm shared birth/location/time calculation inputs
Status: TODO

Acceptance:
- reuses current `BirthDetails` semantics where appropriate rather than inventing a parallel user model;
- date, exact/unknown/approximate time, timezone and location are modeled explicitly;
- unknown-time uncertainty propagates rather than collapsing to a fake default time.

### ASTRO-002 — Implement calculation adapter/protocol layer
Status: TODO  
Depends on: ASTRO-001, ARCH-003

Acceptance:
- Western, Vedic and Chinese/BaZi calculations can have independent adapters;
- app features consume typed Humay calculation results, not vendor/API response shapes;
- calculation provenance/version is retained;
- provider secrets and paid calls remain server-side under the current architecture.

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
- unresolved METHOD items gate only facts that require them.

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
- design artifact values are never accepted merely because they appear in mockups.

### ASTRO-007 — Define stable feature-facing astrology fact contracts
Status: TODO  
Depends on: validated ASTRO paths

Acceptance:
- Chart, Today, Sky, compatibility and Ask consume immutable/typed Humay facts appropriate to their feature;
- Presentation does not know engine/vendor internals;
- unavailable/uncertain facts are typed explicitly.

## Exit criteria

- initial Western precision calculations are validated and testable;
- Vedic/BaZi adapters respect methodology gates;
- features have stable typed contracts for deterministic facts;
- no LLM/interpretation component calculates astrological positions.
