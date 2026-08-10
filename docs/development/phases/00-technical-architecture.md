# Phase 00 — Technical Architecture & Implementation Planning

Status: **IN PROGRESS**

Goal: make the minimum set of technical decisions required to start implementation without coupling product behavior to accidental infrastructure choices.

Design reference: [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md)

## Tasks

### ARCH-001 — Define system and deployment boundaries
Status: IN PROGRESS

Scope:
- Decide what runs on-device vs backend/Cloudflare vs third-party service.
- Define trust boundaries for deterministic calculations, interpretation, entitlements and reference/static data.
- Keep authentication out of v1 unless a concrete requirement emerges.

Acceptance:
- `docs/architecture/SYSTEM_ARCHITECTURE.md` exists with a clear component/data-flow diagram in Markdown.
- Each external dependency has an owner, purpose and failure behavior.

### ARCH-002 — Define iOS architecture and module boundaries
Status: TODO
Depends on: ARCH-001

Scope:
- App/domain/data/presentation boundaries.
- Dependency injection, navigation ownership and feature-module strategy.
- Concurrency/isolation conventions.

Acceptance:
- `IOS_ARCHITECTURE.md` defines module responsibilities and dependency direction.
- No feature layer owns deterministic astrology calculations directly.

### ARCH-003 — Decide deterministic astrology engine strategy
Status: TODO
Depends on: ARCH-001

Scope:
- Evaluate on-device engine vs API vs hybrid.
- Define Western/Vedic/BaZi engine interfaces without forcing one implementation across systems.
- Define versioning and provenance of calculated facts.

Acceptance:
- `ASTROLOGY_ENGINE.md` states the chosen strategy and fallback behavior.
- Engine output is a typed structured contract consumed by interpretation/presentation.
- Methodology-pending areas remain explicit gates.

### ARCH-004 — Define local persistence, cache and offline strategy
Status: TODO
Depends on: ARCH-001, ARCH-002

Scope:
- Local profile, saved people, cached calculations/readings, settings and rewarded unlocks.
- Migration/versioning policy.
- Decide whether v1 is local-only or uses any iCloud/backend sync; no auth assumption.

Acceptance:
- `DATA_MODEL.md` documents stores/entities, ownership, retention and migration policy.
- Offline behavior is defined for each major data category.

### ARCH-005 — Define interpretation/LLM boundary
Status: TODO
Depends on: ARCH-003

Scope:
- Structured input/output contracts.
- Prompt/version provenance, safety and retry/fallback behavior.
- Normal/Roast transformation over the same underlying facts/interpretation.

Acceptance:
- `INTERPRETATION_LAYER.md` explicitly forbids calculation invention.
- Deterministic facts, interpretation output and presentation copy are distinguishable in data contracts.

### ARCH-006 — Define backend and static/reference-data responsibilities
Status: TODO
Depends on: ARCH-001, ARCH-003

Scope:
- Cloudflare Worker/API responsibilities.
- Static JSON/reference datasets and versioning.
- Secrets, rate limiting and cache policy.

Acceptance:
- `BACKEND.md` defines routes/responsibilities conceptually without premature endpoint sprawl.

### ARCH-007 — Define Premium and rewarded-entitlement architecture
Status: TODO
Depends on: ARCH-001, ARCH-004

Scope:
- Premium entitlement source of truth.
- Persistent content unlock vs immediate Ask extension.
- Persistence/recovery behavior.
- No login required.

Acceptance:
- `ENTITLEMENTS.md` maps frozen design semantics to technical responsibilities.
- Store/ad SDK/provider choices remain replaceable behind interfaces.

### ARCH-008 — Define privacy/security and data-handling model
Status: TODO
Depends on: ARCH-001, ARCH-004, ARCH-005

Acceptance:
- `PRIVACY_SECURITY.md` identifies sensitive user/saved-person data, local/remote boundaries, logging/redaction rules and deletion/export expectations.

### ARCH-009 — Define testing and calculation-validation strategy
Status: TODO
Depends on: ARCH-003

Acceptance:
- `TESTING_STRATEGY.md` defines unit/integration/UI tests, deterministic fixtures, engine golden tests and methodology-sign-off fixtures.
- Design mockup values are explicitly excluded as test truth unless independently validated.

### ARCH-010 — Freeze initial implementation roadmap and repo structure
Status: TODO
Depends on: ARCH-002 through ARCH-009

Acceptance:
- Architecture README/index exists.
- Phase 01 tasks are adjusted if architecture decisions require it.
- `STATUS.md` moves to `IOS-001`.

## Exit criteria

- All architecture documents required above are committed.
- Major technical boundaries are decided enough to create the Xcode project and modules.
- Open choices are categorized as implementation choice, methodology blocker or later optimization.
- No production feature implementation has started prematurely.
