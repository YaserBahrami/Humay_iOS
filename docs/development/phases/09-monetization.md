# Phase 09 — Monetization & Entitlements

Status: **TODO**
Depends on: Phase 01, feature access contracts from Phases 04–08

Goal: implement the frozen Free → Rewarded Access → Premium behavior without coupling product logic to a specific store/ad SDK.

## Tasks

### MON-001 — Implement entitlement domain model
Status: TODO

Acceptance:
- Free, valid Premium, persistent content unlock and immediate Ask extension are distinct types.
- Premium is not represented as permanent/lifetime.

### MON-002 — Implement Premium purchase-status adapter
Status: TODO
Depends on: MON-001, ARCH-007

Acceptance:
- Store implementation sits behind an interface.
- Current Premium entitlement can be refreshed/recovered.
- No Humay login is required.

### MON-003 — Implement Premium/paywall surfaces
Status: TODO
Depends on: MON-002

Acceptance:
- Humay Premium screens match frozen design semantics.
- Manage/restore flows are reachable where architecture requires them.
- Free app remains useful when purchase infrastructure is unavailable.

### MON-004 — Implement rewarded-ad provider abstraction
Status: TODO
Depends on: MON-001, ARCH-007

Acceptance:
- Presentation/domain logic requests a reward outcome, not SDK objects.
- Cancel/failure/retry paths never grant a reward accidentally.
- Provider choice can change without rewriting features.

### MON-005 — Implement persistent per-item rewarded unlocks
Status: TODO
Depends on: MON-004, ARCH-004

Acceptance:
- Unlock key identifies one content item/section.
- Successful unlock survives restart and never re-prompts for that item.
- No temporary Premium semantics.

### MON-006 — Implement Ask immediate-extension entitlement
Status: TODO
Depends on: MON-004

Acceptance:
- Successful reward authorizes one additional Ask request.
- No wallet, balance or stacking UI.

### MON-007 — Add entitlement integration tests
Status: TODO
Depends on: MON-002 through MON-006

Acceptance:
- Free/Premium transitions, restore/recovery, ad success/failure, persistent unlock and Ask consumption are tested.

## Exit criteria

- Frozen monetization semantics are implemented independently of provider details.
- No account/login dependency exists.
- Entitlement loss/failure does not lose local profile data.
- Rewarded ads remain voluntary and bounded.
