# Compatibility Refresh

**Status:** APPROVED VISUAL REFERENCE — IMPLEMENTED AND RECONCILED

**Scope:** Compatibility selection and result identity/hero only

**Approval recorded:** 2026-08-13, after production SwiftUI implementation and real iPhone/iPad Light/Dark reconciliation.

This package is the later approved Compatibility-specific refinement to the D2 Soulful Celestial direction. It supersedes only the Compatibility person-selection and result-hero portions of the older D2 reference in [`../`](../README.md). Production implementation lives in [`CompatibilitySelectionView.swift`](../../../../../Humay/Presentation/Circle/CompatibilitySelectionView.swift) and [`CompatibilityView.swift`](../../../../../Humay/Presentation/Circle/CompatibilityView.swift); final simulator evidence lives in [`../../../implementation-evidence/d2-today-circle/compatibility-refresh/`](../../../implementation-evidence/d2-today-circle/compatibility-refresh/README.md).

## Approved implemented direction

- Selection becomes a **pair composer**: the chosen people occupy two explicit relationship slots before the action is available.
- Compact iPhone uses one full-width person row per saved person. The current adaptive two-column grid is intentionally retired for this flow.
- Regular-width iPad uses a two-region composition: pair context and action on the left, a generous one-column saved-people list on the right.
- The result begins with one **relationship field** that combines pair identity, restrained orbit connector, score, relationship label, summary, and basis disclosure.
- The references use `Alexandria` / `Christopher` with `Sagittarius` / `Capricorn` to make long-name and long-sign pressure visible.

Approval applies specifically to Compatibility person selection, Pair Composer, compact one-column person rows, iPad two-region selection, Compatibility Relationship Field, pair identity, relationship connector, score/label/summary composition, Free/Precise disclosure placement, and the adaptive/accessibility behavior represented by the final implementation evidence.

## Approved references

| Surface | iPhone Light | iPhone Dark | iPad Light | iPad Dark |
| --- | --- | --- | --- | --- |
| Selection | [PNG](selection-iphone-light.png) · [SVG](selection-iphone-light.svg) | [PNG](selection-iphone-dark.png) · [SVG](selection-iphone-dark.svg) | [PNG](selection-ipad-light.png) · [SVG](selection-ipad-light.svg) | [PNG](selection-ipad-dark.png) · [SVG](selection-ipad-dark.svg) |
| Result hero | [PNG](result-hero-iphone-light.png) · [SVG](result-hero-iphone-light.svg) | [PNG](result-hero-iphone-dark.png) · [SVG](result-hero-iphone-dark.svg) | [PNG](result-hero-ipad-light.png) · [SVG](result-hero-ipad-light.svg) | [PNG](result-hero-ipad-dark.png) · [SVG](result-hero-ipad-dark.svg) |

## Package contents

- [`design-spec.md`](design-spec.md) — hierarchy, geometry, states, color, type, and result-hero decisions.
- [`adaptive-notes.md`](adaptive-notes.md) — iPhone/iPad behavior, stress tests, Dynamic Type, VoiceOver, pointer/keyboard, and Reduce Motion.
- [`review-notes.md`](review-notes.md) — approved decisions, boundaries, and implementation reconciliation record.
- [`generate-references.cjs`](generate-references.cjs) — deterministic SVG/PNG generator.

## Authority boundary

These are visual references, not production assets. Dates, signs, score, and relationship copy are illustrative. Authority applies only to the Compatibility selection flow in `CompatibilitySelectionView.swift` and the result Relationship Field in `CompatibilityView.swift`. It does not redesign or newly approve:

- `CircleView.swift`, unrelated Today/Circle screens, or any D3 screen;
- Domain models, feature states, lower-result content, or `Assets.xcassets`;
- the current text `ShareLink` implementation;
- metrics, Our Take, precise-access, cache, offline, or error-state design;
- D3.3 Event Detail or any unrelated Today/Circle screen.
