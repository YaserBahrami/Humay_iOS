# Phase 00 — Technical Architecture & Implementation Planning

Status: **IN PROGRESS — ARCH-001 through ARCH-003 complete; cache/interpretation/backend/access/privacy contracts remain**

Goal: define Humay's two-path content architecture: **Free pre-generated catalog** vs **Rewarded/Premium provider-backed precision**, without blocking platform-foundation work that does not depend on unfinished provider contracts.

Product authority: [`../PRODUCT_ACCESS_MODEL.md`](../PRODUCT_ACCESS_MODEL.md)  
System architecture: [`../../architecture/SYSTEM_ARCHITECTURE.md`](../../architecture/SYSTEM_ARCHITECTURE.md)  
Calculation-provider strategy: [`../../architecture/ASTROLOGY_ENGINE.md`](../../architecture/ASTROLOGY_ENGINE.md)  
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
- A missing Free catalog/cache item never falls through to paid generation.
- Provider-backed personalization is server-side and cache-first.
- Structured astrology calculation and interpretation providers remain separate and replaceable behind Humay contracts.
- Apple clients receive normalized Humay contracts, never provider secrets/vendor-native models.
- Provider fallback is allowed only when methodology/contract equivalence is validated; it is not a silent generic retry.
- Rewarded Access grants one generation for a selected result key after cache checks; successful results are cached/reopenable.
- Premium uses the same cache-first precision path without per-generation rewarded ads while entitlement is valid.

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
Status: PARTIAL  
Depends on: ARCH-001, ARCH-002

Current baseline:
- local data ownership and no-silent-volatile-fallback rule are documented in [`../../architecture/DATA_MODEL.md`](../../architecture/DATA_MODEL.md) and `IOS_ARCHITECTURE.md`;
- ARCH-001/003 require calculation facts and interpretation text to remain independently versionable/cacheable.

Remaining acceptance:
- production result-cache identity/version invalidation;
- offline/cached-result behavior;
- durable storage ownership for generated results.

### ARCH-005 — Define interpretation/LLM boundary
Status: TODO  
Depends on: ARCH-003

Current baseline:
- `ASTROLOGY_ENGINE.md` already forbids interpretation from calculating, altering or inventing deterministic facts.

Acceptance:
- `INTERPRETATION_LAYER.md` defines structured input/output, prompt/model provenance, safety, retries and idempotency;
- it forbids invention of calculation facts;
- calculation facts and interpretation/tone text can be cached separately.

### ARCH-006 — Define backend, Free catalog and reference-data responsibilities
Status: TODO  
Depends on: ARCH-001

Current baseline:
- `SYSTEM_ARCHITECTURE.md` freezes the logical Free/precision separation and trust boundaries without selecting a hosting vendor.

Acceptance:
- `BACKEND.md` defines Free and precision runtime flows, catalog generation/review/version/publish behavior, static/reference data and observability;
- Free runtime serving remains functional without external paid providers.

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
- ARCH-001 defines measurable 0-paid-call behavior for Free and valid precision cache hits;
- ARCH-003 defines independent calculation fixtures/provenance requirements.

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
- ARCH-001/003 now provide the system/calculation boundary needed by the early Phase 02 contract work.

Remaining acceptance:
- cache, interpretation, backend, entitlement and privacy documents reconcile with later feature-phase tasks before their implementations start.

## Current implementation gate

Architecture/documentation work may continue while IOS-007 awaits its post-change local Xcode verification.

Phase 02 runtime/source implementation still depends on Phase 01 completion. Once Phase 01 is verified, ASTRO-001 can reconcile concrete calculation inputs with the existing `BirthDetails` model using the now-frozen ARCH-003 semantics.

Provider-backed feature implementation must still wait for every relevant unfinished Phase 00 contract rather than inventing cache/access/privacy/backend behavior inside a feature.

## Exit criteria

Phase 00 is complete when Free/precision provider, cache, entitlement, privacy and backend contracts are documented and testable. Phase 01 platform foundation is allowed to proceed before full Phase 00 exit, but provider-backed feature implementation is not.
