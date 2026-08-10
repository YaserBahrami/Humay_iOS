# Phase 04 — Chart

Status: **TODO**
Depends on: Phase 02, Phase 03

Goal: ship the first complete astrology-reading surface on top of deterministic chart facts.

## Tasks

### CHART-001 — Implement Chart overview shell
Status: TODO

Acceptance:
- Matches final archive structure and system switching behavior.
- Loading/error/unavailable states use shared components.

### CHART-002 — Implement Western chart experience
Status: TODO
Depends on: CHART-001, ASTRO-003

Acceptance:
- Major placements, houses/aspects where valid, and basis disclosures use typed facts.
- Unknown-time limitations are shown per fact rather than disabling the whole chart.

### CHART-003 — Implement interpretation pipeline for chart factors
Status: TODO
Depends on: ARCH-005, CHART-002

Acceptance:
- Interpretation consumes deterministic factor IDs/values.
- Cached/retried interpretations remain tied to calculation and prompt versions.

### CHART-004 — Implement advanced factor/detail access states
Status: TODO
Depends on: CHART-002

Acceptance:
- Free baseline is useful.
- Reward/Premium gates are represented through entitlement interfaces, even if monetization providers are not yet wired.

### CHART-005 — Implement Vedic UI against gated engine contract
Status: TODO
Depends on: CHART-001, ASTRO-004

Acceptance:
- Uses native Vedic terminology.
- Production behavior requiring unsigned methodology remains disabled/marked.

### CHART-006 — Implement Chinese/BaZi structural UI behind feature gate
Status: TODO
Depends on: CHART-001, ASTRO-005

Acceptance:
- UI can be exercised with explicit development fixtures.
- Production calculation path remains disabled until methodology gates close.

### CHART-007 — Implement Compare Systems baseline
Status: TODO
Depends on: CHART-002, CHART-005, CHART-006

Acceptance:
- Shared themes / Different emphasis / Different perspective presentation.
- No ranking or confidence scoring.
- Timing parity remains gated by METHOD-009.

## Exit criteria

- Western Chart is production-valid for supported inputs.
- Unknown-time behavior is correct.
- Vedic/BaZi surfaces respect methodology gating.
- Compare Systems does not imply scientific agreement/confidence.
