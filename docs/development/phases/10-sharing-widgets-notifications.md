# Phase 10 — Sharing, Widgets & Notifications

Status: **TODO**
Depends on: Phases 05–09

Goal: extend validated Humay content to system surfaces without leaking locked content, private saved-person data or Roast tone into notifications.

## Tasks

### PLATFORM-001 — Implement share-card rendering
Status: TODO

Acceptance:
- Uses frozen Humay share treatment.
- Share output contains only already-visible/unlocked content.
- Another person's private placements are not exposed by default.

### PLATFORM-002 — Implement system share sheet integration
Status: TODO
Depends on: PLATFORM-001

Acceptance:
- Export works from supported reading surfaces.
- Failure/cancel leaves app state unchanged.

### PLATFORM-003 — Implement widget data contract and timeline behavior
Status: TODO

Acceptance:
- Widget consumes compact presentation data, not raw engine/vendor models.
- Loading/stale/unavailable states are explicit.
- Widget never bypasses access rules.

### PLATFORM-004 — Implement widget layouts
Status: TODO
Depends on: PLATFORM-003

Acceptance:
- Representative frozen widget sizes/styles are respected.
- Dynamic Type/accessibility constraints appropriate to widgets are covered.

### PLATFORM-005 — Define notification scheduling/delivery architecture
Status: TODO
Depends on: ARCH-006

Acceptance:
- Local vs remote delivery follows architecture decision.
- Permission request timing is contextual, not launch spam.

### PLATFORM-006 — Implement notification content/routing
Status: TODO
Depends on: PLATFORM-005

Acceptance:
- Notifications are always Normal tone; no Roast toggle/path exists.
- No urgency/FOMO language.
- Deep links land on the intended supported surface.

### PLATFORM-007 — Add privacy/access tests for platform surfaces
Status: TODO
Depends on: PLATFORM-001 through PLATFORM-006

Acceptance:
- Locked content, saved-person privacy and notification-tone rules are covered by tests.

## Exit criteria

- Sharing, widgets and notifications respect entitlement/privacy boundaries.
- Roast remains in-app only.
- Deep-link behavior integrates cleanly with root navigation.
