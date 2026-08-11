# Humay Design Authority

**Status:** Current and exclusive design authority  
**Effective:** 2026-08-12  
**Design branch:** `design/soulful-light-dark`

This document defines the design sources that may guide Humay UI implementation. The repository intentionally keeps **one current design program only**. Superseded design plans, generated design passes, historical visual archives and implementation-review screenshots are not part of this branch's design authority.

## 1. Authority order

For implementation, use this order:

1. [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md) for Free / Rewarded / Premium behavior and runtime-cost rules.
2. This document for design authority and non-negotiable product/visual constraints.
3. [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) for visual language, Light/Dark behavior, typography, illustration, color, surfaces and motion.
4. [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md) for D0–D9 screen coverage and approval sequencing.
5. Approved screen references, tokens and asset specifications under [`soulful-reference/`](soulful-reference/README.md).
6. [`../development/METHODOLOGY_TRACK.md`](../development/METHODOLOGY_TRACK.md) for methodology gates that affect actual astrology output.

If a generated screenshot conflicts with product access, methodology, accessibility or this authority document, the screenshot is corrected; it does not redefine the product.

## 2. Canonical information architecture

Primary navigation is:

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is opened from the header/profile entry.
- Profile / Settings is not a sixth tab.
- Compatibility is reached through Circle/people flows.
- A visual exploration must not silently change navigation.

## 3. Current visual direction

Humay uses the **Soulful Celestial** direction:

- warm, alive and emotionally inviting;
- colorful with disciplined semantic accent use;
- painterly gouache/watercolor celestial illustration;
- premium editorial typography;
- rounded/tinted feature surfaces and controlled elevation;
- cute in selected moments without becoming childish or mascot-driven;
- restrained utility screens rather than decorating everything;
- first-class Light and Dark appearances.

The target is storybook-quality celestial art inside a polished modern iOS product: memorable without becoming a cartoon astrology game.

## 4. Light + Dark requirement

Every shipping screen family requires an intentional **Light + Dark pair** before final visual freeze.

Dark mode is not an automatic inversion. It uses midnight-navy surfaces, warm-ivory text and rebalanced accent colors while preserving the identity and warmth of illustrations.

D0 establishes the shared translation strategy. Later Dark references must be reviewed side by side with their Light counterpart.

## 5. Typography

- **Cormorant Garamond** — wordmark, major titles, hero/editorial headlines and selected large scores.
- **SF Pro / system** — body copy, navigation, controls, forms, settings and general UI.
- **SF Mono / system** — degrees, coordinates and technical chart/date/time values where mono improves scanning.

Dynamic Type remains mandatory. Rows reflow rather than shrinking important text to fit.

## 6. Illustration and visual intensity

Humay uses three intensity levels:

- **Level A — Hero:** one major emotional/illustrated moment on screens such as Today, Compatibility, onboarding reveal and premium highlights.
- **Level B — Illustrated feature:** compact meaningful art for categories and feature cards.
- **Level C — Utility:** mostly native typography, controls and quiet surfaces for settings/forms/dense technical data.

Approved art language includes painterly celestial landscapes, restrained sun/moon expression, botanical/cosmic mini-illustrations, tasteful orbit/constellation lines and semi-real editorial portraits where human context benefits.

Avoid chibi, 3D emoji mascots, sticker density, thick cartoon outlines, generic purple-neon galaxy styling and unrelated illustration styles.

## 7. Product access model

Humay's user-facing access hierarchy is:

**Free → optional Rewarded Access → Premium**

The exact rules are defined in `PRODUCT_ACCESS_MODEL.md`; design may improve presentation but may not redefine entitlement behavior.

- Free ordinary runtime usage must not call paid astrology or LLM providers.
- Free Western daily horoscope uses finite pre-generated catalog content.
- Free Western compatibility uses the 12 × 12 sign-pair catalog.
- Free has no natal-chart calculation.
- Rewarded Access authorizes one needed provider-backed generation for the selected result key after cache checks.
- Successfully generated results are cached/reopenable according to the access/cache contract.
- Rewarded Access is not a coin/token wallet or temporary Premium.
- Premium uses the same cache-first precision path without a rewarded ad for each included generation while entitlement is valid.

## 8. Compatibility score presentation

The current design allows numeric compatibility presentation:

- an overall compatibility percentage/score may be shown;
- dimensions may show percentages/scores;
- qualitative explanation must accompany the numbers.

Mock percentages are illustrative only. Production scoring algorithm, weights, confidence and cross-system semantics require explicit product/methodology definition before they become real output.

## 9. Roast and notifications

- Roast is an in-app expression only.
- Notifications are always written in the Normal register.
- Normal and Roast consume the same astrology facts; tone may not change calculated meaning.

## 10. Astrology-data boundary

Design artifacts never validate astronomical or astrological facts.

- Exact placements, houses, aspects, timing, dashas, pillars and relationship facts come from the structured calculation/provider layer and validated methodology.
- Interpretation consumes structured facts and must not invent calculation facts.
- Exact times are shown only when deterministically supported.
- Unknown birth time must degrade only the facts that actually depend on time; no hidden substitute time is allowed.

## 11. Device and accessibility scope

V1 targets **iPhone portrait**. iPad is a dedicated later design/implementation phase, not a stretched phone layout.

The UI must use semantic spacing, reusable components and responsive chart/art geometry. Light and Dark contrast are checked independently. Information is never encoded by color or artwork alone.

## 12. Current design status

- **D0:** Today/Home, Daily Horoscope and Compatibility Light/Dark anchors establish the visual system.
- **D1–D9:** proceed according to `SCREEN_DESIGN_PLAN.md`.
- The existing mock-first app is a structural/accessibility test bed, not visual authority.
- Final production visual polish for a feature family waits for approval of its current Light + Dark references.

After D9, this file is updated with the final screen index and production-asset catalog. No alternate design authority is to be added alongside it.
