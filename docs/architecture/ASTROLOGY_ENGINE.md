# Humay Astrology Calculation Engine Contract

Status: **CURRENT ARCHITECTURE CONTRACT — ARCH-003 complete 2026-08-12**

This document freezes Humay's **provider-independent calculation strategy**. It does not choose a specific vendor API or ephemeris implementation.

Production features consume normalized Humay calculation facts. Vendor-specific calculation requests/responses remain behind server-side adapters and never become Apple Presentation or Domain models.

## 1. Core rule

Humay separates deterministic calculation from natural-language interpretation:

```text
BirthCalculationInput
        │
        ▼
Calculation Adapter / Engine
        │
        ▼
AstrologyCalculationResult
        │
        ▼
Interpretation Boundary
        │
        ▼
Reading / explanation
```

An interpretation/LLM component may explain validated facts. It must never calculate, infer or fabricate planetary positions, houses, Ascendant, aspects, nakshatras, Four Pillars or other deterministic facts that belong to the calculation layer.

Ordinary Free catalog usage does **not** invoke this calculation engine.

## 2. Provider strategy

Humay defines independent server-side calculation boundaries by methodology family:

```text
WesternCalculationProvider
VedicCalculationProvider
BaZiCalculationProvider
```

These names describe Humay-owned interfaces, not vendor classes.

A provider adapter is responsible for:

- translating normalized Humay inputs into the provider/engine request;
- calling the selected server-side calculation engine;
- validating and normalizing the response;
- attaching calculation/methodology provenance;
- rejecting unsupported or malformed facts;
- exposing only Humay-owned typed results to the rest of the system.

A specific Astrologer/RapidAPI service, Swiss Ephemeris deployment or another engine may later implement one or more adapters, but no client/domain contract may depend on that choice.

## 3. Shared calculation input

Phase 02 ASTRO-001 owns the concrete Swift/domain types. The architecture contract requires the following semantics.

### Birth date

Birth date remains calendar components, not an instant manufactured from an arbitrary timezone:

```text
BirthDate
├── year
├── month
└── day
```

### Birth time

Time precision is explicit:

```text
BirthTime
├── exact(minutesFromMidnight)
├── approximate(minutesFromMidnight, toleranceMinutes)
└── unknown
```

Rules:

- `unknown` remains unknown throughout calculation.
- No adapter may silently replace unknown with noon, midnight or another default.
- Approximate time must carry its uncertainty rather than being promoted to exact.

### Birth place

Place is either not provided or contains the canonical values needed by a precision calculation:

```text
BirthPlace
├── notProvided
└── known
    ├── canonical/display name
    ├── latitude
    ├── longitude
    └── timezone identifier/context
```

Provider adapters may derive provider-specific timezone/coordinate formatting from these values, but those vendor formats do not escape the adapter.

### Tradition/methodology

The calculation request must identify the intended methodology family and version rather than relying on provider defaults.

Examples of dimensions that may later be explicit include house system, zodiac basis, ayanamsa or BaZi calendar conventions. These dimensions are added only after their methodology tasks are signed off; unresolved choices must not be silently inherited from a vendor default.

## 4. Normalized calculation result

A calculation response must be structured and immutable from the consuming feature's perspective.

Conceptually:

```text
AstrologyCalculationResult
├── tradition
├── calculationContractVersion
├── methodologyVersion
├── engine/provenance metadata
├── calculatedAt
├── facts[]
└── warnings / unavailable-fact reasons
```

A normalized fact must carry enough information to determine what it is and whether the available input supports it.

Conceptually:

```text
AstrologyFact
├── stable fact kind / identifier
├── normalized value(s)
├── reliability
├── required-input basis
└── fact-level provenance/version when necessary
```

The concrete feature-facing contracts are finalized by ASTRO-007; this document prevents vendor-native schemas from becoming that contract.

## 5. Reliability and uncertainty

Reliability is not a UI decoration; it is a data property.

At minimum the normalized layer must distinguish facts that are:

- valid with the supplied precision;
- unavailable because required time/place input is missing;
- uncertain because approximate input can materially change the result;
- invalid/rejected because the provider response fails validation;
- methodologically unavailable because the convention is not yet approved.

Examples:

- Sun sign may be available from date under a validated Western date-only rule.
- Ascendant/houses require sufficient birth time and place context.
- A fact that may cross a boundary within an approximate-time tolerance must not be emitted as certain.

Feature code must be able to omit or explicitly qualify unavailable/uncertain facts without guessing.

## 6. Provenance and versioning

Every provider-backed calculation result must retain reproducibility metadata sufficient for cache identity, validation and support.

Required conceptual dimensions:

- Humay calculation-contract version;
- Humay methodology version;
- calculation engine/adapter identifier;
- engine/provider version when exposed and meaningful;
- relevant deterministic configuration version;
- calculation timestamp where operationally useful.

Provenance is metadata, not a license for provider-native fields to leak into Presentation.

If a provider cannot expose a useful internal version, Humay must still version its adapter/configuration so results can be invalidated when calculation behavior changes.

## 7. Methodology ownership

Humay, not the provider, owns methodology choices.

A provider default is never automatically a product decision.

Before a methodology-sensitive option is used in production:

1. the relevant methodology task is documented/signed off;
2. the choice receives a Humay methodology version;
3. validation fixtures cover representative and boundary cases;
4. the adapter supplies the explicit setting where the provider supports it;
5. cache identity changes when the result semantics can change.

This is especially important for:

- Western house system and related chart conventions;
- Vedic sidereal/ayanamsa and nakshatra conventions;
- Chinese/BaZi calendar, solar-time and pillar conventions.

## 8. Tradition-specific boundaries

### Western

The Western adapter may eventually produce:

- planetary positions;
- luminary/sign facts;
- Ascendant and houses when precision permits;
- aspects;
- transit/event facts required by validated feature use cases.

The exact initial fact set belongs to ASTRO-003 and feature needs; do not calculate fields merely because a vendor supplies them.

### Vedic

The Vedic adapter is independent from Western even if the same underlying engine can serve both.

Production output remains methodology-gated. Sidereal settings, nakshatra semantics and time-sensitive facts must carry Humay methodology provenance.

### Chinese / BaZi

BaZi/Four-Pillars calculation is a distinct adapter boundary.

A coarse Chinese zodiac Free catalog key is **not** the same thing as a personalized BaZi calculation.

Production Four-Pillars/Luck-Cycle output remains disabled until its required methodology decisions are signed off and validated.

## 9. Normalized failure model

Provider/engine failures must be translated into Humay-owned operational outcomes.

The exact error types are implemented later, but the architecture must distinguish at least:

- invalid input;
- insufficient birth precision for the requested fact set;
- unsupported methodology/configuration;
- calculation provider unavailable/timeout;
- provider rejected request;
- malformed or incomplete provider response;
- validation failure;
- production methodology gate disabled.

Raw vendor error payloads do not become app-facing domain errors and must not be logged with sensitive request data.

## 10. Provider replacement and fallback

Humay is replaceable by design, but **fallback must not silently change astrology semantics**.

A secondary engine/provider may serve as fallback only when all of the following are true:

- it implements the same Humay calculation contract;
- the required methodology/configuration is explicitly supported;
- validation fixtures demonstrate acceptable equivalence for the supported fact set;
- provenance records which adapter/engine produced the result;
- cache identity/versioning prevents incompatible result reuse.

If those conditions are not satisfied, provider failure is surfaced explicitly rather than silently switching engines.

Fallback is therefore a validated adapter capability, not a generic HTTP retry rule.

## 11. Validation contract

ASTRO-006 owns the fixture suite, but every production calculation adapter must be testable against independently validated fixtures.

Fixture coverage must eventually include:

- multiple geographic locations;
- timezone and DST boundaries;
- dates near sign/house/aspect boundaries where relevant;
- exact vs approximate vs unknown time;
- invalid coordinate/timezone inputs;
- provider response normalization;
- cross-provider equivalence only where a fallback is claimed.

A value shown in a design mockup is never a validation source.

## 12. Cache implications

ARCH-004 owns cache implementation, but calculation results must be cacheable independently from interpretation text.

A calculation cache identity must include every dimension that can alter deterministic facts, such as:

- normalized relevant birth inputs;
- tradition/methodology version;
- calculation contract/adapter configuration version;
- requested fact-set/version where materially relevant.

Tone, copy style and interpretation prompt/model are **not** calculation dimensions.

Changing Normal ↔ Roast must never cause a recalculation of unchanged facts.

## 13. Interpretation boundary

The calculation result is the authoritative deterministic input to the later interpretation layer.

Interpretation receives structured facts plus explicitly authorized context. It may:

- summarize;
- explain;
- compare;
- express Normal/Roast tone;
- produce feature-specific prose.

It may not:

- invent a missing Ascendant;
- infer a house from an unknown time;
- change an aspect to fit a narrative;
- manufacture a transit/placement absent from the structured facts;
- replace an unavailable fact with a plausible guess.

The full prompt/model/retry/idempotency contract belongs to ARCH-005.

## 14. Free path isolation

The calculation-provider boundary is **not part of ordinary Free serving**.

Examples:

- Free Western daily horoscope: finite Sun-sign catalog lookup.
- Free Western compatibility: finite 12 × 12 sign-pair catalog lookup.
- Any future Vedic/Chinese Free shortcut: only a methodology-approved finite catalog bucket.

A missing Free catalog entry is not permission to call the calculation provider.

## 15. Server-side security boundary

Calculation providers are called only from Humay-controlled server infrastructure.

- provider credentials remain server-side;
- the Apple app never receives provider API keys;
- Apple code consumes normalized Humay response contracts;
- request logging is redacted/minimized;
- provider transmission is restricted to fields required for the calculation.

The detailed retention/deletion/provider-data policy belongs to ARCH-008.

## 16. Decisions deliberately not frozen here

ARCH-003 does not select:

- a specific commercial calculation API;
- RapidAPI/Astrologer as the permanent provider;
- Swiss Ephemeris hosting topology;
- a specific fallback vendor;
- Western house system or orb tables;
- Vedic ayanamsa;
- BaZi convention set;
- concrete HTTP endpoint/schema;
- interpretation/LLM model.

Those decisions must plug into this contract rather than modify feature/domain code around a vendor.

## 17. Phase 02 handoff

With ARCH-003 complete, Phase 02 should proceed in this order once Phase 01's verification dependency is satisfied:

1. **ASTRO-001** — reconcile concrete shared calculation inputs with existing `BirthDetails` semantics.
2. **ASTRO-002** — implement the Humay provider/adapter protocol layer without choosing vendor-native app models.
3. **ASTRO-003** — validate the initial Western baseline and golden fixtures.
4. Later Vedic/BaZi work remains behind methodology gates.

See also:

- [`SYSTEM_ARCHITECTURE.md`](SYSTEM_ARCHITECTURE.md)
- [`DATA_MODEL.md`](DATA_MODEL.md)
- [`../development/METHODOLOGY_TRACK.md`](../development/METHODOLOGY_TRACK.md)
- [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md)
- [`../development/phases/02-astrology-engine-foundation.md`](../development/phases/02-astrology-engine-foundation.md)
