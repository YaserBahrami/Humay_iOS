# Phase 11 — Hardening & Release Readiness

Status: **TODO**
Depends on: all included shipping phases

Goal: turn the integrated product into a release candidate through correctness, accessibility, performance, privacy, migration and operational validation.

## Tasks

### RC-001 — Full accessibility audit
Status: TODO

Acceptance:
- Dynamic Type, VoiceOver order/labels, chart alternatives, contrast, Reduce Motion and hit targets are validated.
- Astrology glyphs have useful spoken labels.

### RC-002 — Performance and responsiveness audit
Status: TODO

Acceptance:
- Launch, tab switching, Chart/Today/Sky loading and long lists meet documented targets.
- Expensive calculation/interpretation work does not block the main actor.
- Cache behavior is measured, not assumed.

### RC-003 — Offline/failure/recovery audit
Status: TODO

Acceptance:
- Network loss, provider failure, calculation failure, ad failure and store failure have user-safe states.
- Cached data is labeled/handled consistently.

### RC-004 — Persistence and migration audit
Status: TODO

Acceptance:
- Local profile/saved people/reward unlock migrations are tested from every released schema version created during development.
- Corrupt/partial data has a recovery strategy.

### RC-005 — Privacy/security audit
Status: TODO

Acceptance:
- Logs do not expose birth/saved-person/private interpretation data unnecessarily.
- Export/delete/privacy controls match implemented storage.
- Third-party SDK/data flows are documented.

### RC-006 — Astrology correctness and methodology release gate
Status: TODO

Acceptance:
- Every shipping astrology feature identifies its deterministic engine/methodology version.
- All required METHOD tasks for shipping features are signed off.
- Gated/unresolved features cannot accidentally appear as production-valid output.

### RC-007 — Monetization/store/ad QA
Status: TODO

Acceptance:
- Purchase, restore/recovery, Premium transitions, rewarded success/failure and entitlement persistence are tested in appropriate sandbox/test environments.
- Free path remains functional without purchase/ad availability.

### RC-008 — End-to-end product QA against frozen design
Status: TODO

Acceptance:
- All five tabs, onboarding, settings, access states and platform surfaces are checked against final archive/authority.
- Known intentional deviations are documented rather than silently accepted.

### RC-009 — App Store/release documentation and operational checklist
Status: TODO

Acceptance:
- Privacy/support/store metadata requirements are prepared.
- External Humay clearance status is explicitly resolved before brand-dependent public launch.
- Release checklist, rollback/incident notes and versioning policy are documented.

### RC-010 — Release candidate sign-off
Status: TODO
Depends on: RC-001 through RC-009

Acceptance:
- No unresolved critical defects.
- Included methodology gates are closed.
- Documentation/status accurately reflects the build.

## Exit criteria

- Release candidate is technically, visually and methodologically coherent for its included scope.
- Deferred/gated features are clearly absent or labeled non-production.
- The repository contains enough current documentation for a new development session to continue without chat history.
