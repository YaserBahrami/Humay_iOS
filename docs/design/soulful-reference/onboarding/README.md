# D1 — Onboarding Reference Set

**Status:** iPhone Steps 01–02 approved; iPad companion designs pending; Step 03 next.

D1 follows the canonical four-beat product flow:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are intentionally not collected during onboarding. They can be added later for features that genuinely require precision.

The old mock-first onboarding implementation was removed in the 2026-08-12 production-baseline reset. These repository references now drive the new implementation rather than documenting an existing screen.

## Cross-device rule

From this point forward onboarding is designed for:

- iPhone Light + Dark;
- iPad Light + Dark;
- iPad portrait + landscape/adaptive behavior.

Existing approved iPhone references remain valid. They need iPad companion references before the corresponding screen is considered cross-device complete.

## Step 01 — Welcome

Current iPhone references:

- `light/01-welcome.svg`
- `dark/01-welcome.svg`

Status:

- iPhone Light: approved
- iPhone Dark: approved
- iPad Light: pending
- iPad Dark: pending
- implementation: pending production rebuild

## Step 02 — Birth Date

Repository package:

- `step-02-birth-date/birth-date-light.svg`
- `step-02-birth-date/birth-date-dark.svg`
- `step-02-birth-date/birth-date-light-dark.svg`
- `step-02-birth-date/birth-date-elements.svg`
- `step-02-birth-date/design-spec.json`
- `step-02-birth-date/README.md`
- `step-02-birth-date/SOURCE.md`
- `step-02-birth-date/elements/`

Status:

- iPhone Light: approved
- iPhone Dark: approved
- iPhone package/elements/spec: committed
- iPad Light: pending
- iPad Dark: pending
- iPad adaptive notes: pending
- implementation: pending production rebuild

## Next design work

1. backfill iPad Welcome Light/Dark;
2. backfill iPad Birth Date Light/Dark + adaptive notes;
3. design Step 03 Tradition for iPhone + iPad, Light + Dark;
4. after approval, production implementation may proceed using the full cross-device references.

## Typography and token authority

Use:

- `../../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`
- each step's `README.md`
- each step's structured design spec.

Any sample date, sign, system label or astrology value shown in reference art is illustrative unless separately validated by Humay's methodology/calculation layer.
