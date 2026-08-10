# Task Conventions

## Task IDs

Each task uses a stable prefix and number:

- `ARCH-###` — technical architecture
- `IOS-###` — iOS foundation/design system
- `ASTRO-###` — deterministic astrology engine
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

1. mark it `DONE` in the phase file;
2. update `STATUS.md` with the next active task;
3. add or update tests required by the task;
4. update architecture/reference docs if the implementation changed a documented contract;
5. never mark methodology-dependent behavior complete using placeholder calculations.

## Scope changes

If new work is discovered:

- add a new stable task ID to the relevant phase;
- state why it was added;
- state whether it blocks the phase exit criteria;
- do not bury scope changes inside implementation commits without updating the roadmap.

## Design references

Implementation tasks should link to the relevant file under `docs/design/final-archive/reference/` or, when exact authority matters, `docs/design/DESIGN_AUTHORITY.md`.

Screenshots are implementation references, not calculation fixtures.
