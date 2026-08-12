# D3.1 — Current Sky

**Status:** REVIEW CANDIDATE — NOT APPROVED

This package is the first complete visual-reference candidate for Current Sky. It defines presentation for product-owner review only. It does not approve D3, authorize production SwiftUI, or complete `SKY-003`.

## Review first

1. [iPhone Light preview](iphone-light.png) and [editable SVG](iphone-light.svg)
2. [iPhone Dark preview](iphone-dark.png) and [editable SVG](iphone-dark.svg)
3. [iPad Light preview](ipad-light.png) and [editable SVG](ipad-light.svg)
4. [iPad Dark preview](ipad-dark.png) and [editable SVG](ipad-dark.svg)
5. [Current Sky state board](states.png) and [editable SVG](states.svg)
6. [Adaptive layout notes](adaptive-notes.md)
7. [Reference-specific review notes](review-notes.md)

The four device references are loaded/default candidates. Approval remains package-wide: one device or appearance cannot become implementation authority while another remains unresolved.

## Concept

**Lunar Meridian** — a celestial editorial dashboard built around one restrained lunar-orbit hero, compact factual event rows, a distinct nested Calendar entry, and a short upcoming timeline.

The reference demonstrates exact, interval, date-only, and unavailable timing; Astronomical, Western, and Vedic labels; long titles; optional summaries; multiple events; and a sparse day. Interval text uses a natural start/end range, and observation metadata appears once per composition. All event values and editorial copy are illustrative.

## Package files

- `iphone-light.svg` / `.png`
- `iphone-dark.svg` / `.png`
- `ipad-light.svg` / `.png`
- `ipad-dark.svg` / `.png`
- `states.svg` / `.png`
- `elements/current-sky-orbit-light.svg`
- `elements/current-sky-orbit-dark.svg`
- `adaptive-notes.md`
- `review-notes.md`
- `design-spec.md` — requirements authority
- `generate-references.cjs` — reference-only SVG/PNG generator

## Approval boundary

- Every new artifact is labeled **REVIEW CANDIDATE — NOT APPROVED**.
- The hero headline is illustrative. Its layout role is accepted for this candidate, but its production source is not frozen because Domain has no approved editorial-hero contract.
- Calendar remains a child route inside Sky.
- Astronomical, Western, and Vedic methodology labels remain visible and quiet on event rows for this candidate.
- `IllustrationCalendarCelestial` remains candidate art pending review of the wider Calendar family.
- `Development sample · not calculated` is visible as a Debug screenshot treatment, not a Release banner proposal.
- No Current Sky, Calendar, or event-detail production UI is implemented by this package.
- Existing production assets are not modified or promoted by this package.

The next action is product-owner review of the four Current Sky references.
