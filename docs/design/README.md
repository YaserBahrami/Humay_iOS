# Humay Design

This directory is the **single current source of truth** for Humay UI/UX design.

As of **2026-08-12**, there is one design program only: **Soulful Celestial, Light + Dark**.

## Read in this order

1. [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md)
2. [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md)
4. [`soulful-reference/`](soulful-reference/README.md)

## Directory structure

```text
docs/design/
  README.md
  DESIGN_AUTHORITY.md
  SOULFUL_CELESTIAL_DESIGN_DIRECTION.md
  SCREEN_DESIGN_PLAN.md

  soulful-reference/
    README.md
    anchors/
    onboarding/
    today/
    circle/
    sky/
    chart/
    ask/
    settings/
    monetization/
    sharing-widgets/
    brand/
    assets/
```

Only the folders that have generated/approved material need to exist at a given moment.

## Current design goal

Humay should feel **soulful, colorful, charming and premium**: painterly celestial artwork and expressive editorial typography inside a clear modern iOS product.

It may be cute and playful in selected places, but must not become childish, cartoon-heavy, generic purple-neon astrology or visually busy on every surface.

Every product screen requires a deliberate **Light + Dark pair** before final visual implementation is frozen.

## Canonical information architecture

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is reached through the header/profile entry.
- Compatibility lives in Circle/people flows.
- Generated concept images do not change IA unless `DESIGN_AUTHORITY.md` is explicitly updated.

## Current phase

**D0 — Visual anchor lock**

Anchor families:

- Today / Home
- Daily Horoscope / reading detail
- Compatibility

Next: **D1 — Onboarding**, nine screens in both Light and Dark.

## Asset rule

Screen references and design-source artwork stay under `soulful-reference/` during design work. Only reusable, approved and optimized production assets are promoted into `Humay/Resources/Assets.xcassets/`.

Do not ship full screenshot crops as app assets.

## Product/data boundary

Design mockups define presentation and interaction, not astrology truth. Exact placements, aspects, timing, dashas, pillars, compatibility values and interpretations are illustrative unless validated by the structured calculation/methodology layer.

Current access/cost behavior is governed by [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md).
