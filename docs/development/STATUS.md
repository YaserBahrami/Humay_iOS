# Development Status

Last updated: **2026-08-12**

## Active priorities

1. **Start Phase 01 — Apple Platform Foundation** on a temporary feature branch from `main`.
2. Build the SwiftUI + Clean Architecture foundation for iPhone and iPad without restoring prototype feature code.
3. Backfill iPad references for approved Welcome + Birth Date.
4. Design D1 Step 03 Tradition for iPhone + iPad, Light + Dark.
5. After cross-device approval, implement onboarding from repository references.
6. Continue Phase 00 provider/cache/access architecture in parallel where it does not block the app foundation.

## Repository authority

`main` is the current product, architecture, roadmap and design source of truth.

Start each engineering session with [`../START_HERE.md`](../START_HERE.md).

Historical feature/design branches are not authority after merge.

## Production baseline

The old mock-first application implementation was removed on 2026-08-12 before production UI work.

Retained:

- Xcode project/scheme/configuration;
- Swift 6 strict-concurrency foundation;
- bundle/signing settings;
- core profile/birth semantics;
- fonts/assets shell;
- test targets;
- current design/product/methodology documentation.

Removed:

- old Presentation layer;
- old Paper-only DesignSystem;
- mock astrology runtime and fixture catalogs;
- premature persistence schema/repositories;
- speculative Chart/Sky/Circle/Ask implementation;
- prototype navigation and tests tied to removed screens.

Details: [`../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md).

## Engineering track

### Phase 01 — Apple Platform Foundation

**READY TO START.**

Foundation scope:

- SwiftUI application shell;
- Clean Architecture boundaries: `App → Presentation → Domain ← Data`;
- explicit dependency composition;
- production Soulful Celestial semantic design tokens/primitives;
- iPhone + iPad adaptive layout foundations;
- Light + Dark from the start;
- root routing/state boundaries without speculative feature UI;
- persistence/configuration/testing boundaries prepared without premature feature schemas.

See [`phases/01-ios-foundation.md`](phases/01-ios-foundation.md).

### Phase 00 — Technical Architecture

Provider/cache/backend/privacy architecture remains **IN PROGRESS in parallel**. Phase 01 foundation does not require every provider-specific Phase 00 document to be finished first; it does require the current product-access, iOS architecture, clean-baseline and design-authority contracts.

See [`phases/00-technical-architecture.md`](phases/00-technical-architecture.md).

## Device scope

Humay targets **iPhone + iPad** from the start.

- Minimum: iOS / iPadOS 18.0.
- iPhone: portrait-first.
- iPad: portrait + landscape.
- Adaptive layouts support compact/regular widths and narrower multitasking windows where applicable.
- `TARGETED_DEVICE_FAMILY = 1,2`.

## Visual design authority

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

Birth time and birth location are not onboarding steps.

## Implementation gate

Shared architecture/design-system foundation may proceed now. A feature-specific production screen is not visually frozen until its repository package contains iPhone Light/Dark + iPad Light/Dark references and required adaptive notes.

Cadence:

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

The app currently launches a deliberately minimal semantic Light/Dark Humay placeholder. It is a clean build baseline, not production UI.

No production astrology provider, interpretation provider, persistence schema, StoreKit, ads, analytics, notification delivery or post-onboarding feature runtime is wired yet.
