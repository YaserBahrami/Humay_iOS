# Phase 03 — Onboarding & Local Profile

Status: **TODO**
Depends on: Phase 01, ASTRO-001 contracts

Goal: capture and persist the user's birth/profile data safely, including unknown-time paths, without authentication.

## Tasks

### PROFILE-001 — Implement onboarding navigation and state machine
Status: TODO

Acceptance:
- Flow matches frozen onboarding reference.
- Resume/restart behavior is deterministic.
- No login/account step exists.

### PROFILE-002 — Implement birth date/time input
Status: TODO
Depends on: PROFILE-001

Acceptance:
- Exact time, rough/unknown time states are represented explicitly.
- No hidden noon/midnight substitution is treated as real birth time.

### PROFILE-003 — Implement birth location and timezone resolution
Status: TODO
Depends on: PROFILE-001

Acceptance:
- Stored profile retains canonical location/timezone inputs needed by the engine.
- Validation and offline/error behavior are defined.

### PROFILE-004 — Implement system preference and tone preference
Status: TODO
Depends on: PROFILE-001

Acceptance:
- Initial system choice sets first-read preference without hiding other systems.
- Normal/Roast preference is local app state and does not alter calculations.

### PROFILE-005 — Persist local profile and onboarding completion
Status: TODO
Depends on: PROFILE-002, PROFILE-003, PROFILE-004

Acceptance:
- Profile persists across restart.
- Schema is migration-ready.
- Premium status is not stored inside the profile entity.

### PROFILE-006 — Implement Profile/Settings birth-data editing
Status: TODO
Depends on: PROFILE-005

Acceptance:
- Editing invalidates/recalculates affected derived data safely.
- Privacy/data controls remain available without Premium.

### PROFILE-007 — Connect validated chart-reveal pipeline
Status: TODO
Depends on: PROFILE-005, ASTRO-003

Acceptance:
- Reveal uses deterministic engine output.
- Unknown-time behavior follows Pass 6.1.
- Design sample values are never hardcoded as production output.

## Exit criteria

- A user can complete onboarding without an account.
- Profile data is editable, migration-ready and engine-compatible.
- Unknown birth time is modeled honestly.
- Initial chart reveal is backed by validated calculations.
