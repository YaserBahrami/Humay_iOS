# Development Status

Last updated: **2026-08-12**

## Active priorities

1. **Production baseline is clean and cross-device.**
2. **Backfill iPad references for approved Welcome + Birth Date.**
3. **Design D1 Step 03 Tradition for iPhone + iPad, Light + Dark.**
4. After approval, implement onboarding from the repository references rather than the removed prototype UI.
5. Continue Phase 00 provider/cache/access architecture in parallel where it does not depend on unfinished UI.

## Production baseline

The old mock-first application implementation was removed on 2026-08-12 before production UI work.

Retained:

- Xcode project/scheme/configuration;
- Swift 6 strict-concurrency foundation;
- bundle/signing settings;
- core profile/birth semantics;
- fonts/assets shell;
- test targets;
- design/product/methodology documentation.

Removed:

- old Presentation layer;
- old Paper-only DesignSystem;
- mock astrology runtime and fixture catalogs;
- premature persistence schema/repositories;
- speculative Chart/Sky/Circle/Ask domain/service implementation;
- prototype navigation and tests tied to removed screens.

Details: [`../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md).

## Device scope

Humay now targets **iPhone + iPad** from the start.

- Minimum: iOS / iPadOS 18.0.
- iPhone: portrait-first.
- iPad: portrait + landscape.
- Adaptive layouts must support regular/compact widths and narrower multitasking windows where applicable.
- `TARGETED_DEVICE_FAMILY = 1,2`.

The old "iPad later" statement is superseded.

## Visual design authority

Active branch: `design/soulful-light-dark`

Current and exclusive authority:

- [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md)
- [`../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
- [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md)
- [`../design/soulful-reference/`](../design/soulful-reference/README.md)

### D0

iPhone Light/Dark anchors approved for Today, Daily Horoscope and Compatibility. iPad companion anchors are pending.

### D1

Canonical onboarding:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Current status:

- Welcome iPhone Light/Dark: approved; iPad pending.
- Birth Date iPhone Light/Dark + package: approved; iPad pending.
- Tradition: next, designed for iPhone + iPad together.
- Profile Reveal: pending, designed for iPhone + iPad together.

## Implementation gate

A production screen should not be visually frozen until the repository contains iPhone Light/Dark + iPad Light/Dark references and any necessary iPad adaptive/landscape notes.

Development cadence:

**design → approve → implement → capture real cross-device screenshots → reconcile → continue**.

## Binding product decisions

- Product/repository/internal name is Humay.
- Primary IA is Today / Circle / Sky / Chart / Ask.
- Ordinary Free usage must not trigger paid astrology or LLM calls.
- Free Western daily horoscope uses finite Sun-sign catalog content.
- Free Western compatibility uses 12 × 12 sign-pair catalog keys.
- Free has no natal-chart calculation.
- Personalized/precision features use Rewarded Access or Premium.
- Precision is cache-first and server-side.
- Numeric compatibility presentation is allowed, but visual mock scores do not define methodology.
- Roast changes expression, not calculated facts.
- Unknown birth time is never replaced with a fake time.

## Current runtime

The app currently launches a deliberately minimal semantic Light/Dark Humay placeholder. This is not production UI; it exists only to keep the cleaned project buildable while approved screens are implemented one family at a time.

No production astrology provider, interpretation provider, persistence schema, StoreKit, ads, analytics, notification delivery or post-onboarding feature runtime is wired yet.
