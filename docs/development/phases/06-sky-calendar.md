# Phase 06 — Sky & Calendar

Status: **TODO**
Depends on: Phase 02, Phase 05

Goal: implement current sky, event calendar and event detail over deterministically calculated astronomical/astrological timing facts.

## Tasks

### SKY-001 — Define sky/event fact contract
Status: TODO

Acceptance:
- Event type, time window, timezone/location relevance, system and provenance are explicit.
- Exact clock times appear only when deterministically calculated.

### SKY-002 — Implement current Sky data pipeline
Status: TODO
Depends on: SKY-001

Acceptance:
- Refresh/cache/offline behavior is defined.
- User location/timezone changes invalidate affected facts correctly.

### SKY-003 — Implement Sky current view
Status: TODO
Depends on: SKY-002

Acceptance:
- Matches final archive hierarchy and basis disclosure conventions.

### SKY-004 — Implement Calendar month/week views
Status: TODO
Depends on: SKY-002

Acceptance:
- Calendar is nested under Sky, never promoted to a sixth root tab.
- Month/week navigation and empty states are tested.

### SKY-005 — Implement event detail and interpretation
Status: TODO
Depends on: SKY-003, SKY-004, ARCH-005

Acceptance:
- Meaning and Astrological basis are separated.
- Deeper event interpretation can participate in persistent rewarded unlocks later.

### SKY-006 — Add methodology-aware system behavior
Status: TODO
Depends on: SKY-005

Acceptance:
- Cross-system event concepts are not flattened into a universal Western transit model.
- Features requiring METHOD-009 stay gated.

## Exit criteria

- Current Sky and Calendar work for supported Western production facts.
- Event timing is deterministic and timezone-safe.
- System-specific timing terminology remains honest and methodology-gated where needed.
