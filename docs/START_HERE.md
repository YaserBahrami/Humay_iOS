# Humay — Start Here

**Status:** current production documentation index as of 2026-08-12.

`main` is the repository source of truth. Feature branches are temporary implementation workspaces and must not become separate product/design authorities.

## Read in this order

1. [`development/STATUS.md`](development/STATUS.md) — what is active now.
2. [`development/ROADMAP.md`](development/ROADMAP.md) — dependency-driven implementation sequence.
3. [`development/PRODUCT_ACCESS_MODEL.md`](development/PRODUCT_ACCESS_MODEL.md) — Free / Rewarded Access / Premium cost and entitlement rules.
4. [`architecture/SYSTEM_ARCHITECTURE.md`](architecture/SYSTEM_ARCHITECTURE.md) — Free vs precision system/deployment/trust boundaries.
5. [`architecture/ASTROLOGY_ENGINE.md`](architecture/ASTROLOGY_ENGINE.md) — provider-independent calculation, provenance and fallback contract.
6. [`architecture/IOS_ARCHITECTURE.md`](architecture/IOS_ARCHITECTURE.md) — SwiftUI + Clean Architecture boundaries for iPhone and iPad.
7. [`development/VERIFICATION.md`](development/VERIFICATION.md) — canonical repository, build and test verification commands.
8. [`design/DESIGN_AUTHORITY.md`](design/DESIGN_AUTHORITY.md) — exclusive visual/product-device authority.
9. [`design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — current visual system.
10. [`design/SCREEN_DESIGN_PLAN.md`](design/SCREEN_DESIGN_PLAN.md) — D0–D9 screen/design sequence.
11. The approved screen package under [`design/soulful-reference/`](design/soulful-reference/README.md) for the feature being implemented.
12. [`development/METHODOLOGY_TRACK.md`](development/METHODOLOGY_TRACK.md) when a feature depends on astrology conventions that are not yet signed off.

## Current implementation state

The old generated mock-first application was removed before production development. The Xcode project remains intentionally small, with the first production feature slice implemented and the first provider-independent astrology calculation contracts now staged.

Current UI engineering remains **Phase 03 — Onboarding & Local Profile**, covering PROFILE-001 through PROFILE-005. Phase 01 IOS-001 through IOS-006 are complete; IOS-007 implementation is present and awaits its post-change local verification before Phase 01 can close.

Phase 00 architecture continues in parallel. ARCH-001 system/deployment boundaries and ARCH-003 provider-independent astrology calculation strategy are frozen. No backend/provider runtime was added: hosting vendor, calculation provider, interpretation provider and concrete API endpoints remain intentionally unfrozen until their owning tasks.

Phase 02 ASTRO-001 and ASTRO-002 source contracts are implemented under `Humay/Domain/Astrology/`. `BirthCalculationInput` reuses `BirthDetails` and validates exact/approximate/unknown time plus known/not-provided place semantics. The calculation contract layer adds typed result/provenance/reliability/failure models and independent Western/Vedic/BaZi adapter protocols without choosing a provider or adding networking. These tasks are not marked DONE until the latest foundation/Xcode verification and complete Swift Testing pass after the source changes.

Foundation target:

- Swift 6 + strict concurrency;
- SwiftUI;
- Clean Architecture dependency direction: `App → Presentation → Domain ← Data`;
- explicit composition/dependency injection;
- iPhone + iPad from the start;
- intentional Light + Dark appearance;
- no vendor/provider models in Presentation or Domain;
- no speculative feature implementation ahead of approved design references;
- production onboarding Presentation for the approved D1 four-beat flow;
- profile completion in the app-owned version-1 local snapshot until future private sync work;
- build/deployment/version settings remain project metadata; no runtime backend/provider configuration exists yet;
- application diagnostics use finite privacy-safe OSLog events with no raw profile/birth/provider payload logging;
- `Scripts/verify-foundation.sh` plus [`development/VERIFICATION.md`](development/VERIFICATION.md) define the canonical local foundation verification contract;
- Free catalog and precision paths are system-level separate cost/trust paths;
- precision calculation inputs and outputs are normalized Humay Domain contracts before any interpretation layer.

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
- D1 Welcome iPhone Light/Dark;
- D1 Birth Date iPhone Light/Dark + repository package;
- D1 Welcome, Birth Date, Tradition and Profile Reveal cross-device package approved 2026-08-12.

The D1 onboarding UI is implemented under `Humay/Presentation/Onboarding/`. A fresh install restores no state and starts at Welcome. A completed profile/settings aggregate is restored from the version-1 local snapshot on relaunch.

Before production visual freeze, each shipping screen requires iPhone Light/Dark + iPad Light/Dark and adaptive/landscape notes where needed. User-facing UI must be designed and approved before implementation; non-visual architecture/domain/foundation work does not require an invented UI design gate.

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
