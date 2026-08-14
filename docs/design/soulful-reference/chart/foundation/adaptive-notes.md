# D4.1 Chart adaptive and accessibility notes

**Status:** REVIEW CANDIDATE — NOT APPROVED

## iPhone

- Portrait-first, one reading column with 20–24 pt content gutters.
- Chart Overview leads with explanation/readiness, not a full natal wheel.
- Loaded Western wheel uses a readable compact size; key placements follow in a list/card hierarchy.
- Placement Detail reads fact → basis/reliability → interpretation.
- Unknown-time state keeps known and unavailable groups visible without collapsing the limitation into a footnote.
- Primary actions stay inset from safe areas and use native 44 pt targets.
- Bottom root navigation remains the existing Today / Circle / Sky / Chart / Ask shell.

## iPad portrait

- Use a bounded two-region composition when regular width supports it.
- Chart Overview: editorial/readiness/access content beside the abstract preview.
- Loaded Western: wheel and chart identity on the leading side; placements/highlight/detail on the trailing side.
- Placement Detail: fact/basis on the leading side; interpretation on the trailing side.
- Unknown time: limitation/partial-sky explanation beside known/unavailable fact groups.
- Preserve a comfortable text measure; do not stretch paragraphs across the full canvas.

## iPad landscape

- Treat landscape as chart + detail, not a rotated phone.
- Keep the wheel bounded on the leading side and use gained width for selected placement facts or interpretation.
- Keep navigation stable and native. Do not add a second root tab bar.
- If height becomes constrained, scroll the content rather than compressing degree values, uncertainty language or actions.
- If the right region cannot hold its minimum readable measure, collapse to one ordered column.

## Compact Split View / narrow regular width

Collapse in this order:

1. remove secondary decorative illustration;
2. move wheel detail/list below the wheel;
3. stack placement cards;
4. return to one reading column;
5. preserve title, basis, reliability, limitation and primary action.

Breakpoints follow content fit, not device-number presets. No fixed-height text container may clip localized or Dynamic-Type copy.

## Dynamic Type and long content

- Newsreader headings wrap before decorative art yields space.
- Body and interpretation copy uses system Dynamic Type and a readable measure.
- Fact rows may grow vertically; values do not truncate into ambiguity.
- Big Three cards stack when labels or reliability notes no longer fit side by side.
- A long placement name, translated sign, methodology label or unavailable reason remains reachable in full.
- Exact degree/coordinate values use tabular/monospaced digits only where alignment helps; they do not force a tiny type floor.

## VoiceOver alternative for natal wheel

The wheel is not the sole content representation. Accessibility order:

1. Chart title and tradition;
2. sample/production and basis disclosure;
3. wheel summary: number of available placements, time/place basis and whether houses are shown;
4. ordered placement list: body, sign, degree, house if valid, reliability and basis;
5. selected aspects with body pair, aspect type, orb if available and reliability;
6. route to Placement Detail.

Decorative orbit lines, background rings and illustrative marks are hidden from VoiceOver. If wheel selection is interactive later, each marker needs a native focus target plus an equivalent list route.

## Input and targets

- Native NavigationStack, Button, Link and scroll behavior remain preferred.
- Touch targets are at least 44 pt; nearby expanded hit areas must not overlap.
- Back, placement rows, access actions and “add time/place” actions are independently focusable.
- iPad pointer hover and keyboard focus apply to complete rows/cards, not only tiny glyphs.
- Color never carries the only meaning for selected placements, aspect types, reliability or access state; pair with labels, shape, text or outline.

## Motion, zoom and safe areas

- Reduce Motion removes wheel reveal/orbit motion and preserves a static chart/list.
- D4.1 does not require pinch-to-zoom. A later zoom decision must include reset, keyboard/pointer, reduced-motion and VoiceOver equivalents.
- Backgrounds may bleed under system areas; text, controls and bottom content stay inside safe areas.
- Loading uses stable placeholders; it does not animate a fake wheel or imply calculation progress beyond the real state.

## Light / Dark

Light: warm cream ground, soft off-white surfaces, quiet hairlines and deep ink.

Dark: midnight/navy ground, raised navy surfaces, warm text, controlled coral/lavender/gold/blue accents.

Aspect lines and degree marks need enough contrast without becoming laser-like. Increase Contrast strengthens borders, selection outlines and secondary grouping. The composition is authored separately for each appearance.
