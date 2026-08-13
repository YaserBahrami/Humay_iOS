# D3.1 — Current Sky

**Status:** APPROVED VISUAL REFERENCE

This package is the approved visual reference for Current Sky. The product owner approved the complete Lunar Meridian package across iPhone, iPad, Light, Dark, adaptive behavior, and state language. Visual approval is the D3.1 design gate; it does not by itself complete `SKY-003` or authorize unrelated D3 work.

## Approved reference set

1. [iPhone Light preview](iphone-light.png) and [editable SVG](iphone-light.svg)
2. [iPhone Dark preview](iphone-dark.png) and [editable SVG](iphone-dark.svg)
3. [iPad Light preview](ipad-light.png) and [editable SVG](ipad-light.svg)
4. [iPad Dark preview](ipad-dark.png) and [editable SVG](ipad-dark.svg)
5. [Current Sky state board](states.png) and [editable SVG](states.svg)
6. [Adaptive layout notes](adaptive-notes.md)
7. [Reference-specific review notes](review-notes.md)

The four device references are the approved loaded/default visual authority. The state board and adaptive notes are approved as visual guidance.

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

## Approval record and boundary

- **Lunar Meridian** is the approved Current Sky visual direction.
- iPhone Light, iPhone Dark, iPad Light, and iPad Dark are approved.
- Adaptive behavior and the state language are approved as visual guidance.
- The hero headline is illustrative. Its layout role is approved, but its editorial-copy source remains deferred because Domain has no approved editorial-hero contract. Hero copy is not methodology authority.
- Calendar remains a child route inside Sky.
- Astronomical, Western, and Vedic methodology labels remain visible and quiet on Current Sky event rows.
- Intervals use natural start/end ranges rather than a “Window” label.
- Observation context remains quiet secondary metadata.
- `IllustrationCalendarCelestial` artwork ownership remains pending the Calendar-family design.
- `Development sample · not calculated` is visible as a Debug screenshot treatment, not a Release banner proposal.
- This reference package itself does not implement Current Sky, Calendar, or event-detail production UI.
- Existing production assets are not modified or promoted by this package.

Current Sky implementation evidence is recorded at [`docs/design/implementation-evidence/d3-sky-calendar/current-sky/`](../../../../design/implementation-evidence/d3-sky-calendar/current-sky/README.md). Calendar and event-detail implementation remain separately gated by `SKY-004` and `SKY-005`.
