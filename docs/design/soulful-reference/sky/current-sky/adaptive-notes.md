# Current Sky adaptive-layout notes

**Status:** REVIEW CANDIDATE — NOT APPROVED

## Reference canvases

- iPhone: 430 × 932 pt portrait, matching a current large iPhone class while retaining a compact single-column rhythm.
- iPad: 1024 × 1366 pt portrait, using a real two-region layout rather than enlarging the phone screen.
- The reference widths describe composition, not hardcoded production device checks.

## Width behavior

### Compact width

Use one scroll column with 20–24 pt side margins and this order:

1. Sky header and profile/settings entry
2. development-sample disclosure in Debug only
3. current celestial hero, with one concise observation treatment when factual context is relevant
4. Happening now
5. Calendar entry
6. Coming up

The phone reference keeps all major regions discoverable in one viewport while showing useful event content immediately after the hero. Observation data is not repeated elsewhere in the composition. The bottom navigation remains the existing native five-destination shell.

### Regular width

At roughly 820 pt of usable width and above, use a bounded two-region composition:

- primary/left: hero, one-line observation footer, then Calendar entry;
- secondary/right: Happening now, then Coming up timeline.

The 1024 pt reference uses a 928 pt content area: a 454 pt primary region, 32 pt gap, and 442 pt secondary region. Long-form text remains bounded. Body type, corner radii, event glyphs, and controls do not scale in proportion to the canvas.

### iPad landscape

- Center the two-region content within a maximum width near 1120 pt.
- Keep the primary region near 46% and the secondary region near 54%; add outer margin before enlarging either column.
- Allow the hero art to breathe horizontally, but do not increase its height beyond the content need.
- Keep the quiet observation footer and Calendar below the hero, with the event timeline beside them. Do not introduce a third feed column.
- Preserve the native adaptive top tab/sidebar presentation and existing Sky route ownership.

### Split View and narrow iPad windows

When the two bounded regions cannot preserve readable event rows, collapse to the compact order. Use available width or size class, not an iPad model check. The collapse must preserve scroll position and route state when feasible.

## Dynamic Type pressure

- Hero copy may grow to three lines. Art moves behind a stricter clipping region or below the copy before text is reduced.
- Event rows expand vertically. Order becomes glyph, title, optional summary, timing, then methodology. Critical timing never truncates.
- A long methodology label moves to its own line; it does not squeeze the event title.
- Calendar copy wraps above its disclosure indicator. The complete row remains a minimum 44 pt target.
- Observation metadata may wrap to two concise lines. Its field order is timezone, supplied location, then observed/freshness time; absent values are omitted. A second line may explain date-only timing only when the visible content needs that clarification. It never becomes a separate card or repeats metadata already presented with the hero.
- At accessibility sizes, the two-region iPad composition may collapse even when the geometric width is regular.
- Decorative art and sparse sparkles may be hidden before factual text is compressed.

## Interaction and focus

- Each event row is one native navigation target; the small chevron is decorative. The row height supplies at least a 44 × 44 pt target.
- Calendar is one native navigation target with a visible disclosure affordance.
- iPad pointer hover/focus should apply to the complete event or Calendar row, not only the icon.
- Keyboard order follows the semantic reading order below. Standard Return/Space activation remains available through native controls.

## VoiceOver order

Compact order follows the single visual column:

1. Sky heading
2. Profile and settings
3. Debug disclosure when present
4. Hero headline and factual observation context
5. Happening now heading and event rows
6. Calendar entry
7. Coming up heading and timeline entries

Regular-width order finishes the primary/left region before the secondary/right region: Sky heading, Profile and settings, Debug disclosure, hero headline, observation footer, Calendar, Happening now, then Coming up. This order remains stable for keyboard focus as well as VoiceOver.

Decorative lunar-orbit art is hidden. Event glyph labels are supplied through their parent rows, for example “Waning gibbous Moon, Astronomical, exact, today at 18:00 TRT.” The interval example reads “Mercury square Uranus, Western. From Friday at 21:00 until Saturday at 03:00.”

## Safe areas and motion

- Background may extend under system areas; headings, profile, tabs, and scroll content do not.
- The phone tab bar reserves the home-indicator inset and never obscures the last event after scroll-content padding.
- A future slow orbit or sparkle entrance is optional. With Reduce Motion, show the final static art with no replacement animation.
