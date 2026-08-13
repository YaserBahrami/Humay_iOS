# Phase 06 — Sky & Calendar

Status: **IN PROGRESS — non-visual foundation only**

Depends on:
- Phase 01 platform/design-system foundation;
- relevant Phase 02 deterministic sky/timing facts;
- required Phase 00 cache/backend contracts;
- approved D3 cross-device design references before feature-specific UI implementation.

Goal: implement current Sky, event calendar and event detail over deterministic astronomical/astrological timing facts without coupling the UI to provider-native models.

## Tasks

### SKY-001 — Define sky/event fact contract
Status: PARTIAL

Implemented foundation:

- Humay-owned event identity, type, tradition/system ownership, timing, relevance and reliability;
- validated civil dates, event intervals, month selections and seven-day week structures;
- explicit unavailable timing rather than guessed clock values;
- separate compact event and event-detail meaning/astrological-basis contracts;
- typed Current Sky, month, week and detail availability/state inputs;
- Debug-only deterministic/unverified sample composition and Release-unavailable composition.

Still required before DONE:

- production calculation/catalog source and provenance wiring;
- methodology validation for supported event families;
- real timezone/location invalidation behavior through the owning data pipeline.

Acceptance:
- event type, time window, timezone/location relevance, system and provenance are explicit;
- exact clock times appear only when deterministically calculated;
- unsupported/methodology-gated events are typed rather than guessed.

### SKY-002 — Implement current Sky data pipeline
Status: TODO  
Depends on: SKY-001

This later production provider/cache integration is not a prerequisite for SKY-003 or SKY-004.

Acceptance:
- refresh/cache/offline behavior follows current architecture;
- user timezone/location changes invalidate affected facts correctly;
- Presentation receives Humay-owned models, not vendor responses.

### SKY-003 — Implement D3 Current Sky UI for iPhone + iPad
Status: TODO  
Depends on: sufficient SKY-001 feature/domain contracts, approved D3 package

Acceptance:
- uses current Design Authority and approved D3 reference package;
- can use explicit Debug-only development sample data before SKY-002 is complete;
- iPhone Light/Dark and iPad Light/Dark are intentional compositions;
- basis/availability disclosure matches the facts actually supplied;
- no deleted final-archive/old design artifact is used as authority.

### SKY-004 — Implement D3 Calendar month/week views
Status: TODO  
Depends on: sufficient SKY-001 feature/domain contracts, approved D3 package

Acceptance:
- Calendar remains nested under Sky, never a sixth root tab;
- can use explicit Debug-only development sample data before SKY-002 is complete;
- month/week navigation and empty/unavailable states are tested;
- iPad uses available width according to the approved adaptive composition.

### SKY-005 — Implement event detail and interpretation
Status: TODO  
Depends on: SKY-003, SKY-004, ARCH-005

Acceptance:
- Meaning and Astrological basis remain distinct;
- interpretation consumes only structured facts;
- access/caching follows product contracts when a deeper provider-backed result is offered.

### SKY-006 — Add methodology-aware system behavior
Status: TODO  
Depends on: SKY-005

Acceptance:
- cross-system event concepts are not flattened into a universal Western transit model;
- features requiring unresolved methodology remain gated.

## Exit criteria

- Current Sky and Calendar work for supported deterministic facts;
- event timing is timezone-safe and sourceable;
- system-specific terminology remains methodology-aware;
- shipping Sky/Calendar surfaces reconcile with approved D3 iPhone+iPad Light/Dark references.

The current partial foundation does not satisfy the phase exit criteria. D3.1 Current Sky and D3.2 Calendar have approved visual references, but `SKY-003` and `SKY-004` remain TODO because visual approval is not implementation completion. D3.3 Event Detail remains a review candidate, so `SKY-005` also remains TODO.
