# Phase 05 — Today

Status: **TODO**
Depends on: Phase 02, Phase 04

Goal: deliver the primary personalized daily-reading experience with transparent basis and shared Normal/Roast facts.

## Tasks

### TODAY-001 — Define daily reading input contract
Status: TODO

Acceptance:
- Inputs are natal facts + current calculated timing facts + selected system + locale/tone/access context.
- No interpretation component invents current sky facts.

### TODAY-002 — Implement Today data pipeline and caching
Status: TODO
Depends on: TODAY-001

Acceptance:
- Daily result freshness/versioning is explicit.
- Offline/cached behavior is defined and tested.

### TODAY-003 — Implement primary Today UI
Status: TODO
Depends on: TODAY-002

Acceptance:
- Matches final design archive.
- Free baseline is useful without monetization.

### TODAY-004 — Implement Astrological basis disclosure
Status: TODO
Depends on: TODAY-003

Acceptance:
- Basis links reading statements to structured calculated factors.
- User-facing copy avoids presenting astrology as scientific evidence.

### TODAY-005 — Implement Normal/Roast expression pipeline
Status: TODO
Depends on: TODAY-002, ARCH-005

Acceptance:
- Both modes use identical calculated facts and underlying interpretive meaning.
- Roast follows safety rules and never reaches notifications.

### TODAY-006 — Add rewarded/Premium depth states via entitlement abstraction
Status: TODO
Depends on: TODAY-003

Acceptance:
- Persistent content unlock semantics are respected.
- No ad SDK dependency leaks into Today presentation/domain code.

## Exit criteria

- Today is useful on Free.
- Basis is inspectable.
- Normal/Roast fact parity is testable.
- Cached/offline/error behavior is deterministic.
