# Humay Development Plan

This directory is the persistent engineering roadmap for Humay. It should let any implementation session answer: **where are we, what is next, what is blocked, and what defines done?**

Product access/cost authority is [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md). Current visual authority is [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md), with the only screen-design plan in [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md).

## How to use this plan

1. Read [`STATUS.md`](STATUS.md).
2. Read [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md).
3. Read [`ROADMAP.md`](ROADMAP.md).
4. For UI work, read [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md) and the relevant D-phase in [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md).
5. Open the active engineering phase file under [`phases/`](phases/).
6. Work tasks in dependency order and update status/acceptance criteria when a product or architecture decision changes.
7. Update `STATUS.md` after meaningful sessions.

## Planning principles

- **Free runtime cost is bounded by design.** Ordinary Free reads Humay-owned pre-generated catalogs and must not trigger paid astrology/LLM calls.
- **Cache before generation.** Rewarded and Premium personalized paths reuse valid cached results before external calls.
- **Calculated facts before interpretation.** The interpretation model never invents positions, houses, aspects or timing.
- **Provider boundaries stay replaceable.** Initial providers remain behind backend interfaces.
- **No authentication for v1 unless a concrete requirement emerges.** Entitlements and local profile data are separate concerns.
- **Methodology blockers are scoped.** Unresolved methodology blocks only affected feature paths.
- **Every phase has exit criteria.** Code alone is not completion.
- **One current design program.** Do not create or reference a parallel UI plan; update the current design authority/plan directly.

## Documents

- [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md) — product/access/cost rules.
- [`ROADMAP.md`](ROADMAP.md) — engineering phases plus D0–D9 visual dependencies.
- [`STATUS.md`](STATUS.md) — current priorities and blockers.
- [`TASK_CONVENTIONS.md`](TASK_CONVENTIONS.md) — task IDs/status/update rules.
- [`METHODOLOGY_TRACK.md`](METHODOLOGY_TRACK.md) — astrology-methodology research/sign-off.
- [`phases/`](phases/) — phase-by-phase implementation tasks.

## Current state

Current engineering phase: **Phase 00 — Technical Architecture & Implementation Planning**.

Current UI priority: **Soulful Celestial D0 → D1**, with Light + Dark references generated phase by phase before final production visual polish.
