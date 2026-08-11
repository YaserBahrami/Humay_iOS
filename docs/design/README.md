# Humay Design Reference

This directory is the repository-owned source of truth for Humay product and UI/UX design artifacts.

## Current visual direction

As of **2026-08-12**, Humay's current visual authority is:

1. [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md)
2. [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md)
4. Approved paired screen references in [`soulful-reference/`](soulful-reference/README.md)

The target feeling is **soulful, colorful, charming and premium**: painterly celestial artwork and expressive editorial typography inside a clear modern iOS product. It should be fun/cute in selected moments without becoming childish, cartoon-heavy or visually noisy.

Every redesigned product screen requires a deliberate **Light + Dark pair** before final visual implementation is frozen.

## Current structure

```text
docs/design/
  README.md
  DESIGN_AUTHORITY.md
  SOULFUL_CELESTIAL_DESIGN_DIRECTION.md
  SCREEN_DESIGN_PLAN.md
  MINIMAL_DESIGN_DIRECTION.md          # historical previous visual direction

  soulful-reference/                  # current redesign references
    README.md
    anchors/
      light/
      dark/
    assets/
    ... screen families added D1-D9

  review/                              # screenshots of the existing mock-first app
  claude-reference/                    # historical original design artifacts
  final-archive/                       # historical GitHub-friendly derived archive
```

## Where to start

For design/implementation work:

1. Read [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md).
2. Read [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md).
3. Use [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md) to identify whether the screen family is already visually frozen.
4. Use [`soulful-reference/`](soulful-reference/README.md) for approved Light/Dark composition references.
5. Use `claude-reference/`, `final-archive/` and `review/` only to recover product behavior, states, copy and historical interaction decisions that have not been superseded.

## Canonical information architecture

The visual redesign does not automatically change navigation.

**Today / Circle / Sky / Chart / Ask** remains canonical.

- Calendar is nested under Sky.
- Profile / Settings is reached from the header/profile entry.
- Compatibility lives in Circle/people flows.
- Concept screenshots that temporarily show `Compatibility` or `Library` tabs are style explorations, not IA authority.

## Historical material

### `MINIMAL_DESIGN_DIRECTION.md`

Preserved as the previous visual direction. Its serious/minimal appearance, all-paper lock, square/no-shadow emphasis and restricted color treatment are superseded.

Its useful implementation/accessibility lessons—semantic layout, reflow instead of shrinking, Dynamic Type hierarchy and responsive fixed-geometry behavior—remain captured in the current authority map.

### `claude-reference/`

Original product/design explorations and freeze artifacts. Use for feature concepts, interaction history, terminology and states where newer authority does not conflict.

### `final-archive/`

Historical GitHub-friendly derived screenshots/Markdown. It is a convenient inventory, not current visual authority.

### `review/`

Screenshots of the completed Phase 01M mock-first application. They document what was built, not the new target appearance.

## Current redesign status

**D0 — Visual anchor lock** is the active first step.

The anchor family is:

- Today / Home
- Daily Horoscope / reading detail
- Compatibility

Each has a Light reference and an initial Dark translation. The Light anchors define the selected art direction; Dark receives a deliberate refinement pass before it becomes the pattern for all downstream screens.

Next: **D1 — Onboarding**, nine screens in both appearances.

## Product/data caveat

Design artifacts define presentation and interaction. They do **not** validate astrology calculations.

Exact placements, aspects, timing, dashas, pillars, compatibility values and interpretations shown in mockups are illustrative unless independently validated by the structured calculation/methodology layer. Current access/cost behavior is governed by [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md).