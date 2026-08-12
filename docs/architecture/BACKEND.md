# Humay Backend, Free Catalog & API Responsibilities

Status: **CURRENT ARCHITECTURE CONTRACT — ARCH-006 complete 2026-08-12**

This document defines Humay's backend responsibilities without choosing a hosting vendor or concrete provider implementation. It preserves the product invariant that ordinary Free runtime usage makes no paid astrology or LLM call.

Related authority:

- [`SYSTEM_ARCHITECTURE.md`](SYSTEM_ARCHITECTURE.md)
- [`ASTROLOGY_ENGINE.md`](ASTROLOGY_ENGINE.md)
- [`RESULT_CACHE_OFFLINE.md`](RESULT_CACHE_OFFLINE.md)
- [`INTERPRETATION_LAYER.md`](INTERPRETATION_LAYER.md)
- [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md)

## 1. Backend responsibilities

Humay-controlled server infrastructure owns:

- Free catalog publishing and serving;
- precision request validation/normalization;
- authoritative result-cache lookup/write;
- provider secrets;
- astrology calculation adapters;
- interpretation adapters;
- access/generation authorization integration;
- generation idempotency/concurrency control;
- normalized API response contracts;
- reference-data/version distribution where server authority is needed;
- provider failure normalization;
- privacy-safe observability and cost metrics.

The Apple client does not call paid astrology/LLM providers directly.

## 2. Logical backend components

The production topology may be deployed as one service initially, but responsibilities remain logically distinct:

```text
                    Humay Apple App
                          │
             ┌────────────┴────────────┐
             │                         │
        Free Catalog API          Precision API
             │                         │
             ▼                         ▼
   Published catalog store      normalize + cache lookup
             │                         │
             │                  ┌──────┴──────┐
             │                  │             │
             │               cache hit     cache miss
             │                  │             │
             │                  ▼             ▼
             │               return      access/generation gate
             │                                │
             │                                ▼
             │                         calculation adapter
             │                                │
             │                                ▼
             │                        calculation artifact
             │                                │
             │                                ▼
             │                       interpretation adapter
             │                                │
             │                                ▼
             │                        interpretation artifact
             │                                │
             └────────────────────────────────┴──► cache + return
```

Free serving remains independent from the precision provider path even if both are deployed on the same platform.

## 3. Free catalog production pipeline

Free content is generated **ahead of runtime**, reviewed/versioned, then published to Humay-owned storage.

Conceptual pipeline:

```text
catalog definition
      │
      ▼
batch generation/editorial tooling
      │
      ▼
validation + review
      │
      ▼
immutable/versioned candidate
      │
      ▼
publish manifest/version
      │
      ▼
Humay-owned runtime catalog
```

AI-assisted generation may be used as a content-production tool. That does not make the runtime request an LLM request.

Each published catalog family defines:

- key dimensions/cardinality;
- locale/tone variants;
- content/schema version;
- effective date/period where relevant;
- review status;
- publication timestamp/version;
- rollback/supersession behavior.

A visual mock value is never accepted as catalog truth merely because it appears in design.

## 4. Free runtime flow

A Free request sends only the coarse key required for already-published content.

```text
validate finite catalog key
        │
        ▼
local/CDN/backend catalog lookup
   ┌────┴────┐
 found      missing
   │          │
return     explicit unavailable/error
              │
              └── NEVER precision/provider fallback
```

Free runtime must continue to function when external astrology/LLM providers are unavailable.

For Western V1 examples:

- daily horoscope: Sun-sign/date/locale/tone catalog;
- coarse compatibility: 12 × 12 Sun-sign pair catalog.

Vedic/Chinese coarse catalogs exist only after methodology validates their bucket definitions.

## 5. Precision runtime flow

Provider-backed generation is server-side and cache-first.

Conceptual sequence:

1. validate request shape and allowed feature;
2. normalize relevant birth/person/event inputs;
3. derive privacy-safe semantic cache identity;
4. check authoritative calculation/interpretation caches;
5. if a complete valid cached result exists, return it with **0 new paid provider calls**;
6. if generation is required, enforce the owning Rewarded/Premium authorization contract;
7. acquire/reuse an idempotent generation scope;
8. call the approved calculation adapter;
9. validate/normalize facts and provenance;
10. persist the calculation artifact;
11. call interpretation only when the feature requires prose and no valid interpretation artifact exists;
12. validate/cache interpretation;
13. return normalized Humay response.

ARCH-007 owns the exact rewarded/Premium authorization and recovery semantics. This document requires the cache lookup to occur before new generation consumption.

## 6. API contract principles

Humay APIs expose Humay-owned contracts, never vendor-native schemas.

Principles:

- explicit schema/versioning where compatibility requires it;
- stable feature/result identifiers;
- typed normalized status/error codes;
- no provider credentials or hidden prompt text;
- no raw vendor errors;
- privacy-minimized request fields;
- calculation provenance and reliability preserved where the feature needs them;
- interpretation provenance/version preserved independently;
- idempotency supported for provider-backed generation;
- cache/reopen semantics represented explicitly rather than inferred from HTTP timing.

Concrete endpoint paths and transport DTOs are intentionally deferred until backend implementation.

## 7. Reference data

Humay may publish versioned reference data needed by clients or content tooling, such as:

- astrology-system metadata already approved by methodology;
- content/catalog manifests;
- feature availability/version metadata;
- locale/static copy catalogs where appropriate.

Reference data must not become a hidden channel for provider secrets, raw private profile data or unreviewed methodology defaults.

Methodology-sensitive values are versioned and traceable to the relevant methodology decision.

## 8. Provider adapters

Provider adapters live behind Humay backend boundaries.

A calculation adapter:

- converts normalized Humay input into vendor/engine input;
- supplies explicit approved methodology settings;
- performs the provider/engine call;
- validates response structure/ranges;
- maps to Humay facts/reliability/provenance;
- never leaks vendor response models to the Apple app.

An interpretation adapter follows `INTERPRETATION_LAYER.md` and receives already-validated facts/context.

Provider replacement/fallback is not generic failover. It is allowed only where the relevant Humay contract/methodology equivalence has been validated.

## 9. Data minimization

The backend sends external providers only fields required for the requested precision operation.

Examples:

- a Free coarse catalog request sends **no full birth profile to a paid provider**;
- a deterministic natal calculation may require birth date/time/location but should not receive unrelated settings or saved-person data;
- interpretation receives normalized facts and only authorized context; it should not require raw coordinates if facts already contain what it needs;
- Ask question text is transmitted only to the interpretation path that needs it.

ARCH-008 finalizes retention/deletion/export/provider-data policy before production rollout.

## 10. Observability and cost invariants

Backend metrics must make product cost rules measurable.

At minimum record privacy-safe counters/timings for:

- Free catalog requests and misses;
- precision cache hits/misses;
- calculation provider calls by adapter/version;
- interpretation provider calls by adapter/model-policy version;
- provider latency/failure class;
- idempotency/coalescing outcomes;
- generated artifact counts;
- cost/token/request totals where available.

Required invariants include:

- normal Free request → **0 paid provider calls**;
- Free catalog miss → **0 paid provider calls**;
- valid complete precision cache hit → **0 new calculation/LLM calls**;
- one authorized generation does not create uncontrolled duplicate calls.

Operational logs do not contain raw birth inputs, full questions, generated readings, secrets or provider payloads.

## 11. Failure behavior

Normalize external failures into Humay-owned outcomes.

Examples:

- invalid request;
- unsupported methodology/feature;
- insufficient precision;
- access/generation authorization required;
- provider unavailable/timeout;
- provider rejection;
- malformed response;
- validation failure;
- catalog unavailable;
- generation still in progress/idempotent retry state.

A backend error must never cause the Apple client to directly retry against a paid provider.

## 12. Accountless V1 boundary

Humay V1 has no login UI or Humay account requirement.

The backend may later need an anonymous installation/device/app identity for abuse control, generation receipts or idempotency. That identity:

- is not presented as a user account;
- does not change local profile ownership;
- must not be treated as permanent cross-platform identity without a later product decision;
- is finalized with ARCH-007/ARCH-008 and backend implementation.

## 13. UI-first implementation sequence

The approved engineering sequence after the current architecture work is intentionally **UI first, backend/API second**.

### Stage A — design and implement UI with development sample data

For each feature family:

1. create iPhone Light/Dark + iPad Light/Dark references and get approval;
2. implement the real production SwiftUI screen/state structure;
3. feed it typed **development sample data** at a development composition boundary;
4. cover loading, loaded, limited/Free, precision, cache-hit, offline, empty and failure states that are part of the approved design;
5. capture/reconcile real simulator screenshots.

Requirements:

- sample data must conform to Humay-owned Domain/feature contracts;
- sample values are explicitly development/preview/test data;
- do not restore the deleted mock-provider architecture;
- do not create vendor-shaped UI models;
- Release builds must not present sample astrology as real provider output;
- Presentation must remain replaceable at the data-source/composition boundary.

### Stage B — implement backend/API

After the relevant UI/feature contracts are stable:

1. implement backend schemas/endpoints against the already-frozen Humay contracts;
2. implement Free catalog serving/publishing;
3. implement server cache/idempotency;
4. implement calculation and interpretation adapters;
5. implement access/privacy requirements;
6. validate providers with fixtures and cost invariants.

### Stage C — connect real runtime

Replace the development sample source with real API/Data adapters at composition. The visual hierarchy and Presentation contracts should not require redesign merely because the data source changed.

This UI-first sequence is a development workflow only; it does **not** permit sample/mock output to ship as production truth.

## 14. Deployment/vendor choices deliberately open

ARCH-006 does not select:

- Cloudflare Workers/Pages/KV/D1/R2;
- a VPS/container platform;
- Postgres/Redis/object storage;
- Astrologer/RapidAPI;
- Swiss Ephemeris deployment;
- DeepSeek or another LLM;
- exact endpoint names;
- exact anonymous identity implementation.

Those choices are made when backend/API implementation begins, using this contract as the constraint.
