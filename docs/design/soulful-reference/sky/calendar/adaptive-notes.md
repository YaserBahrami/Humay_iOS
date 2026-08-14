# Calendar adaptive-layout and accessibility notes

**Status:** APPROVED VISUAL GUIDANCE

## Reference canvases

- iPhone: 430 × 932 pt portrait, rendered to 860 × 1864 PNG.
- iPad: 1024 × 1366 pt portrait, rendered to 2048 × 2732 PNG.
- State board: 1600 × 1080 px.
- Geometry describes width-driven composition, not device-model checks.

## Compact width

Month uses one vertical scroll hierarchy: nested header, segmented control, month navigation, grid, selected-day agenda, then existing tab shell. Week replaces the grid with the seven-day rail and adds a lightweight later-week chronology.

Compact rules:

- 20 pt screen margins;
- civil-date cells remain at least 44 pt targets;
- segmented control gains invisible vertical hit padding when its visible height is below 44 pt;
- event rows expand instead of clipping title, time, methodology, or unavailable reason;
- selected-day rows use hairlines and spacing instead of another full-width rounded card;
- bottom content padding clears the tab bar and home indicator;
- outside-month dates remain selectable and announce their full civil date;
- month-to-month animation is optional, never required to understand the new range.

## Regular width — Month

At roughly 820 pt usable width and above, Month becomes overview/detail:

- left: dominant bounded grid;
- right: selected date and agenda;
- 28–36 pt inter-region gap;
- right agenda keeps a bounded reading width;
- grid rows do not expand merely to consume vertical space.

The right agenda updates in place when selection changes. Selection and scroll position remain stable during appearance changes and rotation.

## Regular width — Week

Week keeps one full-width seven-day rail. The lower region becomes:

- left: selected-day agenda;
- right: an unboxed chronological continuation with upcoming signals and a quiet date.

The secondary region summarizes chronology; it never becomes an hourly timetable, a second dashboard card, or full Event Detail.

## iPad landscape

- Center content within a maximum width near 1120 pt.
- Add outer breathing room before increasing grid or agenda width.
- Keep Month near a 60/40 overview/detail balance.
- Keep Week rail full-width within the bounded content area, then retain agenda/context below.
- Do not add a third agenda column.
- Do not enlarge type, glyphs, radii, and date targets in proportion to canvas width.
- Preserve the adaptive Sky tab/sidebar and nested Back behavior.

## Split View and narrow iPad windows

When the right agenda cannot preserve roughly 300 pt of readable width, collapse toward the compact single-column hierarchy. Use available width and Dynamic Type pressure, not an iPad model check. Month grid remains above the agenda; Week rail remains above selected-day content.

The selected civil date, visible range, and active Month/Week mode remain stable across collapse when possible.

## Month height and calendar structure

- Six-week months use six 44 pt-or-larger rows.
- Five-week months keep the same row rhythm and reduce total grid height.
- Outside-month dates retain civil navigation but use reduced emphasis and boundary month labels.
- A month beginning late in the week does not center or rebalance dates artificially.
- The grid may derive civil structure, but only supplied event-bearing dates receive celestial markers.

## Localization pressure

- Month names may wrap to two editorial lines before navigation targets shrink.
- Narrow grids use locale-appropriate short weekday forms; full names remain in accessibility labels.
- Week range copy can wrap above the rail.
- Event titles wrap freely; critical timing and methodology never truncate.
- At accessibility sizes, the segmented control may move to its own row and iPad may collapse to one region.

## Dynamic Type

- Navigation, date headings, event titles, timing, and methodology use semantic scaling in production.
- Date cells may expose only date and marker visually at large sizes; full state stays in the grouped accessibility label.
- Event-row order under pressure is glyph, title, timing, methodology, then disclosure.
- Secondary week context can move below the selected-day agenda.
- Decorative dots disappear before text becomes unreadable.

The supporting [stress board](stress.png) demonstrates long localized month naming, five- and six-row months, `Sagittarius`, a cross-midnight interval, unavailable timing, and accessibility-sized reflow pressure.

## VoiceOver grouping

Do not expose dots, counts, or decorative chevrons as separate elements.

Example Month labels:

- `Thursday, August 13, today, no celestial events.`
- `Friday, August 14, selected, 3 celestial events.`
- `Tuesday, September 1, outside August, no celestial events.`

Example Week label:

- `Wednesday, August 12, selected, 1 celestial event, waning gibbous Moon.`

Example event label:

- `Mercury square Uranus, Western. From Friday at 21:00 until Saturday at 03:00. Opens Event Detail.`

The neutral development-sample badge is announced once near the top, not repeated for every event.

## Focus order and interaction

### Compact Month

Back → Today → Month/Week → previous/next month → month dates in row-major civil order → selected-day event rows → tab shell.

### Compact Week

Back → Today → Month/Week → previous/next week → seven dates in chronological order → selected-day rows → later-week signals → tab shell.

### Regular Month

Header and range controls → grid dates in row-major order → selected agenda rows. Visual columns do not produce an alternating focus order.

### Regular Week

Header and range controls → week rail dates → selected agenda → week context.

Pointer hover and keyboard focus apply to the complete target. Standard Back swipe, native segmented selection, Return/Space activation, and system focus rings remain intact.

## Appearance and contrast

- Light uses soft borders and restrained shadow.
- Dark uses tonal surfaces and visible outlines without shadow dependency.
- Today outline, selected fill, event glyph/count, and outside-month type all require at least 3:1 graphical contrast in production.
- Normal text requires 4.5:1; large text requires 3:1.
- Increase Contrast strengthens today/selection outlines and secondary text.
- Differentiate Without Color preserves every state through shape and text.

## Motion

Potential transitions are limited to segmented selection, date selection, and range change. Reduce Motion uses immediate state changes or a short opacity transition. No orbit, particle field, or looping illustration exists on Calendar.
