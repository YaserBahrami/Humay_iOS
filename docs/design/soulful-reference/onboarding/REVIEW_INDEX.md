# D1 Onboarding — Cross-Device Review Index

Status: **reference set authored; awaiting user approval before implementation**

This is the design gate before Codex receives any onboarding implementation task.

## Step 01 — Welcome

Already approved iPhone:
- `light/01-welcome.svg`
- `dark/01-welcome.svg`

New iPad review board:
- `step-01-welcome/welcome-ipad-review.svg`

## Step 02 — Birth Date

Already approved iPhone:
- `step-02-birth-date/birth-date-light.svg`
- `step-02-birth-date/birth-date-dark.svg`

New iPad review board:
- `step-02-birth-date/birth-date-ipad-review.svg`

## Step 03 — Tradition

New iPhone + iPad Light/Dark review board:
- `step-03-tradition/tradition-cross-device-review.svg`

## Step 04 — Profile Reveal

New iPhone + iPad Light/Dark review board:
- `step-04-profile-reveal/profile-reveal-cross-device-review.svg`

## Review invariants

Confirm before implementation:
- hierarchy matches Soulful Celestial;
- Humay V1 remains accountless;
- onboarding collects only birth date + leading tradition;
- no time/location question appears;
- Tradition does not hide the other systems;
- Profile Reveal contains no invented precision;
- iPad is not a stretched iPhone;
- Dark enabled primary actions use Coral → Lavender with dark semantic foreground;
- large Dynamic Type can collapse multi-region/card layouts instead of shrinking important text.

After explicit approval, package statuses can be changed from `readyForReview` to `approved`, and only then should Codex implement the D1 onboarding UI.
