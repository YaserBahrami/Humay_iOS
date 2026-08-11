# Phase 01 — iOS Foundation

Status: **TODO**
Depends on: Phase 00

Goal: produce a clean, buildable **Humay** app shell with the approved navigation/visual system, persistence/test scaffolding and no vendor-specific astrology logic.

## Tasks

### IOS-001 — Create Humay Xcode project and build targets
Status: TODO

Acceptance:
- iPhone/iPad app builds on the supported deployment target.
- Product, target, scheme and internal naming use **Humay**; no active `Astara` working-name requirement remains.
- Bundle identifier is chosen as a separate implementation decision and documented.
- Debug/Release configuration and a CI-ready build command exist.

### IOS-002 — Establish module/folder structure and dependency injection
Status: TODO
Depends on: IOS-001

Acceptance:
- Structure matches `IOS_ARCHITECTURE.md`.
- Feature code cannot reach concrete backend/provider services without interfaces/composition root.

### IOS-003 — Implement Humay design-system foundation
Status: TODO
Depends on: IOS-001

Scope:
- semantic colors/surfaces;
- typography roles;
- spacing/radius/border primitives;
- icon/glyph treatment;
- motion/reduced-motion primitives.

Acceptance:
- Light/dark semantic tokens are centralized.
- Normal/Roast styling follows the latest approved Humay visual direction.
- Representative previews/tests exist.

### IOS-004 — Implement root navigation shell
Status: TODO
Depends on: IOS-002, IOS-003

Acceptance:
- Today / Circle / Sky / Chart / Ask tabs exist unless the next design revision explicitly changes IA.
- Calendar is nested under Sky.
- Profile/Settings entry is available from the header.
- Tab stacks preserve state according to architecture contract.

### IOS-005 — Add shared UI components and access/state surfaces
Status: TODO
Depends on: IOS-003

Scope:
- app/section headers;
- insight cards/basis disclosure;
- buttons/controls/sheets;
- loading/empty/error/unavailable;
- Free coarse-content disclosure;
- Rewarded generation/Premium/cached-result states.

Acceptance:
- Components support Dynamic Type and VoiceOver from the start.
- Access components do not embed ad/provider SDK types.

### IOS-006 — Add persistence/test scaffolding
Status: TODO
Depends on: IOS-002

Acceptance:
- Persistence/repository interfaces support local profile and cached-result metadata without prematurely finalizing schemas.
- Unit/UI test targets build.
- Test fixtures are separated from design prototype content.

### IOS-007 — Add diagnostics and configuration foundation
Status: TODO
Depends on: IOS-002

Acceptance:
- Privacy-safe structured logging.
- Environment/config abstraction for Humay backend endpoints, feature flags and dev fixtures.
- No secrets committed or shipped for paid providers.

## Exit criteria

- Humay builds and launches.
- Navigation/core visual system matches the reconciled design authority.
- Access-state primitives exist without vendor coupling.
- Accessibility and architecture boundaries are in place before feature work.
