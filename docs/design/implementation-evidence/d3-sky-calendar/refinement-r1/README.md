# D3 Sky + Calendar Visual Refinement R1 implementation evidence

**Status:** implemented and visually reconciled  
**Starting HEAD:** `add3e298437d8f4bdeb75079ab20f9bec7c6b0cd`  
**Branch:** `feature/foundation-clean-architecture`  
**Captured:** 2026-08-13 from production SwiftUI with the Debug-only deterministic D3 sample

The screenshots are XCTest attachments captured on iOS 26.5 simulators. Light and Dark were set through simulator appearance state, not post-processed. The accessibility capture uses the simulator `accessibility-large` content-size category.

## Current Sky

| Device | Light | Dark |
|---|---|---|
| iPhone 17 Pro | [image](current-sky/iphone-light.png) | [image](current-sky/iphone-dark.png) |
| iPad Pro 13-inch | [image](current-sky/ipad-light.png) | [image](current-sky/ipad-dark.png) |

## Calendar Month

| Device | Light | Dark |
|---|---|---|
| iPhone 17 Pro | [image](month/iphone-light.png) | [image](month/iphone-dark.png) |
| iPad Pro 13-inch | [image](month/ipad-light.png) | [image](month/ipad-dark.png) |

The iPhone captures also establish the first-fold result: the selected-date heading and initial agenda content are visible directly below the compact six-row civil grid.

## Calendar Week

| Device | Light | Dark |
|---|---|---|
| iPhone 17 Pro | [image](week/iphone-light.png) | [image](week/iphone-dark.png) |
| iPad Pro 13-inch | [image](week/ipad-light.png) | [image](week/ipad-dark.png) |

The iPhone captures establish the compact seven-day rail and intentionally omit the large `Across the week` region. The iPad captures retain it as an unboxed contextual column.

## Additional runtime evidence

- [Accessibility Large Current Sky](additional/iphone-ax-current-sky.png): editorial text and event rows expand; decorative hero art yields; content remains scrollable without clipped text.
- [Bottom-tab clearance](additional/iphone-bottom-tab-clearance.png): the final coming-up rows finish above the floating root tab surface.

## Visual reconciliation

- Current Sky uses the approved Light/Dark `IllustrationCurrentSky` authored SVG instead of procedural SwiftUI art.
- The compact hero brings `Happening now` materially earlier in the initial iPhone viewport.
- Month removes permanent label/marker/Today slots and uses one quiet grid with 44 pt compact interaction rows.
- Week replaces tall capsules with compact selected/Today discs while retaining 44 pt targets.
- Newsreader carries editorial roles; system typography carries event titles, timing, controls, and dates; ordinary timing uses monospaced digits without SF Mono.
- Dark remains a layered midnight/navy composition rather than black.

`SKY-002` provider/backend/cache work and `SKY-005` Event Detail remain deferred and are not represented by this evidence.
