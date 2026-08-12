# Humay System Architecture

Status: **CURRENT ARCHITECTURE CONTRACT — ARCH-001 complete 2026-08-12**

This document defines Humay's system/deployment boundaries for the two product paths authorized by [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md):

1. **Free catalog** — Humay-owned, pre-generated, versioned content with no paid calculation or LLM call during ordinary Free use.
2. **Precision/personalized** — cache-first, server-orchestrated calculation and interpretation available only through the owning Rewarded Access/Premium rules.

It defines boundaries and failure behavior, not a commitment to a specific hosting, calculation-provider or interpretation-provider vendor.

## 1. Non-negotiable invariants

- The Apple app never contains paid-provider secrets or calls paid astrology/LLM providers directly.
- Ordinary Free usage has **no execution path** that can fall through to a paid calculation or interpretation provider.
- Free runtime reads only Humay-owned published/catalog content and valid Humay-controlled caches.
- Precision requests go through a Humay server boundary before any paid provider is considered.
- A valid precision cache hit returns without a new calculation or interpretation call.
- Calculation facts and interpretation text are separate artifacts with independent provenance/versioning.
- An interpretation provider may explain structured facts but may not calculate or invent astrology facts.
- Vendor-native request/response models do not become Apple Presentation or Domain contracts.
- Sensitive birth/profile inputs are minimized per request and are never emitted to ordinary public logs.
- Unknown birth time is preserved as unknown; no layer substitutes noon, midnight or another guessed time.

## 2. Logical system view

```text
                        Humay iOS / iPadOS
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
            FREE PATH                  PRECISION PATH
                 │                           │
      coarse catalog key              normalized request
                 │                           │
                 ▼                           ▼
       Humay catalog endpoint         Humay backend/API boundary
                 │                           │
                 ▼                     access + cache lookup
     Humay-owned published data              │
                 │                   ┌───────┴────────┐
                 ▼                   │                │
          local HTTP/cache       valid cache hit   cache miss
                 │                   │                │
                 ▼                   ▼                ▼
              render             return result   calculation adapter
                                                     │
                                                     ▼
                                             structured astrology facts
                                                     │
                                                     ▼
                                            interpretation adapter
                                                     │
                                                     ▼
                                              reading/result text
                                                     │
                                                     ▼
                                             versioned cache + return
```

The Free and precision paths may share infrastructure operationally, but they remain **logically isolated cost/trust paths**. A missing Free catalog object must not invoke the precision pipeline.

## 3. Apple client boundary

The iOS/iPadOS app owns:

- current local profile/settings persistence;
- UI/navigation and feature presentation;
- request construction from the minimum currently required user inputs;
- local transient/result caching only where later cache architecture authorizes it;
- display of normalized Humay contracts;
- client-side access UX once its owning monetization/design phases are implemented.

The Apple app does **not** own:

- paid-provider credentials;
- calculation-provider vendor orchestration;
- interpretation-provider credentials/prompts that must remain server controlled;
- Free catalog generation/publishing;
- server result-cache authority;
- provider retry/fallback policy;
- entitlement truth that requires server/store verification.

Humay V1 remains accountless. A future anonymous backend identity may support abuse control/idempotency without creating login UI; that identity design is not frozen by ARCH-001.

## 4. Free catalog path

### Request shape

A Free request contains only the coarse key required to identify already-published Humay content, for example:

- feature/content family;
- astrology system/bucket;
- date or period;
- locale;
- Normal/Roast content variant where the published text differs;
- catalog/content version dimensions as required by the publishing contract.

Full birth time, location or natal-chart inputs are not sent merely to serve a coarse Free catalog item.

### Serving behavior

```text
Apple app
   │
   ├── valid local/HTTP cache → render
   │
   └── catalog request
          │
          ▼
     Humay-owned published catalog/static storage
          │
          ├── found → return versioned content
          └── missing/unavailable → explicit unavailable/retry behavior
                                   NEVER paid-provider fallback
```

### Failure behavior

- A valid cached Humay catalog object may be reused according to its version/expiry policy.
- If no valid Humay-owned object exists, return a catalog-unavailable/error state.
- External calculation or interpretation provider availability is irrelevant to ordinary Free serving.
- A Free cache/catalog miss must be observable as a cost invariant: **0 paid provider calls**.

The exact CDN/object-storage/Worker implementation is deferred to ARCH-006. No infrastructure vendor is frozen here.

## 5. Precision/personalized path

### Request flow

```text
Apple app
   │
   ▼
Humay backend/API
   │
   ├── validate/minimize input
   ├── verify access semantics when required
   ├── derive canonical result identity
   ├── cache lookup
   │     └── valid hit → return normalized result
   │
   └── cache miss
         │
         ▼
   calculation provider adapter
         │
         ▼
   normalized AstrologyFacts
         │
         ├── cache/version facts separately
         │
         ▼
   interpretation provider adapter
         │
         ▼
   normalized reading/result
         │
         ▼
   cache + return
```

The precise reward-consumption, Premium, idempotency and recovery sequence remains owned by ARCH-007. This document only fixes the rule that cache lookup precedes paid generation.

### Failure behavior

- Invalid or insufficient input fails before provider calls.
- Calculation failure does not trigger interpretation over invented or partial unvalidated facts.
- Interpretation failure does not invalidate already-validated calculation facts; fact and text caching/retry may be independent under ARCH-004/ARCH-005.
- Provider retries must be bounded and idempotent once the backend contract is implemented.
- A provider switch is not an automatic retry mechanism when it could alter methodology; fallback rules are defined in [`ASTROLOGY_ENGINE.md`](ASTROLOGY_ENGINE.md).

## 6. Trust boundaries and external dependencies

| Boundary/dependency | Purpose | Trust boundary | Required failure behavior |
|---|---|---|---|
| Apple app | Presentation, local user state, request initiation | Untrusted client from backend perspective; contains sensitive user inputs locally | Never expose secrets; show explicit offline/provider states; do not fabricate results |
| Humay backend/API | Orchestration, validation, access, normalization, cache coordination | First trusted server-side boundary | Reject malformed/unauthorized work; redact logs; never let Free fall through to paid generation |
| Humay catalog/static storage | Published Free content/reference data | Humay-controlled content plane | Missing object returns unavailable/stale-authorized behavior, never paid fallback |
| Humay result cache | Precision fact/text reuse | Humay-controlled server data plane | Invalid/stale/version-mismatched entry is a miss; no silent cross-version reuse |
| Calculation provider(s) | Deterministic structured astrology facts | External/untrusted vendor behind adapter | Validate normalized response; bounded retry; explicit unavailable/invalid-response failure |
| Interpretation provider(s) | Natural-language interpretation from structured facts | External/untrusted vendor behind adapter | Must not invent calculation facts; bounded retry; explicit failure; provenance retained |
| Store/ad systems | Later Premium/reward authorization | External platform/SDK boundary, not implemented here | Deferred to ARCH-007; must not redefine product access semantics |

A specific calculation API, LLM, hosting service, CDN or cache technology is intentionally **not** selected by this contract.

## 7. Data minimization and transmission

The backend request contract must be feature-specific and minimal.

Examples:

- Free Sun-sign daily content: send/use only the coarse catalog key; no full time/place payload.
- Natal chart: exact/approximate/unknown time and place/timezone are included only if needed and available.
- Precise compatibility: transmit only the two persons' fields required by the chosen validated methodology.
- Ask: structured context must be assembled from already-authorized facts/results rather than sending an unrestricted local profile dump.

Provider transmission rules, retention, deletion and export are finalized in ARCH-008 before production provider rollout.

## 8. Cache separation requirement

ARCH-004 owns storage technology and full cache-key rules, but the system boundary requires two separable cache layers/concepts:

1. **Calculation facts** — keyed by normalized calculation inputs + methodology/calculation version/provenance dimensions.
2. **Interpretation text** — keyed by the fact/result identity plus interpretation model/prompt/locale/tone dimensions.

Changing Roast/Normal wording, locale or prompt version must not require recalculating astronomy/astrology facts when the underlying valid fact set is unchanged.

## 9. Observability and cost controls

Future backend observability must be able to prove:

- ordinary Free request → 0 calculation-provider calls and 0 interpretation-provider calls;
- valid precision cache hit → 0 new paid provider calls;
- one authorized generation cannot fan out into duplicate unbounded provider work;
- provider retry counts and failure classes are measurable without logging raw sensitive birth/profile payloads;
- catalog and precision traffic are distinguishable operationally.

The current Apple `HumayLog` contract remains privacy-safe and does not receive provider payloads.

## 10. Deployment decisions deliberately deferred

ARCH-001 does not freeze:

- Cloudflare Worker vs another backend runtime;
- object storage/CDN vendor;
- database/cache technology;
- calculation provider vendor;
- interpretation/LLM vendor;
- API hostname;
- authentication/anonymous identity format;
- production/staging environment layout;
- StoreKit/ad SDK integration.

Those choices must satisfy this system contract when their owning tasks begin.

## 11. Consequences for implementation

- Phase 02 may define provider-independent calculation contracts once its Phase 01 dependency is verified.
- No iOS feature should import vendor SDK response models.
- Backend/provider runtime implementation remains blocked on its relevant Phase 00 contracts.
- Free Today/Compatibility implementation must have a testable zero-paid-call path.
- Precision features must be designed around cache/reopen behavior rather than "generate every tap".

See also:

- [`ASTROLOGY_ENGINE.md`](ASTROLOGY_ENGINE.md)
- [`IOS_ARCHITECTURE.md`](IOS_ARCHITECTURE.md)
- [`DATA_MODEL.md`](DATA_MODEL.md)
- [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md)
- [`../development/phases/00-technical-architecture.md`](../development/phases/00-technical-architecture.md)
