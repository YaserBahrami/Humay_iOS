# Phase 04 — Chart

Status: **TODO**

Depends on:
- Phase 02 validated calculation contracts;
- Phase 03 profile/birth-data foundation;
- Phase 00 cache/access contracts required by provider-backed generation;
- approved D4 cross-device design references before feature-specific UI implementation.

Goal: deliver Humay's natal/precision Chart experience without creating paid provider cost for ordinary Free users.

## Tasks

### CHART-001 — Define Chart shell and access-state contract
Status: TODO

Acceptance:
- route/feature ownership matches canonical IA;
- Free state can explain/preview the precision feature but does not calculate a natal chart or call a paid provider;
- Rewarded/Premium/cached/error states follow current product-access contracts;
- no vendor/provider type enters Domain or Presentation.

### CHART-002 — Implement Western precision chart path
Status: TODO  
Depends on: CHART-001, ASTRO-003

Acceptance:
- calculation happens only after cache/access checks;
- major placements, houses/aspects where valid and uncertainty use typed provider-independent facts;
- unknown-time limitations are represented per fact;
- calculation provenance/version is retained.

### CHART-003 — Implement interpretation pipeline for chart factors
Status: TODO  
Depends on: ARCH-005, CHART-002

Acceptance:
- interpretation consumes deterministic structured factor IDs/values;
- calculation and interpretation versions are recorded separately;
- reopening a valid cached result does not regenerate it;
- interpretation cannot fabricate missing calculation facts.

### CHART-004 — Implement rewarded one-generation and Premium integration
Status: TODO  
Depends on: CHART-001, ARCH-007

Acceptance:
- cache hit opens without another ad/provider call;
- rewarded completion authorizes one required chart-generation result key;
- Premium bypasses the per-generation ad while entitlement is valid;
- provider failure recovery follows the entitlement contract.

### CHART-005 — Implement D4 Chart UI for iPhone + iPad
Status: TODO  
Depends on: CHART-002, approved D4 package

Acceptance:
- implementation uses current `docs/design/DESIGN_AUTHORITY.md` + D4 package, not deleted/historical design archives;
- iPhone Light/Dark and iPad Light/Dark are implemented intentionally;
- iPad landscape uses its approved chart/detail composition rather than a stretched iPhone layout;
- Dynamic Type, VoiceOver alternatives and pointer/keyboard behavior are considered where applicable.

### CHART-006 — Implement Vedic UI against methodology/provider gates
Status: TODO  
Depends on: CHART-001, ASTRO-004, approved D4 support

Acceptance:
- uses native Vedic terminology;
- unsigned methodology remains disabled/marked;
- unsupported output is a typed unavailable/pending state rather than guessed data.

### CHART-007 — Implement Chinese/BaZi structural UI behind methodology gate
Status: TODO  
Depends on: CHART-001, ASTRO-005, approved D4 support

Acceptance:
- production calculation remains gated until required methodology sign-off;
- development samples cannot be mistaken for production output.

### CHART-008 — Implement Compare Systems baseline
Status: TODO  
Depends on: supported CHART paths, approved D4 support

Acceptance:
- Shared themes / Different emphasis / Different perspective presentation follows current design/methodology;
- no fake ranking/confidence score;
- unsupported cross-system timing remains gated.

## Exit criteria

- ordinary Free usage never calculates a natal chart;
- supported precision Chart generation is cache-first and access-controlled;
- calculation facts remain provider-independent and validated;
- Vedic/BaZi respect methodology gates;
- shipping Chart surfaces reconcile with approved D4 iPhone+iPad Light/Dark references.
