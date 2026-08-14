# D4.1 Chart visual foundation — design specification

**Status:** APPROVED VISUAL REFERENCE — IMPLEMENTED AND RECONCILED

**Approval record:** D4.1 approved 2026-08-14 for the first UI-first Chart slice: Free entry, typed states, Western known-time development fixture, Placement Detail, unknown-time handling and iPhone/iPad adaptive presentation. This does not approve production calculation, provider, access, cache, entitlement or methodology work.

## 1. Product role

Today gives guidance. Circle gives relationship perspective. Sky gives current celestial context. Chart gives personal celestial structure.

Chart should feel personal, precise, elegant, premium and exploratory while remaining understandable and trustworthy. It is a denser utility/editorial surface than Today or Sky, not an occult poster, generic purple horoscope wheel or scientific dashboard.

The first navigation model stays native:

```text
Chart root tab
└── Chart Overview
    ├── Western Chart
    │   └── Placement Detail
    ├── Vedic                    future, methodology-gated
    ├── Chinese / BaZi            future, methodology-gated
    └── Compare Systems           future, methodology-gated
```

No new root tab is introduced. Native navigation-stack behavior owns Back and route context.

## 2. Trust boundary

Ordinary Free Chart entry explains value and readiness. It does not calculate a natal chart, call a paid provider, show houses/Ascendant as if known, or render a personalized fake wheel.

Free entry may show:

- an authored, abstract wheel-like illustration explicitly labeled **Illustrative preview · not your chart**;
- what Chart can contain after precision access;
- birth-data readiness and missing-input explanations;
- an informational future access path for Rewarded/Premium.

Precision is a later Rewarded/Premium/cache-backed feature. Access presentation must remain separate from calculation truth: an unlocked access path is not proof that calculation succeeded, and a cached result can reopen without another access event.

## 3. Fixture boundary

Loaded Western references use illustrative development values only:

| Fact | Sample value | Fixture note |
|---|---|---|
| Sun | Aquarius · 22° 11′ | sample, not calculated |
| Moon | Libra · 14° 27′ | sample, not calculated |
| Ascendant | Gemini · 03° 02′ | known-time fixture only |
| House | 5th | known-time fixture only; methodology-sensitive |
| Aspect | Sun trine Moon | restrained highlight; sample only |

Primary references carry **Development sample · not calculated**. No value belongs to the actual user. The loaded wheel explicitly says **Known-time fixture** before houses or Ascendant appear.

## 4. Chart Overview / Free entry

### iPhone composition

1. Native Chart root header and short editorial introduction: **Your personal sky map**.
2. One calm abstract preview illustration, not a personalized natal wheel.
3. One value explanation: Chart maps structure — placements, patterns and the basis behind later interpretation.
4. Precision/access card with a clear future action treatment, never a paywall wall.
5. Birth-data readiness card: date supplied, time state, place state, and what each state unlocks.
6. A short section previewing Big Three, placements and patterns as destinations rather than fabricated facts.

The first viewport does not begin with a giant unreadable wheel. Controls stay inset from safe areas and inside the shared phone content gutter.

### iPad composition

Regular width uses two bounded regions:

- leading region: editorial intro, readiness and access explanation;
- trailing region: larger abstract preview and concise **What precision unlocks** list.

The illustration gains room, not semantic weight. Portrait and landscape preserve this relationship; narrow Split View collapses to the iPhone reading order.

## 5. Western loaded overview

### Information hierarchy

1. Chart identity and basis disclosure;
2. Big Three / key placements;
3. selected highlights and major aspects;
4. full placement route;
5. methodology/provenance disclosure.

### iPhone composition

- Header: **Western chart**, tradition label, sample disclosure.
- Compact identity row: date basis and **Known-time fixture**.
- Natal wheel sized for readable symbols, with labels outside the ring only where they do not collide.
- Big Three cards in a two-column or stacked arrangement depending on Dynamic Type pressure.
- One selected highlight row and a visible route to **All placements**.
- Aspects appear as a restrained list, never as a dense line web.

The wheel is central but not the only explanation. Meaning remains available as text and list content.

### iPad composition

The regular-width composition is intentionally chart + detail:

- left: wheel, basis disclosure and compact identity;
- right: Big Three, selected interpretation and placement navigation.

The right region can scroll independently only if native behavior remains clear; otherwise the page scrolls as one bounded reading surface. The wheel does not stretch to fill unused width.

## 6. Natal-wheel component contract

The wheel is a scalable, meaningful component concept, not decorative art.

Visual layers:

1. outer zodiac ring with readable sign names/abbreviations;
2. inner planet markers with redundant color + text/shape cues;
3. aspect lines limited to selected major aspects;
4. house ring and cusps only in fixtures with sufficient birth time/place and approved house methodology;
5. selected marker state with a visible outline/label, not color alone;
6. textual placement list as the equivalent meaning-bearing representation.

Rules:

- iPhone wheel fits comfortably without tiny glyph walls;
- iPad uses width for adjacent facts/details rather than only enlarging the wheel;
- no label collisions; labels may move to a list when geometry becomes crowded;
- no houses or Ascendant in unknown-time fixtures;
- exact degrees use the technical role only where useful;
- zoom/pan is not required for D4.1; if introduced later, it needs a reset affordance, keyboard/pointer path and VoiceOver equivalent;
- VoiceOver must receive a spoken summary and ordered placement list, not an image-only chart.

## 7. Placement Detail — Moon in Libra

Placement Detail separates fact from meaning.

### Fact layer

- body: Moon;
- sign: Libra;
- degree: `14° 27′`;
- house: `5th` only for the known-time fixture;
- reliability: `Exact · known-time fixture`;
- basis: Western tropical sample, exact time + place assumed;
- provenance: development sample, not calculated.

### Interpretation layer

The interpretation is concise, labeled **What this may mean**, and does not introduce omitted facts. It may explain the supplied Moon-in-Libra factor without inventing a house, aspect or life claim.

On iPhone, fact precedes meaning. On iPad, fact and meaning may sit side by side while preserving the same reading order. A native Back action returns to Western Chart.

## 8. Unknown birth-time state

Unknown time is first-class, not an alert.

Fixture inputs:

- birth date: known;
- birth time: unknown;
- birth place: not provided.

The state says:

**Known**

- date-valid facts where the approved methodology supports them;
- supplied birth date and its display basis;
- any fact explicitly marked reliable for the available input.

**Unavailable or uncertain**

- Ascendant;
- houses and house cusps;
- time-dependent exact placements;
- boundary-sensitive facts that cannot be treated as certain;
- place-dependent calculations when place is not provided.

The UI shows a quiet partial-sky visual with no house ring. It does not draw a fake wheel, silently choose noon/midnight/sunrise, or present a tiny footnote as the only limitation.

The primary explanation is supportive: **Your date still gives Chart a starting point. Adding time and place unlocks the parts of the sky that depend on where and when you were born.** The user is not framed as incomplete.

## 9. Presentation/state contract recommendation

This is a documentation-level CHART-001 recommendation, not production code.

Use a provider-independent, Humay-owned presentation envelope with separate access and calculation concerns:

```text
ChartPresentationState
├── loading(context)
├── freePreview(readiness)
├── precisionLocked(offer, readiness)
├── generationAvailable(offer, readiness)
├── loaded(chart)
├── cached(chart, freshness)
├── offlineCached(chart, freshness)
├── offlineNoCache(context)
├── unsupportedMethodology(context, system)
├── insufficientBirthPrecision(context, missingInputs)
└── failed(context, failure, recovery)
```

Recommended envelope concepts:

- `ChartContext`: route origin, tradition, profile identity, supplied birth-input summary, sample/production source disclosure;
- `ChartReadiness`: date/time/place readiness with fact-level implications;
- `ChartAccessPresentation`: free, rewarded path, premium path, cached reopen; no vendor SDK DTO;
- `ChartPayload`: tradition-specific normalized facts, reliability, provenance, calculation/interpretation artifact identity and valid-through metadata;
- `ChartFact`: stable Humay fact identifier, display value, reliability, required-input basis and optional provenance reference;
- `ChartRecovery`: retry/reopen/back guidance without claiming that an access event produced a result.

The existing Domain contracts are the correct foundation:

- `BirthTime.unknown` remains explicit;
- `AstrologyFactReliability` already distinguishes reliable, uncertain and unavailable facts;
- `AstrologyFactUnavailability` covers missing time/place, insufficient precision, methodology approval and calculation-boundary support;
- `AstrologyCalculationProvenance` carries Humay contract/methodology/adapter/configuration metadata;
- `WesternAstrologyFact` currently covers planetary positions and aspects without freezing houses/Ascendant while `METHOD-001` remains open.

Do not add vendor DTOs, an opaque `confidence` score, guessed time defaults or a universal Western-shaped payload for Vedic/BaZi.

## 10. State and access treatment

The state board is conceptual outside simulated app UI. It covers:

- loading: stable skeleton, no fake facts;
- Free preview: educational explanation, no natal result;
- precision locked: value/access explanation, no personalized wheel;
- generation available: future access action, calculation still pending;
- loaded: calculation facts plus reliability/provenance disclosure;
- cached: valid result reopens without another access event;
- offline cached: saved result plus freshness/basis label;
- offline no cache: explicit unavailable state, no queued paid call;
- unsupported methodology: name the blocked system/convention;
- insufficient birth precision: explain missing time/place and affected facts;
- failed: distinguish access, provider, validation and recovery outcomes later.

Access UI never becomes the chart itself. Provider failure after a completed reward remains a later ARCH-007 recovery decision.

## 11. Typography and data density

Frozen role mapping:

- Cormorant Garamond: Humay wordmark only;
- Newsreader: editorial/display framing and interpretation headings;
- SF Pro/system: body, navigation, controls, labels, placement names, dates/times;
- SF Pro/system + `monospacedDigit()`: ordinary aligned timing/numeric UI;
- SF Mono/system: genuinely technical Chart values such as degrees, coordinates and tightly aligned longitude values.

Chart does not introduce a new font family. Any genuinely new reusable role is documented for `HumayTypography` review rather than assigned an arbitrary size.

Use hierarchy, not tiny type: factual labels, values, reliability, basis and interpretation must remain readable under Dynamic Type. Long copy wraps; no critical degree or uncertainty label is truncated without an expanded path.

## 12. Other systems

The shared Chart shell leaves room for three distinct conceptual families:

- **Western:** planets, signs, houses, aspects;
- **Vedic:** grahas, rashis, bhavas, nakshatras, dashas;
- **Chinese/BaZi:** pillars, stems, branches, elements, cycles.

Vedic must not become a Western wheel with renamed labels. BaZi must not become a circular natal wheel. Compare Systems should later compare themes, different emphasis and different perspective without ranking systems or inventing cross-system timing.

This package validates shared navigation and disclosure only. It does not close `METHOD-001` through `METHOD-009`, `ASTRO-003`, `ASTRO-004`, `ASTRO-005` or cross-system timing work.

## 13. Appearance and assets

Light uses warm cream ground, off-white surfaces, restrained coral/lavender/gold/blue/sage accents and editorial contrast. Dark uses layered midnight/navy surfaces, warm text and controlled brighter accents. No black + neon wheel.

Reference-only authored assets proposed:

- abstract Free Chart entry illustration;
- partial-sky / unknown-time visual cue;
- restrained wheel anatomy marks and accessible legend.

Keep these inside the D4.1 package. Do not modify `Assets.xcassets` in this pass. Prefer scalable SVG.

## 14. Approval boundary

D4.1 is approved, implemented and reconciled for the UI-first foundation.

Still NOT completed:

- production calculation;
- provider integration;
- CHART-002;
- ASTRO-003;
- cache;
- access;
- entitlement;
- rewarded ads;
- methodology gates;
- Vedic;
- BaZi;
- Compare Systems.
