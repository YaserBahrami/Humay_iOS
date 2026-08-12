# Humay — Start Here

**Status:** current production documentation index as of 2026-08-12.

`main` is the repository source of truth. Feature branches are temporary implementation workspaces and must not become separate product/design authorities.

## Read in this order

1. [`development/STATUS.md`](development/STATUS.md) — what is active now.
2. [`development/ROADMAP.md`](development/ROADMAP.md) — dependency-driven implementation sequence and the current UI-first/backend-second workflow.
3. [`development/PRODUCT_ACCESS_MODEL.md`](development/PRODUCT_ACCESS_MODEL.md) — Free / Rewarded Access / Premium cost and entitlement rules.
4. [`architecture/SYSTEM_ARCHITECTURE.md`](architecture/SYSTEM_ARCHITECTURE.md) — Free vs precision system/deployment/trust boundaries.
5. [`architecture/ASTROLOGY_ENGINE.md`](architecture/ASTROLOGY_ENGINE.md) — provider-independent calculation, provenance and fallback contract.
6. [`architecture/RESULT_CACHE_OFFLINE.md`](architecture/RESULT_CACHE_OFFLINE.md) — result identity, invalidation, authoritative server cache and offline behavior.
7. [`architecture/INTERPRETATION_LAYER.md`](architecture/INTERPRETATION_LAYER.md) — interpretation/LLM boundary, provenance, safety, retries and idempotency.
8. [`architecture/BACKEND.md`](architecture/BACKEND.md) — Free catalog, precision API, provider adapter and observability responsibilities.
9. [`architecture/IOS_ARCHITECTURE.md`](architecture/IOS_ARCHITECTURE.md) — SwiftUI + Clean Architecture boundaries for iPhone and iPad.
10. [`development/VERIFICATION.md`](development/VERIFICATION.md) — canonical repository, build and test verification commands.
11. [`design/DESIGN_AUTHORITY.md`](design/DESIGN_AUTHORITY.md) — exclusive visual/product-device authority.
12. [`design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — current visual system.
13. [`design/SCREEN_DESIGN_PLAN.md`](design/SCREEN_DESIGN_PLAN.md) — D0–D9 screen/design sequence.
14. The approved screen package under [`design/soulful-reference/`](design/soulful-reference/README.md) for the feature being implemented.
15. [`development/METHODOLOGY_TRACK.md`](development/METHODOLOGY_TRACK.md) when a feature depends on astrology conventions that are not yet signed off.

## Current implementation state

The old generated mock-first application was removed before production development. The clean app foundation, approved D1 onboarding, local profile persistence and provider-independent astrology Domain contracts are now in place.

Phase 01 IOS-001 through IOS-006 are complete; IOS-007 implementation is present and still needs the documented post-change local verification before Phase 01 can close.

Phase 00 ARCH-001 through ARCH-006 are complete. Humay now has frozen contracts for:

- system/trust boundaries;
- Apple Clean Architecture;
- astrology calculation adapters;
- result cache/offline behavior;
- interpretation/LLM behavior;
- backend/Free catalog/API responsibilities.

ARCH-007 entitlement and ARCH-008 privacy/security remain open before production rewarded/Premium provider rollout.

Phase 02 ASTRO-001 and ASTRO-002 are implemented. ASTRO-003 has the provider-independent Western fact/structural-validation foundation, but real engine/provider integration and golden validation are deliberately deferred.

## Current implementation order

The preferred next sequence is **UI first, backend/API second**.

For each core feature family:

```text
UI design + approval
        ↓
SwiftUI implementation with development sample data
        ↓
real simulator screenshot reconciliation
        ↓
stabilize feature-facing contracts
        ↓
backend/API implementation
        ↓
real Data/API integration
```

Development sample data is allowed only as explicit development/preview/test content conforming to Humay-owned contracts. It must not restore the deleted mock-provider architecture and must not ship in Release as real personalized astrology.

The next visual family is **D2 — Today + Circle**, followed by implementation with development sample data after approval.

## Foundation target

- Swift 6 + strict concurrency;
- SwiftUI;
- Clean Architecture dependency direction: `App → Presentation → Domain ← Data`;
- explicit composition/dependency injection;
- iPhone + iPad from the start;
- intentional Light + Dark appearance;
- no vendor/provider models in Presentation or Domain;
- production onboarding for the approved D1 four-beat flow;
- local versioned profile/settings persistence;
- privacy-safe typed diagnostics;
- Free and precision paths remain separate cost/trust paths;
- precision calculation facts are normalized before interpretation;
- calculation and interpretation results are independently versioned/cacheable;
- provider secrets and paid calls remain server-side.

See:

- [`development/phases/00-technical-architecture.md`](development/phases/00-technical-architecture.md)
- [`development/phases/01-ios-foundation.md`](development/phases/01-ios-foundation.md)
- [`development/phases/02-astrology-engine-foundation.md`](development/phases/02-astrology-engine-foundation.md)

## Current design state

The only active direction is **Soulful Celestial — cosmic editorial with selective cute line/flat celestial illustration**.

Canonical onboarding is exactly four beats:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are not onboarding steps. They can be added later from Profile for precision-dependent features.

Current approved references:

- D0 iPhone Light/Dark anchors: Today, Daily Horoscope, Compatibility;
- D1 Welcome, Birth Date, Tradition and Profile Reveal cross-device package approved 2026-08-12.

The D1 onboarding UI is implemented under `Humay/Presentation/Onboarding/`.

Every user-facing shipping screen requires iPhone Light/Dark + iPad Light/Dark and adaptive/landscape notes where needed. User-facing UI must be designed and approved before implementation; non-visual architecture/domain/foundation work does not require an invented UI design gate.

## Do not use as authority

Do not restore or follow:

- deleted mock-first Presentation/DesignSystem/provider code;
- deleted nine-screen onboarding drafts;
- old Paper/minimal UI assumptions;
- old painterly/watercolor design explorations;
- historical branch names;
- historical Claude/design-pass references;
- sample astrology values shown only for layout.

Git history exists for archaeology only. If history conflicts with the current documents above, the current documents win.

## Documentation rule

When a product, architecture, access or design decision changes, update the authoritative document and `development/STATUS.md` in the same change. Do not create a parallel plan to preserve an obsolete decision.
