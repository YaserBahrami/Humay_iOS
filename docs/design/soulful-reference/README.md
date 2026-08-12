# Humay Current Design References

This directory is the repository-owned visual reference set for the current Humay Soulful Celestial design.

## Authority

1. [`../DESIGN_AUTHORITY.md`](../DESIGN_AUTHORITY.md)
2. [`../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`../SCREEN_DESIGN_PLAN.md`](../SCREEN_DESIGN_PLAN.md)
4. the approved screen package in this directory

Supporting component boards or SVG renderer metadata never override those sources.

## Cross-device rule

Humay ships on iPhone and iPad from the same production baseline.

A screen is cross-device complete only when the repository contains:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- adaptive/landscape notes where necessary.

Existing approved iPhone references remain valid; missing iPad companions are tracked as pending work rather than inferred by stretching the phone layout.

## D0 — selected anchors

`anchors/` contains the current iPhone visual source for:

- Today / Home
- Daily Horoscope
- Compatibility

These establish warm cream / deep navy, Cormorant-led editorial hierarchy, clean system UI typography, simple celestial illustration, soft cards and disciplined accent color.

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

Birth time/place are later Profile inputs, not onboarding beats.

The old mock-first onboarding code and obsolete nine-screen design drafts were removed. Git history is the archive; these current references lead implementation.

## Components

`components/` contains supporting visual-language boards. They are not an independent component/token authority. Production components are defined from the current design authority, token file and owning approved screen package.

## Typography note for SVG references

Some generated SVGs may contain renderer fallback font-family names. Production typography is always the canonical Cormorant Garamond + SF Pro/system system described in `SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`.

## Assets

Reference mockups are not automatically shippable assets. Reusable artwork is isolated, approved and exported deliberately into `Humay/Resources/Assets.xcassets/` during implementation. Use the current `assets/ASSET_CATALOG.md` and line/flat illustration guidance.

## Astrology values

Dates, signs, scores and readings shown in mockups are illustrative unless separately validated by Humay's calculation/methodology layer. Design references define presentation and interaction, not astronomical truth.
