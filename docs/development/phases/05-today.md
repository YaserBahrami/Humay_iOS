# Phase 05 — Today

Status: **PARTIAL — D2 sample-driven presentation implemented; production catalog/provider work deferred**

Depends on:
- Phase 01 platform/design-system foundation;
- Phase 03 profile/birth-date foundation;
- relevant Phase 02 facts for precision Today;
- ARCH-006 for Free catalog serving;
- ARCH-005/007 for provider-backed interpretation/access;
- approved D2 cross-device design references before feature-specific UI implementation.

Goal: deliver a useful zero-paid-provider-call Free daily reading plus an optional cache-first precise personalized upgrade.

## Tasks

### TODAY-001 — Define Free vs precision Today contracts
Status: **PARTIAL — presentation contracts implemented**

Implemented in D2:

- separate typed Free Western Sun-sign and precise-personalized basis values;
- explicit feature states rather than unrelated optionals;
- Presentation consumes Humay-owned content models with no vendor structure.

Still required: production Free catalog identity/version/locale contracts, precision fact input contract, telemetry/cache integration and Data/API adapters.

Acceptance:
- Free reading key uses only approved coarse system bucket/date/locale/variant inputs;
- Western Free baseline is a 12-Sun-sign daily catalog;
- precision contract consumes structured validated natal/timing facts when access permits;
- the two paths cannot be confused in telemetry/cache/UI basis disclosure.

### TODAY-002 — Implement Free daily catalog pipeline and app cache
Status: TODO  
Depends on: TODAY-001, ARCH-006

Acceptance:
- reads Humay-owned pre-generated/versioned content;
- offline/edge/local cache behavior follows the architecture contract;
- a missing Free entry never falls through to a paid provider;
- tests assert 0 paid provider calls for ordinary Free requests.

### TODAY-003 — Implement D2 Today UI for iPhone + iPad
Status: **PARTIAL — development-sample UI and evidence complete**
Depends on: TODAY-002, approved D2 package

Implemented in D2:

- adaptive main shell, Today and Daily Horoscope for iPhone/iPad Light/Dark;
- Today/Tomorrow/This Week, Love/Career/Money/Health detail, tip and Roast presentation;
- Free, precise-locked, precise-loaded, loading, cached, offline and failed presentation states;
- Debug-only typed sample composition and Release production-unavailable composition;
- real portrait evidence and passing adaptive landscape UI tests.

Not complete: production Free catalog/cache pipeline, provider-backed precision, entitlement behavior, formal static iPad-reference reconciliation and approved production portrait/illustration assets.

Acceptance:
- uses current Design Authority and approved D2 package;
- iPhone Light/Dark and iPad Light/Dark are intentional compositions;
- Free experience is useful while clearly labeled as coarse/sign- or validated-system-bucket-based;
- precision upgrade/cached-result state is understandable without overstating accuracy;
- implementation evidence is reconciled against approved cross-device references.

### TODAY-004 — Implement astrological basis/accuracy disclosure
Status: **PARTIAL — D2 presentation disclosure implemented**
Depends on: TODAY-003

The Free sample is labeled as coarse date-and-sign catalog content with no natal calculation. Precise presentation states are labeled development-only and explicitly state that no provider calculation/generation occurred. Production precision disclosure remains dependent on the actual structured facts and provider path.

Acceptance:
- Free disclosure states the coarse basis and does not claim natal personalization;
- precision disclosure references only structured factors actually used;
- copy does not present astrology as scientific evidence.

### TODAY-005 — Implement Normal/Roast expression behavior
Status: **PARTIAL — inert D2 Roast presentation only**
Depends on: TODAY-002, ARCH-005

The approved Roast card and a safe informational action exist. No tone transformation, provider call or calculated-fact mutation is implemented.

Acceptance:
- Normal/Roast never change underlying facts;
- calculation facts are not recalculated merely for tone;
- notifications remain Normal-register copy unless product authority changes.

### TODAY-006 — Implement precise personalized Today generation
Status: TODO  
Depends on: TODAY-001, required ASTRO contracts, ARCH-005, ARCH-007

Acceptance:
- cache lookup occurs before reward/provider generation;
- Rewarded Access authorizes one needed personalized-result generation;
- successful result is cached/reopenable;
- Premium uses the same cache-first path without the per-generation ad;
- provider failures have typed recovery behavior.

## Exit criteria

- Free Today causes 0 paid provider calls;
- Western Free catalog supports all 12 signs for every published day/variant;
- precision Today is access-controlled, cache-first and sourceable to structured facts;
- Free vs precision basis is transparent;
- shipping Today surfaces reconcile with approved D2 iPhone+iPad Light/Dark references.

## D2 verification snapshot

On 2026-08-12, representative iPhone/iPad Debug builds, the Release simulator build, 69 Swift tests, 9/9 iPhone UI tests and 9/9 iPad UI tests passed. The D2 navigation flow also passed at accessibility-extra-extra-extra-large content size. See [`../../design/implementation-evidence/d2-today-circle/`](../../design/implementation-evidence/d2-today-circle/README.md).

Phase 05 remains partial because no production catalog, cache adapter, backend/API, precision provider or entitlement runtime was added.
