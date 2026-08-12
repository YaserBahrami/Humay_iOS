# Humay Development Plan

This directory is the persistent engineering roadmap for Humay. It should let any implementation session answer: **where are we, what is next, what is blocked, and what defines done?**

Start with [`../START_HERE.md`](../START_HERE.md).

Product access/cost authority is [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md). Current visual authority is [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md), with the only screen-design plan in [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md).

## How to use this plan

1. Read [`STATUS.md`](STATUS.md).
2. Read [`ROADMAP.md`](ROADMAP.md).
3. Read [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md).
4. For app architecture, read [`../architecture/IOS_ARCHITECTURE.md`](../architecture/IOS_ARCHITECTURE.md).
5. For UI work, read [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md) and the relevant D-phase in [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md).
6. Open the active engineering phase file under [`phases/`](phases/).
7. Work tasks in dependency order and update status/acceptance criteria when a product or architecture decision changes.
8. Update `STATUS.md` after meaningful sessions.

## Planning principles

- **Free runtime cost is bounded by design.** Ordinary Free reads Humay-owned pre-generated catalogs and must not trigger paid astrology/LLM calls.
- **Cache before generation.** Rewarded and Premium personalized paths reuse valid cached results before external calls.
- **Calculated facts before interpretation.** The interpretation model never invents positions, houses, aspects or timing.
- **Provider boundaries stay replaceable.** Initial providers remain behind backend interfaces.
- **Clean Architecture boundaries stay explicit.** App → Presentation → Domain ← Data; UI does not depend on provider/persistence implementations.
- **iPhone + iPad are first-class.** Foundation and shipping UI are cross-device from the start.
- **No authentication for v1 unless a concrete requirement emerges.** Entitlements and local profile data are separate concerns.
- **Methodology blockers are scoped.** Unresolved methodology blocks only affected feature paths.
- **Every phase has exit criteria.** Code alone is not completion.
- **One current design program.** Do not create or reference a parallel UI plan; update the current design authority/plan directly.
- **Git history is not current authority.** Deleted prototype implementation and obsolete design drafts stay deleted unless a current requirement explicitly justifies rebuilding the idea.

## Documents

- [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md) — product/access/cost rules.
- [`ROADMAP.md`](ROADMAP.md) — engineering phases plus D0–D9 visual dependencies.
- [`STATUS.md`](STATUS.md) — current priorities and blockers.
- [`TASK_CONVENTIONS.md`](TASK_CONVENTIONS.md) — task IDs/status/update rules.
- [`METHODOLOGY_TRACK.md`](METHODOLOGY_TRACK.md) — astrology-methodology research/sign-off.
- [`phases/`](phases/) — phase-by-phase implementation tasks.

## Current state

Primary engineering work: **Phase 03 — Onboarding & Local Profile (PROFILE-001–004 implemented; PROFILE-005 TODO)**.

Parallel architecture work: **Phase 00 — provider/cache/backend/access contracts (IN PROGRESS)**.

Current UI work: **D1 onboarding** — PROFILE-001 through PROFILE-004 production implementation is complete for Welcome, Birth Date, Tradition and Profile Reveal across iPhone/iPad Light/Dark. PROFILE-005 persistence remains TODO.
