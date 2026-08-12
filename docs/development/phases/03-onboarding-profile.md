# Phase 03 — Onboarding & Local Profile

Status: **TODO**

Depends on:
- Phase 01 Apple Platform Foundation;
- approved cross-device D1 references;
- validated methodology only for facts actually shown in Profile Reveal.

Goal: implement the canonical four-beat onboarding and durable local profile behavior without authentication, fake precision or provider coupling.

## Canonical onboarding

Exactly four beats:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are **not** onboarding steps. They are optional profile details added later when a precision-dependent feature needs them.

Tone/Roast is also not an onboarding question unless product authority is explicitly changed.

## Tasks

### PROFILE-001 — Implement onboarding navigation and state machine
Status: TODO

Acceptance:
- flow matches the approved D1 references;
- back/forward behavior is deterministic;
- restart/resume behavior is defined;
- no login/account step exists;
- iPhone+iPad adaptive behavior matches the approved cross-device design.

### PROFILE-002 — Implement Birth Date step
Status: TODO  
Depends on: PROFILE-001

Acceptance:
- collects date only;
- does not request time/location;
- preserves calendar-date semantics rather than manufacturing an instant;
- native date-input accessibility behavior is retained;
- validation/date bounds match the approved screen package;
- no hidden noon/midnight substitution exists.

### PROFILE-003 — Implement Tradition step
Status: TODO  
Depends on: PROFILE-001

Acceptance:
- Western / Vedic / Chinese remain available;
- selected tradition sets leading vocabulary/default presentation only;
- selection does not hide the other systems;
- no provider-native concept leaks into onboarding state.

### PROFILE-004 — Implement Profile Reveal
Status: TODO  
Depends on: PROFILE-002, PROFILE-003

Acceptance:
- only facts legitimately derivable from the available birth date + validated methodology are shown;
- no natal-chart precision, house, rising-sign or exact-time-dependent fact is invented;
- visual sample fixtures are never hardcoded as production truth;
- the screen clearly explains that time/place can be added later for precision-dependent features.

### PROFILE-005 — Persist profile/settings and onboarding completion
Status: TODO  
Depends on: PROFILE-002, PROFILE-003

Acceptance:
- birth date, leading tradition and onboarding-completion state persist across restart;
- durable-storage failure is handled explicitly;
- schema is versioned before shipping;
- entitlement/Premium state is not embedded in the profile entity;
- persistence implementation remains inside Data.

### PROFILE-006 — Add optional birth time/place editor in Profile
Status: TODO  
Depends on: PROFILE-005

Acceptance:
- exact, approximate and unknown time remain explicit domain states;
- place stores the canonical inputs needed by precision calculation, including timezone context where required;
- adding/removing time/place does not rewrite the original birth date;
- affected cached/derived precision results can be invalidated safely when those features exist.

This editor is a Profile/Settings surface governed by D6, not an onboarding extension.

### PROFILE-007 — Profile preferences and privacy controls
Status: TODO  
Depends on: PROFILE-005

Acceptance:
- leading tradition can be changed later;
- Normal/Roast preference is local expression state and never changes calculation facts;
- user-owned profile data can be removed according to the privacy architecture once finalized;
- controls remain available without Premium unless product authority explicitly says otherwise.

## Exit criteria

- a user can complete the four-step onboarding without an account;
- onboarding asks for birth date and tradition only;
- profile data persists reliably;
- time/place can be added later without fake defaults;
- Profile Reveal shows only validated date-supported facts;
- iPhone and iPad implementations reconcile with approved Light/Dark references.
