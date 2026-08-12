# Phase 11 — Hardening & Release Readiness

Status: **TODO**
Depends on: all included shipping phases

Goal: turn the integrated iPhone+iPad product into a release candidate through correctness, accessibility, performance, privacy, migration, cost and operational validation.

## Tasks

### RC-001 — Full cross-device accessibility audit
Status: TODO

Acceptance:
- Dynamic Type, VoiceOver order/labels, chart alternatives, contrast, Reduce Motion and hit targets are validated;
- astrology glyphs have useful spoken labels;
- representative iPhone/iPad layouts, including relevant iPad landscape/compact windows, are covered;
- pointer/keyboard behavior is functional where native platform behavior provides it.

### RC-002 — Performance and responsiveness audit
Status: TODO

Acceptance:
- launch, navigation, Chart/Today/Sky loading and long lists meet documented targets;
- expensive calculation/interpretation work does not block the main actor;
- cache behavior is measured, not assumed;
- iPad layouts do not introduce avoidable rendering/layout regressions.

### RC-003 — Offline/failure/recovery audit
Status: TODO

Acceptance:
- network loss, provider failure, calculation failure, ad failure and store failure have user-safe states;
- cached data is labeled/handled consistently;
- durable user-data failures do not silently become volatile storage.

### RC-004 — Persistence and migration audit
Status: TODO

Acceptance:
- migrations are tested from every actually shipped schema version;
- local profile, Saved People and any locally persisted cache/entitlement metadata included in the release have round-trip/migration coverage;
- corrupt/partial data has a recovery strategy;
- unknown birth time/place semantics survive migrations.

### RC-005 — Privacy/security audit
Status: TODO

Acceptance:
- logs do not expose birth/saved-person/private interpretation data unnecessarily;
- export/delete/privacy controls match implemented storage;
- third-party SDK/provider data flows are documented;
- secrets remain server-side where required.

### RC-006 — Astrology correctness and methodology release gate
Status: TODO

Acceptance:
- every shipping astrology feature identifies deterministic engine/methodology version where relevant;
- required METHOD tasks for shipping features are signed off;
- gated/unresolved features cannot appear as production-valid output;
- design/sample fixtures are not accepted as calculation validation.

### RC-007 — Monetization/store/ad QA
Status: TODO

Acceptance:
- purchase, restore/recovery, Premium transitions, rewarded success/failure and entitlement persistence are tested in appropriate sandbox/test environments;
- Free path remains functional without purchase/ad availability;
- cache-first and 0-paid-call Free invariants remain observable.

### RC-008 — End-to-end product QA against current design authority
Status: TODO

Acceptance:
- all included screens/states are checked against `docs/design/DESIGN_AUTHORITY.md`, the owning D-phase and approved packages under `docs/design/soulful-reference/`;
- iPhone Light/Dark + iPad Light/Dark are checked for every shipping screen family;
- iPad landscape/adaptive behavior is checked where documented;
- no deleted `final-archive`, old Paper/minimal, painterly exploration or historical design pass is used as authority;
- intentional implementation deviations are documented and approved rather than silently accepted.

### RC-009 — App Store/release documentation and operational checklist
Status: TODO

Acceptance:
- privacy/support/store metadata requirements are prepared;
- external Humay clearance status is explicitly resolved before brand-dependent public launch;
- release checklist, rollback/incident notes and versioning policy are documented.

### RC-010 — Release candidate sign-off
Status: TODO  
Depends on: RC-001 through RC-009

Acceptance:
- no unresolved critical defects;
- included methodology gates are closed;
- documentation/status accurately reflects the build and current design/product authority.

## Exit criteria

- release candidate is technically, visually and methodologically coherent for its included scope;
- deferred/gated features are clearly absent or labeled non-production;
- the repository contains enough current documentation for a new development session to continue without chat history.
