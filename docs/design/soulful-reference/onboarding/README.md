# D1 — Onboarding Reference Set

**Status:** APPROVED cross-device reference set — 2026-08-12; implemented for PROFILE-001 through PROFILE-004.

D1 follows the canonical four-beat product flow:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are intentionally not collected during onboarding. They can be added later for features that genuinely require precision.

The old mock-first onboarding implementation was removed in the 2026-08-12 production-baseline reset. These repository references remain the visual authority for the current production implementation.

## Approval gate

The complete D1 set was explicitly approved by the user on 2026-08-12. `REVIEW_INDEX.md` records the approved references and implementation invariants.

## Step 01 — Welcome

- approved iPhone: `light/01-welcome.svg`, `dark/01-welcome.svg`
- approved iPad Light/Dark portrait + landscape: `step-01-welcome/welcome-ipad-review.svg`
- spec/notes: `step-01-welcome/`

## Step 02 — Birth Date

- approved iPhone package remains under `step-02-birth-date/`
- approved iPad Light/Dark portrait + landscape: `step-02-birth-date/birth-date-ipad-review.svg`
- spec/notes: `step-02-birth-date/`

## Step 03 — Tradition

- approved iPhone + iPad Light/Dark: `step-03-tradition/tradition-cross-device-review.svg`
- spec/notes: `step-03-tradition/`

## Step 04 — Profile Reveal

- approved iPhone + iPad Light/Dark: `step-04-profile-reveal/profile-reveal-cross-device-review.svg`
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
