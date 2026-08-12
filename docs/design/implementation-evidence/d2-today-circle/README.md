# D2 Today + Circle Implementation Evidence

Captured on **2026-08-12** from the production SwiftUI hierarchy with the Debug-only `DevelopmentD2Sample` composition. These are simulator screenshots, not mockups and not calculated astrology results.

## Devices

- iPhone 17 Pro, iOS 26.5: portrait, Light and Dark.
- iPad Pro 13-inch (M5, 16 GB), iOS 26.5: portrait, Light and Dark.
- The same iPad simulator exercised landscape in Light and Dark.

## Captured states

- Today: loaded development sample with greeting, Cosmic Weather, Love/Career/Money and Roast Mode.
- Daily Horoscope: Free Leo Sun-sign reading with Today/Tomorrow/This Week selection and the inert precise-access presentation.
- Circle: loaded with two development people and the compatibility entry.
- Compatibility: precise presentation sample with two people, score, four metrics and Our Take. The screen explicitly states that no provider calculation or synastry generation occurred.

## Portrait screenshots

Each image is a kept `XCTAttachment` from `LaunchUITests.testCaptureD2Evidence`.

| Device | Appearance | Today | Daily Horoscope | Circle | Compatibility |
| --- | --- | --- | --- | --- | --- |
| iPhone | Light | [image](screenshots/iphone-light-today.png) | [image](screenshots/iphone-light-daily-horoscope.png) | [image](screenshots/iphone-light-circle.png) | [image](screenshots/iphone-light-compatibility.png) |
| iPhone | Dark | [image](screenshots/iphone-dark-today.png) | [image](screenshots/iphone-dark-daily-horoscope.png) | [image](screenshots/iphone-dark-circle.png) | [image](screenshots/iphone-dark-compatibility.png) |
| iPad portrait | Light | [image](screenshots/ipad-light-today.png) | [image](screenshots/ipad-light-daily-horoscope.png) | [image](screenshots/ipad-light-circle.png) | [image](screenshots/ipad-light-compatibility.png) |
| iPad portrait | Dark | [image](screenshots/ipad-dark-today.png) | [image](screenshots/ipad-dark-daily-horoscope.png) | [image](screenshots/ipad-dark-circle.png) | [image](screenshots/ipad-dark-compatibility.png) |

## Adaptive behavior

- iPhone keeps a portrait-first, single-column reading flow with the native bottom tab presentation.
- Regular-width iPad uses two regions for Today, Circle and Compatibility instead of stretching the phone column.
- Daily Horoscope remains centered at a bounded reading width.
- `TabView` uses the native adaptive tab/sidebar behavior while preserving Today / Circle / Sky / Chart / Ask ownership.
- Width-driven breakpoints collapse naturally toward the compact hierarchy; no `UIDevice` check controls layout.
- The landscape UI test selects Circle through the native sidebar cell, opens Compatibility and verifies both two-region screens in Light and Dark.

## Landscape capture limitation

`LaunchUITests.testCaptureD2LandscapeEvidence` passes on the iPad simulator in Light and Dark. iOS 26.5 nevertheless exports the landscape framebuffer rotated and cropped. The untouched attachments are retained under [`raw-simulator-artifacts/`](raw-simulator-artifacts/) as diagnostic evidence, with `raw-xctest` in every filename; they are not presented as valid pixel-reconciliation screenshots.

This is a simulator evidence limitation, not an app bootstrap or UI-test failure. No production behavior was changed to hide it.

## Known visual discrepancies

- The approved composites use portrait photography. No approved, licensed portrait asset was supplied for production, so D2 uses accessible native person medallions and initials.
- The artwork refresh retired the two sample portrait assets above and replaced separate roast-fire/roast-planet assets with one approved `IllustrationRoastMode`; the former 19-asset test count was therefore obsolete.
- Celestial art is implemented as lightweight native vector/SF Symbol composition rather than copying raster art from the reference composites.
- The shipping shell uses the task-authoritative Today / Circle / Sky / Chart / Ask IA and iOS 26 native adaptive tabs; the older labels and custom tab treatment visible in the composites are not reproduced.
- Free/precise and development-sample disclosures add vertical content absent from parts of the visual composites. They are required to avoid presenting sample astrology as calculated truth.
- Static approved D2 iPad mockups were not present. The iPad implementation follows the written adaptive authority and is evidenced here, but pixel-perfect iPad reconciliation is not claimed.

## Verification

- `bash Scripts/verify-foundation.sh`: passed.
- Debug build: iPhone 17 Pro and iPad Pro 13-inch simulators passed.
- Release simulator build passed; the executable contains no `DevelopmentD2Sample` symbol or sample astrology payload strings.
- Swift Testing: 69 tests in 10 suites passed.
- HumayUITests: 9/9 passed on iPhone and 9/9 passed on iPad.
- D2 navigation passed at `accessibility-extra-extra-extra-large` content size on iPhone.
