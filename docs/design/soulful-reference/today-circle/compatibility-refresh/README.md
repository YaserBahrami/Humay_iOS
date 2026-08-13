# Compatibility Refresh

**Status:** REVIEW CANDIDATE — NOT APPROVED

**Scope:** Compatibility selection and result identity/hero only

**Next action:** Product owner reviews this package before any SwiftUI implementation.

This package proposes a Compatibility-specific refinement to the approved D2 Soulful Celestial direction. It does not replace or relabel the approved references in [`../`](../README.md), and it does not change the current design authority. If approved, a later implementation task can supersede only the relevant Compatibility portions and reconcile real simulator screenshots.

## Proposed direction

- Selection becomes a **pair composer**: the chosen people occupy two explicit relationship slots before the action is available.
- Compact iPhone uses one full-width person row per saved person. The current adaptive two-column grid is intentionally retired for this flow.
- Regular-width iPad uses a two-region composition: pair context and action on the left, a generous one-column saved-people list on the right.
- The result begins with one **relationship field** that combines pair identity, restrained orbit connector, score, relationship label, summary, and basis disclosure.
- The references use `Alexandria` / `Christopher` with `Sagittarius` / `Capricorn` to make long-name and long-sign pressure visible.

## Review references

| Surface | iPhone Light | iPhone Dark | iPad Light | iPad Dark |
| --- | --- | --- | --- | --- |
| Selection | [PNG](selection-iphone-light.png) · [SVG](selection-iphone-light.svg) | [PNG](selection-iphone-dark.png) · [SVG](selection-iphone-dark.svg) | [PNG](selection-ipad-light.png) · [SVG](selection-ipad-light.svg) | [PNG](selection-ipad-dark.png) · [SVG](selection-ipad-dark.svg) |
| Result hero | [PNG](result-hero-iphone-light.png) · [SVG](result-hero-iphone-light.svg) | [PNG](result-hero-iphone-dark.png) · [SVG](result-hero-iphone-dark.svg) | [PNG](result-hero-ipad-light.png) · [SVG](result-hero-ipad-light.svg) | [PNG](result-hero-ipad-dark.png) · [SVG](result-hero-ipad-dark.svg) |

## Package contents

- [`design-spec.md`](design-spec.md) — hierarchy, geometry, states, color, type, and result-hero decisions.
- [`adaptive-notes.md`](adaptive-notes.md) — iPhone/iPad behavior, stress tests, Dynamic Type, VoiceOver, pointer/keyboard, and Reduce Motion.
- [`review-notes.md`](review-notes.md) — approval questions, boundaries, and implementation handoff conditions.
- [`generate-references.cjs`](generate-references.cjs) — deterministic SVG/PNG generator.

## Authority boundary

These are reference mockups, not production assets. Dates, signs, score, and relationship copy are illustrative. The package does not change:

- `CompatibilitySelectionView.swift`, `CompatibilityView.swift`, or `CircleView.swift`;
- Domain models, feature states, tests, or `Assets.xcassets`;
- the current text `ShareLink` implementation;
- metrics, Our Take, precise-access, cache, offline, or error-state design;
- D3.3 Event Detail or any unrelated Today/Circle screen.
