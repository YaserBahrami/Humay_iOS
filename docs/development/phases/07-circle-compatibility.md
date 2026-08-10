# Phase 07 — Circle & Compatibility

Status: **TODO**
Depends on: Phase 02, Phase 06

Goal: implement saved people, relationship context, Today Together and supported compatibility without inventing unresolved methodologies.

## Tasks

### CIRCLE-001 — Implement Saved People domain/persistence
Status: TODO

Acceptance:
- Saved people are local-profile data, not accounts.
- Free/Premium capacity is abstract configuration; Rewarded Access does not expand capacity.

### CIRCLE-002 — Implement Circle people and person-detail UI
Status: TODO
Depends on: CIRCLE-001

Acceptance:
- Add/edit/remove flows follow final design reference.
- Birth-data uncertainty is retained per person.

### CIRCLE-003 — Define compatibility engine contracts by system
Status: TODO
Depends on: ASTRO-007

Acceptance:
- Western/Vedic/Chinese compatibility do not share a fake universal scoring formula.
- Unsupported methodologies return typed unavailable/pending states.

### CIRCLE-004 — Implement supported Western compatibility baseline
Status: TODO
Depends on: CIRCLE-003

Acceptance:
- Approximately 5–8 meaningful primary dimensions where appropriate.
- No arbitrary percentage score.
- Deeper basis is linked to deterministic relationship facts.

### CIRCLE-005 — Implement compatibility report UI/access states
Status: TODO
Depends on: CIRCLE-004

Acceptance:
- Free overview remains useful.
- Deeper bounded sections can use persistent rewarded unlocks or Premium.

### CIRCLE-006 — Implement Today Together
Status: TODO
Depends on: CIRCLE-002, TODAY-002

Acceptance:
- Uses both people's validated facts and current timing context.
- Does not replace or mutate the user's normal Today reading.

### CIRCLE-007 — Add methodology-gated Vedic/Chinese relationship paths
Status: TODO
Depends on: CIRCLE-003, relevant METHOD tasks

Acceptance:
- Romantic/non-romantic support is enabled only for signed-off methodologies.
- No placeholder method ships as production truth.

## Exit criteria

- Saved People and Circle are stable locally.
- Supported compatibility is deterministic and sourceable.
- Vedic/Chinese relationship features remain gated where methodology is unresolved.
