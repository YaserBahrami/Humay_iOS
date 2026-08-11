# Humay iOS

**Humay** is the product, repository and internal project name for this iOS application.

## Current state

A mock-first iOS application exists and runs with five primary tabs, complete main flows, a reusable design system and fixture content behind replaceable service protocols. It was built ahead of the normal Phase 00 production gate by explicit direction; that exception is recorded in [`docs/development/DEVIATIONS.md`](docs/development/DEVIATIONS.md).

> **Every astrological value currently shown by the app is illustrative fixture content.** Nothing is calculated from an ephemeris and no astrology/interpretation provider is connected. See [`docs/architecture/MOCK_DATA_STRATEGY.md`](docs/architecture/MOCK_DATA_STRATEGY.md).

```bash
xcodebuild -project Humay.xcodeproj -scheme Humay -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' build
```

| | |
|---|---|
| Minimum target | iOS 18.0, iPhone, portrait |
| Bundle identifier | `online.humay.ios` |
| Stack | SwiftUI, SwiftData (versioned from V1), Swift 6 |
| Architecture | [`docs/architecture/`](docs/architecture/) |

Not yet connected: production networking, astrology providers, interpretation providers, authentication, StoreKit, advertising, analytics, widgets, notification delivery or iPad layouts.

## Current product model

Humay has two content paths.

### 1. Free catalog — near-zero marginal runtime cost

- Free daily horoscope is coarse pre-generated content rather than a natal chart.
- Western daily horoscope uses the 12 Sun signs.
- Free Western compatibility uses 12 × 12 = 144 sign-pair catalog keys.
- Other systems use finite coarse catalogs only when methodology validates that model.
- Ordinary Free runtime requests must not call paid astrology or LLM providers.

### 2. Precision/personalized — Rewarded Access or Premium

- Natal chart, precise personalized horoscope, precise compatibility and other provider-backed features use the precision path.
- The initial provider direction is a structured astrology calculation service behind a replaceable adapter plus DeepSeek V4 Flash for interpretation/expression.
- Provider calls are server-side and cache-first.
- One rewarded completion authorizes one needed generation for a selected result key after cache checks.
- Successfully generated results are cached/reopenable according to the access contract.
- Premium uses the same cache-first path without a rewarded ad for each included generation while entitlement is valid.

See [`docs/development/PRODUCT_ACCESS_MODEL.md`](docs/development/PRODUCT_ACCESS_MODEL.md).

## Current design program

Humay has one current design authority: **Soulful Celestial, Light + Dark**.

Start here:

1. [`docs/design/DESIGN_AUTHORITY.md`](docs/design/DESIGN_AUTHORITY.md)
2. [`docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`docs/design/SCREEN_DESIGN_PLAN.md`](docs/design/SCREEN_DESIGN_PLAN.md)
4. [`docs/design/soulful-reference/`](docs/design/soulful-reference/README.md)

The target feeling is soulful, colorful, charming and premium with painterly celestial artwork, expressive editorial typography and restrained cute/playful moments. Every shipping screen family requires an intentional Light + Dark pair before final visual freeze.

Canonical primary IA remains:

- Today / Circle / Sky / Chart / Ask
- Calendar nested under Sky
- Profile / Settings through the header/profile entry
- Compatibility through Circle/people flows

## Development plan

Start engineering sessions with:

1. [`docs/development/STATUS.md`](docs/development/STATUS.md)
2. [`docs/development/PRODUCT_ACCESS_MODEL.md`](docs/development/PRODUCT_ACCESS_MODEL.md)
3. [`docs/development/ROADMAP.md`](docs/development/ROADMAP.md)
4. the active phase file under [`docs/development/phases/`](docs/development/phases/)

Current engineering phase: **Phase 00 — Technical Architecture & Implementation Planning**. The completed mock-first Phase 01M remains a structural/accessibility test bed but is not current visual authority.

## Source-of-truth boundary

Exact astronomical/astrological facts are never invented by an interpretation model. Precision features consume structured calculated facts from the astrology calculation layer; interpretation consumes those facts and produces user-facing meaning/expression.

Free catalog content is intentionally coarse and must disclose its basis. Any methodology choice that changes calculated output requires domain validation/sign-off.

## Brand status

**Humay** is the selected product/project name. External trademark, store-name, domain/handle and cultural/linguistic clearance remain launch tasks.
