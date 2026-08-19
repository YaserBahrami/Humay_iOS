# Humay — Start Here

**Status:** current production documentation index as of 2026-08-19.

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
12. [`design/PREMIUM_CELESTIAL_REDESIGN.md`](design/PREMIUM_CELESTIAL_REDESIGN.md) — current post-onboarding visual system, IA, and implementation record.
13. [`design/SCREEN_DESIGN_PLAN.md`](design/SCREEN_DESIGN_PLAN.md) — D0–D9 screen inventory and propagation sequence.
14. [`design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — retained onboarding authority and legacy context.
15. The approved screen package under [`design/soulful-reference/`](design/soulful-reference/README.md) when it has not been visually superseded.
16. [`development/METHODOLOGY_TRACK.md`](development/METHODOLOGY_TRACK.md) when a feature depends on astrology conventions that are not yet signed off.

## Current implementation state

The old generated mock-first application was removed before production development. The clean app foundation, approved D1 onboarding, local profile persistence, provider-independent astrology Domain contracts, D2–D4 presentation contracts, and Premium Celestial representative redesign are now in place.

Phase 01 IOS-001 through IOS-007 are complete. Post-D2 foundation verification, iPhone/iPad builds, Swift Testing and complete iPhone/iPad UI suites passed on 2026-08-12.

Phase 00 ARCH-001 through ARCH-006 are complete. Humay now has frozen contracts for:

- system/trust boundaries;
- Apple Clean Architecture;
- astrology calculation adapters;
- result cache/offline behavior;
- interpretation/LLM behavior;
- backend/Free catalog/API responsibilities.

ARCH-007 entitlement and ARCH-008 privacy/security remain open before production rewarded/Premium provider rollout.

Phase 02 ASTRO-001 and ASTRO-002 are implemented. ASTRO-003 has the provider-independent Western fact/structural-validation foundation, but real engine/provider integration and golden validation are deliberately deferred.

**D4.1 Chart UI foundation** is approved and implemented over an explicit Debug-only sample. Premium Celestial now supplies its chart-first hero, interactive wheel/focus treatment, ordered accessibility alternative, Placement Detail disclosure hierarchy, and adaptive iPad composition. Typed access/cache/offline/error and unknown-time behavior remain intact. Production calculation, provider, access, cache, entitlement, and methodology gates remain open.

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

**D2 — Today + Circle** is implemented with Debug-only development sample data. Premium Celestial now supersedes Today and Compatibility styling; Daily Horoscope and remaining people flows await propagation. Release uses production-unavailable/empty composition and contains no development sample astrology payload.

**D3 — Sky + Calendar** has implemented Current Sky, Calendar month/week, and Event Detail presentation over Debug-only deterministic samples. Their contracts and Release-safe unavailable composition remain in force; their visual migration under Explore is a later Premium Celestial phase.

Backend/API/provider, entitlement/monetization, and Saved People persistence remain deferred. The Premium Celestial representative phase redesigned Today, Chart, Placement Detail, Compatibility, and the new Explore hub without changing those boundaries. Ask remains an existing experience reached through Explore; no provider work was added.

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

The active post-onboarding direction is **Premium Celestial**: contemporary premium iOS, restrained Persian celestial heritage, and subtle Huma-derived geometry. [`design/PREMIUM_CELESTIAL_REDESIGN.md`](design/PREMIUM_CELESTIAL_REDESIGN.md) is authoritative. Soulful Celestial remains authority only for the existing D1 onboarding implementation until its own migration phase.

Canonical onboarding is exactly four beats:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are not onboarding steps. They can be added later from Profile for precision-dependent features.

Current reference status:

- D0 iPhone Light/Dark anchors: historical behavior/state reference for Today and Compatibility; Daily Horoscope still awaits propagation;
- D1 Welcome, Birth Date, Tradition and Profile Reveal cross-device package approved 2026-08-12;
- D2 Today, Daily Horoscope and Compatibility iPhone Light/Dark composites approved 2026-08-12;
- D4.1 Chart foundation cross-device package approved 2026-08-14 and visually superseded by Premium Celestial on 2026-08-19.

The D1 onboarding UI is implemented under `Humay/Presentation/Onboarding/`.
The D2 UI is implemented under `Humay/Presentation/Today/`, `Humay/Presentation/Circle/` and `Humay/Presentation/Main/`; evidence is under [`design/implementation-evidence/d2-today-circle/`](design/implementation-evidence/d2-today-circle/README.md).
The D4 UI-first slice is implemented under `Humay/Presentation/Chart/` and `Humay/Presentation/D4/`; evidence is under [`design/implementation-evidence/d4-chart/`](design/implementation-evidence/d4-chart/README.md).

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
