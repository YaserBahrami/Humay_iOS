# SKY-005 — Event Detail implementation evidence

Status: implemented and reconciled over the Debug-only `DevelopmentD3Sample`; production provider/cache pipeline remains `SKY-002`.

## Authority

- Approved reference: [`docs/design/soulful-reference/sky/event-detail/`](../../../soulful-reference/sky/event-detail/README.md)
- R1 supersession: Newsreader owns editorial/display UI; SF Pro/system owns body, controls, dates and times; Cormorant remains wordmark-only.
- Implementation: `Humay/Presentation/Sky/SkyEventDetailView.swift`
- Route state: `Humay/Presentation/D3/D3FeatureState.swift` and `D3FeatureInput.eventDetailState(for:)`
- Fixtures: `Humay/Presentation/D3/DevelopmentD3Sample.swift` (DEBUG-only, unverified)

## Capture matrix

Captures are actual app output from the Debug simulator UI-test evidence flow, not reference exports. Device model, OS, appearance, state, and route origin are recorded in each filename and in the reconciliation notes below.

Capture runs: iPhone 17 Pro (`491D593D-23B0-4992-B995-568C8AEE5ECE`) and iPad Pro 11-inch (M5, `6F36DBA5-F778-4267-8B9D-F90B443675C4`), iOS 26.5, portrait. The Light/Dark runs explicitly set simulator appearance before launch.

| State / flow | iPhone Light | iPhone Dark | iPad Light | iPad Dark |
|---|---|---|---|---|
| Loaded — Current Sky origin | [capture](iphone-light/loaded-current-sky.png) | [capture](iphone-dark/loaded-current-sky.png) | [capture](ipad-light/loaded-current-sky.png) | [capture](ipad-dark/loaded-current-sky.png) |
| Loaded — Calendar origin | [capture](iphone-light/loaded-calendar.png) | [capture](iphone-dark/loaded-calendar.png) | [capture](ipad-light/loaded-calendar.png) | [capture](ipad-dark/loaded-calendar.png) |
| Loading | [capture](iphone-light/loading.png) | [capture](iphone-dark/loading.png) | [capture](ipad-light/loading.png) | [capture](ipad-dark/loading.png) |
| Unavailable | [capture](iphone-light/unavailable.png) | [capture](iphone-dark/unavailable.png) | [capture](ipad-light/unavailable.png) | [capture](ipad-dark/unavailable.png) |
| Offline cached | [capture](iphone-light/offline-cached.png) | [capture](iphone-dark/offline-cached.png) | [capture](ipad-light/offline-cached.png) | [capture](ipad-dark/offline-cached.png) |
| Offline no cache | [capture](iphone-light/offline-no-cache.png) | [capture](iphone-dark/offline-no-cache.png) | [capture](ipad-light/offline-no-cache.png) | [capture](ipad-dark/offline-no-cache.png) |
| Failed | [capture](iphone-light/failed.png) | [capture](iphone-dark/failed.png) | [capture](ipad-light/failed.png) | [capture](ipad-dark/failed.png) |
| Event not found | [capture](iphone-light/event-not-found.png) | [capture](iphone-dark/event-not-found.png) | [capture](ipad-light/event-not-found.png) | [capture](ipad-dark/event-not-found.png) |
| Long-title stress | [capture](iphone-light/long-title.png) | [capture](iphone-dark/long-title.png) | [capture](ipad-light/long-title.png) | [capture](ipad-dark/long-title.png) |

## Reconciliation

- iPhone keeps the nested Sky root shell and native origin-aware Back behavior. Identity, timing, meaning, and factual rows reach the first useful viewport without a giant hero.
- iPad uses bounded identity/meaning and facts/basis regions at regular width; accessibility-size and narrow-window pressure collapse to one reading column.
- Light/Dark use existing Humay ground, surface, hairline, and accent tokens. The small event glyph is semantic decoration and hidden from VoiceOver.
- `SkyEventTimingFormatter` remains the only timing formatter. The supplied `SkyObservationContext` controls timezone formatting; no location is fabricated.
- Meaning and astrological basis remain separate optional regions. Factual rows use only Domain-supplied event type, system, timing, relevance, and reliability.
- Loading has no fake title or facts. Unavailable, event-not-found, offline cached, offline no-cache, and failed states have distinct user-facing copy and no unsupported Retry action.
- Current Sky, Calendar Month, and Calendar Week rows use native `NavigationLink`. Calendar selection and mode remain local to the existing Calendar route when Back returns.
- The iPad captures show the bounded two-region layout; iPhone captures show the compact single-column layout. Long-title captures use the Mars ingress sample and retain readable wrapping.

## Verification

- Swift Testing covers detail fixtures and Presentation label formatters.
- XCUITest covers Current Sky → loaded detail → Back, Calendar Month/Week → detail → Back, selection/mode preservation, all typed detail states, iPhone, and iPad execution.
- Typography guard: `Scripts/verify-typography.sh`.
- Canonical repository checks: `Scripts/verify-foundation.sh`, layering, nomenclature, diagnostics, and whitespace.

`SKY-002` remains pending. `SKY-006` remains pending. No provider, backend, cache, persistence, Chart, or Ask work is included.
