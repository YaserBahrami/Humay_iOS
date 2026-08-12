# Humay — Start Here

**Status:** current production documentation index as of 2026-08-12.

`main` is the repository source of truth. Feature branches are temporary implementation workspaces and must not become separate product/design authorities.

## Read in this order

1. [`development/STATUS.md`](development/STATUS.md) — what is active now.
2. [`development/ROADMAP.md`](development/ROADMAP.md) — dependency-driven implementation sequence.
3. [`development/PRODUCT_ACCESS_MODEL.md`](development/PRODUCT_ACCESS_MODEL.md) — Free / Rewarded Access / Premium cost and entitlement rules.
4. [`architecture/IOS_ARCHITECTURE.md`](architecture/IOS_ARCHITECTURE.md) — SwiftUI + Clean Architecture boundaries for iPhone and iPad.
5. [`development/VERIFICATION.md`](development/VERIFICATION.md) — canonical repository, build and test verification commands.
6. [`design/DESIGN_AUTHORITY.md`](design/DESIGN_AUTHORITY.md) — exclusive visual/product-device authority.
7. [`design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — current visual system.
8. [`design/SCREEN_DESIGN_PLAN.md`](design/SCREEN_DESIGN_PLAN.md) — D0–D9 screen/design sequence.
9. The approved screen package under [`design/soulful-reference/`](design/soulful-reference/README.md) for the feature being implemented.
10. [`development/METHODOLOGY_TRACK.md`](development/METHODOLOGY_TRACK.md) when a feature depends on astrology conventions that are not yet signed off.

## Current implementation state

The old generated mock-first application was removed before production development. The Xcode project remains intentionally small, with the first production feature slice now implemented.

Current engineering work is **Phase 03 — Onboarding & Local Profile**, covering the approved onboarding slice PROFILE-001 through PROFILE-005. Phase 01 IOS-001 through IOS-006 are complete; IOS-007 implementation is present and awaits its post-change local verification before Phase 01 can close. Provider/cache/backend details from Phase 00 may continue in parallel where they do not block the app foundation.

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
- `Scripts/verify-foundation.sh` plus [`development/VERIFICATION.md`](development/VERIFICATION.md) define the canonical local foundation verification contract.

See [`development/phases/01-ios-foundation.md`](development/phases/01-ios-foundation.md).

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

Before production visual freeze, each shipping screen requires iPhone Light/Dark + iPad Light/Dark and adaptive/landscape notes where needed.

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
