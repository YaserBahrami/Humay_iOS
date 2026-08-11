# Development Status

Last updated: **2026-08-12**

## Active priorities

Humay has two parallel priorities:

1. **D1 review — current Light/Dark onboarding reference set**
2. **Phase 00 — Technical Architecture & Implementation Planning**

Architecture work that does not depend on final appearance may continue while screen designs are produced phase by phase.

## Visual design status

**Active branch:** `design/soulful-light-dark`

Current and exclusive visual authority:

- [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md)
- [`../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
- [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md)
- [`../design/soulful-reference/`](../design/soulful-reference/README.md)

There are no alternate design plans on this branch.

### D0 — Visual anchor lock

**APPROVED STYLE SOURCE.** Light/Dark references are committed for:

- Today / Home
- Daily Horoscope / reading detail
- Compatibility

The selected direction is cosmic editorial: warm cream / deep navy, expressive serif hierarchy, simple line/flat cute celestial illustration, soft rounded cards, sparse star/orbit decoration and disciplined coral/lavender/gold/blue/sage accents. The painterly/watercolor exploration is no longer the current direction.

### D1 — Onboarding

**GENERATED / REVIEW NEXT.** Nine screens × Light/Dark are committed under `docs/design/soulful-reference/onboarding/`, with shared component/illustration boards.

D1 must be reviewed against D0 before it is marked approved or used as the source for D2.

### Next design phase after approval

**D2 — Today + Circle.** Then D3–D9 proceed through Sky, Chart, Ask, Settings, Monetization, Sharing/Widgets/States and final brand/production handoff.

## Phase 00 — Architecture

Phase 00 remains **IN PROGRESS**.

Current architecture work defines:

1. on-device/backend/provider data flow and failure boundaries;
2. calculation-provider adapter/output contract and validation;
3. local + backend cache identity, retention and offline behavior;
4. interpretation contract, provenance and Normal/Roast separation;
5. Free catalog generation/review/publication pipeline;
6. rewarded one-generation entitlement, Premium and provider-failure recovery;
7. privacy/security boundary for birth/saved-person data.

## Binding product decisions

- Product/repository/internal name is **Humay**.
- Primary IA is **Today / Circle / Sky / Chart / Ask**.
- Calendar is nested under Sky; Profile/Settings is reached through the header/profile entry.
- Ordinary Free usage must not trigger paid astrology or LLM calls.
- Free Western daily horoscope uses finite pre-generated Sun-sign catalog content.
- Free Western compatibility uses 12 × 12 = 144 sign-pair catalog keys.
- Free has no natal-chart calculation.
- Personalized/precision features use Rewarded Access or Premium.
- Precision is cache-first and server-side.
- One rewarded completion authorizes one needed provider-backed generation for the selected result key after cache checks.
- Numeric compatibility presentation is allowed, but mock percentages do not define production scoring methodology.
- Roast is in-app expression only; notifications remain Normal register.

## Phase 01M — Completed mock-first application

The existing app builds, launches and exposes major flows over fixture content. It remains useful for:

- route/flow coverage;
- mock domain/service boundaries;
- Dynamic Type and accessibility behavior;
- reusable implementation lessons.

It is **not current visual authority**. Do not use the existing visual treatment to override the D0–D9 references.

Every astrological value in the mock-first application remains fixture content and is not calculation truth.

## Implementation constraints

- Bundle identifier `online.humay.ios`.
- Minimum deployment target iOS 18.0.
- V1 targets iPhone portrait; iPad is a dedicated later phase.
- Persistence uses SwiftData with versioned schema/migration planning from V1.
- Swift 6 remains the implementation language.
- Dynamic Type hierarchy/reflow behavior remains binding.
- No hidden fake birth time may substitute for unknown input.

## Active blockers

No blocker prevents current design work or Phase 00 architecture planning.
