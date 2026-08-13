# D3.2 — Calendar Month + Week

**Status:** REVIEW CANDIDATE — NOT APPROVED

This package defines the first complete cross-device visual-reference candidate for Calendar inside Sky. It does not approve Calendar, authorize production SwiftUI, complete `SKY-004`, or begin D3.3 Event Detail.

## Review first

### Month

1. [Month · iPhone Light](month-iphone-light.png) and [editable SVG](month-iphone-light.svg)
2. [Month · iPhone Dark](month-iphone-dark.png) and [editable SVG](month-iphone-dark.svg)
3. [Month · iPad Light](month-ipad-light.png) and [editable SVG](month-ipad-light.svg)
4. [Month · iPad Dark](month-ipad-dark.png) and [editable SVG](month-ipad-dark.svg)

### Week

5. [Week · iPhone Light](week-iphone-light.png) and [editable SVG](week-iphone-light.svg)
6. [Week · iPhone Dark](week-iphone-dark.png) and [editable SVG](week-iphone-dark.svg)
7. [Week · iPad Light](week-ipad-light.png) and [editable SVG](week-ipad-light.svg)
8. [Week · iPad Dark](week-ipad-dark.png) and [editable SVG](week-ipad-dark.svg)

### Supporting review

- [Calendar state board](states.png) and [editable SVG](states.svg)
- [Calendar stress board](stress.png) and [editable SVG](stress.svg)
- [Design specification](design-spec.md)
- [Adaptive and accessibility notes](adaptive-notes.md)
- [Reference-specific review notes](review-notes.md)
- [`generate-references.cjs`](generate-references.cjs) — deterministic reference generator

## Concept

**Meridian Almanac** — the quieter chronological layer behind approved Lunar Meridian Current Sky.

Month uses a coherent seven-column civil grid with sparse semantic signals and a selected-day agenda. Week uses a seven-day celestial rail with mixed-precision event context instead of an hourly schedule. iPad turns each view into an intentional overview/detail composition rather than enlarging the phone layout. Agenda rows use editorial hairlines and quiet inline methodology labels instead of another layer of category chips.

## Route ownership

```text
Sky
  ├─ Current Sky
  └─ Calendar
       ├─ Month
       ├─ Week
       └─ Event Detail later
```

Calendar is not a root tab, a work calendar, or a generic iOS Calendar clone. The references preserve the existing Sky root selection while showing a native Back to Sky control.

## Reference data boundary

The visible events are explicit development/reference fixtures drawn from `DevelopmentD3Sample` and the approved Current Sky sample language. They are illustrative, unverified, and not actual astronomy for August 2026. Every primary reference keeps `Development sample · not calculated` visible as Debug-style treatment.

No absent `SkyCalendarDay` is treated as provider failure. The month grid derives the civil structure of August 2026 but adds event markers only to explicit reference-bearing dates. Week remains seven contiguous civil dates and does not assume every day has events.

## Approval boundary

- Every Calendar artifact remains **REVIEW CANDIDATE — NOT APPROVED**.
- The approved Current Sky package remains approved and separate.
- Calendar artwork and production glyph promotion remain review decisions, not asset-catalog changes.
- Event-row chevrons reserve a future Event Detail destination; no Event Detail screen is designed here.
- No production code, route, ViewModel, provider, calculation, cache, or asset-catalog entry is created.

**NEXT ACTION:** Product owner reviews the eight Calendar Month/Week references.
