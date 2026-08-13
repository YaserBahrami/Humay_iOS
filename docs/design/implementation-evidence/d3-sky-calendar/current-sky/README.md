# SKY-003 — Current Sky implementation evidence

Status: implemented over the Debug-only `DevelopmentD3Sample`; production data pipeline remains `SKY-002`.

## Authority and scope

- Visual authority: [`soulful-reference/sky/current-sky/`](../../../soulful-reference/sky/current-sky/README.md)
- Implemented surface: `Humay/Presentation/Sky/CurrentSkyView.swift`
- App boundary: `Humay/App/AppFeatureComposition.swift`
- Deterministic sample: `Humay/Presentation/D3/DevelopmentD3Sample.swift`
- Calendar and Event Detail remain gated. The Calendar entry is intentionally disabled until `SKY-004`; no Event Detail route was added.

## Actual simulator captures

Captured from XCTest attachments on iOS 26.5 simulators, portrait, using `-HumayD2Demo` plus the D3 state launch arguments. Captures are real app output, not reference exports.

### Loaded/default

| Device / appearance | Evidence |
|---|---|
| iPhone 17 Pro / Light | [loaded](iphone/loaded-light.png) |
| iPhone 17 Pro / Dark | [loaded](iphone/loaded-dark.png) |
| iPad Pro 11-inch / Light | [loaded](ipad-light/loaded-light.png) |
| iPad Pro 11-inch / Dark | [loaded](ipad-dark/loaded-dark.png) |

### State coverage

The iPhone capture set includes loading, empty, unavailable, offline with cached content, offline without cached content, and failed/error. The iPad capture sets include the same state board for adaptive review. `loaded-light.png` and `loaded-dark.png` are captured from separate simulator appearance runs; each device directory's remaining state captures use that directory's recorded appearance.

- [iPhone state captures](iphone/)
- [iPad Light state captures](ipad-light/)
- [iPad Dark state captures](ipad-dark/)

## Reconciliation notes

- iPhone uses one reading column: header → Debug disclosure → restrained orbital hero → current events → Calendar gate → upcoming timeline.
- iPad uses an intentional two-region composition at wide width: bounded hero/observation/Calendar context on the left and current/upcoming event scanning on the right. Compact widths collapse through the same SwiftUI content into the iPhone hierarchy.
- Light mode uses the approved warm cream / dark ink treatment; Dark mode uses midnight/navy surfaces with warm readable text and tonal elevation.
- Timing remains data-driven: exact instant, natural interval range, date-only, and explicit unavailable states are rendered from `SkyEventTiming` and the supplied `SkyObservationContext` timezone. Device timezone is not consulted.
- Methodology remains explicit and centralized: Astronomical, Western, Vedic, and future tradition labels do not collapse into one astrology vocabulary.
- The hero headline remains restrained editorial chrome because the Domain contract does not provide an approved editorial-hero field. It does not assert a calculated interpretation.
- Decorative orbital art is SwiftUI-only, hidden from VoiceOver, and kept subordinate to supplied event facts. The Calendar asset is displayed as a disabled future-route gate; it is not a Calendar implementation.
- `Development sample · not calculated` is Debug-only. Release composition supplies unavailable D3 input and excludes development sample types.

## Verification

- `HumayTests`: formatter, state, methodology, timezone, composition-boundary coverage.
- `HumayUITests`: loaded hierarchy, distinct state identifiers, cached offline content, and evidence capture.
- Captured devices: iPhone 17 Pro (`491D593D-23B0-4992-B995-568C8AEE5ECE`) and iPad Pro 11-inch (`6F36DBA5-F778-4267-8B9D-F90B443675C4`), iOS 26.5.
