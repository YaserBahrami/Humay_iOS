# D1 Onboarding Evidence

Captured 2026-08-12 from the production SwiftUI onboarding flow.

## Devices

- iPhone 17 Pro, iOS 26.5: Light and Dark.
- iPad Pro 11-inch (M5), iOS 26.5: Light and Dark, portrait.

## Screenshots

Each image is a kept `XCTAttachment` from `LaunchUITests.testCaptureOnboardingEvidence`, not a mockup.

| Device | Appearance | Welcome | Birth date | Tradition | Profile reveal |
| --- | --- | --- | --- | --- | --- |
| iPhone | Light | [image](screenshots/iphone-light-welcome.png) | [image](screenshots/iphone-light-birth-date.png) | [image](screenshots/iphone-light-tradition.png) | [image](screenshots/iphone-light-profile-reveal.png) |
| iPhone | Dark | [image](screenshots/iphone-dark-welcome.png) | [image](screenshots/iphone-dark-birth-date.png) | [image](screenshots/iphone-dark-tradition.png) | [image](screenshots/iphone-dark-profile-reveal.png) |
| iPad portrait | Light | [image](screenshots/ipad-light-welcome.png) | [image](screenshots/ipad-light-birth-date.png) | [image](screenshots/ipad-light-tradition.png) | [image](screenshots/ipad-light-profile-reveal.png) |
| iPad portrait | Dark | [image](screenshots/ipad-dark-welcome.png) | [image](screenshots/ipad-dark-birth-date.png) | [image](screenshots/ipad-dark-tradition.png) | [image](screenshots/ipad-dark-profile-reveal.png) |

The picker starts at the current valid date (`12 August 2026` in this capture), not a hard-coded sample date. Profile Reveal shows only the entered date, selected tradition, and optional-precision statement.

## Manual checks

- Large Dynamic Type (`accessibility-extra-extra-extra-large`) was inspected on iPhone; screens reflow into the existing scroll container and remain horizontally readable.
- Light and Dark surfaces, selected-state affordances, native date picker, back navigation, and completion were visually inspected.

## Landscape note

`testCaptureOnboardingLandscapeEvidence` passes on the iPad simulator and exercises the geometry-based two-region layouts. Landscape screenshots are intentionally not committed: iOS 26.5 simulator/XCTest screenshot export produced a 90°-rotated framebuffer with a black band, so the output was not reliable evidence. No rotated artifact is presented as a valid landscape screenshot.

