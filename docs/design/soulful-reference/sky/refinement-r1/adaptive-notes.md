# Adaptive and Accessibility Notes

**Status:** APPROVED VISUAL REFERENCE — IMPLEMENTED AND RECONCILED

## Reference canvases

- iPhone: 430 × 932 pt portrait.
- iPad: 1024 × 1366 pt portrait.
- Dimensions communicate composition, not device-model branching.

## Compact width

Use one chronological scroll column. Keep 20 pt side gutters and reserve bottom content inset for the floating tab shell. Current Sky places the first event heading near the first third of the screen. Month exposes the selected-date heading under the grid. Week exposes the selected agenda immediately below the rail.

At narrow iPhone widths, reduce side gutters to 16 pt before changing type sizes. Date targets remain 44 pt; visible circles may remain smaller.

## Regular width

### Current Sky

Use two bounded regions. Left: concise hero, observation context, Calendar route. Right: `Happening now` followed by upcoming context. The hero does not grow vertically with the canvas.

### Month

Use a bounded grid/agenda split. The grid stays a civil utility surface; the agenda becomes a parallel detail region. Focus order remains header, range controls, grid dates in row-major order, then agenda.

### Week

Use one full-width rail followed by two regions: selected agenda and `Across the week`. The secondary chronology remains unboxed and concise.

## iPad landscape and Split View

- Center content inside a maximum width around 1120 pt.
- Add outer breathing room before scaling type, icons, radii, or cells.
- Month grid should not exceed a comfortable pointer-scanning width; agenda absorbs useful remaining width.
- Week rail remains a single seven-day row while each date target is at least 44 pt.
- Collapse to compact hierarchy when either region cannot preserve readable titles and metadata.
- Preserve selection and route state across size-class changes.

## Dynamic Type

- Newsreader editorial text maps to scaled semantic roles; maximum line counts are relaxed at accessibility sizes.
- Hero art yields space first: it narrows, moves behind a stricter clip, or moves below copy before any text reduction.
- Event rows reflow to title, timing, then methodology. Optional summary may move to a second line but cannot reserve an empty slot when absent.
- Month weekday labels may use localized narrow forms. Date hit areas stay 44 pt even if visible grid rows grow.
- Week rail can become horizontally scrollable only at accessibility sizes when seven 44 pt targets cannot fit. Default sizes remain a complete seven-day overview.
- Segmented control and Today action use native scaling behavior.

## VoiceOver examples

- Current event: `Waning gibbous Moon. Astronomical. Exact today at 18:00, Europe/Istanbul. Opens event detail.`
- Month date: `Thursday, 13 August 2026. Today. Button.`
- Selected event date: `Friday, 14 August 2026. Selected. 3 events. Button.`
- Week lunar date: `Wednesday, 12 August 2026. 1 lunar event. Button.`
- Disabled range action: `Previous month. Dimmed.`

## Input and focus

- Back, Today, segmented control, range controls, date cells, and event rows use full native targets.
- Month focus order is row-major civil order.
- Week focus order is chronological, then selected agenda, then secondary week context.
- iPad pointer hover and keyboard focus cover the full target, not only the visible number/disc.
- Standard swipe-back and native segmented-control behavior remain unchanged.

## Bottom-tab behavior

- The tab bar may visually float over the background only.
- Compact scroll containers receive a bottom content inset of at least 96 pt plus any unconsumed system safe-area inset.
- Agenda lists include an explicit end spacer or safe-area inset owned by the shell; nested screens must not double-apply it.
- Scroll-to-selection positions the selected agenda above the tab bar, not centered behind it.
- iPad top navigation has no floating bottom-tab overlap; bottom safe area still protects the home indicator.

## Contrast and motion

- Validate Light and Dark independently, including Increase Contrast.
- Today, selected, event-bearing, disabled, and outside-month states all have non-color cues.
- Reduce Motion replaces any future hero drift or selection animation with an immediate state change or brief opacity transition.
