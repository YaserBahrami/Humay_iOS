# Phase 09 — Monetization & Generation Entitlements

Status: **TODO**

Depends on:
- Phase 01 platform foundation;
- ARCH-007 entitlement/recovery architecture;
- implemented provider-backed feature result-key/cache contracts;
- approved D7 cross-device design references before feature-specific UI implementation.

Goal: implement **Free catalog → Rewarded one-generation access → Premium** while preserving the zero-paid-call Free invariant and cache-first behavior.

## Tasks

### MON-001 — Implement access/entitlement domain model
Status: TODO

Acceptance:
- Free catalog access, valid Premium, rewarded-generation authorization and cached-result availability are distinct concepts;
- Rewarded Access is not temporary Premium and is not a wallet/currency;
- domain types do not expose store/ad SDK objects.

### MON-002 — Implement Premium purchase-status adapter
Status: TODO  
Depends on: MON-001, ARCH-007

Acceptance:
- Store implementation sits behind an interface;
- Premium entitlement can be refreshed/recovered;
- no Humay login is required by default;
- purchase state is not embedded in UserProfile.

### MON-003 — Implement D7 Premium/paywall surfaces for iPhone + iPad
Status: TODO  
Depends on: MON-002, approved D7 package

Acceptance:
- surfaces use current Design Authority + approved D7 references;
- iPhone Light/Dark and iPad Light/Dark are intentional compositions;
- they explain personalized/precision value without implying Free content is broken/fake;
- Free catalog remains usable when purchase infrastructure is unavailable.

### MON-004 — Implement rewarded-ad provider abstraction
Status: TODO  
Depends on: MON-001, ARCH-007

Acceptance:
- Domain/Presentation requests a reward outcome rather than SDK objects;
- cancel/failure paths do not grant generation authorization;
- provider choice can change without rewriting features.

### MON-005 — Implement one-generation rewarded authorization
Status: TODO  
Depends on: MON-004, cache contract

Acceptance:
- cache lookup occurs before asking for an ad when the exact valid result already exists;
- successful reward authorizes exactly one needed provider-backed generation for the selected result key;
- successful result is cached/reopenable without another generation/ad;
- a materially different result key may require another reward.

### MON-006 — Implement provider-failure recovery after reward
Status: TODO  
Depends on: MON-005

Acceptance:
- user is not stranded after completing an ad when downstream generation fails;
- retry/recovery is idempotent and cannot multiply provider calls/rewards;
- recovery semantics are documented and tested.

### MON-007 — Add entitlement/cost integration tests
Status: TODO  
Depends on: MON-002 through MON-006

Acceptance:
- Free catalog requests cause 0 paid provider calls;
- cache hits cause 0 new paid provider calls and no redundant reward gate;
- Premium/reward transitions, ad success/failure and provider recovery are tested;
- duplicate client retries cannot duplicate generation.

## Exit criteria

- Free runtime cost invariant is enforced;
- Rewarded Access maps to one needed personalized generation, not temporary Premium;
- cached results reopen without repeat generation;
- Premium uses the same cache-first provider pipeline;
- no account/login dependency exists unless separately approved;
- shipping access surfaces reconcile with approved D7 iPhone+iPad Light/Dark references.
