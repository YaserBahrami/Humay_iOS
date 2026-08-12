# Phase 00 — Technical Architecture & Implementation Planning

Status: **IN PROGRESS — provider/cache/backend track continues in parallel with Phase 01 foundation**

Goal: define Humay's two-path content architecture: **Free pre-generated catalog** vs **Rewarded/Premium provider-backed precision**, without blocking platform-foundation work that does not depend on unfinished provider contracts.

Product authority: [`../PRODUCT_ACCESS_MODEL.md`](../PRODUCT_ACCESS_MODEL.md)  
Apple-platform architecture: [`../../architecture/IOS_ARCHITECTURE.md`](../../architecture/IOS_ARCHITECTURE.md)  
Design authority: [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md)

## Foundation start gate

Phase 01 Apple Platform Foundation may proceed because these contracts are already current:

- clean production baseline/reset;
- SwiftUI + Swift 6 + Clean Architecture dependency direction;
- iPhone + iPad platform scope;
- Free vs precision product/access boundary;
- current Soulful Celestial design authority;
- no vendor/provider models in app Presentation/Domain.

Phase 01 must not invent provider/cache/entitlement details that belong to unfinished Phase 00 tasks.

## Architecture baseline

- Ordinary Free use makes no paid astrology/LLM request.
- Free content is pre-generated, versioned and served from Humay-owned backend/static/cache storage.
- Provider-backed personalization is server-side and cache-first.
- Structured astrology calculation and interpretation providers remain replaceable behind Humay contracts.
- Apple clients receive normalized Humay contracts, never provider secrets/vendor-native models.
- Rewarded Access grants one generation for a selected result key after cache checks; successful results are cached/reopenable.
- Premium uses the same cache-first precision path without per-generation rewarded ads while entitlement is valid.

## Tasks

### ARCH-001 — Define system and deployment boundaries
Status: IN PROGRESS

Acceptance:
- `docs/architecture/SYSTEM_ARCHITECTURE.md` defines Free and precision component/data flows.
- Every external dependency has purpose, trust boundary and failure behavior.
- Free cannot fall through to a paid provider.

### ARCH-002 — Define Apple app architecture and module boundaries
Status: COMPLETE

Evidence:
- [`../../architecture/IOS_ARCHITECTURE.md`](../../architecture/IOS_ARCHITECTURE.md)
- [`../../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](../../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md)

Acceptance satisfied:
- `App → Presentation → Domain ← Data` direction defined;
- iPhone + iPad scope defined;
- provider/persistence implementations are composition-boundary details;
- old mock/runtime architecture removed.

### ARCH-003 — Freeze astrology calculation-provider strategy
Status: TODO  
Depends on: ARCH-001

Acceptance:
- `ASTROLOGY_ENGINE.md` defines provider-independent Western/Vedic/Chinese contracts, provenance, methodology/version fields and replacement/fallback rules.
- Precision output is typed structured data.
- Ordinary Free does not require the calculation provider.

### ARCH-004 — Define persistence, result cache and offline strategy
Status: PARTIAL  
Depends on: ARCH-001, ARCH-002

Current baseline:
- local data ownership and no-silent-volatile-fallback rule are documented in [`../../architecture/DATA_MODEL.md`](../../architecture/DATA_MODEL.md) and `IOS_ARCHITECTURE.md`.

Remaining acceptance:
- production result-cache identity/version invalidation;
- offline/cached-result behavior;
- durable storage ownership for generated results.

### ARCH-005 — Define interpretation/LLM boundary
Status: TODO  
Depends on: ARCH-003

Acceptance:
- `INTERPRETATION_LAYER.md` defines structured input/output, prompt/model provenance, safety, retries and idempotency.
- It forbids invention of calculation facts.
- Calculation facts and interpretation/tone text can be cached separately.

### ARCH-006 — Define backend, Free catalog and reference-data responsibilities
Status: TODO  
Depends on: ARCH-001

Acceptance:
- `BACKEND.md` defines Free and precision runtime flows, catalog generation/review/version/publish behavior, static/reference data and observability.
- Free runtime serving remains functional without external paid providers.

### ARCH-007 — Define Premium and rewarded-generation entitlement architecture
Status: TODO  
Depends on: ARCH-001, ARCH-004

Acceptance:
- `ENTITLEMENTS.md` maps current access semantics to technical responsibilities.
- Cache hits occur before reward consumption/provider generation.
- Provider/store/ad SDKs remain replaceable.
- Recovery is fair/idempotent when an ad succeeds but generation fails.

### ARCH-008 — Define privacy/security and data handling
Status: TODO  
Depends on: ARCH-001, ARCH-004, ARCH-005

Acceptance:
- `PRIVACY_SECURITY.md` defines birth/saved-person data minimization, logging/redaction, retention, deletion/export and provider transmission.
- Full birth data is never sent to paid providers for a Free coarse catalog request.

### ARCH-009 — Define testing, validation and cost-invariant strategy
Status: PARTIAL  
Depends on: ARCH-003 through ARCH-007

Current baseline:
- cross-device/unit/UI/persistence test direction exists in [`../../architecture/TESTING_STRATEGY.md`](../../architecture/TESTING_STRATEGY.md).

Remaining acceptance:
- provider contract tests;
- cache/idempotency tests;
- explicit 0-paid-call assertions for Free and valid cache hits;
- methodology validation fixtures.

### ARCH-010 — Freeze implementation roadmap and repo structure
Status: PARTIAL

Current baseline:
- clean repo structure and current roadmap exist;
- Phase 01 foundation scope is current.

Remaining acceptance:
- provider/backend architecture documents reconcile with later feature-phase tasks before those features start.

## Exit criteria

Phase 00 is complete when Free/precision provider, cache, entitlement, privacy and backend contracts are documented and testable. Phase 01 platform foundation is allowed to proceed before full Phase 00 exit, but provider-backed feature implementation is not.
