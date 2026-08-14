# D3.3 — Event Detail

**Status:** APPROVED VISUAL REFERENCE — IMPLEMENTED AND RECONCILED

This package is the approved visual reference for the implemented explanatory Event Detail destination reached from Current Sky rows and Calendar Month/Week agenda rows. `SKY-005` is implemented over the Debug-only sample; `SKY-002` and `SKY-006` remain pending.

R1 typography supersedes older font-family and size choices in this package: Newsreader owns editorial/display UI, SF Pro/system owns body, controls, dates and times, and Cormorant Garamond remains wordmark-only.

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

1. native Back action whose title follows the opening screen;
2. event identity and timing;
3. a short Humay editorial meaning;
4. factual context with a quiet methodology label.

The primary fixture is **Mercury enters Virgo**, shown as a Planetary ingress in the Western system. It exercises a two-line identity, a methodology label, instant timing, involved body/sign context, interpretive copy, and explicit reference-only availability. Every primary reference keeps **Development sample · not calculated** visible.

The fixture is illustrative only. It is not real astronomy or astrology for the displayed date.

## Family relationship

- **Current Sky:** emotional and current; Event Detail receives its event rows but does not repeat its hero.
- **Calendar:** chronological and almanac-like; Event Detail is the explanatory destination behind its agenda rows.
- **Event Detail:** editorial and factual; interpretation and supplied facts remain visibly separate.

Calendar remains nested under Sky. Event Detail does not add a root destination or a second navigation shell.

## Navigation origin and root shell

Event Detail can open from Current Sky, Calendar Month, or Calendar Week. Native navigation-stack behavior owns the Back destination:

- Current Sky origin returns to Current Sky / the Sky navigation stack.
- Calendar origin returns to Calendar and preserves Month/Week selection state.

Primary references use Calendar as visual origin, so Back reads `Calendar`. No custom origin selector is shown. iPhone keeps the existing Sky-selected root tab bar visible; iPad keeps the adaptive Sky root-navigation model.

## Approval boundary

- Event Detail is an **APPROVED VISUAL REFERENCE**.
- Approval covers iPhone Light/Dark, iPad Light/Dark, state board, stress board, Celestial editorial sheet direction, origin-aware native navigation behavior, visible Sky root shell behavior, factual versus interpretive hierarchy, timing/methodology treatment, observation context, and adaptive/accessibility guidance.
- `SKY-003`, `SKY-004`, and `SKY-005` are implemented over the Debug-only sample; `SKY-002` remains pending for the production data pipeline and `SKY-006` remains pending for methodology-aware system behavior.
- Production SwiftUI and native routes are implemented; provider, API, cache, persistence, Chart, Ask, sharing, and asset-catalog work remain outside this slice.
- Reference fixtures do not define production calculations, methodology authority, editorial copy contracts, recovery actions, or asset ownership.

**Implementation result:** Event Detail is implemented and reconciled under `SKY-005`. This package remains visual authority; it does not authorize `SKY-002` or `SKY-006`.
