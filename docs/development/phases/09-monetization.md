# Phase 09 — Monetization & Generation Entitlements

Status: **TODO**
Depends on: Phase 01, feature access contracts from Phases 04–08

Goal: implement **Free catalog → Rewarded one-generation access → Premium** while preserving the zero-paid-call Free invariant and cache-first behavior.

## Tasks

### MON-001 — Implement access/entitlement domain model
Status: TODO

Acceptance:
- Free catalog access, valid Premium, rewarded-generation authorization and cached-result availability are distinct concepts.
- Rewarded Access is not temporary Premium and is not a wallet/currency.

### MON-002 — Implement Premium purchase-status adapter
Status: TODO
Depends on: MON-001, ARCH-007

Acceptance:
- Store implementation sits behind an interface.
- Premium entitlement can be refreshed/recovered.
- No Humay login is required by default.

### MON-003 — Implement Premium/paywall surfaces
Status: TODO
Depends on: MON-002

Acceptance:
- Surfaces match the next reconciled design.
- They explain personalized/precision value without implying Free content is broken or fake.
- Free catalog remains usable when purchase infrastructure is unavailable.

### MON-004 — Implement rewarded-ad provider abstraction
Status: TODO
Depends on: MON-001, ARCH-007

Acceptance:
- Domain/presentation requests a reward outcome, not SDK objects.
- Cancel/failure paths do not grant generation authorization.
- Provider choice can change without rewriting features.

### MON-005 — Implement one-generation rewarded authorization
Status: TODO
Depends on: MON-004, ARCH-004

Acceptance:
- Cache lookup happens before asking for an ad when the exact valid result already exists.
- Successful reward authorizes exactly one needed provider-backed generation for the selected feature/result key.
- Successful generated result is cached and reopenable without another generation/ad.
- A new materially different result key can require another reward.

### MON-006 — Implement provider-failure recovery after reward
Status: TODO
Depends on: MON-005

Acceptance:
- User is not stranded after completing an ad when downstream generation fails.
- Retry/recovery is idempotent and cannot multiply provider calls/rewards.
- Recovery semantics are documented and tested.

### MON-007 — Add entitlement/cost integration tests
Status: TODO
Depends on: MON-002 through MON-006

Acceptance:
- Free catalog requests cause 0 paid provider calls.
- Cache hits cause 0 new paid provider calls and no redundant reward gate.
- Premium/reward transitions, ad success/failure and provider recovery are tested.
- Duplicate client retries cannot duplicate generation.

## Exit criteria

- Free runtime cost invariant is enforced.
- Rewarded Access maps to one required personalized generation, not temporary Premium.
- Cached results reopen without repeat generation.
- Premium uses the same cache-first provider pipeline.
- No account/login dependency exists unless separately approved.
