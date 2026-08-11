# Phase 05 — Today

Status: **TODO**
Depends on: Phase 02, Phase 04 contracts

Goal: deliver a useful zero-runtime-cost Free daily reading plus an optional precise personalized upgrade.

## Tasks

### TODAY-001 — Define Free vs precision Today contracts
Status: TODO

Acceptance:
- Free reading key uses only the approved coarse system bucket/date/locale/variant inputs.
- Western Free baseline is a 12-Sun-sign daily catalog.
- Precision reading contract uses structured natal/timing facts when access permits.
- The two paths cannot be confused in telemetry/cache/UI basis disclosure.

### TODAY-002 — Implement Free daily catalog pipeline and app cache
Status: TODO
Depends on: TODAY-001, ARCH-006

Acceptance:
- Reads Humay-owned pre-generated/versioned backend content.
- Offline/edge/local cache behavior is defined.
- A missing Free entry never silently falls through to a paid provider.
- Tests assert 0 paid provider calls for normal Free requests.

### TODAY-003 — Implement primary Today UI
Status: TODO
Depends on: TODAY-002

Acceptance:
- Matches the next reconciled Humay design.
- Free experience is useful while clearly labeled as coarse/sign- or system-bucket-based.
- Precision upgrade/cached-result state is understandable without overstating accuracy.

### TODAY-004 — Implement astrological basis/accuracy disclosure
Status: TODO
Depends on: TODAY-003

Acceptance:
- Free disclosure states the coarse basis and does not claim natal personalization.
- Precision disclosure can reference the structured calculated factors actually used.
- Copy avoids presenting astrology as scientific evidence.

### TODAY-005 — Implement Normal/Roast expression behavior
Status: TODO
Depends on: TODAY-002, ARCH-005

Acceptance:
- Normal/Roast never change underlying astrology facts.
- Calculation facts are not recalculated merely for tone.
- Notifications remain Normal-only.

### TODAY-006 — Implement precise personalized Today generation
Status: TODO
Depends on: TODAY-001, ARCH-003, ARCH-005, ARCH-007

Acceptance:
- Cache lookup happens before reward/provider generation.
- Rewarded Access authorizes one needed personalized result generation; successful result is cached/reopenable.
- Premium uses the same cache-first path without the per-generation ad.
- Provider failures have typed retry/recovery behavior.

## Exit criteria

- Free Today causes 0 paid provider calls.
- Western Free catalog supports all 12 signs for every published day/variant.
- Precision Today is access-controlled, cache-first and sourceable to structured facts.
- Free vs precision accuracy/basis is transparent.
