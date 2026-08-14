# D4.1 Chart review and contract notes

**Status:** REVIEW CANDIDATE — NOT APPROVED

## CHART-001 findings

### Existing foundation is usable

- `AstrologyCalculationAdapter` already keeps Western, Vedic and BaZi boundaries provider-independent.
- `BirthCalculationInput` wraps existing `BirthDetails`; it preserves `.unknown` time and `.notProvided` place.
- `AstrologyFactReliability` gives Presentation a typed reliable/uncertain/unavailable basis.
- `AstrologyFactUnavailability` already names missing time, missing place, insufficient precision, methodology not approved and unsupported calculation boundary.
- `AstrologyCalculationProvenance` carries Humay contract, methodology, adapter, engine and configuration versions.
- `WesternAstrologyFact` currently contains planetary positions and aspects without prematurely freezing houses/Ascendant while `METHOD-001` remains open.

### Minimum future presentation contract

Keep a Chart state envelope independent from calculation/provider DTOs. It needs:

- route/tradition/profile context;
- explicit source disclosure: production, cached, offline cached or Debug-only sample;
- birth-data readiness: date, time precision, place;
- fact-level reliability and required-input basis;
- access presentation separate from calculation truth;
- calculated/cached artifact identity and freshness where applicable;
- interpretation sections that reference supplied facts rather than inventing them;
- Humay-owned failure/recovery categories.

Recommended state names are documented in [design-spec.md](design-spec.md): loading, free preview, precision locked, generation available, loaded, cached, offline cached, offline no cache, unsupported methodology, insufficient birth precision and failed.

Do not introduce a universal Western-shaped `Chart` payload, vendor DTOs, a fake exact birth time, a generic confidence score or production state code in D4.1.

## Phase 04 dependency recommendation

Keep the current `CHART-005` dependency on `CHART-002` and the approved D4 package as the production completion gate. Do not mark `CHART-002` done or weaken its calculation requirement.

Recommend a small wording clarification in Phase 04/roadmap:

> Approved D4 references plus explicit Humay-owned, Debug-only sample facts may unblock a UI-first Presentation slice after CHART-001 contract review. Production/provider-backed Chart completion remains blocked by CHART-002/ASTRO-003, access/cache contracts and applicable methodology gates.

This distinguishes:

- **UI-first preparation:** approved references rendered against typed, clearly marked sample facts;
- **production Chart:** validated calculation, provenance, cache/access behavior, methodology and provider-backed output.

The recommendation does not change task ownership, close a dependency or authorize a production Chart implementation in this pass.

## Access-state review

The visual package treats these as separate concepts:

- Free preview explains value and readiness without a natal calculation;
- precision locked explains future Rewarded/Premium access without making Chart a paywall;
- generation available represents a future access action, not a completed calculation;
- loaded/cached states disclose basis and provenance;
- offline cached reopens an already-authorized result;
- offline no-cache never queues or silently triggers paid generation;
- provider failure after access remains a later fair/idempotent recovery contract.

## Unknown-time review

Unknown time is visible in the first useful viewport. The package never substitutes noon, midnight, sunrise or a hidden default. It shows date-valid facts only when methodology supports them, withholds Ascendant/houses and qualifies boundary-sensitive facts. Missing place is shown separately so users understand which input unlocks which feature.

## Methodology gates preserved

No design decision closes:

- `METHOD-001` Western house-system strategy;
- `METHOD-003` Vedic ayanamsa;
- `METHOD-005` Chinese calendar conventions;
- `METHOD-006` BaZi Four Pillars;
- `METHOD-007` BaZi local/solar-time behavior;
- `METHOD-009` cross-system timing.

The loaded wheel’s houses/Ascendant belong only to a clearly labeled known-time development fixture. Vedic and BaZi references are intentionally not flattened into Western geometry.

## Review checklist

- [ ] Product owner confirms Free entry is educational, not a fake personalized chart.
- [ ] Product owner confirms unknown time/place language and “what adding data unlocks” treatment.
- [ ] Product owner confirms wheel + list hierarchy on iPhone.
- [ ] Product owner confirms iPad chart + detail composition and Split View collapse.
- [ ] Product owner confirms access presentation remains separate from calculation truth.
- [ ] Product owner confirms Newsreader/SF Pro/system/SF Mono role mapping.
- [ ] Product owner confirms Vedic/BaZi/Compare Systems remain future, distinct and methodology-gated.
- [ ] Product owner confirms the proposed reference-only assets before any production asset work.

## Out of scope and explicit non-actions

- No `Humay/App/`, `Humay/Presentation/`, `Humay/Data/` or `Humay/Domain/` production edits.
- No `ChartView.swift`, `NatalChartView.swift`, provider adapter, backend/API, cache, entitlement SDK, rewarded-ad or subscription code.
- No real natal calculation or methodology validation.
- No D3 visual redesign, `SKY-002` or `SKY-006` work.
- No D5 Ask work.

Product owner reviews this package next. It remains **REVIEW CANDIDATE — NOT APPROVED**.
