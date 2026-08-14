# Data Model — Clean Baseline

**Status:** current after the 2026-08-12 production reset and ARCH-004 cache/offline contract.

Humay intentionally carries only user facts/preferences and feature contracts that already have product/architecture authority. The previous unshipped SwiftData schema was removed rather than treated as a migration obligation.

## Current domain values

### `BirthDetails`

Retained because its semantics are important to product correctness:

- year / month / day;
- `BirthTime.exact`, `.approximate`, or `.unknown`;
- `BirthPlace.known(...)` or `.notProvided`;
- precision is supported only when both time and place are known.

Unknown birth time must never be silently replaced with noon, midnight or another guessed time.

### `UserProfile`

Current minimal shape:

- stable local UUID;
- display name (may be empty until the product asks for one);
- `BirthDetails`.

### `AppSettings`

Current minimal shape:

- leading astrology tradition;
- reading tone (`normal` / `roast`);
- onboarding completion timestamp.

Notification preferences, purchase state, access entitlements, provider state and experiment flags are not part of this baseline.

### Astrology calculation contracts

Current Domain calculation values include:

- `BirthCalculationInput` reusing `BirthDetails`;
- typed calculation result/provenance/reliability contracts;
- independent Western/Vedic/BaZi adapter boundaries;
- the initial provider-independent Western fact vocabulary/structural validation.

These are Domain contracts only. No provider-native payload is persisted as user state.

## Current profile/settings persistence

PROFILE-005 introduces the first production durable slice as a local, versioned Codable snapshot. The Domain `UserStateStore` contract owns one aggregate containing `UserProfile?` and `AppSettings`; Data owns the DTO mapping and concrete file store.

Schema version 1 is stored at `Application Support/Humay/user-state.json`. The document includes only provider-independent profile/settings values: UUID, display name, calendar birth year/month/day, explicit birth-time and birth-place states, leading tradition, tone and onboarding completion timestamp. It contains no route, picker cursor, validation state, appearance state, provider result, cache, entitlement or Premium state.

The file store is actor-isolated, creates its app-owned directory before saving and uses atomic writes. Missing file returns no persisted state; read/decode failure, unsupported schema, write failure and clear failure are explicit errors. Completion commits application state only after the durable save succeeds. A failed restore is not treated as a fresh user, and production never falls back to an in-memory store.

Future migration logic belongs at the Data decoding boundary. No previous production schema shipped, so no legacy migration is included. SwiftData, Core Data, UserDefaults and CloudKit are not implemented. Private iCloud/CloudKit sync and restore remain planned later.

Humay V1 is accountless. It does not require email/password registration, Sign in with Apple or another Humay login. User-owned profile, preferences and saved-person data are local-first: local app storage is the immediate runtime source, and private iCloud/CloudKit-backed persistence is planned for Apple-device sync and restore. Private astrology/profile data must not use the public CloudKit database. Transient caches that do not need device sync may remain local.

CloudKit sync/restore, backend identity and authentication are not implemented yet. A later precision-request boundary may use anonymous app/backend identity without changing the user-owned data model into an account model.

## Result-cache ownership

ARCH-004 is authoritative: [`RESULT_CACHE_OFFLINE.md`](RESULT_CACHE_OFFLINE.md).

Humay separates these artifacts:

- **Free catalog artifact** — Humay-owned pre-generated content;
- **calculation artifact** — deterministic structured astrology facts + reliability/provenance;
- **interpretation artifact** — generated reading/prose over an existing calculation artifact;
- **Apple-local result mirror** — a non-authoritative local copy for responsiveness/offline reopening.

The server-side precision result cache is authoritative for paid-generation deduplication/idempotency. Apple-local copies do not authorize provider calls, consume rewards or redefine entitlement state.

Calculation and interpretation artifacts have separate semantic identities. Tone/locale/prompt changes may invalidate interpretation without changing deterministic calculation facts.

No generated-result local schema is added by ARCH-004 itself. The owning feature/runtime task introduces local result storage only when it has a real need and migration/eviction policy.

`user-state.json` remains profile/settings-only until an explicit versioned migration changes that contract.

## Offline data behavior

- valid local Free catalog copies may be displayed offline;
- absence of a valid Free artifact produces an explicit offline/unavailable state, never paid fallback;
- already-local personalized results may reopen offline where the owning feature permits;
- a new provider-backed generation cannot begin offline;
- no rewarded-generation opportunity is consumed while the authoritative backend generation path is unreachable.

## Development sample data

The current development workflow is UI-first, backend/API-second.

Approved screens may consume explicit **development sample data** before production APIs exist. Sample data:

- conforms to Humay-owned Domain/feature contracts;
- is development/preview/test content only;
- must not be stored or presented as authoritative provider output;
- must not restore the deleted mock-provider runtime architecture;
- must be replaceable by real Data/API adapters at composition without rewriting Presentation;
- must not be used as methodology/golden-fixture evidence.

Release builds must not present development sample astrology as real personalized calculation/interpretation output.

## Future persistence changes

Future persistence changes must:

- be versioned;
- preserve user-owned data reliably;
- avoid provider-native storage models;
- expose persistence failure explicitly;
- separate user-owned durable state from replaceable caches where practical;
- define migrations before changing a shipped schema.

## Future models

Circle people, Ask conversations, saved/generated readings, chart data and entitlement/cache metadata should be introduced only with their owning production phase and methodology/access rules.
