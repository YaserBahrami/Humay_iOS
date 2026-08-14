# Sky + Calendar Refinement R1 Design Specification

**Status:** APPROVED VISUAL REFERENCE — IMPLEMENTED AND RECONCILED  
**Direction:** Soulful Celestial, compact editorial utility  
**Platforms:** iPhone/iPad, Light/Dark

## 1. Design intent

Increase useful information per first screen while retaining one memorable celestial moment. The visual hierarchy should feel warm, premium, alive, slightly playful, and native to Apple platforms. Astrology styling remains secondary to legibility and civil-date utility.

## 2. Current Sky

### Compact hierarchy

1. Native Sky header.
2. Quiet Debug-only disclosure.
3. 132 pt hero.
4. `Happening now` heading.
5. Compact event surface with 60–66 pt rows.
6. Calendar route.
7. Coming-up content.
8. 96 pt bottom clearance.

### Hero

- Approved name: **Lunar Compass**.
- Editorial title: two lines maximum at default Dynamic Type.
- Supporting context: system and location on one concise line.
- Observation time uses SF Pro with monospaced digits, not SF Mono.
- Hero art is a standalone Light/Dark SVG asset, clipped by the hero surface rather than procedurally drawn at runtime.
- Target compact height: 132 pt; regular-width primary card: 228–244 pt.
- Debug disclosure is a quiet 22 pt text row, not a large filled pill.

### Illustration asset

- Shipping asset: `IllustrationCurrentSky` with separate Light and Dark artwork.
- Visual idea: a crescent crossing a tilted meridian window, with one coral compass star, a gold horizon, and a sparse lavender trail.
- Meaning: symbolic current-sky identity only; no factual planetary position.
- Medium: flat vector, simple fills, thin curves, no 3D, watercolor, neon galaxy, procedural SwiftUI orbit, or face.
- Decorative accessibility: hidden when the hero title and context already convey all information.

## 3. Event density

- One shared surface contains related events.
- Full row remains a 44 pt minimum disclosure target.
- Default row height: 60 pt; long-title row: 66 pt; accessibility sizes expand vertically.
- Event glyph: 28 pt tinted circle, optically centered.
- Title: SF Pro/system, semibold, 15 pt reference size.
- Summary: optional; omit its slot when absent.
- Timing: SF Pro/system with monospaced digits only.
- Methodology: inline text with a small semantic marker; no permanent capsule unless reliability needs explicit emphasis.
- Hairline separators replace card-per-event stacking.

## 4. Calendar chrome

- Back and Today each retain at least a 44 × 44 pt target.
- Today is a text action with a quiet bounded target, not an oversized pill.
- Month/Week uses one native-height segmented control.
- Month/week range title and previous/next controls share one row.
- `Week begins Monday` is secondary metadata beside or below the range, never a major heading.
- Disabled range controls use lower contrast plus disabled semantics; opacity alone is not the accessibility label.

## 5. Month grid

- Seven columns, Monday-first.
- Weekday header: 28–32 pt visual band.
- Six date rows: 44 pt each on compact width; 48–52 pt at regular width.
- Each date has a 44 × 44 pt hit target even when the visible state is 30–34 pt.
- No day cards and no permanent empty vertical event slot.
- Normal: number only.
- Today: 30 pt coral outline plus a 4 pt top tick; accessibility value includes `Today`.
- Selected: 30 pt filled circle; accessibility value includes `Selected`.
- Today + selected: one filled circle plus top tick and `Today` accessibility value.
- Event-bearing: one 4 pt dot, lunar glyph, or dot + count beneath/adjacent without increasing row height.
- Outside month: lower-emphasis number; boundary month label appears once per boundary, not in every cell.
- Selected-date agenda begins immediately after the grid; on iPhone its heading is visible in the first screenful.

## 6. Week rail

- Seven equal date targets in one quiet shared surface.
- Compact visual height: 60 pt; hit areas remain at least 44 pt.
- Weekday: 10–11 pt uppercase/system label.
- Date: 19–21 pt semibold/system number.
- Event: 4 pt dot, lunar crescent, or dot + count.
- Today: coral top tick plus outline and concise `TODAY` metadata outside the number.
- Selected: 38–42 pt filled rounded disc, not a tall capsule.
- Today + selected: selected fill plus top tick and spoken Today state.
- iPhone omits the large `Across the week` panel; later-week context becomes at most two compact signals after the selected agenda.
- iPad retains `Across the week` as an unboxed secondary column because width supports overview without added vertical cost.

## 7. Typography roles

| Role | Family | Reference treatment |
|---|---|---|
| Humay wordmark | Cormorant Garamond | Approved exception for the brand wordmark. |
| Editorial display | Newsreader | Approved expressive family; variable weight and optical-size axes are available in the shipping font. |
| Body, navigation, event titles | SF Pro/system | Semantic styles and Dynamic Type. |
| Dates and times | SF Pro/system | Monospaced digits only. |
| Degrees/coordinates | SF Mono | Reserved for genuinely technical chart values. |

Newsreader uses fewer oversized sizes than the previous system: 28 pt editorial titles and a 40 pt hero role, scaled relative to semantic Dynamic Type styles. Runtime registration uses the verified PostScript name `Newsreader16pt-Regular` and the real variable weight axis.

## 8. Color and surfaces

Use existing Soulful Celestial semantic colors. Light uses warm cream ground and subtle hairlines; Dark uses deliberate navy tonal elevation. Coral identifies selection/current emphasis; gold marks lunar context; lavender and blue remain sparse secondary accents. Meaning never depends on color alone.

## 9. Safe area and tab clearance

- Floating tab-bar reference frame: approximately 76 pt high on iPhone.
- Scroll content bottom inset: tab-bar height + 20 pt breathing room + system safe-area contribution.
- Candidate minimum content clearance above the viewport bottom: 96 pt, with runtime safe-area addition where the shell does not already provide it.
- No event row, heading, or actionable control may finish behind the tab surface.
- Background may extend under the tab bar; readable or interactive content may not.

## 10. Accessibility contract

- All controls and date cells retain 44 pt minimum targets.
- VoiceOver combines glyph, title, timing, methodology, Today, selected, and event-count states into one coherent label/value.
- Decorative hero art is hidden from accessibility.
- Date traversal remains civil row-major order in Month and chronological order in Week.
- Dynamic Type expands rows and can move metadata below titles; text is never shrunk below semantic comfort.
- Contrast targets: 4.5:1 normal text, 3:1 large text and meaningful graphics.
- Reduce Motion removes any future drift/sparkle animation; static composition remains complete.

## 11. Implementation / accessibility verification

Production reconciliation must verify 44 pt targets, Dynamic Type through accessibility sizes, VoiceOver labels and order, Light and Dark appearances, Increase Contrast, Differentiate Without Color, pointer and keyboard behavior on iPad, Reduce Motion, safe areas, and floating-tab clearance at runtime. Static references establish intent but do not replace simulator and Accessibility Inspector verification.
