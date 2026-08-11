# Phase 04 — Chart

Status: **TODO**
Depends on: Phase 02, Phase 03

Goal: deliver Humay's natal/precision Chart experience without creating paid provider cost for ordinary Free users.

## Tasks

### CHART-001 — Implement Chart shell and access states
Status: TODO

Acceptance:
- Matches the next reconciled Humay design.
- Free state can explain/preview the feature but does not calculate a natal chart or call a paid provider.
- Rewarded/Premium/cached-result/error states use shared access components.

### CHART-002 — Implement Western precision chart path
Status: TODO
Depends on: CHART-001, ASTRO-003

Acceptance:
- Calculation happens only after cache/access checks.
- Major placements, houses/aspects where valid and uncertainty use typed provider-independent facts.
- Unknown-time limitations are represented per fact.

### CHART-003 — Implement interpretation pipeline for chart factors
Status: TODO
Depends on: ARCH-005, CHART-002

Acceptance:
- Interpretation consumes deterministic/structured factor IDs and values.
- Calculation and interpretation versions are recorded separately.
- Reopening a valid cached chart/result does not regenerate it.

### CHART-004 — Implement rewarded one-generation and Premium integration
Status: TODO
Depends on: CHART-001, ARCH-007

Acceptance:
- A cache hit opens without another ad/provider call.
- A rewarded completion authorizes one required chart generation/result key.
- Premium bypasses the per-generation ad requirement while valid.
- Provider failure recovery follows the entitlement contract.

### CHART-005 — Implement Vedic UI against methodology/provider gates
Status: TODO
Depends on: CHART-001, ASTRO-004

Acceptance:
- Uses native Vedic terminology.
- Unsigned methodology remains disabled/marked.

### CHART-006 — Implement Chinese/BaZi structural UI behind feature gate
Status: TODO
Depends on: CHART-001, ASTRO-005

Acceptance:
- UI can use explicit development fixtures.
- Production calculation remains gated until methodology sign-off.

### CHART-007 — Implement Compare Systems baseline
Status: TODO
Depends on: supported CHART paths

Acceptance:
- Shared themes / Different emphasis / Different perspective presentation.
- No fake ranking/confidence score.
- Unsupported cross-system timing remains gated.

## Exit criteria

- No ordinary Free request calculates a natal chart.
- Supported precision Chart generation is cache-first and access-controlled.
- Calculation facts remain provider-independent and validated.
- Vedic/BaZi respect methodology gates.
