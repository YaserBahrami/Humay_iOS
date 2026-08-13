# Compatibility Refresh Implementation Evidence

Captured on **2026-08-13** from final production SwiftUI code using Debug-only deterministic D2 sample content. References: [`../../../soulful-reference/today-circle/compatibility-refresh/`](../../../soulful-reference/today-circle/compatibility-refresh/README.md).

## Devices and appearances

- iPhone 17 Pro, iOS 26.5, portrait, Light and Dark.
- iPad Pro 13-inch (M5, 16 GB), iOS 26.5, portrait, Light and Dark.
- Selection and result are separate kept XCUITest attachments for each device/appearance combination.

## Actual simulator screenshots

| Device | Appearance | Selection | Compatibility result |
| --- | --- | --- | --- |
| iPhone 17 Pro | Light | [image](screenshots/iphone-light-selection.png) | [image](screenshots/iphone-light-result.png) |
| iPhone 17 Pro | Dark | [image](screenshots/iphone-dark-selection.png) | [image](screenshots/iphone-dark-result.png) |
| iPad Pro 13-inch | Light | [image](screenshots/ipad-light-selection.png) | [image](screenshots/ipad-light-result.png) |
| iPad Pro 13-inch | Dark | [image](screenshots/ipad-dark-selection.png) | [image](screenshots/ipad-dark-result.png) |

## Reconciliation result

### Selection

- Removed compact `GridItem(.adaptive(minimum: 170))`. iPhone now uses full-width one-column rows; iPad uses bounded pair-context and people-list regions.
- Names and signs own flexible leading width before the fixed check control. Names/signs may wrap by word to two lines; normal words no longer fragment vertically.
- Added explicit 0/1/2 Pair Composer slots, restrained vector orbit/heart connector, redundant selected count/check state and deterministic ordered selection capped at two.
- Added safe-area iPhone action tray. Disabled copy changes for 0/1 selection; final rows remain scroll-reachable above native tab/home safe areas. iPad action remains inside pair-context region.

### Result

- Replaced separate basis, pair header, score and summary with one tonal Relationship Field.
- Pair title owns full width. Connected medallions/signs and score/label/summary share the same field; iPad splits identity/result within that single field.
- Connector uses SwiftUI `Shape`, gradient stroke, endpoints and a small heart. It is decorative and accessibility-hidden.
- Free disclosure remains `Free · Sun-sign pair` and explicitly says `not natal synastry`. Precise state remains labeled as development-only, without provider calculation or synastry generation.

### Visual corrections made after simulator comparison

- Reduced compact selection title from hero scale to editorial scale so it matches the approved one-line iPhone hierarchy.
- Removed a parent accessibility identifier that masked `compatibility.score` and basis identifiers in the rendered accessibility tree.
- Applied the approved lavender/coral/gold relationship gradient to score in both appearances.
- Reflowed composer and saved-list headers at accessibility Dynamic Type sizes. People rows use a 96 pt default height that scales from the body text metric, preventing iPad stretch while preserving room at every Dynamic Type size.
- Kept people rows eagerly present in the accessibility hierarchy after an AX XXXL simulator run exposed lazy-row discovery failure.

## Accessibility verification

- Full-row buttons exceed 44 pt and expose selected/unselected values and add/remove hints.
- Pair Composer provides one concise pair summary in correct reading order.
- Selection uses checkmarks, copy and border weight in addition to color.
- Decorative orbit, heart and endpoint nodes are hidden from accessibility.
- Semantic text styles and custom relative fonts scale with Dynamic Type. `accessibility-extra-extra-extra-large` Compatibility flow passed on iPhone.
- Native buttons provide keyboard/pointer focus and activation on iPad; no looping motion was added, so Reduce Motion needs no alternate animation.

## Scope notes

- Metrics, Our Take, precise-access, cached, offline and failure behavior remain existing lower-result content.
- Existing plain-text `ShareLink` remains functional and intentionally unpolished.
- Branded visual share-card work remains deferred to D8 / Phase 10.
