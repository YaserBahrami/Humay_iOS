# Phase 00 — Technical Architecture & Implementation Planning

Status: **IN PROGRESS**

Goal: freeze the minimum architecture needed for Humay's two-path content model: **Free pre-generated catalog** vs **Rewarded/Premium provider-backed precision**.

Product authority: [`../PRODUCT_ACCESS_MODEL.md`](../PRODUCT_ACCESS_MODEL.md)  
Design authority: [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md)

## Architecture baseline

- Ordinary Free use makes no paid astrology/LLM request.
- Free content is pre-generated, versioned and served from Humay-owned backend/static/cache storage.
- Provider-backed personalization is server-side only and cache-first.
- Initial provider direction: structured astrology calculation provider + DeepSeek V4 Flash interpretation behind replaceable adapters.
- iOS receives normalized Humay contracts, never provider secrets/vendor-native models.
- Rewarded Access grants one generation for a selected result key after cache checks; successful results are cached/reopenable.
- Premium uses the same cache-first precision path without per-generation rewarded ads while entitlement is valid.

## Tasks

### ARCH-001 — Define system and deployment boundaries
Status: IN PROGRESS

Acceptance:
- `docs/architecture/SYSTEM_ARCHITECTURE.md` defines Free and precision component/data flows.
- Every external dependency has purpose, trust boundary and failure behavior.
- Free cannot fall through to a paid provider.

### ARCH-002 — Define iOS architecture and module boundaries
Status: TODO  
Depends on: ARCH-001

Acceptance:
- `IOS_ARCHITECTURE.md` defines app/domain/data/presentation dependency direction.
- Features consume Humay repositories/use cases, not vendor SDK/API models.

### ARCH-003 — Freeze astrology calculation-provider strategy
Status: TODO  
Depends on: ARCH-001

Acceptance:
- `ASTROLOGY_ENGINE.md` defines provider-independent Western/Vedic/Chinese contracts, provenance, methodology/version fields and replacement/fallback rules.
- Precision output is typed structured data.
- Ordinary Free does not require the calculation provider.

### ARCH-004 — Define persistence, result cache and offline strategy
Status: TODO  
Depends on: ARCH-001, ARCH-002

Acceptance:
- `DATA_MODEL.md` documents ownership, cache identity, version invalidation and offline behavior.
- Reopening a valid cached personalized result does not trigger another provider call/reward gate.

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
Status: TODO  
Depends on: ARCH-003 through ARCH-007

Acceptance:
- `TESTING_STRATEGY.md` covers provider contracts, cache/idempotency and methodology fixtures.
- Ordinary Free requests assert 0 paid provider calls.
- Valid cached personalized results assert 0 new calculation/LLM calls.

### ARCH-010 — Freeze implementation roadmap and repo structure
Status: TODO  
Depends on: ARCH-002 through ARCH-009

Acceptance:
- Architecture README/index exists.
- Phase tasks match final architecture.
- `STATUS.md` may advance to production foundation work only when the relevant current access/design contracts are ready.

## Exit criteria

- Free and precision architecture contracts are documented.
- Provider/cache/entitlement/privacy boundaries are explicit.
- Cost invariants are testable.
- Current D0–D9 design program reflects the shipping access states required by each feature family.
- Production feature implementation does not proceed against stale access or visual contracts.
