# Data Model — Clean Baseline

**Status:** current after the 2026-08-12 production reset.

Humay intentionally carries only user facts/preferences that already have product authority. The previous unshipped SwiftData schema was removed rather than treated as a migration obligation.

## Current domain values

### `BirthDetails`

Retained because its semantics are already important to product correctness:

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

## Persistence

No durable schema is committed yet. Persistence will be designed when the first production data-owning implementation slice lands.

Before shipping, the chosen persistence layer must:

- be versioned;
- preserve user-owned data reliably;
- avoid provider-native storage models;
- expose persistence failure explicitly;
- define migrations before changing a shipped schema.

## Future models

Circle people, Ask conversations, cached generated readings, provider results, chart data and entitlement/cache metadata should be introduced only with their owning production phase and methodology/access rules.
