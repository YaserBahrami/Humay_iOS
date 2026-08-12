# Phase 07 — Circle & Compatibility

Status: **TODO**

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

Acceptance:
- saved people are local/profile data, not accounts;
- birth date is preserved separately from optional time/place precision inputs;
- capacity rules remain configurable; Rewarded Access is not a slot-expansion currency;
- persistence models remain inside Data.

### CIRCLE-002 — Implement D2 Circle people/person-detail UI
Status: TODO  
Depends on: CIRCLE-001, approved D2 package

Acceptance:
- add/edit/remove flows use current Design Authority + approved D2 references;
- iPhone Light/Dark and iPad Light/Dark are intentional compositions;
- birth-time/location uncertainty is retained for precision features;
- no deleted/historical design artifact is used as authority.

### CIRCLE-003 — Define compatibility contracts by system and precision tier
Status: TODO  
Depends on: relevant ASTRO fact contracts

Acceptance:
- coarse Free catalog and precise natal compatibility are distinct domain result types;
- Western/Vedic/Chinese do not share a fake universal scoring formula;
- unsupported methodologies return typed unavailable/pending states;
- numeric presentation, where used, does not substitute for a defined methodology.

### CIRCLE-004 — Implement Free Western compatibility catalog
Status: TODO  
Depends on: CIRCLE-003, ARCH-006

Acceptance:
- supports **12 × 12 = 144** Western Sun-sign pairing keys;
- uses Humay-owned pre-generated/versioned content only;
- makes 0 paid provider calls;
- does not claim synastry/natal precision.

### CIRCLE-005 — Implement D2 compatibility report/access states
Status: TODO  
Depends on: CIRCLE-004, approved D2 package

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
