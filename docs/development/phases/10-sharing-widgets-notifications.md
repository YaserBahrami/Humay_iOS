# Phase 10 — Sharing, Widgets & Notifications

Status: **TODO**

Depends on:
- owning feature surfaces/data contracts;
- current privacy/access architecture;
- approved D8 references before user-facing platform-surface implementation.

Goal: extend validated Humay content to system surfaces without leaking locked content, private saved-person data or Roast tone into notifications.

## Tasks

### PLATFORM-001 — Implement D8 share-card rendering
Status: TODO  
Depends on: approved D8 package + owning feature

Acceptance:
- uses current Design Authority and approved D8 share system;
- share output contains only already-visible/unlocked content;
- another person's private placements are not exposed by default;
- layout works for the approved export sizes without embedding stale UI screenshots.

### PLATFORM-002 — Implement system share sheet integration
Status: TODO  
Depends on: PLATFORM-001

Acceptance:
- export works from supported reading surfaces;
- failure/cancel leaves app state unchanged.

### PLATFORM-003 — Implement widget data contract and timeline behavior
Status: TODO

Acceptance:
- widget consumes compact Humay presentation data, not raw engine/vendor models;
- loading/stale/unavailable states are explicit;
- widget never bypasses access rules.

### PLATFORM-004 — Implement D8 widget layouts
Status: TODO  
Depends on: PLATFORM-003, approved D8 package

Acceptance:
- uses the current approved widget family rather than historical/frozen archive artifacts;
- supported widget families/sizes are explicitly documented;
- accessibility/content-density constraints appropriate to widgets are covered.

### PLATFORM-005 — Define notification scheduling/delivery architecture
Status: TODO  
Depends on: ARCH-006/privacy architecture

Acceptance:
- local vs remote delivery follows current architecture decision;
- permission request timing is contextual, not launch spam;
- notification inputs do not require exposing provider secrets or unnecessary private data to the client.

### PLATFORM-006 — Implement notification content/routing
Status: TODO  
Depends on: PLATFORM-005

Acceptance:
- notifications use Normal-register copy; no Roast notification path exists unless product policy changes;
- no urgency/FOMO language;
- deep links land on the intended supported route;
- routing remains consistent on iPhone and iPad.

### PLATFORM-007 — Add privacy/access tests for platform surfaces
Status: TODO  
Depends on: PLATFORM-001 through PLATFORM-006

Acceptance:
- locked content, saved-person privacy and notification-tone rules are covered by tests.

## Exit criteria

- sharing, widgets and notifications respect entitlement/privacy boundaries;
- platform-surface visuals use current D8 authority;
- Roast remains in-app only under current policy;
- deep-link behavior integrates cleanly with root navigation.
