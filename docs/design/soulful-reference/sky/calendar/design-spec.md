# Calendar Month + Week visual-design specification

**Design phase:** D3.2 — Calendar Month + Week  
**Status:** REVIEW CANDIDATE — NOT APPROVED  
**Concept:** Meridian Almanac  
**Platforms:** iPhone and iPad, Light and Dark

## 1. Purpose and boundary

Calendar is the chronological exploration layer inside Sky. It extends the approved Lunar Meridian Current Sky family with quieter utility, a clear civil-date rhythm, sparse celestial signals, and factual event rows.

This is visual guidance only. It does not implement `SKY-002`, `SKY-004`, or `SKY-005`; add production SwiftUI; calculate astrology; define providers; or authorize Event Detail.

## 2. Authority and family relationship

Use these sources in order:

1. [`../../../DESIGN_AUTHORITY.md`](../../../DESIGN_AUTHORITY.md)
2. [`../../../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../../../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`../../../SCREEN_DESIGN_PLAN.md`](../../../SCREEN_DESIGN_PLAN.md)
4. [Approved Current Sky](../current-sky/README.md)
5. This Calendar package after product-owner approval

Current Sky owns the stronger hero moment. Calendar reuses editorial typography, semantic surfaces, restrained accents, methodology labels, event-row rhythm, and native Sky route ownership without duplicating the lunar hero.

## 3. Chosen visual system

### 3.1 Meridian Almanac

- A border-light calendar field rather than a card per date.
- Serif month, range, and selected-day headings; system type for controls and scanning.
- Sparse Moon, event-count, and neutral event signals only where supplied data supports them.
- One shared selected-day agenda region on iPhone, separated by editorial hairlines rather than another large card.
- Dominant overview plus bounded agenda/context on iPad.
- No illustration inside primary Calendar views.

### 3.2 Token layers

The generator maps the existing Soulful Celestial primitives through semantic and component roles.

| Layer | Examples | Calendar use |
|---|---|---|
| Primitive | cream, midnight, coral, lavender, gold, blue, sage | Existing approved color values; not new brand colors. |
| Semantic | ground, surface, raised, primary text, secondary text, hairline, selection, event accent | Appearance-specific purpose mapping. |
| Component | month-grid surface, today outline, selected-date fill, event-count marker, methodology badge, agenda row | Component state without hardcoding meaning into one hue. |

Color reinforces hierarchy. Shape, text, weight, count, glyph, and VoiceOver labels carry state meaning.

## 4. Shared nested-screen header

Both views use:

- native Back to `Sky`;
- inline `Calendar` title;
- native-looking Month / Week segmented control;
- visible Today action;
- previous and next controls tied to the visible month or week;
- existing Sky root selection in the adaptive tab shell.

The Today action returns the visible range and selection to the current civil date. Switching Month / Week preserves the selected civil date when it exists in the destination range; otherwise the destination anchors to the range containing that date. No gesture-only switcher exists.

## 5. Month — iPhone

Hierarchy:

```text
Back / Calendar / Today
Development sample disclosure + Month / Week
Month name + previous / next
Seven-column month grid
Selected date + event count
Selected-day agenda
Existing Sky tab shell
```

The August 2026 fixture visibly exercises a six-week month with July and September outside-month dates. Date cells remain part of one coherent grid; they are not individual rounded cards. The selected Friday has three compact rows without putting event titles inside the grid.

## 6. Month — iPad

The 1024 pt portrait reference uses a 928 pt bounded content region:

- primary left region: dominant six-week month grid and quiet observation footer;
- secondary right region: selected date, healthy-width three-event agenda, and a lightweight timing note.

The right agenda never stretches to full canvas width. The left grid remains dominant, but date cells do not scale proportionally with the device. Selection on August 14 visibly connects the grid to the matching right-side heading and agenda.

## 7. Week — iPhone

Week is a seven-day navigator, not an hourly calendar.

Hierarchy:

```text
Back / Calendar / Today
Development sample disclosure + Month / Week
Week range + previous / next
Seven-day celestial rail
Selected date + selected-day agenda
Later-this-week signals
Existing Sky tab shell
```

The compact reference selects Wednesday to demonstrate a one-event day with exact timing. Friday remains visibly event-bearing with a count of three. Thursday shows Today without becoming selected.

## 8. Week — iPad

The full-width seven-day rail exposes the complete week at once. Below it:

- primary left region: selected Friday and its three-event agenda;
- secondary right region: a lightweight chronological continuation showing exact lunar timing on Wednesday, Friday event density, and a quiet Sunday.

This gives additional week context without an hourly vertical timetable, a second dashboard card, or full Event Detail content.

## 9. Date semantics

| State | Visual treatment | Non-color reinforcement |
|---|---|---|
| Today | Coral outline with a short top rule | Bold date and visible `TODAY` label |
| Selected | Solid selection disc/pill | Strong weight, bounded shape, and selected agenda relationship |
| Event-bearing | Small semantic Moon glyph or dot plus count | Glyph or numeric count; accessible event total |
| Normal | Plain date | No marker |
| Outside month | Reduced emphasis | Italic date and explicit `JUL` / `SEP` boundary labels |

When Today and Selected coincide, the implementation should merge the selected fill with an explicit Today label/value rather than stack multiple circles. The references separate them so both base states can be reviewed.

## 10. Event presentation

Calendar reuses Current Sky factual row DNA at higher density. Each row is one future navigation target with:

- semantically valid event glyph or neutral tradition-event marker;
- title that may wrap;
- exact, range, date-only, or unavailable timing;
- visible methodology label;
- disclosure chevron for future Event Detail.

| Timing form | Reference example | Rule |
|---|---|---|
| Exact | `Exact · 18:00 TRT` | Clock time appears only for an explicit instant fixture. |
| Interval | `Fri 21:00 – Sat 03:00` | Natural start/end range remains visible across midnight. |
| Date only | `Date only · 14 August` | No midnight or noon is invented. |
| Unavailable | `Timing unavailable` | Explicit language replaces a blank or fake clock time. Methodology remains a separate factual label. |

Astronomical, Western, and Vedic remain visible as quiet inline labels with a small semantic marker rather than colored category chips. Reference rows demonstrate lunar phase, planetary ingress, aspect, and a Vedic event with unavailable timing.

## 11. Sparse data constraints

### Month

`SkyCalendarMonth` contains sparse event-bearing days. Presentation may derive all civil dates for the selected Gregorian month. It must not create celestial events for missing model days, treat normal dates as failures, or place fake markers to balance the grid.

### Week

`SkyCalendarWeek` contains seven contiguous dates. The design supports month/year boundaries, zero-event dates, a one-event date, and multiple events on one date. Missing events remain visually quiet.

## 12. Quiet-day behavior

Selecting a normal date with no supplied events keeps the month/week navigator active and replaces the agenda with:

> Quiet sky this day

Supporting copy remains restrained: `No notable events are supplied.` This is neither empty Calendar data nor an error.

## 13. State language

[The state board](states.png) separates:

1. loading — stable grid skeleton, no fake events;
2. month with no event-bearing days — valid empty Calendar result;
3. selected quiet day — valid date within otherwise usable navigation;
4. unavailable — explicit source or methodology limitation;
5. offline with cached Calendar — loaded structure plus saved-time disclosure;
6. offline without cached Calendar — no saved dates and reconnect guidance;
7. failed/error — source could not load;
8. date-state semantics key.

No Retry control is shown because no current contract promises it.
Any explanation for the absent recovery action stays in the board annotation outside simulated product surfaces.

## 14. Light and Dark composition

### Light

- warm cream ground;
- off-white grid and agenda surfaces;
- warm hairlines and very soft shadow;
- deep coral selection;
- restrained coral, lavender, gold, blue, and sage event accents.

### Dark

- midnight ground rather than black;
- tonal navy grid, agenda, and controls;
- brighter coral selection with dark selected text;
- warm ivory primary text and lighter secondary text;
- brighter glyph accents with borders rather than shadow dependency.

Dark is separately composed. It is not an inversion of Light.

## 15. Artwork and glyph policy

- `IllustrationCalendarCelestial` remains only the Current Sky Calendar-entry illustration. It does not become the Calendar family’s in-screen illustration.
- Primary Month and Week screens use no large illustration.
- Moon-phase glyphs appear only for supplied lunar events.
- Planet glyphs are candidates only where the event names the matching planet and optical review passes.
- Generic event dots are not exposed individually to VoiceOver.
- A neutral diamond marker identifies the Vedic fixture without implying astronomical certainty.
- No production asset is promoted, changed, or retired by this reference package.

## 16. Accessibility and platform behavior

- Every day cell and navigation action has at least a 44 pt interaction target, even when its visible treatment is smaller.
- Each date is one grouped accessibility element; decorative markers are hidden inside the combined label.
- Example: `Friday, August 14, selected, 3 celestial events.`
- Today adds `today`; outside dates add their full month and outside-month status.
- Event rows combine glyph, title, timing, methodology, and state into one element.
- Dynamic Type expands rows and may collapse iPad regions before factual text is truncated.
- Month cells never shrink important dates to accommodate long localized names; weekday headers use locale-appropriate short forms while VoiceOver receives full names.
- Keyboard order follows visual/semantic order. Arrow-key range movement and native segmented-control behavior remain predictable.
- Pointer hover/focus applies to the full day cell or row.
- Increase Contrast strengthens outlines, hairlines, markers, and secondary labels.
- Differentiate Without Color retains today text, selection shape, event count/glyph, and outside-month typography.
- Reduce Motion removes optional selection/range transitions without replacing them with motion.
- Background may extend under safe areas; controls and content do not.

## 17. Stress coverage

The primary references, [stress board](stress.png), and documented reflow rules cover:

- six-week month beginning late in the week;
- outside-month dates at both ends;
- one event and three events on a date;
- quiet selected day on the state board;
- long event title;
- interval crossing midnight;
- date-only and unavailable timing;
- mixed Astronomical, Western, and Vedic events;
- sparse week and sparse month behavior;
- compact iPhone and materially different iPad composition.

The stress board additionally exercises September, a six-row November beginning late in the week, `Sagittarius`, mixed timing, long localized month naming, and accessibility text pressure without creating extra full-device screenshots.

Five-week months retain the same row target and allow the grid to become shorter; they do not stretch rows to fill the six-week height. Long month names wrap or reduce editorial display emphasis before controls are compressed. Full localized weekday names are represented through accessibility labels and wider contexts, not forced into narrow month columns.

## 18. Generator and handoff

`generate-references.cjs` is the editable source for all SVG/PNG pairs. It uses the repository’s existing Cormorant Garamond font by reference and does not copy font files into this package. PNGs render at 2× the point canvases. Reference output remains illustrative and contains no production provider assumptions.

Approval must remain package-wide. Product-owner acceptance of D3.2 is required before any Calendar SwiftUI implementation begins.
