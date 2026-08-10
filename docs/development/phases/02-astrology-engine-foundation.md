# Phase 02 — Astrology Engine Foundation

Status: **TODO**
Depends on: Phase 00, Phase 01 foundation

Goal: establish trustworthy deterministic astrology facts and validation infrastructure before product features depend on them.

## Tasks

### ASTRO-001 — Define shared birth/location/time input models
Status: TODO

Acceptance:
- Date, exact/unknown/approximate time, timezone and location are modeled explicitly.
- Unknown-time uncertainty can be propagated rather than collapsed to a fake default time.

### ASTRO-002 — Implement engine adapter/protocol layer
Status: TODO
Depends on: ASTRO-001

Acceptance:
- Western, Vedic and Chinese/BaZi calculations can have independent adapters.
- App features consume typed calculation results, not vendor/API response shapes.
- Calculation provenance/version is retained.

### ASTRO-003 — Implement validated Western calculation baseline
Status: TODO
Depends on: ASTRO-002

Scope:
- planetary positions;
- Ascendant/houses when time permits;
- aspects;
- relevant event/transit facts required by initial features.

Acceptance:
- Golden fixtures are independently validated.
- Unknown-time reliability is represented per fact.

### ASTRO-004 — Add Vedic calculation baseline behind methodology gates
Status: TODO
Depends on: ASTRO-002, METHOD-003 where production sign-off is required

Acceptance:
- Sidereal facts/nakshatra/time-dependent outputs carry methodology version/provenance.
- Provisional Lahiri use is clearly dev-only until sign-off.

### ASTRO-005 — Add BaZi engine boundary and disabled production gate
Status: TODO
Depends on: ASTRO-002

Acceptance:
- Four-Pillars/Luck-Cycle interfaces exist without pretending unresolved conventions are settled.
- Production BaZi output remains feature-gated until METHOD-005/006/007 are signed off.

### ASTRO-006 — Build calculation fixture and validation suite
Status: TODO
Depends on: ASTRO-003

Acceptance:
- Multiple birth locations, DST/timezone cases, unknown-time cases and boundary cases are covered.
- Fixtures record source/method/version.
- Design artifact values are not accepted merely because they appear in mockups.

### ASTRO-007 — Define stable feature-facing astrology fact contracts
Status: TODO
Depends on: ASTRO-003 through ASTRO-006

Acceptance:
- Chart, Today, Sky, compatibility and Ask can consume immutable/typed facts.
- Presentation does not need to know engine/vendor internals.

## Exit criteria

- Initial Western calculations are validated and testable.
- Vedic/BaZi adapters respect methodology gates.
- Features have stable typed contracts for deterministic facts.
- No LLM/interpretation component calculates astrological positions.
