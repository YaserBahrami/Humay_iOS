# Phase 01 — iOS Foundation

Status: **TODO**
Depends on: Phase 00

Goal: produce a clean, buildable Humay app shell with the frozen design language, navigation contract, persistence/test scaffolding and no feature-specific astrology logic.

## Tasks

### IOS-001 — Create Xcode project and build targets
Status: TODO

Acceptance:
- iPhone/iPad app builds on supported deployment target.
- Bundle/product naming keeps Astara as repository/internal working name and Humay as consumer-facing copy.
- Debug/Release configuration and basic CI-ready build command exist.

### IOS-002 — Establish module/folder structure and dependency injection
Status: TODO
Depends on: IOS-001

Acceptance:
- Structure matches `IOS_ARCHITECTURE.md`.
- Feature code cannot reach concrete services without interfaces/composition root.

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
- Normal/Roast styling uses the frozen Gilt/Cinnabar rules.
- Representative design-system previews/tests exist.

### IOS-004 — Implement root navigation shell
Status: TODO
Depends on: IOS-002, IOS-003

Acceptance:
- Today / Circle / Sky / Chart / Ask tabs exist.
- Calendar is not a sixth tab.
- Profile/Settings entry is available from the header.
- Tab stacks preserve state according to architecture contract.

### IOS-005 — Add shared UI components and state surfaces
Status: TODO
Depends on: IOS-003

Scope:
- app header;
- section header;
- insight card;
- astrological-basis disclosure;
- buttons/controls/sheets;
- loading/empty/error/unavailable surfaces.

Acceptance:
- Components respect Dynamic Type and VoiceOver from the start.
- Feature screens do not duplicate foundational primitives unnecessarily.

### IOS-006 — Add persistence/test scaffolding
Status: TODO
Depends on: IOS-002

Acceptance:
- Persistence container/repository interfaces exist without prematurely finalizing feature schemas.
- Unit-test target and UI-test target build.
- Test fixtures are clearly separated from design mockup content.

### IOS-007 — Add diagnostics and configuration foundation
Status: TODO
Depends on: IOS-002

Acceptance:
- Structured logging with privacy-safe defaults.
- Environment/config abstraction for API endpoints, feature flags and dev-only fixtures.
- No secrets committed to the repository.

## Exit criteria

- App builds and launches.
- Frozen navigation and core visual system are represented faithfully.
- Accessibility foundations are in place.
- Architecture boundaries are enforced before astrology feature development begins.
