# Humay Design

This directory is the **single current source of truth** for Humay UI/UX design.

As of **2026-08-12**, there is one design program only: **Soulful Celestial, Light + Dark**, for **iPhone + iPad**.

## Read in this order

1. [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md)
2. [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md)
4. [`soulful-reference/`](soulful-reference/README.md)

## Current visual direction

Humay should feel **warm, alive, friendly, colorful and premium** without becoming childish or visually busy.

The approved language is **cosmic editorial with selective cute illustration**:

- warm cream Light mode and deep midnight-navy Dark mode;
- Cormorant Garamond editorial hierarchy with clean system UI typography;
- restrained coral, lavender, gold, blue and sage accents;
- soft rounded surfaces;
- simple line/flat celestial illustration used selectively;
- modern Apple-platform UI first, astrology styling second.

Do **not** use painterly/watercolor landscapes, the old Paper/minimal system, generic purple-neon astrology styling, or cartoon/sticker-heavy decoration.

## Device rule

Every shipping screen is designed for:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- iPad portrait/landscape and compact/regular width behavior where composition changes.

The iPad layout is not a stretched phone layout.

## Canonical information architecture

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is reached through the header/profile entry.
- Compatibility lives in Circle/people flows.
- Concept-image navigation labels never override this IA.

## Current design phase

### D0 — style source

iPhone Light/Dark anchors are approved for:

- Today / Home;
- Daily Horoscope;
- Compatibility.

iPad companion anchors remain pending.

### D1 — onboarding

Canonical flow:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are not onboarding steps.

Current status:

- Welcome iPhone Light/Dark — approved; iPad pending.
- Birth Date iPhone Light/Dark + package — approved; iPad pending.
- Tradition — next; design iPhone + iPad together.
- Profile Reveal — pending; design iPhone + iPad together.

## Asset rule

Design references stay under `soulful-reference/`. Only reusable, approved and optimized production assets are promoted into `Humay/Resources/Assets.xcassets/`.

Do not ship screenshot crops as app assets.

## Product/data boundary

Design mockups define presentation and interaction, not astrology truth. Exact placements, aspects, timing, dashas, pillars, compatibility values and interpretations are illustrative unless validated by the structured calculation/methodology layer.

Current access/cost behavior is governed by [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md).
