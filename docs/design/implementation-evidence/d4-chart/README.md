# D4.1 Chart UI-first implementation evidence

**Status:** APPROVED VISUAL REFERENCE — IMPLEMENTED AND RECONCILED

D4.1 was approved as the first Chart UI slice. These screenshots are Debug builds using the deterministic `DevelopmentD4Sample`; they are not calculation, provider, entitlement or methodology evidence.

## Capture matrix

Captured on iOS 26.5 simulators:

- iPhone 17 Pro — 491D593D-23B0-4992-B995-568C8AEE5ECE
- iPad Pro 11-inch (M5) — 6F36DBA5-F778-4267-8B9D-F90B443675C4

Each primary state has Light/Dark coverage:

| State | iPhone Light | iPhone Dark | iPad Light | iPad Dark |
|---|---|---|---|---|
| Chart root / Free entry | [PNG](free-entry-iphone-light.png) | [PNG](free-entry-iphone-dark.png) | [PNG](free-entry-ipad-light.png) | [PNG](free-entry-ipad-dark.png) |
| Western loaded overview | [PNG](western-loaded-iphone-light.png) | [PNG](western-loaded-iphone-dark.png) | [PNG](western-loaded-ipad-light.png) | [PNG](western-loaded-ipad-dark.png) |
| Placement Detail — Moon in Libra | [PNG](placement-detail-iphone-light.png) | [PNG](placement-detail-iphone-dark.png) | [PNG](placement-detail-ipad-light.png) | [PNG](placement-detail-ipad-dark.png) |
| Unknown birth time | [PNG](unknown-time-iphone-light.png) | [PNG](unknown-time-iphone-dark.png) | [PNG](unknown-time-ipad-light.png) | [PNG](unknown-time-ipad-dark.png) |

Additional stress capture:

- [Dynamic Type accessibility-extra-extra-large — Free entry, iPhone Light](dynamic-type-large-iphone-light.png)

## Reconciliation notes

- Chart root stays inside the existing Today / Circle / Sky / Chart / Ask shell; no sixth root destination was added.
- Free entry uses authored abstract art labeled “Illustrative preview · not your chart”; it does not render a personalized wheel.
- Loaded Western uses typed `ChartWheelModel` placements/aspects/houses and a separate ordered placement route. The wheel is not the only representation.
- Loaded Debug sample routes show one quiet disclosure: “Development sample · not calculated”. Free Preview and Unknown Time remain product-facing surfaces without development notices.
- Known-time sample values are fixed presentation fixtures: Sun Aquarius 22° 11′, Moon Libra 14° 27′, Ascendant Gemini 03° 02′, Moon 5th house and Sun trine Moon.
- Unknown time keeps the supplied date fact, explicitly shows the missing time/place, withholds Ascendant/houses/cusps, and never supplies noon, midnight, sunrise or another guessed time.
- iPad regular width uses a bounded chart/detail composition; narrow content reflows toward one ordered column. Big Three cards do not rely on color alone and remain text-readable.
- Fact rows precede interpretation in Placement Detail. Degree values use the reserved technical typography role; sign names, body names, houses and prose use semantic Humay roles.
- Native navigation owns Back. Existing root-tab safe-area behavior remains the source of tab clearance; no arbitrary large bottom padding was added.

## Hardening / reconciliation note

- Free Preview copy now describes Chart, birth-data readiness and the precision more complete birth details can unlock; implementation status is not exposed in product UI.
- `-HumayD4Route` was removed. UI tests enter Chart, open Western Chart, open Moon Placement Detail and return through native navigation.
- Unknown Time splits the date-valid fact into normal sign/body text and technical degree text.
- `ChartDegreeFormatter` normalizes rounded arcminutes into `0°00′ ... 29°59′`, including boundary, negative and over-range inputs.
- Release-safe composition remains `Free Preview` with no `ChartPayload`; no sample placements, houses, interpretations or development disclosure cross into production.
- Canonical verification passes: `verify-foundation: OK`.

## Verification path

Debug launch fixtures:

```text
-HumayResetPersistence -HumayD2Demo -HumayD4Demo
-HumayD4ChartState free|loaded|unknown-time|loading|locked|available|cached|offline|offline-empty|unsupported|failed
```

Unit coverage lives in `HumayTests/D4FeatureModelTests.swift`. UI coverage lives in `HumayUITests/LaunchUITests.swift` and checks Free, real loaded navigation with Back, unknown-time withholding and typed state identifiers. Production completion remains blocked by `CHART-002`, `ASTRO-003`, access/cache/entitlement contracts and methodology gates.
