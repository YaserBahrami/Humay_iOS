# Calendar reference-specific review notes

**Status:** APPROVED VISUAL REFERENCE

## Chosen direction — Meridian Almanac

Meridian Almanac carries the approved Lunar Meridian family into a quieter chronological surface:

- editorial date headings rather than another hero;
- one coherent civil grid rather than a field of date cards;
- sparse semantic event signals rather than titles inside cells;
- selected-day factual rows that echo Current Sky at higher density;
- a seven-day rail rather than an hourly schedule;
- true iPad overview/detail composition.

## Reference hierarchy

### Month · iPhone

Native nested header → Month/Week selector → month navigation → six-week grid → selected Friday → three-event agenda.

### Month · iPad

The grid owns the primary left region. The selected Friday agenda is widened and bounded on the right. A lightweight timing note explains the cross-midnight fixture without adding another card or introducing an Event Detail screen.

### Week · iPhone

The seven-day rail selects Wednesday and demonstrates a one-event day with exact timing. A compact unboxed chronology exposes Friday’s denser date without turning the screen into a schedule or dashboard.

### Week · iPad

The rail spans the bounded width. The selected Friday agenda sits beside an unboxed `Across the week` chronology showing Wednesday exact timing and a quiet Sunday.

## Month / Week switching

The segmented control is the sole primary mode switch. Previous/next controls change the visible unit. Today restores the current civil range and selects today. Switching modes preserves the selected date where possible. No custom gesture is required; standard Back behavior returns to Current Sky.

## Date-state decisions

- **Today:** outline, top rule, bold date, and `TODAY` text.
- **Selected:** solid disc/pill with strong text contrast.
- **Event-bearing:** semantically valid lunar glyph or dot-plus-count.
- **Normal:** unadorned date.
- **Outside month:** reduced, italic date plus explicit boundary month label.

The primary references intentionally separate Today and Selected so both states can be reviewed. A coincident state should use one selected shape plus an explicit Today accessibility value, not nested circles.

## Event fixtures and timing

| Fixture | Type/system | Timing treatment |
|---|---|---|
| Waning gibbous Moon | lunar phase / Astronomical | `Exact · 18:00 TRT` |
| Mars enters Gemini after an extended retrograde cycle | planetary ingress / Western | `Date only · 14 August` |
| Mercury square Uranus | aspect / Western | `Fri 21:00 – Sat 03:00` |
| Jupiter trine Saturn | tradition-specific / Vedic | `Timing unavailable` |

These are Debug/reference fixtures only. They do not claim actual astronomy for the rendered date.

## Quiet day

`Quiet sky this day` is the selected-date empty agenda. It is visually gentle and keeps all date navigation active. It does not share the failed, unavailable, or offline-without-cache treatment.

## State board decisions

- Empty Month shows a usable civil grid with no event markers.
- Quiet selected day shows a specific date and no rows.
- Unavailable states a source limitation.
- Offline with cache preserves visible dates and saved-time metadata.
- Offline without cache asks for reconnection. The board annotation, outside the simulated UI, records that current contracts expose no recovery action.
- Failed says the source could not load.
- A separate date key documents Today, Selected, event-bearing, and outside-month semantics.

## Light and Dark

### Light

Cream ground, off-white calendar field, restrained warm hairlines, soft shadow, deep coral selection, and muted celestial accents.

### Dark

Midnight ground, raised navy calendar/agenda surfaces, brighter coral selection, tonal controls, warm ivory text, and brighter celestial glyphs. Surface hierarchy comes from tone and borders rather than inversion or heavy glow.

## Calendar artwork decision

**Recommendation A:** `IllustrationCalendarCelestial` should remain exactly as the Current Sky entry illustration. It does not become the Calendar family illustration and is not forced into Month or Week. Calendar’s identity comes from civil rhythm, restrained semantic glyphs, and editorial headings.

This decision resolves the D3.1 ownership question at the visual-reference level only. The production asset remains unchanged.

## Glyph decisions

- Lunar crescent appears only on supplied lunar-phase dates/events.
- The ingress fixture uses a planet/ingress symbol because the title names that event family.
- The aspect fixture uses a neutral two-body relationship glyph.
- The Vedic fixture uses a neutral diamond marker, not a fabricated astrology symbol or a claim of astronomical certainty.
- Count markers prevent dense glyph walls on event-heavy dates.
- Existing production Moon/planet glyphs remain candidates pending approval, small-size optical checks, template rendering checks, and accessibility naming.

## RESOLVED FOR FINAL CANDIDATE

- **Month grid marker system:** one lunar glyph for a supplied lunar event; dot plus count for dense dates; no decorative symbol wall.
- **Today treatment:** outlined celestial disc, short top rule, bold date, and `TODAY` text.
- **Selection treatment:** one solid disc/pill with strong contrast and a direct selected-agenda relationship; coincident Today merges into one shape.
- **Outside-month treatment:** reduced italic date plus explicit boundary month label.
- **Event-row density:** compact factual rows separated by hairlines on iPhone; one bounded agenda surface on iPad.
- **Week rail:** seven contiguous civil dates, not an hourly schedule and not seven independent cards.
- **Methodology visibility:** quiet inline marker plus factual `Astronomical`, `Western`, or `Vedic` text; no colored chip system.
- **Timing visibility:** exact, cross-midnight range, date-only, and `Timing unavailable` remain explicit and subordinate to title.
- **Quiet-day language:** `Quiet sky this day` with concise supporting copy; never an error or oversized empty state.
- **Calendar art:** recommendation A retains `IllustrationCalendarCelestial` only on the approved Current Sky entry.
- **iPad Month:** dominant grid, widened bounded agenda, and lightweight timing note.
- **iPad Week:** full-width rail, dominant selected-day agenda, and unboxed `Across the week` chronology.

## Adaptive findings

- iPhone maintains a single chronological reading order.
- iPad Month uses a dominant grid plus bounded agenda.
- iPad Week uses a full-width rail plus agenda/chronology.
- Landscape adds outer breathing room before scaling content.
- Split View and accessibility Dynamic Type collapse toward compact hierarchy.
- Five-week months become shorter rather than stretching dates.

## Accessibility findings

- [x] Visible navigation and date cells support 44 pt targets through layout or invisible hit padding.
- [x] Today, Selected, event-bearing, normal, and outside-month states do not rely only on color.
- [x] Event rows retain methodology text and explicit timing form.
- [x] Full-row disclosure reserves a future Event Detail target.
- [x] Decorative dots and chevrons are hidden from VoiceOver inside grouped elements.
- [x] Row-major Month and chronological Week focus order are documented.
- [x] Dark uses separate tonal hierarchy.
- [x] Reduce Motion leaves complete static screens.
- [ ] Runtime semantic-color, focus-ring, Dynamic Type, and Accessibility Inspector checks remain implementation-time work.

Static references receive qualitative HIG review only; they do not receive a numerical runtime score.

## Stress-test coverage

- Six-week August 2026 starts late in the week and includes both outside-month boundaries.
- Friday carries three events.
- Wednesday carries one exact lunar event.
- Sunday quiet-day behavior is shown in the state board and iPad `Across the week` chronology.
- The ingress title wraps.
- The aspect interval crosses midnight.
- Date-only and unavailable timing remain explicit.
- Astronomical, Western, and Vedic labels remain visible.
- The supporting stress board shows September, six-row November, `Sagittarius`, long localized month naming, cross-midnight timing, unavailable timing, and accessibility text pressure.
- Documented rules cover localized weekday names, year boundaries, five-week months, six-week months, and accessibility sizes.

## DEFERRED

1. Production event data, freshness, caching, and recovery actions remain owned by future `SKY-002` work.
2. Event Detail layout and transition remain D3.3.
3. Locale-specific first weekday and localized compact weekday symbols must follow the final product locale policy.
4. Production promotion or redrawing of existing Moon/planet glyphs requires Calendar approval and later asset handoff.

## Scope confirmation

No production SwiftUI, route, ViewModel, Domain model, provider, calculation, cache, CloudKit, notification, StoreKit, test, or asset-catalog file is changed by this package.

**IMPLEMENTATION HANDOFF:** `SKY-004` Month and Week are implemented from this approved package; `SKY-005` remains the next Event Detail slice.
