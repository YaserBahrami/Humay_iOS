# Phase 07 — Circle & Compatibility

Status: **TODO**
Depends on: Phase 02, Phase 06

Goal: implement Saved People plus two clearly different compatibility products: coarse Free catalog compatibility and precise provider-backed compatibility.

## Tasks

### CIRCLE-001 — Implement Saved People domain/persistence
Status: TODO

Acceptance:
- Saved people are local/profile data, not accounts.
- Capacity rules remain configurable; Rewarded Access is not a slot-expansion currency.

### CIRCLE-002 — Implement Circle people/person-detail UI
Status: TODO
Depends on: CIRCLE-001

Acceptance:
- Add/edit/remove flows follow the reconciled design.
- Birth-time/location uncertainty is retained for precision features.

### CIRCLE-003 — Define compatibility contracts by system and precision tier
Status: TODO
Depends on: ASTRO-007

Acceptance:
- Coarse Free catalog and precise natal compatibility are distinct domain result types.
- Western/Vedic/Chinese do not share a fake universal scoring formula.
- Unsupported methodologies return typed unavailable/pending states.

### CIRCLE-004 — Implement Free Western compatibility catalog
Status: TODO
Depends on: CIRCLE-003, ARCH-006

Acceptance:
- Supports **12 × 12 = 144** Western Sun-sign pairing keys.
- Uses Humay-owned pre-generated/versioned content only.
- Makes 0 paid provider calls.
- Does not claim synastry/natal precision.

### CIRCLE-005 — Implement compatibility report UI/access states
Status: TODO
Depends on: CIRCLE-004

Acceptance:
- Free coarse result is useful and basis-labeled.
- Precision upgrade, Rewarded/Premium and cached-result states are clear.

### CIRCLE-006 — Implement Today Together
Status: TODO
Depends on: CIRCLE-002, TODAY-002

Acceptance:
- Free behavior, if offered, must come from an approved finite catalog path.
- Any individual timing/natal calculation path follows Rewarded/Premium precision rules.
- Does not mutate either person's ordinary Today reading.

### CIRCLE-007 — Add methodology-gated Vedic/Chinese relationship paths
Status: TODO
Depends on: CIRCLE-003, relevant METHOD tasks

Acceptance:
- Coarse Free buckets are enabled only if methodologically valid.
- Precise production support is enabled only for signed-off methodologies.

### CIRCLE-008 — Implement precise Western compatibility generation
Status: TODO
Depends on: CIRCLE-003, ARCH-003, ARCH-005, ARCH-007

Acceptance:
- Cache lookup precedes reward/provider generation.
- Calculation provider supplies structured relationship facts; interpretation provider consumes them.
- One rewarded completion authorizes one needed result generation; successful result is cached/reopenable.
- Premium uses the same cache-first pipeline without per-generation ad.

## Exit criteria

- Free Western compatibility covers all 144 sign-pair keys with 0 paid provider calls.
- Precise compatibility is clearly differentiated, cache-first and access-controlled.
- Unsupported methodologies remain gated.
