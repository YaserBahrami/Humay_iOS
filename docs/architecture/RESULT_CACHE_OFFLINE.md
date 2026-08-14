# Humay Result Cache & Offline Architecture

Status: **CURRENT ARCHITECTURE CONTRACT — ARCH-004 complete 2026-08-12**

This document defines Humay's persistence, result-cache identity, invalidation and offline behavior for Free catalog content and provider-backed precision results. It does not select a database, CDN, object store or cloud vendor.

Product/access authority remains [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md). Calculation semantics remain owned by [`ASTROLOGY_ENGINE.md`](ASTROLOGY_ENGINE.md).

## 1. Core invariants

- Free catalog content and precision results are different cache classes and never share a fallback path.
- A Free miss never invokes a paid astrology or interpretation provider.
- A valid precision cache hit is resolved before any new paid calculation, interpretation or rewarded-generation consumption.
- Deterministic calculation facts and interpretation text are cached independently.
- Tone, locale or copy changes never force deterministic recalculation when the underlying calculation identity is unchanged.
- Cache identity is derived from normalized result-changing dimensions, never from display formatting.
- Cache keys exposed to logs/analytics must not contain raw birth date/time/location, saved-person data or question text.
- Server-side precision cache is authoritative for generation/idempotency decisions; Apple-local cached copies are performance/offline mirrors, not entitlement or provider-call authority.
- Unknown/approximate birth time remains part of the normalized input semantics; cache identity must not collapse it to a guessed exact time.

## 2. Artifact classes

Humay treats these as separate versioned artifacts:

### 2.1 Free catalog artifact

Pre-generated Humay-owned content identified by a finite catalog key such as:

- feature/content family;
- astrology system or approved coarse bucket;
- date/period;
- locale;
- Normal/Roast variant where the stored copy differs;
- catalog schema/content version.

A Free catalog artifact contains no personalized calculation result.

### 2.2 Calculation artifact

Structured deterministic astrology facts plus reliability and provenance. It is independent of interpretation tone and prose.

Conceptually:

```text
CalculationArtifact
├── opaque artifact id
├── calculation semantic key/version
├── normalized facts
├── reliability/unavailable reasons
├── calculation provenance
├── createdAt
└── validity metadata
```

### 2.3 Interpretation artifact

Structured reading/prose generated from an already-existing calculation artifact plus explicitly authorized feature context.

Conceptually:

```text
InterpretationArtifact
├── opaque artifact id
├── calculation artifact identity/digest
├── feature/context identity
├── prompt/model/safety provenance
├── locale
├── tone
├── structured reading output
├── createdAt
└── validity metadata
```

### 2.4 Apple-local result mirror

The app may keep a local copy of already-authorized Free/precision artifacts for responsiveness and offline reopening. This mirror does not authorize new provider work and does not override server invalidation when connectivity returns.

User-owned save/bookmark metadata may later sync through private Apple storage; that is separate from server result-cache authority.

## 3. Calculation cache identity

A calculation semantic key includes every approved dimension that can change deterministic facts, for example:

- normalized relevant birth input(s), represented server-side by canonical serialization/fingerprint rather than loggable raw values;
- person ordering semantics when a calculation is pair-based;
- tradition;
- Humay methodology version;
- Humay calculation-contract version;
- requested fact-set/version;
- adapter/calculation-policy configuration version;
- event/transit date or period where the deterministic request depends on it.

It excludes dimensions that cannot change calculation facts:

- Normal vs Roast;
- UI layout;
- locale when it changes presentation only;
- interpretation prompt/model;
- notification/share-card formatting.

If a validated fallback engine is semantically equivalent under the same Humay methodology/calculation policy, the same semantic request may be satisfied by either adapter while provenance records the actual adapter/engine. If equivalence has not been validated, results are not interchangeable.

## 4. Interpretation cache identity

An interpretation semantic key is based on:

- calculation artifact identity or deterministic digest;
- feature/readout type;
- explicitly authorized non-calculation context that can change the reading;
- prompt-contract version;
- model-policy/configuration version;
- safety-policy version where output behavior can change;
- locale;
- tone (`normal` / `roast`);
- question/context digest for Ask-like features.

Changing tone, locale or prompt policy can invalidate interpretation text without recalculating astrology.

## 5. Validity and invalidation

Humay distinguishes **semantic invalidation** from ordinary **storage eviction**.

Semantic invalidation occurs when a version/dimension that can change the artifact changes, for example:

- methodology version changes;
- calculation contract/fact-set changes;
- calculation policy/configuration changes;
- prompt/model/safety policy changes for interpretation;
- the user's relevant birth input changes;
- the requested date/period changes;
- a published catalog version is superseded according to catalog policy.

Storage eviction is operational and may remove an old artifact to control space/cost without changing its semantics.

Time-sensitive artifacts may also have an explicit valid-through/refresh policy. A TTL must never substitute for a methodology/version change that actually changes semantics.

## 6. Server ownership

The Humay backend is authoritative for:

- precision cache-key derivation;
- deduplicating concurrent identical generation attempts;
- deciding whether a valid server artifact already exists;
- storing calculation and interpretation artifacts independently;
- server invalidation/version policy;
- provider-generation idempotency;
- returning opaque artifact/result identifiers to clients.

The Apple app must not become the authoritative deduplication layer for paid calls.

Humay V1 remains accountless. The exact anonymous backend identity/receipt mechanism is deferred to the backend/access/privacy implementation; cache architecture does not require login UI.

## 7. Apple-local cache ownership

The Apple app may locally cache:

- published Free catalog responses;
- previously returned calculation/interpretation results needed for reopening;
- presentation-ready derived data that can be regenerated from authoritative artifacts.

Local cache must be:

- versioned where persisted;
- replaceable/evictable without losing the user's profile/settings source of truth;
- separate from `user-state.json` unless a later migration explicitly changes ownership;
- treated as non-authoritative for generation entitlement and provider-call decisions;
- free of provider-native response objects.

Generated-result persistence should be introduced only with the owning feature/runtime implementation; ARCH-004 does not add a second local schema now.

## 8. Offline behavior

### Free

When offline:

- a valid local Free catalog artifact may be displayed;
- if no acceptable local artifact exists, show an explicit offline/unavailable state;
- never invoke or queue a paid precision provider as fallback.

### Precision

When offline:

- an already-local generated result may be reopened when its local validity metadata permits;
- time-sensitive stale results must be labeled/withheld according to the owning feature policy rather than silently presented as current;
- a new provider-backed generation cannot start;
- no rewarded-generation opportunity is consumed while the app cannot reach the authoritative generation path;
- the client may retain the user's draft/request locally if the owning feature deliberately supports retry, but it must not claim generation succeeded.

Whether previously generated Premium results remain viewable after entitlement expiry is still a product/ARCH-007 decision and is not silently decided here.

## 9. Failure and idempotency behavior

For provider-backed generation, the runtime order is conceptually:

```text
normalize request
      │
      ▼
derive semantic key
      │
      ▼
server cache lookup
   ┌──┴──┐
 hit    miss
  │       │
return   generation authorization
          │
          ▼
      idempotent generation
          │
          ▼
      cache + return
```

Retries for the same authorized generation must reuse the same idempotency scope. Concurrent identical requests should be coalesced server-side where practical. Fair recovery after a rewarded ad succeeds but generation fails belongs to ARCH-007, but this cache layer must support that recovery without duplicate paid fan-out.

## 10. Privacy and observability

- Raw birth/profile/question values are not emitted in ordinary logs or analytics.
- Cache hit/miss metrics use opaque result keys, feature names and version identifiers.
- Provider-call metrics count calls/cost without storing sensitive request bodies.
- A cache-key fingerprint is not treated as harmless public data merely because it is hashed.
- Retention/deletion/export policy is finalized by ARCH-008 before provider rollout.

## 11. Development/UI-first workflow

Humay may implement approved user-facing screens before the real backend/API by feeding the same Presentation/Domain contracts with **development sample data**.

Rules:

- sample data is explicit development/preview/test content, not production astrology truth;
- no shipped Release path may present sample values as calculated/provider output;
- sample states should cover cache hit, cache miss/loading, offline, stale/unavailable, Free and precision-access states needed by the approved UI;
- Presentation must not depend on the sample source type, so the later backend adapter can replace it at composition without redesigning the feature;
- the previous deleted mock-first provider architecture must not be restored.

## 12. Not selected by ARCH-004

This document does not choose:

- Redis/KV/D1/Postgres/object storage;
- Cloudflare/AWS/Fly/VPS hosting;
- local SQLite/SwiftData for result mirrors;
- a concrete anonymous identity scheme;
- exact per-feature TTL values;
- Premium-after-expiry viewing policy;
- provider retry counts.

Those decisions may be made by the owning backend/feature tasks while preserving this contract.
