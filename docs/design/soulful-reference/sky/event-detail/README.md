# D3.3 — Event Detail

**Status:** REVIEW CANDIDATE — NOT APPROVED

This package is the visual-reference candidate for the explanatory Event Detail destination reached from Current Sky rows and Calendar Month/Week agenda rows. It is reference-only work. It does not approve Event Detail, authorize SwiftUI, complete `SKY-005`, or mark D3 complete.

## Review first

1. [iPhone Light](iphone-light.png) and [editable SVG](iphone-light.svg)
2. [iPhone Dark](iphone-dark.png) and [editable SVG](iphone-dark.svg)
3. [iPad Light](ipad-light.png) and [editable SVG](ipad-light.svg)
4. [iPad Dark](ipad-dark.png) and [editable SVG](ipad-dark.svg)

Supporting review:

- [Event Detail state board](states.png) and [editable SVG](states.svg)
- [Event Detail stress board](stress.png) and [editable SVG](stress.svg)
- [Design specification](design-spec.md)
- [Adaptive and accessibility notes](adaptive-notes.md)
- [Reference-specific review notes](review-notes.md)
- [`generate-references.cjs`](generate-references.cjs) — deterministic reference-only SVG/PNG generator

## Chosen concept

**Celestial editorial sheet** — Event Detail is more focused than Calendar and quieter than the Current Sky hero. It opens one event into a compact explanatory sequence:

1. native Back to Calendar;
2. event identity and timing;
3. a short Humay editorial meaning;
4. factual context with a quiet methodology label;
5. route context showing why the page exists.

The primary fixture is **Mercury enters Virgo**, shown as a Planetary ingress in the Western system. It exercises a two-line identity, a methodology label, instant timing, involved body/sign context, interpretive copy, and explicit reference-only availability. Every primary reference keeps **Development sample · not calculated** visible.

The fixture is illustrative only. It is not real astronomy or astrology for the displayed date.

## Family relationship

- **Current Sky:** emotional and current; Event Detail receives its event rows but does not repeat its hero.
- **Calendar:** chronological and almanac-like; Event Detail is the explanatory destination behind its agenda rows.
- **Event Detail:** editorial and factual; interpretation and supplied facts remain visibly separate.

Calendar remains nested under Sky. Event Detail does not add a root destination or a second navigation shell.

## Approval boundary

- Event Detail remains **REVIEW CANDIDATE — NOT APPROVED**.
- `SKY-003`, `SKY-004`, and `SKY-005` remain TODO.
- No production SwiftUI, route, provider, API, cache, persistence, Chart, Ask, sharing work, or asset-catalog entry is created.
- Reference fixtures do not define production calculations, methodology authority, editorial copy contracts, recovery actions, or asset ownership.

**NEXT STEP:** Product owner reviews the four Event Detail primary references first. Do not begin D3 SwiftUI implementation automatically.
