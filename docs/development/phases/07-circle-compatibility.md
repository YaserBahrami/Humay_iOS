# Phase 07 — Circle & Compatibility

Status: **PARTIAL — D2 sample-driven presentation implemented; persistence/catalog/provider work deferred**

Depends on:
- Phase 01 platform/design-system foundation;
- Phase 03 local-profile/persistence foundation;
- relevant Phase 02 compatibility facts for precision paths;
- ARCH-006 for Free catalog serving;
- ARCH-005/007 for precise interpretation/access;
- approved D2 cross-device Circle/Compatibility references before feature-specific UI implementation.

Goal: implement Saved People plus two clearly different compatibility products: coarse Free catalog compatibility and precise provider-backed compatibility.

## Tasks

### CIRCLE-001 — Implement Saved People domain/persistence
Status: TODO

D2 deliberately keeps added people transient and does not expand the shipped persistence schema. The UI preserves optional birth-time semantics; production Saved People ownership remains this task.

Acceptance:
- saved people are local/profile data, not accounts;
- birth date is preserved separately from optional time/place precision inputs;
- capacity rules remain configurable; Rewarded Access is not a slot-expansion currency;
- persistence models remain inside Data.

### CIRCLE-002 — Implement D2 Circle people/person-detail UI
Status: **PARTIAL — minimal approved D2 shell implemented**
Depends on: CIRCLE-001, approved D2 package

Implemented in D2:

- adaptive Circle landing, loaded/empty/loading/offline/failed states and two development people;
- person detail and minimal Add Person form for name, birth date and unknown/approximate/exact optional time;
- no invented required birth location, no persistence-schema expansion and no account semantics.

Not complete: production save/edit/remove, capacity behavior, canonical place/time-zone entry and formal static iPad-reference reconciliation.

Acceptance:
- add/edit/remove flows use current Design Authority + approved D2 references;
- iPhone Light/Dark and iPad Light/Dark are intentional compositions;
- birth-time/location uncertainty is retained for precision features;
- no deleted/historical design artifact is used as authority.

### CIRCLE-003 — Define compatibility contracts by system and precision tier
Status: **PARTIAL — Western presentation contracts implemented**
Depends on: relevant ASTRO fact contracts

D2 introduces distinct `FreeCompatibilityResult` and `PreciseCompatibilityResult` types, validated 0...100 presentation scores and four typed metric categories. It does not define a production synastry formula or falsely reuse Western scoring for Vedic/Chinese systems.

Acceptance:
- coarse Free catalog and precise natal compatibility are distinct domain result types;
- Western/Vedic/Chinese do not share a fake universal scoring formula;
- unsupported methodologies return typed unavailable/pending states;
- numeric presentation, where used, does not substitute for a defined methodology.

### CIRCLE-004 — Implement Free Western compatibility catalog
Status: **PARTIAL — 144-key model only**
Depends on: CIRCLE-003, ARCH-006

The ordered 12 × 12 Sun-sign pair keyspace is modeled and tested at 144 keys. No generated catalog, serving pipeline, Data/API adapter or paid-provider fallback exists.

Acceptance:
- supports **12 × 12 = 144** Western Sun-sign pairing keys;
- uses Humay-owned pre-generated/versioned content only;
- makes 0 paid provider calls;
- does not claim synastry/natal precision.

### CIRCLE-005 — Implement D2 compatibility report/access states
Status: **PARTIAL — development-sample UI and evidence complete**
Depends on: CIRCLE-004, approved D2 package

Implemented in D2:

- two-person selection and Free coarse compatibility result;
- precise locked/upgrade presentation, precise development sample result and cached/reopen state;
- loading, offline and failed states;
- score, relationship label, four metric bars and Our Take;
- explicit Free Sun-sign vs precise-development basis disclosure;
- real iPhone/iPad Light/Dark portrait evidence and passing adaptive landscape UI tests.

The unlock action is informational only. Rewarded/Premium, StoreKit, ads, provider synastry, production cache and backend behavior remain unimplemented.

Acceptance:
- Free coarse result is useful and basis-labeled;
- precise upgrade, Rewarded/Premium and cached-result states follow current access semantics;
- iPhone+iPad Light/Dark implementation reconciles with approved D2 references.

### CIRCLE-006 — Implement Today Together
Status: TODO  
Depends on: CIRCLE-002, relevant Today/catalog contracts

Acceptance:
- Free behavior, if offered, comes only from an approved finite-catalog path;
- individual timing/natal calculation follows Rewarded/Premium precision rules;
- it does not mutate either person's ordinary Today reading.

### CIRCLE-007 — Add methodology-gated Vedic/Chinese relationship paths
Status: TODO  
Depends on: CIRCLE-003, relevant METHOD tasks

Acceptance:
- coarse Free buckets are enabled only if methodologically valid;
- precise production support is enabled only for signed-off methodologies.

### CIRCLE-008 — Implement precise Western compatibility generation
Status: TODO  
Depends on: CIRCLE-003, required ASTRO facts, ARCH-005, ARCH-007

Acceptance:
- cache lookup precedes reward/provider generation;
- calculation provider supplies structured relationship facts; interpretation consumes them;
- one rewarded completion authorizes one needed result generation;
- successful result is cached/reopenable;
- Premium uses the same cache-first pipeline without per-generation ad.

## Exit criteria

- Free Western compatibility covers all 144 sign-pair keys with 0 paid provider calls;
- precise compatibility is clearly differentiated, cache-first and access-controlled;
- unsupported methodologies remain gated;
- shipping Circle/Compatibility surfaces reconcile with approved D2 iPhone+iPad Light/Dark references.

## D2 verification snapshot

On 2026-08-12, representative iPhone/iPad Debug builds, the Release simulator build, 69 Swift tests, 9/9 iPhone UI tests and 9/9 iPad UI tests passed. Compatibility model tests cover score validation, semantic Free/precise separation and all 144 Western pair keys. See [`../../design/implementation-evidence/d2-today-circle/`](../../design/implementation-evidence/d2-today-circle/README.md).

Phase 07 remains partial because Saved People persistence, the production Free catalog, entitlement runtime, backend/API and precise provider generation were not added.
