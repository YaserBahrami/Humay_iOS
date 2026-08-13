# SKY-004 — Calendar Month + Week implementation evidence

Status: implemented over the Debug-only `DevelopmentD3Sample`; production provider/cache pipeline remains `SKY-002`. Event Detail remains `SKY-005` and is intentionally not exposed.

## Authority and scope

- Visual authority: [`soulful-reference/sky/calendar/`](../../../soulful-reference/sky/calendar/README.md)
- Implementation: `Humay/Presentation/Sky/SkyCalendarView.swift` and `Humay/Presentation/Sky/SkyCalendarComponents.swift`
- Typed boundary: `Humay/Presentation/D3/D3FeatureState.swift`
- Deterministic sample: `Humay/Presentation/D3/DevelopmentD3Sample.swift`

Calendar stays nested under Sky. Month is a Monday-first 5/6-row civil grid with sparse event markers; Week is a contiguous seven-day rail with agenda/context. Range arrows remain visible but disabled because adjacent fixture payloads are not supplied.

## Actual simulator captures

Captured from XCTest attachments on iOS 26.5 simulators, portrait, with `-HumayD2Demo` and explicit Light/Dark appearance arguments. These are real app output, not reference exports.

| Device / appearance | Loaded | Quiet day | State board |
|---|---|---|---|
| iPhone 16 Pro / Light | [Month](iphone-light/month-loaded.png), [Week](iphone-light/week-loaded.png) | [quiet](iphone-light/quiet.png) | [states](iphone-light/) |
| iPhone 16 Pro / Dark | [Month](iphone-dark/month-loaded.png), [Week](iphone-dark/week-loaded.png) | [quiet](iphone-dark/quiet.png) | [states](iphone-dark/) |
| iPad Pro 11-inch / Light | [Month](ipad-light/month-loaded.png), [Week](ipad-light/week-loaded.png) | [quiet](ipad-light/quiet.png) | [states](ipad-light/) |
| iPad Pro 11-inch / Dark | [Month](ipad-dark/month-loaded.png), [Week](ipad-dark/week-loaded.png) | [quiet](ipad-dark/quiet.png) | [states](ipad-dark/) |

State board filenames: `loading.png`, `empty.png`, `unavailable.png`, `offline-cached.png`, `offline-no-cache.png`, and `failed.png`.

## Reconciliation notes

- Month initial selection is the supplied highest-density date, August 14, while Today is the deterministic August 13 sample date; both are distinct and accessible.
- Event rows show title, optional summary, centralized timezone-safe timing, and methodology. Date-only, exact, interval, and unavailable timing remain mutually exclusive.
- Quiet days are explicit agenda content, not empty/loading/unavailable states. Offline cached keeps civil dates and event metadata; offline no-cache is a distinct message.
- iPhone uses one reading column. iPad uses the approved overview/detail composition: Month grid or Week rail/context alongside the selected-date agenda.
- No Event Detail chevrons or dead-end route affordances are added. Event interpretation remains deferred to `SKY-005`.
- Release uses `D3FeatureInput.productionUnavailable`; the development sample and its deterministic date are DEBUG-only.

## Verification

- `HumayTests`: typed date/grid, deterministic sample composition, state semantics, and centralized timing formatter coverage.
- `HumayUITests`: nested navigation, selected-date persistence, quiet-day behavior, Month/Week state identifiers, cached offline content, and capture coverage.
- Captured devices: iPhone 16 Pro and iPad Pro 11-inch, iOS 26.5.
