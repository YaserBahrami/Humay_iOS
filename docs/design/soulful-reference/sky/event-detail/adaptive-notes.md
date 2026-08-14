# Event Detail adaptive-layout and accessibility notes

**Status:** APPROVED VISUAL GUIDANCE

## Reference canvases

- iPhone: 430 × 932 pt portrait, rendered to 860 × 1864 PNG.
- iPad: 1024 × 1366 pt portrait, rendered to 2048 × 2732 PNG.
- State board: 1600 × 1080 px.
- Stress board: 1600 × 900 px.
- Geometry describes width-driven composition, not device-model checks.

## Compact width

Use one scroll column with 20 pt side margins and this order:

1. origin-aware native Back action;
2. Event Detail context;
3. Debug disclosure when present;
4. identity hero;
5. editorial meaning;
6. factual context rows;
7. existing Sky tab shell.

The hero exposes title, type, methodology, and timing before the first fold ends. Factual rows are grouped and expand vertically. Methodology text moves below the title when Dynamic Type pressure requires it. No critical timing is truncated.

The primary fixture uses Calendar as its origin. Current Sky-origin opens return to Current Sky / the Sky navigation stack; Calendar-origin opens return to Calendar with Month/Week state preserved. No origin selector is part of the UI.

## Regular width — iPad

At roughly 820 pt usable width and above, use two bounded regions:

- left: identity and meaning;
- right: factual context.

Keep a 44–56 pt inter-region gap and comfortable reading widths. Do not stretch phone cards across the whole canvas. Do not scale type, glyphs, radii, or illustration in proportion to device width.

The left region completes its identity/meaning sequence before the right region begins in VoiceOver and keyboard order, even though the regions are side by side.

## iPad landscape

- Center content within a maximum width near 1120 pt.
- Keep identity/meaning near 46% and factual context near 54% of usable content width.
- Add outer breathing room before enlarging either region.
- Keep the identity hero compact in height; use width for title breathing room.
- Keep one factual context region; do not introduce a third feed or a share panel.
- If landscape height is short, let the content scroll inside the bounded page rather than compressing timing or fact rows.

## Split View and narrow iPad windows

When the right region cannot preserve readable fact rows, collapse toward the iPhone hierarchy:

1. identity;
2. meaning;
3. facts.

Use available width, horizontal size class, and Dynamic Type pressure—not an iPad model check. Preserve the selected event and route state when collapsing.

## Dynamic Type

- Title may grow to three lines; hero motif moves below or hides before title shrinks.
- Meaning grows to several lines; card height follows text.
- Fact rows use label, value, and optional detail in a vertical rhythm; methodology may occupy its own line.
- Timing remains complete and keeps its semantic form: instant, range, date-only, or unavailable.
- iPad may collapse to one region at accessibility sizes even when geometric width remains regular.
- Decorative arcs, sparkles, and glyphs disappear before factual text is reduced.

## VoiceOver and focus order

### Compact phone

Back to opening screen → Event Detail heading → Debug disclosure → event type → event title → methodology → timing → What this means → meaning text → Factual context heading → fact rows → tab shell.

The hero motif is decorative. A fact row is one grouped element, for example: “Timing, Friday at 21:00 TRT.”

### Regular iPad

Back to opening screen → Event Detail heading → Debug disclosure → identity hero → meaning → Factual context.

Do not expose chevrons, dots, orbital arcs, or decorative accents as separate focusable elements. The full row owns pointer hover, keyboard focus, and activation when implementation introduces a row target.

## Safe areas, input, and motion

- Background may extend under system areas; text and controls remain inside safe areas.
- The phone bottom shell reserves home-indicator clearance and does not obscure the last fact row.
- Back and future fact rows use native 44 pt targets.
- iPad pointer hover and keyboard focus apply to the complete target, not only an icon.
- Native Back swipe, Return/Space activation, and system focus rings remain available.
- Reduce Motion shows static orbital art with no replacement animation.

## Appearance and contrast

- Light uses warm ground, off-white fact surface, soft borders, and safe tonal accent text.
- Dark uses midnight ground, raised navy/plum surfaces, warm text, and brighter accents without inversion.
- Meaning remains understandable without color through labels and copy.
- Increase Contrast strengthens hairlines, fact grouping, and the selected navigation context.
- Runtime implementation evidence is captured under [`docs/design/implementation-evidence/d3-sky-calendar/event-detail/`](../../../implementation-evidence/d3-sky-calendar/event-detail/README.md) for cross-device states, Dynamic Type pressure, native focus/navigation and pointer/keyboard paths; future changes must re-run platform inspections.
