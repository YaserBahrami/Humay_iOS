# Humay iOS + iPadOS

**Humay** is the product, repository and internal project name.

> **Start every implementation session with [`docs/START_HERE.md`](docs/START_HERE.md).** `main` is the current product/architecture/design authority.

## Current state

The repository was reset to a **clean production baseline on 2026-08-12**. On 2026-08-19, the Premium Celestial representative redesign established the current post-onboarding system across Today, Chart, Placement Detail, Compatibility, and Explore.

The old mock-first Presentation, DesignSystem, fixture runtime and premature persistence/provider layers were removed. Git history remains available for archaeology, but removed prototype code is not current implementation authority.

See [`docs/architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](docs/architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md).

```bash
xcodebuild -project Humay.xcodeproj -scheme Humay -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build
```

| | |
|---|---|
| Minimum target | iOS / iPadOS 18.0 |
| Devices | iPhone + iPad |
| iPhone | portrait-first |
| iPad | portrait + landscape, adaptive widths |
| Bundle identifier | `online.humay.ios` |
| Stack | SwiftUI, Swift 6; persistence/provider layers added deliberately by production phase |
| Architecture | [`docs/architecture/`](docs/architecture/) |

## Current engineering work

**Phase 01 — Apple Platform Foundation is complete.** Current work propagates Premium Celestial through remaining post-onboarding surfaces while preserving SwiftUI + Clean Architecture (`App → Presentation → Domain ← Data`), explicit dependency composition, state contracts, and persistence/provider seams.

Provider/cache/backend details from Phase 00 continue in parallel where they do not block foundation work.

See [`docs/development/STATUS.md`](docs/development/STATUS.md) and [`docs/development/phases/01-ios-foundation.md`](docs/development/phases/01-ios-foundation.md).

## Product model

Humay has two content paths.

### Free catalog — near-zero marginal runtime cost

- Free daily horoscope is coarse pre-generated content rather than a natal chart.
- Western daily horoscope uses the 12 Sun signs.
- Free Western compatibility uses 12 × 12 = 144 sign-pair catalog keys.
- Other systems use finite coarse catalogs only when methodology validates that model.
- Ordinary Free runtime requests must not call paid astrology or LLM providers.

### Precision / personalized — Rewarded Access or Premium

- Natal chart, precise horoscope, precise compatibility and other provider-backed features use the precision path.
- Structured astrology calculation and interpretation providers remain behind replaceable production boundaries.
- Provider calls are server-side and cache-first.
- One rewarded completion authorizes one needed generation for a selected result key after cache checks.
- Premium uses the same cache-first path without a rewarded ad for each included generation while entitlement is valid.

See [`docs/development/PRODUCT_ACCESS_MODEL.md`](docs/development/PRODUCT_ACCESS_MODEL.md).

## Current design program

Humay has one post-onboarding design authority: **Premium Celestial, Light + Dark**.

Start here:

1. [`docs/design/DESIGN_AUTHORITY.md`](docs/design/DESIGN_AUTHORITY.md)
2. [`docs/design/PREMIUM_CELESTIAL_REDESIGN.md`](docs/design/PREMIUM_CELESTIAL_REDESIGN.md)
3. [`docs/design/SCREEN_DESIGN_PLAN.md`](docs/design/SCREEN_DESIGN_PLAN.md)
4. [`docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — retained onboarding authority and legacy context

The target feeling is editorial, quiet, and unmistakably Humay: ivory/midnight grounds, restrained gold, thin celestial mechanics, and subtle feather/eye/orbit motifs. Generic purple-neon astrology, cute celestial characters, and excessive cards are superseded post-onboarding.

### Cross-device rule

Every shipping screen is designed and reviewed for:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- iPad landscape/adaptive behavior when needed.

A phone layout is not stretched onto iPad.

The approved D1 onboarding family already covers iPhone and iPad Light/Dark. It remains intact until onboarding receives a dedicated Premium Celestial migration phase.

## Canonical onboarding

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are not onboarding steps. They may be added later from Profile for precision-dependent features.

## Canonical IA

- Today / Chart / Explore / Connections / You
- Current Sky, Calendar, and Ask under Explore
- Circle/people and Compatibility under Connections
- Profile, birth details, preferences, access, and settings under You

## Development cadence

The architecture and Premium Celestial representative foundation are implemented. Remaining feature-family migration follows:

1. design the family for iPhone + iPad, Light + Dark;
2. approve;
3. implement;
4. capture real iPhone/iPad screenshots;
5. reconcile code against design;
6. continue.

## Source-of-truth boundary

Exact astronomical/astrological facts are never invented by an interpretation model. Precision features consume structured calculated facts from the astrology calculation layer; interpretation consumes those facts and produces user-facing meaning/expression.

Free catalog content is intentionally coarse and must disclose its basis. Unknown birth time must never be replaced with a hidden fake time.

## Brand status

**Humay** is the selected product/project name. External trademark, store-name, domain/handle and cultural/linguistic clearance remain launch tasks.
