# Development Status

Last updated: **2026-08-12**

## Active priorities

Humay currently has two parallel priorities:

1. **D0 — Soulful Celestial Light/Dark visual redesign**
2. **Phase 00 — Technical Architecture & Implementation Planning**

The visual redesign is now the first UI step before additional production screen polish. Architecture work that does not depend on final appearance may continue in parallel.

## Visual redesign status

**Active branch:** `design/soulful-light-dark`

The previous minimal/serious appearance is superseded. Current visual authority is:

- [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md)
- [`../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
- [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md)

### D0 — Visual anchor lock

Initial Light/Dark anchor pairs are being stored for:

- Today / Home
- Daily Horoscope / reading detail
- Compatibility

The selected direction is soulful, colorful and charming with painterly celestial art, expressive editorial typography and restrained use of cute motifs. It should not become cartoon-heavy or decorate every utility surface.

Light anchors are the selected direction. The first Dark anchors establish the midnight-surface/color translation and require a deliberate refinement pass before downstream Dark screens are frozen.

### Next design phase

**D1 — Onboarding:** nine screens × Light/Dark.

Then proceed through Today/Circle, Sky, Chart, Ask, Settings, Monetization, Sharing/Widgets/States and final brand/production handoff according to the screen design plan.

## Phase 00 — Architecture

Phase 00 remains **IN PROGRESS**.

Current architecture work continues to define:

1. top-level on-device/backend/provider data flow and failure boundaries;
2. calculation-provider adapter/output contract and validation;
3. local + backend cache identity, retention and offline behavior;
4. interpretation contract, provenance and Normal/Roast separation;
5. Free catalog generation/review/publication pipeline;
6. rewarded one-generation entitlement, Premium and provider-failure recovery;
7. privacy/security boundary for birth/saved-person data.

## Product decisions currently binding

- Product/repository/internal name is **Humay**.
- Canonical primary IA remains **Today / Circle / Sky / Chart / Ask**.
- Calendar is nested under Sky; Profile/Settings is reached through the header/profile entry.
- Free ordinary usage must not trigger paid astrology or LLM calls.
- Free daily horoscope uses finite pre-generated catalog content; Western baseline has 12 Sun-sign entries per day/variant.
- Free Western compatibility uses 12 × 12 = 144 coarse sign-pair catalog keys.
- No Free natal chart calculation.
- Personalized/precision features are Rewarded Access or Premium.
- Precision path is cache-first and server-side.
- One rewarded completion authorizes one provider-backed generation for the selected result key; successful results are cached/reopenable according to the access contract.
- Numeric compatibility score presentation is now allowed by current visual authority, but mockup percentages do not define the production scoring methodology.
- Roast remains in-app expression only; notifications remain Normal register.

## Phase 01M — Mock-first application

**Complete.** The existing app builds, launches and provides every major flow over fixture content.

Phase 01M remains valuable for:

- route/flow coverage;
- mock domain/service boundaries;
- Dynamic Type and accessibility behavior;
- reusable layout lessons;
- baseline interaction structure.

Its minimal visual treatment is **no longer the target appearance**. Do not extend its serious/minimal styling as production UI while the Soulful Celestial D0–D9 redesign is in progress.

Every astrological value in the mock-first application remains fixture content and is not calculation truth.

## Implementation constraints retained

- Bundle identifier `online.humay.ios`.
- Minimum deployment target iOS 18.0.
- V1 targets iPhone portrait; iPad remains a dedicated later phase.
- Persistence uses SwiftData with versioned schema/migration planning from V1.
- Swift 6 remains the implementation language.
- Dynamic Type hierarchy/reflow behavior from the reconciliation pass remains binding even though its visual style is superseded.
- No hidden fake birth time may be substituted for unknown input.

## Active blockers

No blocker prevents D0/D1 design work or Phase 00 architecture planning.

Provider/API access is not required to complete the current design pass because visual references use explicit mock content. Production implementation of provider-backed features remains gated by architecture/provider/methodology work.

## Methodology blockers

See [`METHODOLOGY_TRACK.md`](METHODOLOGY_TRACK.md). Vedic/Chinese coarse Free catalogs must not be invented solely for cost symmetry; their bucket models require methodology validity. Exact compatibility scoring semantics also require an explicit production definition before mock percentages become real outputs.