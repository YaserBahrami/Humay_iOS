# Humay iOS + iPadOS

**Humay** is the product, repository and internal project name.

> **Start every implementation session with [`docs/START_HERE.md`](docs/START_HERE.md).** `main` is the current product/architecture/design authority.

## Current state

The repository was reset to a **clean production baseline on 2026-08-12** before implementation of the approved Soulful Celestial design.

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

**Phase 01 — Apple Platform Foundation is ready to start.** It establishes SwiftUI + Clean Architecture (`App → Presentation → Domain ← Data`), explicit dependency composition, the production Soulful Celestial design-system foundation, cross-device root state/navigation boundaries, and test/config/persistence seams without rebuilding speculative features.

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

Humay has two design layers.

**Product/voice direction (current authority):** **Playful Editorial — entertainment-first.**
Start here: [`docs/design/PLAYFUL_EDITORIAL_DIRECTION.md`](docs/design/PLAYFUL_EDITORIAL_DIRECTION.md).
Astrology is the content engine; Humay is a personalized entertainment feed. Smart,
mischievous, premium, self-aware. IA: Today (Cosmic Feed) · Chemistry · You · Sky.

**Material foundation:** the Soulful Celestial token system (palette, type, spacing)
remains the visual material underneath the new direction:

1. [`docs/design/DESIGN_AUTHORITY.md`](docs/design/DESIGN_AUTHORITY.md)
2. [`docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)

The target feeling is warm, soulful, colorful, charming and premium with editorial
typography. Screen-level Soulful Celestial references that conflict with the
entertainment-first direction are superseded by it.

### Cross-device rule

Every shipping screen is designed and reviewed for:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- iPad landscape/adaptive behavior when needed.

A phone layout is not stretched onto iPad.

Existing iPhone Welcome and Birth Date references remain approved. Their iPad companions are the next backfill before those screens are cross-device complete. Step 03 Tradition is designed for both device families from the start.

## Canonical onboarding

1. Welcome
2. Birth Date
3. Name
4. Tradition
5. Profile Reveal (Sun sign moment)

Birth time and birth location are not onboarding steps. They may be added later from Profile for precision-dependent features — Humay never substitutes a fake time.

## Canonical IA

- Today / Chemistry / You / Sky
- Profile / Settings through the header/profile entry
- Compatibility lives inside Chemistry (people flows)

## Development cadence

Shared architecture/design-system foundation can proceed now. Feature-specific UI follows:

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
