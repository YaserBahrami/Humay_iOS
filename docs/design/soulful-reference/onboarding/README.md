# D1 — Onboarding Reference Set

**Status:** full cross-device reference set authored; awaiting user approval before production implementation.

D1 follows the canonical four-beat product flow:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are intentionally not collected during onboarding. They can be added later for features that genuinely require precision.

The old mock-first onboarding implementation was removed in the 2026-08-12 production-baseline reset. These repository references drive the new implementation rather than documenting an existing screen.

## Approval gate

Review `REVIEW_INDEX.md` before implementation. Existing iPhone Welcome and Birth Date references remain approved. Newly authored iPad references and Steps 03–04 are `ready for review`, not silently approved.

## Step 01 — Welcome

- approved iPhone: `light/01-welcome.svg`, `dark/01-welcome.svg`
- iPad Light/Dark portrait + landscape: `step-01-welcome/welcome-ipad-review.svg`
- spec/notes: `step-01-welcome/`

## Step 02 — Birth Date

- approved iPhone package remains under `step-02-birth-date/`
- iPad Light/Dark portrait + landscape: `step-02-birth-date/birth-date-ipad-review.svg`
- spec/notes updated in `step-02-birth-date/`

## Step 03 — Tradition

- iPhone + iPad Light/Dark: `step-03-tradition/tradition-cross-device-review.svg`
- spec/notes: `step-03-tradition/`

## Step 04 — Profile Reveal

- iPhone + iPad Light/Dark: `step-04-profile-reveal/profile-reveal-cross-device-review.svg`
- spec/notes: `step-04-profile-reveal/`

## Product invariants preserved

- no Humay account/login step;
- Birth Date collects date only;
- Tradition chooses a leading presentation vocabulary and never hides the other systems;
- Profile Reveal shows only user-entered facts / date-only precision state in the reference;
- no natal precision is invented;
- Dark enabled primary actions use the approved Coral → Lavender treatment;
- iPad uses intentional bounded/two-region composition and collapses toward compact hierarchy in narrower windows.

## Typography and token authority

Use:
- `../../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`
- each step's `README.md`
- each step's structured design spec.

Any sample date, sign, system label or astrology value shown in reference art is illustrative unless separately validated by Humay's methodology/calculation layer.
