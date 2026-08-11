# Phase 00 — Technical Architecture & Implementation Planning

Status: **IN PROGRESS**

Goal: freeze the minimum architecture needed to implement Humay's two-path content model safely and cheaply: **Free pre-generated catalog** vs **Rewarded/Premium provider-backed precision**.

Product authority: [`../PRODUCT_ACCESS_MODEL.md`](../PRODUCT_ACCESS_MODEL.md)
Design reference: [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md)

## Architecture baseline already decided

- Ordinary Free use makes no paid astrology/LLM request.
- Free content is pre-generated, versioned and served from Humay-owned backend/static/cache storage.
- Provider-backed personalization is server-side only and cache-first.
- Initial provider direction: Astrologer API for structured calculation facts + DeepSeek V4 Flash for interpretation.
- iOS receives normalized Humay contracts, never provider secrets/vendor-native models.
- Rewarded Access grants one generation for a selected result key; successful results are cached and reopenable.
- Premium uses the same cache-first path without per-generation rewarded ads while entitlement is valid.

## Tasks

### ARCH-001 — Define system and deployment boundaries
Status: IN PROGRESS

Scope:
- Document iOS vs Humay backend/Cloudflare vs static catalog storage vs external providers.
- Define cache-before-entitlement/provider flow.
- Define failure behavior when catalog, ad, calculation provider or interpretation provider is unavailable.
- Keep provider secrets and paid-provider calls off-device.

Acceptance:
- `docs/architecture/SYSTEM_ARCHITECTURE.md` contains component/data-flow diagrams for Free and precision paths.
- Every external dependency has purpose, trust boundary and failure behavior.
- The Free flow demonstrably cannot fall through to a paid provider.

### ARCH-002 — Define iOS architecture and module boundaries
Status: TODO
Depends on: ARCH-001

Acceptance:
- `IOS_ARCHITECTURE.md` defines app/domain/data/presentation and dependency direction.
- Feature layers consume Humay repositories/use cases, not vendor SDK/API models.

### ARCH-003 — Freeze astrology calculation-provider strategy
Status: TODO
Depends on: ARCH-001

Scope:
- Define provider-independent Western/Vedic/Chinese calculation contracts.
- Use Astrologer/RapidAPI as the initial precision-provider direction without coupling domain code to it.
- Define provenance, methodology/version fields, validation fixtures and replacement/fallback rules.

Acceptance:
- `ASTROLOGY_ENGINE.md` states the selected initial provider path and replaceable adapter boundary.
- Precision output is typed structured data consumed by interpretation/presentation.
- No calculation provider is required for ordinary Free catalog requests.

### ARCH-004 — Define persistence, result cache and offline strategy
Status: TODO
Depends on: ARCH-001, ARCH-002

Scope:
- Local profile/saved people/settings.
- Free catalog cache/version behavior.
- Personalized calculation and interpretation cache identity.
- Migration/retention/invalidation policy.

Acceptance:
- `DATA_MODEL.md` documents ownership, cache keys, version invalidation and offline behavior.
- Reopening a valid cached personalized result does not trigger another provider call/reward gate.

### ARCH-005 — Define interpretation/LLM boundary
Status: TODO
Depends on: ARCH-003

Scope:
- DeepSeek V4 Flash as initial interpretation provider behind an interface.
- Structured input/output, prompt/model provenance, safety, retries and idempotency.
- Normal/Roast expression from the same facts.

Acceptance:
- `INTERPRETATION_LAYER.md` forbids calculation invention.
- Calculation facts can be cached separately from interpretation/tone text.

### ARCH-006 — Define backend, Free catalog and static/reference-data responsibilities
Status: TODO
Depends on: ARCH-001

Scope:
- Cloudflare/backend responsibilities.
- ChatGPT-assisted offline/batch Free catalog generation workflow.
- Editorial/review/version/publish process.
- Static JSON/edge-cache/reference datasets and invalidation.
- Secrets/rate limiting/idempotency/cost observability.

Acceptance:
- `BACKEND.md` defines Free and precision request flows conceptually.
- Free runtime serving remains functional without external paid providers.
- Catalog versions can be rolled forward/back without app release.

### ARCH-007 — Define Premium and rewarded-generation entitlement architecture
Status: TODO
Depends on: ARCH-001, ARCH-004

Scope:
- Premium entitlement source of truth.
- Rewarded one-generation authorization for selected result key.
- Cache hit behavior before reward consumption.
- Recovery when ad succeeds but provider generation fails.
- No token/coin wallet and no login requirement by default.

Acceptance:
- `ENTITLEMENTS.md` maps current product semantics to technical responsibilities.
- Provider/store/ad SDKs remain replaceable.

### ARCH-008 — Define privacy/security and data handling
Status: TODO
Depends on: ARCH-001, ARCH-004, ARCH-005

Acceptance:
- `PRIVACY_SECURITY.md` defines sensitive birth/saved-person data boundaries, minimization, logging/redaction, retention, deletion/export and provider transmission rules.
- Full birth data is never sent to paid providers for a Free coarse catalog request.

### ARCH-009 — Define testing, validation and cost-invariant strategy
Status: TODO
Depends on: ARCH-003 through ARCH-007

Acceptance:
- `TESTING_STRATEGY.md` covers calculation fixtures, provider contract tests, cache/idempotency tests and methodology fixtures.
- Tests assert that ordinary Free requests cause 0 paid provider calls.
- Tests assert cached personalized results cause 0 new calculation/LLM calls.

### ARCH-010 — Freeze initial implementation roadmap and repo structure
Status: TODO
Depends on: ARCH-002 through ARCH-009

Acceptance:
- Architecture README/index exists.
- Phase tasks match the final architecture.
- `STATUS.md` can advance to `IOS-001` after the affected Claude Design revision is reconciled.

## Exit criteria

- Free and precision architecture contracts are documented.
- Provider/cache/entitlement/privacy boundaries are explicit.
- Cost invariants are testable.
- The next Claude Design pass reflects the revised access states.
- No production feature implementation starts against stale monetization/access design.
