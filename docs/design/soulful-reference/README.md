# Humay Current Design References

This directory is the repository-owned visual reference set for the current Humay Soulful Celestial design.

## Authority

1. [`../DESIGN_AUTHORITY.md`](../DESIGN_AUTHORITY.md)
2. [`../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`../SCREEN_DESIGN_PLAN.md`](../SCREEN_DESIGN_PLAN.md)
4. the committed screen packages in this directory

## Cross-device rule

Humay now ships on iPhone and iPad from the same production baseline.

A screen is cross-device complete only when the repository contains:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- adaptive/landscape notes where necessary.

Existing iPhone references remain valid; missing iPad companions are tracked as pending work rather than inferred by stretching the phone layout.

## D0 — selected anchors

`anchors/` contains the current iPhone visual source for:

- Today / Home
- Daily Horoscope
- Compatibility

These establish warm cream / deep navy, editorial serif hierarchy, simple celestial illustration, soft cards and disciplined accent color.

iPad companion anchors are pending and must preserve the visual language while using iPad width deliberately.

## D1 — onboarding

Canonical onboarding:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Current status:

- Welcome iPhone Light/Dark — approved; iPad pending.
- Birth Date iPhone Light/Dark package — approved; iPad pending.
- Tradition — next; design iPhone + iPad together.
- Profile Reveal — pending; design iPhone + iPad together.

The old mock-first onboarding code was removed in the production reset. These references now lead implementation rather than describe existing code.

## Components

`components/` contains shared historical/current visual boards. Production components are rebuilt only from approved current references; older component boards do not override a newer screen package.

## Assets

Reference mockups are not automatically shippable assets. Reusable artwork is isolated, approved and exported deliberately into `Humay/Resources/Assets.xcassets/` during implementation.

## Astrology values

Dates, signs, scores and readings shown in mockups are illustrative unless separately validated by Humay's calculation/methodology layer. Design references define presentation and interaction, not astronomical truth.
