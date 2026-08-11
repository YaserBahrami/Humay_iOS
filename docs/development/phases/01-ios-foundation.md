# Phase 01 — iOS Foundation

Status: **TODO**  
Depends on: Phase 00

Goal: produce a clean, buildable Humay app shell with the approved navigation/visual system, persistence/test scaffolding and no vendor-specific astrology logic.

## Tasks

### IOS-001 — Production project/build baseline
Status: TODO

Acceptance:
- iPhone app builds on the supported deployment target.
- Product, target, scheme and internal naming use **Humay**.
- Debug/Release configuration and a CI-ready build command exist.
- Existing mock-first project work is reconciled rather than blindly duplicated.

### IOS-002 — Module/folder structure and dependency injection
Status: TODO  
Depends on: IOS-001

Acceptance:
- Structure matches `IOS_ARCHITECTURE.md`.
- Feature code cannot reach concrete backend/provider services without interfaces/composition root.

### IOS-003 — Production Humay design-system foundation
Status: TODO  
Depends on: IOS-001

Scope:
- semantic Light/Dark colors/surfaces;
- typography roles;
- spacing/radius/border/elevation primitives;
- icon/glyph treatment;
- illustration hooks/assets;
- motion/reduced-motion primitives.

Acceptance:
- Light/Dark semantic tokens are centralized.
- Components match `docs/design/DESIGN_AUTHORITY.md` and `SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`.
- Representative previews/tests exist.

### IOS-004 — Root navigation shell
Status: TODO  
Depends on: IOS-002, IOS-003

Acceptance:
- Today / Circle / Sky / Chart / Ask are the primary tabs.
- Calendar is nested under Sky.
- Profile/Settings entry is available from the header.
- Per-tab navigation state follows the architecture contract.

### IOS-005 — Shared UI components and access/state surfaces
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
- Final visual polish follows the relevant approved D-phase Light/Dark references.

### IOS-006 — Persistence/test scaffolding
Status: TODO  
Depends on: IOS-002

Acceptance:
- Persistence/repository interfaces support local profile and cached-result metadata.
- Unit/UI test targets build.
- Test fixtures remain separate from production calculation truth.

### IOS-007 — Diagnostics and configuration foundation
Status: TODO  
Depends on: IOS-002

Acceptance:
- Privacy-safe structured logging.
- Environment/config abstraction for backend endpoints, flags and dev fixtures.
- No paid-provider secrets are committed or shipped.

## Exit criteria

- Humay builds and launches on the supported iPhone target.
- Navigation/core visual system matches the single current design authority.
- Access-state primitives exist without vendor coupling.
- Accessibility and architecture boundaries are in place before production feature work.
