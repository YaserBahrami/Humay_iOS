# D1 — Onboarding Reference Set

Status: **REDESIGN IN PROGRESS — STEPS 01–02 READY FOR REVIEW**

D1 is being rebuilt against the approved Soulful Celestial Light/Dark anchors and the **current four-beat onboarding flow in the app**. The older nine-screen concept set in this folder is superseded and must not be treated as product authority.

## Current canonical onboarding flow

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

This mirrors `OnboardingFlowView.Step` in the current codebase. Birth time and birth location are intentionally **not** collected during onboarding; they can be added later for precise chart features.

## Step 01 — Welcome

Current review references:

- `light/01-welcome.svg`
- `dark/01-welcome.svg`

The pair follows the selected D0 direction: warm cream vs midnight navy, editorial serif hierarchy, crisp system typography, selective coral/lavender/gold accents, simple friendly celestial illustration, restrained sparkle detail and intentionally brighter dark-mode accent treatment.

### Review status

- Light: ready for review
- Dark: ready for review
- Product semantics: reconciled with current app
- Implementation: not started from this reference yet

## Step 02 — Birth Date

Complete review package:

- `step-02-birth-date/birth-date-light-dark.webp` — primary Light/Dark review board
- `step-02-birth-date/birth-date-elements.webp` — element / component review board
- `step-02-birth-date/design-spec.json` — structured implementation handoff
- `step-02-birth-date/README.md` — full visual, copy, behavior and accessibility specification
- `step-02-birth-date/elements/` — editable vector reference motifs and progress elements

The design is intentionally utility-led: editorial question, native wheel picker, one small calendar/celestial motif, two explanatory notes and a pinned Continue action. It does not introduce fake precision or ask for birth time/place.

### Review status

- Light: ready for review
- Dark: ready for review
- Element board: committed
- Vector reference elements: committed
- Product semantics: reconciled with `OnboardingBirthDateView`
- Implementation: not started from this reference yet

## Next

Continue with:

- Step 03 — Tradition
- Step 04 — Profile Reveal

The existing legacy files for the former nine-screen onboarding exploration remain only as historical drafts until the new four-screen set fully replaces them. Do not use those legacy files for implementation decisions.

## Typography and token authority

Generated raster review boards can contain incidental annotation labels from the image-generation pass. Production typography and color values are governed by:

- `../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`
- the per-step `README.md`
- the per-step `design-spec.json`

## Design-data note

Any sample date, sign, system label or astrology value shown in a reference image is a visual fixture unless separately validated by Humay's calculation/methodology layer.
