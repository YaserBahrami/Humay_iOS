# Task Conventions

## Task IDs

Each production task uses a stable prefix and number:

- `ARCH-###` — technical/backend/provider architecture
- `IOS-###` — Apple platform foundation/design system
- `ASTRO-###` — deterministic astrology calculation foundation
- `PROFILE-###` — onboarding/local profile
- `CHART-###`
- `TODAY-###`
- `SKY-###`
- `CIRCLE-###`
- `ASK-###`
- `MON-###` — monetization/entitlements
- `PLATFORM-###` — sharing/widgets/notifications
- `RC-###` — hardening/release
- `METHOD-###` — methodology research/sign-off

The former mock-first task track is closed and must not be extended. Preview/test fixtures are implementation details of the production task that needs them, not a parallel product track.

Task IDs should not be renumbered after work begins.

## Status values

Use only:

- `TODO`
- `IN PROGRESS`
- `BLOCKED`
- `DONE`
- `DEFERRED`

A task is `DONE` only when its acceptance criteria and required tests/docs are satisfied.

## Task format

```text
### TASK-ID — Title
Status: TODO
Depends on: TASK-ID, ...

Scope:
- ...

Acceptance:
- ...

Notes:
- ...
```

## Completion discipline

For every completed task:

1. mark it `DONE` in the owning phase file;
2. update `STATUS.md` with the next active task;
3. add/update tests required by the task;
4. update architecture/reference docs if implementation changed a documented contract;
5. for user-facing UI, record the approved D-phase/reference package used and reconcile iPhone+iPad implementation evidence;
6. never mark methodology-dependent behavior complete using placeholder calculations.

## Scope changes

If new work is discovered:

- add a new stable task ID to the relevant phase;
- state why it was added;
- state whether it blocks phase exit criteria;
- do not bury scope changes inside implementation commits without updating the roadmap/status.

## Design references

For UI work, implementation tasks reference the current sources in this order:

1. `docs/design/DESIGN_AUTHORITY.md`;
2. the relevant D-phase in `docs/design/SCREEN_DESIGN_PLAN.md`;
3. the approved package under `docs/design/soulful-reference/`.

Do not reference deleted `final-archive`, old design passes, historical branches, or superseded onboarding drafts as implementation authority.

Screenshots/mock values are presentation references, never calculation fixtures.
