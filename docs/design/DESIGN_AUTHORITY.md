# Humay Design Authority

**Status:** Current and exclusive design authority  
**Effective:** 2026-08-12  
**Design branch:** `design/soulful-light-dark`

This branch intentionally contains one current design program only.

## 1. Authority order

For implementation, use this order:

1. [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md) — access/cost behavior.
2. This document — design authority and non-negotiable product/visual constraints.
3. [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — current visual language and component rules.
4. [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md) — D0–D9 screen inventory and sequencing.
5. Approved references under [`soulful-reference/`](soulful-reference/README.md).
6. [`../development/METHODOLOGY_TRACK.md`](../development/METHODOLOGY_TRACK.md) — methodology gates for real astrology output.

If a mockup conflicts with product access, methodology or accessibility, the mockup is corrected.

## 2. Canonical information architecture

Primary navigation remains:

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is opened from the profile/header entry.
- Compatibility is reached through Circle/people flows.
- Reference screenshots may contain temporary navigation labels; they do not silently redefine IA.

## 3. Current visual direction

The selected Humay style is **cosmic editorial with selective cute illustration**:

- warm cream Light mode and deep navy Dark mode;
- strong serif editorial headlines with clean system UI typography;
- restrained coral/lavender/gold/blue/sage accents;
- soft rounded cards and simple line/flat illustrations;
- friendly celestial characters/objects used sparingly;
- clean utility surfaces with minimal decoration;
- first-class intentional Light and Dark designs.

The D0 Today, Daily Horoscope and Compatibility Light/Dark references under `soulful-reference/anchors/` define the visual source of truth.

The current direction explicitly **does not use painterly watercolor/gouache landscapes** as its primary illustration language.

## 4. Light + Dark requirement

Every shipping screen family requires a deliberate Light + Dark pair before final visual freeze.

Dark mode is not an automatic inversion: it uses midnight grounds, tonal card elevation, warm light text and slightly brighter accent colors.

## 5. Typography

- **Cormorant Garamond** — wordmark, hero/editorial headlines and selected large scores.
- **SF Pro / system** — body copy, controls, navigation, forms and settings.
- **SF Mono / system** — technical degrees/coordinates/dates/times where beneficial.

Dynamic Type remains mandatory; rows reflow rather than shrinking important text.

## 6. Illustration and visual intensity

- **Level A:** one major emotional moment on Today, Compatibility, onboarding welcome/reveal and selected premium surfaces.
- **Level B:** one compact simple illustration for meaningful feature/category cards.
- **Level C:** quiet native utility surfaces for forms, settings and dense technical data.

Approved illustration is simple line/flat cosmic art with minimal shading, small stars/orbit details and occasional friendly faces. Avoid chibi, 3D emoji, sticker density, painterly landscapes, thick cartoon outlines and generic purple-neon galaxy styling.

## 7. Product access model

User-facing access hierarchy remains:

**Free → optional Rewarded Access → Premium**

Design may improve presentation but cannot redefine entitlement behavior. Free ordinary runtime usage must not call paid providers. Rewarded/Premium precision is cache-first and follows `PRODUCT_ACCESS_MODEL.md`.

## 8. Compatibility score presentation

Numeric compatibility presentation is allowed:

- overall percentage/score;
- dimension percentages/scores;
- qualitative explanation alongside numbers.

Mock percentages are illustrative only. Production scoring requires explicit methodology/product definition.

## 9. Roast and notifications

- Roast is an in-app expression only.
- Notifications remain Normal-register copy.
- Tone does not change calculated facts.

## 10. Astrology-data boundary

Design artifacts do not validate astrology facts. Exact placements, houses, aspects, timing, dashas, pillars and relationship facts come from structured calculation/provider data and validated methodology. Unknown birth time is never replaced with a hidden fake time.

## 11. Device and accessibility scope

V1 targets iPhone portrait. iPad is a dedicated later phase.

The UI uses semantic spacing, reusable components and responsive technical geometry. Light/Dark contrast is checked independently, information is not encoded only by color, and minimum hit targets remain accessible.

## 12. Current design status

- **D0 — APPROVED STYLE SOURCE:** Today, Daily Horoscope and Compatibility Light/Dark anchors are committed under `soulful-reference/anchors/`.
- **D1 — GENERATED / REVIEW NEXT:** 9 onboarding screens × Light/Dark plus component/illustration reference boards are committed under `soulful-reference/onboarding/` and `soulful-reference/components/`.
- D2–D9 proceed according to `SCREEN_DESIGN_PLAN.md`.
- The mock-first app remains an engineering/accessibility test bed, not visual authority.

No alternate design authority should be added alongside this one.
