# Soulful Celestial Design References

This directory contains the current visual-reference work for Humay's 2026-08-12 redesign.

## Authority

Read these first:

1. [`../DESIGN_AUTHORITY.md`](../DESIGN_AUTHORITY.md)
2. [`../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`../SCREEN_DESIGN_PLAN.md`](../SCREEN_DESIGN_PLAN.md)

## D0 anchor set

The first committed anchor family establishes the target visual language across three high-value surfaces:

- Today / Home
- Daily Horoscope / reading detail
- Compatibility

Each has a Light and Dark reference under `anchors/`.

The Light anchors are the selected design direction. The first Dark anchors are **initial appearance translations** used to lock the midnight-surface/color strategy. They are not the final per-pixel Dark implementation reference; Dark mode receives a deliberate refinement pass before D1 becomes the pattern for the rest of the app.

## Assets

`assets/` contains cropped artwork/style references derived from approved anchor compositions. They are useful for maintaining illustration consistency and identifying reusable production-art candidates.

These files are **not automatically shippable application assets**. Shipping artwork should be exported/optimized separately into `Humay/Resources/Assets.xcassets/` after approval.

## Astrology values

All dates, signs, percentages, timing windows and readings in visual mockups are illustrative unless separately validated by Humay's calculation/methodology layer. Design references define presentation, hierarchy and interaction—not astronomical truth.