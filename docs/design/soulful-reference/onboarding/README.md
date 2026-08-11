# D1 — Onboarding Reference Set

Status: **REDESIGN IN PROGRESS — STEP 01 READY FOR REVIEW**

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

The pair intentionally follows the selected D0 direction: warm cream vs midnight navy, editorial serif hierarchy, crisp system typography, selective coral/lavender/gold accents, a simple friendly coffee/celestial illustration, restrained sparkle detail, and a stronger but still premium dark-mode color treatment.

### Review status

- Light: ready for review
- Dark: ready for review
- Product semantics: reconciled with current app
- Implementation: not started from this reference yet

## Next

After Step 01 is approved, continue with:

- Step 02 — Birth Date
- Step 03 — Tradition
- Step 04 — Profile Reveal

The existing legacy files for the former nine-screen onboarding exploration remain only as historical drafts until the new four-screen set fully replaces them. Do not use those legacy files for implementation decisions.

## Design-data note

Any sample date, sign, system label or astrology value shown in a reference image is a visual fixture unless separately validated by Humay's calculation/methodology layer.
