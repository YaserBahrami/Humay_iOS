# Phase 05 — Today

Status: **TODO**

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
Status: TODO

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
Status: TODO  
Depends on: TODAY-002, approved D2 package

Acceptance:
- uses current Design Authority and approved D2 package;
- iPhone Light/Dark and iPad Light/Dark are intentional compositions;
- Free experience is useful while clearly labeled as coarse/sign- or validated-system-bucket-based;
- precision upgrade/cached-result state is understandable without overstating accuracy;
- implementation evidence is reconciled against approved cross-device references.

### TODAY-004 — Implement astrological basis/accuracy disclosure
Status: TODO  
Depends on: TODAY-003

Acceptance:
- Free disclosure states the coarse basis and does not claim natal personalization;
- precision disclosure references only structured factors actually used;
- copy does not present astrology as scientific evidence.

### TODAY-005 — Implement Normal/Roast expression behavior
Status: TODO  
Depends on: TODAY-002, ARCH-005

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
