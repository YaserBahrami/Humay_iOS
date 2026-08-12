# Humay iOS + iPadOS

**Humay** is the product, repository and internal project name.

## Current state

The repository was reset to a **clean production baseline on 2026-08-12** before implementation of the approved Soulful Celestial design.

The old mock-first Presentation, DesignSystem, fixture runtime and premature persistence/provider layers were removed. Git history remains available for reference, but removed prototype code is not current implementation authority.

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

Humay has one design authority: **Soulful Celestial, Light + Dark**.

Start here:

1. [`docs/design/DESIGN_AUTHORITY.md`](docs/design/DESIGN_AUTHORITY.md)
2. [`docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`docs/design/SCREEN_DESIGN_PLAN.md`](docs/design/SCREEN_DESIGN_PLAN.md)
4. [`docs/design/soulful-reference/`](docs/design/soulful-reference/README.md)

The target feeling is warm, soulful, colorful, charming and premium with editorial typography and restrained celestial illustration.

### Cross-device rule

Every shipping screen is designed and reviewed for:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- iPad landscape/adaptive behavior when needed.

A phone layout is not stretched onto iPad.

Existing iPhone Welcome and Birth Date references remain approved. Their iPad companions are the next backfill before those screens are cross-device complete. Step 03 Tradition is designed for both device families from the start.

## Canonical IA

- Today / Circle / Sky / Chart / Ask
- Calendar nested under Sky
- Profile / Settings through the header/profile entry
- Compatibility through Circle/people flows

## Development cadence

1. design next family for iPhone + iPad, Light + Dark;
2. approve;
3. implement only the approved family;
4. capture real iPhone/iPad screenshots;
5. reconcile code against design;
6. continue.

Current application source is intentionally minimal until the first approved production slice is implemented.

## Source-of-truth boundary

Exact astronomical/astrological facts are never invented by an interpretation model. Precision features consume structured calculated facts from the astrology calculation layer; interpretation consumes those facts and produces user-facing meaning/expression.

Free catalog content is intentionally coarse and must disclose its basis. Unknown birth time must never be replaced with a hidden fake time.

## Brand status

**Humay** is the selected product/project name. External trademark, store-name, domain/handle and cultural/linguistic clearance remain launch tasks.
