# Phase 00 — Technical Architecture & Implementation Planning

Status: **IN PROGRESS — ARCH-001 through ARCH-006 complete; entitlement/privacy/testing/roadmap closure remains**

Goal: define Humay's two-path content architecture: **Free pre-generated catalog** vs **Rewarded/Premium provider-backed precision**, without blocking platform/UI work that does not depend on unfinished provider runtime.

Product authority: [`../PRODUCT_ACCESS_MODEL.md`](../PRODUCT_ACCESS_MODEL.md)  
System architecture: [`../../architecture/SYSTEM_ARCHITECTURE.md`](../../architecture/SYSTEM_ARCHITECTURE.md)  
Calculation-provider strategy: [`../../architecture/ASTROLOGY_ENGINE.md`](../../architecture/ASTROLOGY_ENGINE.md)  
Cache/offline strategy: [`../../architecture/RESULT_CACHE_OFFLINE.md`](../../architecture/RESULT_CACHE_OFFLINE.md)  
Interpretation boundary: [`../../architecture/INTERPRETATION_LAYER.md`](../../architecture/INTERPRETATION_LAYER.md)  
Backend responsibilities: [`../../architecture/BACKEND.md`](../../architecture/BACKEND.md)  
Apple-platform architecture: [`../../architecture/IOS_ARCHITECTURE.md`](../../architecture/IOS_ARCHITECTURE.md)  
Design authority: [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md)

## Foundation start gate

Phase 01 Apple Platform Foundation may proceed because these contracts are current:

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
- A missing Free catalog/cache item never falls through to paid generation.
- Provider-backed personalization is server-side and cache-first.
- Structured astrology calculation and interpretation providers remain separate and replaceable behind Humay contracts.
- Apple clients receive normalized Humay contracts, never provider secrets/vendor-native models.
- Provider fallback is allowed only when methodology/contract equivalence is validated; it is not a silent generic retry.
- Calculation facts and interpretation text use separate semantic cache identities and can be invalidated independently.
- Server precision cache/idempotency is authoritative; Apple-local result copies are non-authoritative offline/performance mirrors.
- Rewarded Access grants one generation for a selected result key after cache checks; successful results are cached/reopenable.
- Premium uses the same cache-first precision path without per-generation rewarded ads while entitlement is valid.
- Approved UI may be built before the real backend using explicit development sample data that conforms to Humay-owned contracts; sample output never ships as production truth.

## Tasks

### ARCH-001 — Define system and deployment boundaries
Status: **COMPLETE — 2026-08-12**

Evidence:
- [`../../architecture/SYSTEM_ARCHITECTURE.md`](../../architecture/SYSTEM_ARCHITECTURE.md)

Acceptance satisfied:
- Free and precision component/data flows are defined separately;
- Apple, Humay backend/catalog/cache and external provider trust boundaries are explicit;
- failure behavior is defined, including the invariant that Free cannot fall through to a paid provider;
- infrastructure/provider vendors remain deliberately unfrozen until their owning tasks.

### ARCH-002 — Define Apple app architecture and module boundaries
Status: **COMPLETE — 2026-08-12**

Evidence:
- [`../../architecture/IOS_ARCHITECTURE.md`](../../architecture/IOS_ARCHITECTURE.md)
- [`../../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](../../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md)

Acceptance satisfied:
- `App → Presentation → Domain ← Data` direction defined;
- iPhone + iPad scope defined;
- provider/persistence implementations are composition-boundary details;
- old mock/runtime architecture removed.

### ARCH-003 — Freeze astrology calculation-provider strategy
Status: **COMPLETE — 2026-08-12**  
Depends on: ARCH-001

Evidence:
- [`../../architecture/ASTROLOGY_ENGINE.md`](../../architecture/ASTROLOGY_ENGINE.md)

Acceptance satisfied:
- Western, Vedic and BaZi calculation boundaries are provider-independent;
- shared birth date/time/place precision semantics are required without fake defaults;
- normalized facts retain reliability, methodology/calculation version and provenance;
- provider replacement/fallback requires validated methodology equivalence rather than silent vendor switching;
- calculation facts remain separate from interpretation text;
- ordinary Free serving does not invoke the calculation provider.

### ARCH-004 — Define persistence, result cache and offline strategy
Status: **COMPLETE — 2026-08-12**  
Depends on: ARCH-001, ARCH-002

Evidence:
- [`../../architecture/RESULT_CACHE_OFFLINE.md`](../../architecture/RESULT_CACHE_OFFLINE.md)
- [`../../architecture/DATA_MODEL.md`](../../architecture/DATA_MODEL.md)

Acceptance satisfied:
- Free catalog, deterministic calculation, interpretation and Apple-local mirror artifacts have separate ownership;
- calculation and interpretation cache identities include only result-changing dimensions and can invalidate independently;
- server precision cache/idempotency is authoritative while Apple-local copies are non-authoritative mirrors;
- semantic invalidation is separated from ordinary storage eviction;
- Free and precision offline behavior is explicit, including no paid fallback and no reward consumption while offline;
- no new local generated-result persistence schema is invented before an owning feature/runtime needs it.

### ARCH-005 — Define interpretation/LLM boundary
Status: **COMPLETE — 2026-08-12**  
Depends on: ARCH-003

Evidence:
- [`../../architecture/INTERPRETATION_LAYER.md`](../../architecture/INTERPRETATION_LAYER.md)

Acceptance satisfied:
- interpretation consumes validated structured facts plus minimized authorized context;
- structured output, prompt/model/safety provenance, validation, retries and idempotency are defined;
- interpretation may explain but never calculate, alter or invent deterministic astrology facts;
- Normal/Roast share the same calculation facts and are independently cacheable interpretation variants;
- provider errors/prompts/secrets stay server-side and privacy-sensitive payloads are not ordinary logs;
- development sample readings are allowed for approved UI work but cannot ship as real personalized output.

### ARCH-006 — Define backend, Free catalog and reference-data responsibilities
Status: **COMPLETE — 2026-08-12**  
Depends on: ARCH-001

Evidence:
- [`../../architecture/BACKEND.md`](../../architecture/BACKEND.md)

Acceptance satisfied:
- Free catalog production/review/version/publish and runtime serving are separate from precision generation;
- Free runtime remains functional when external paid providers are unavailable;
- precision runtime is normalized, cache-first, idempotent and server-orchestrated;
- calculation/interpretation adapters, secrets, observability and reference-data ownership are server responsibilities;
- API contract principles expose Humay-owned normalized schemas rather than vendor-native payloads;
- hosting/database/provider vendors remain deliberately open until backend implementation;
- implementation sequence explicitly supports approved UI with development sample data before backend/API integration.

### ARCH-007 — Define Premium and rewarded-generation entitlement architecture
Status: TODO  
Depends on: ARCH-001, ARCH-004

Acceptance:
- `ENTITLEMENTS.md` maps current access semantics to technical responsibilities;
- cache hits occur before reward consumption/provider generation;
- provider/store/ad SDKs remain replaceable;
- recovery is fair/idempotent when an ad succeeds but generation fails.

### ARCH-008 — Define privacy/security and data handling
Status: TODO  
Depends on: ARCH-001, ARCH-004, ARCH-005

Acceptance:
- `PRIVACY_SECURITY.md` defines birth/saved-person data minimization, logging/redaction, retention, deletion/export and provider transmission;
- full birth data is never sent to paid providers for a Free coarse catalog request.

### ARCH-009 — Define testing, validation and cost-invariant strategy
Status: PARTIAL  
Depends on: ARCH-003 through ARCH-007

Current baseline:
- cross-device/unit/UI/persistence test direction exists in [`../../architecture/TESTING_STRATEGY.md`](../../architecture/TESTING_STRATEGY.md);
- ARCH-001/004/006 define measurable 0-paid-call behavior for Free and valid precision cache hits;
- ARCH-003 defines independent calculation fixtures/provenance requirements;
- ARCH-005 defines interpretation validation/idempotency requirements.

Remaining acceptance:
- provider contract tests;
- cache/idempotency tests;
- explicit 0-paid-call assertions for Free and valid cache hits;
- methodology validation fixtures.

### ARCH-010 — Freeze implementation roadmap and repo structure
Status: PARTIAL

Current baseline:
- clean repo structure and current roadmap exist;
- Phase 01 foundation scope is current;
- ARCH-001 through ARCH-006 now define system/calculation/cache/interpretation/backend boundaries;
- roadmap records the UI-first-with-development-sample-data, backend/API-second implementation sequence.

Remaining acceptance:
- entitlement and privacy documents reconcile with later backend/monetization tasks before those runtime slices start.

## Current implementation gate

Architecture/documentation work may continue while IOS-007 awaits its post-change local Xcode verification.

Approved user-facing feature work may proceed **UI first** after its cross-device design package is approved. During that stage, Presentation may use explicit development sample data conforming to Humay-owned contracts so screens/states can be built and reconciled before the backend exists.

Development sample data must not restore the deleted mock-provider runtime, must not leak vendor-shaped models into Presentation/Domain, and must not ship in Release as real astrology output.

Backend/API/provider runtime is deliberately **second**. Before production paid-provider rollout it must satisfy the relevant ARCH-007 entitlement, ARCH-008 privacy and methodology/validation gates rather than inventing those rules inside endpoint code.

## Exit criteria

Phase 00 is complete when entitlement, privacy, testing/cost and final roadmap contracts are also documented/testable. Phase 01 and approved UI work may proceed before full Phase 00 exit, but production backend/provider rollout may not bypass the unfinished access/privacy gates.
