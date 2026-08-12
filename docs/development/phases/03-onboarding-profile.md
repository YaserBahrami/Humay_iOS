# Phase 03 — Onboarding & Local Profile

Status: **IN PROGRESS — PROFILE-001 through PROFILE-005 DONE 2026-08-12; PROFILE-006 not started**

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
Status: **DONE — 2026-08-12**

Acceptance:
- flow matches the approved D1 references;
- back/forward behavior is deterministic;
- restart/resume behavior is defined;
- no login/account step exists;
- iPhone+iPad adaptive behavior matches the approved cross-device design.
- `AppNavigationState.onboardingRoute` remains transient and owns the four canonical routes;
- onboarding draft/input state remains inside `Presentation/Onboarding`.

### PROFILE-002 — Implement Birth Date step
Status: **DONE — 2026-08-12**
Depends on: PROFILE-001

Acceptance:
- collects date only;
- does not request time/location;
- preserves calendar-date semantics rather than manufacturing an instant;
- native date-input accessibility behavior is retained;
- validation/date bounds match the approved screen package;
- no hidden noon/midnight substitution exists.
- valid range is `1900-01-01...today` in the current calendar;
- picker cursor is UI state and enters `UserProfile` only after Continue confirms it.

### PROFILE-003 — Implement Tradition step
Status: **DONE — 2026-08-12**
Depends on: PROFILE-001

Acceptance:
- Western / Vedic / Chinese remain available;
- selected tradition sets leading vocabulary/default presentation only;
- selection does not hide the other systems;
- no provider-native concept leaks into onboarding state.
- Western remains the initial selection from `AppSettings.default`;
- selected state uses outline/tonal treatment and an explicit check indicator.

### PROFILE-004 — Implement Profile Reveal
Status: **DONE — 2026-08-12**
Depends on: PROFILE-002, PROFILE-003

Acceptance:
- only facts legitimately derivable from the available birth date + validated methodology are shown;
- no natal-chart precision, house, rising-sign or exact-time-dependent fact is invented;
- visual sample fixtures are never hardcoded as production truth;
- the screen clearly explains that time/place can be added later for precision-dependent features.
- displayed facts are limited to entered birth date, selected leading tradition and date-only/non-precise profile state;
- no astrology provider or calculation is used.

### PROFILE-005 — Persist profile/settings and onboarding completion
Status: **DONE — 2026-08-12**
Depends on: PROFILE-002, PROFILE-003

Acceptance:
- profile/settings and onboarding completion persist across termination/relaunch;
- date components, unknown birth time, not-provided birth place, leading tradition,
  current tone and completion timestamp roundtrip exactly;
- durable-storage failure is distinct from a fresh install, and save failure leaves
  draft values available for retry;
- schema version 1 is explicit and unsupported future versions fail;
- entitlement/Premium state is absent from the snapshot;
- the contract remains in Domain, DTO/file implementation remains inside Data and
  composition remains in App;
- local Application Support is the current source of truth; private CloudKit sync
  and restore remain future work.

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

- a user can complete the four-step onboarding without an account — **DONE for PROFILE-001–005**;
- onboarding asks for birth date and tradition only — **DONE**;
- profile completion is represented in current in-memory state after durable save — **DONE**;
- durable profile/settings persistence is represented by PROFILE-005's version-1 local snapshot and relaunch restore;
- time/place can be added later without fake defaults — domain semantics preserved; editor remains PROFILE-006;
- Profile Reveal shows only entered facts and the date-only precision state — **DONE**;
- iPhone and iPad Light/Dark implementations reconcile with approved D1 references — **DONE for current implementation evidence**.

### Current implementation boundary

`Enter Humay` saves through the app-owned `UserStateStore` before `AppNavigationState.root` resolves to `.main`. A newly created environment restores from the injected store; a missing file starts at Welcome, while read/decode failure exposes a persistence-failure state. The local version-1 snapshot uses Application Support and does not use UserDefaults, SwiftData or CloudKit. Do not begin PROFILE-006 or IOS-006 in this slice.
