# Humay Development Plan

This directory is the persistent engineering roadmap for Humay. It should let any implementation session answer: **where are we, what is next, what is blocked, and what defines done?**

The existing visual/UX archive is frozen through Pass 6.1 as a reference baseline. The product access/cost model changed on **2026-08-11** and is authoritative in [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md). Access/monetization/personalization surfaces affected by that decision require the next Claude Design revision before implementation is considered visually final.

## How to use this plan

1. Read [`STATUS.md`](STATUS.md) first.
2. Read [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md) for Free/Rewarded/Premium and runtime-cost rules.
3. Read [`ROADMAP.md`](ROADMAP.md) for the full phase sequence.
4. Open the current phase file under [`phases/`](phases/).
5. Work tasks in dependency order and update task/acceptance criteria when a product or architecture decision changes.
6. At the end of each meaningful implementation session, update `STATUS.md` and the active phase checklist.

## Planning principles

- **Free runtime cost is bounded by design.** Ordinary Free content reads Humay-owned pre-generated catalogs and must not trigger paid astrology/LLM calls.
- **Cache before generation.** Rewarded and Premium personalized paths must reuse valid cached results before external provider calls.
- **Calculated facts before interpretation.** Precision astrology facts come from the calculation layer; the interpretation model does not invent positions, houses, aspects or timing.
- **Provider boundaries stay replaceable.** The initial direction is Astrologer API for calculation facts and DeepSeek V4 Flash for interpretation, both behind backend interfaces.
- **No authentication for v1 unless a concrete requirement emerges.** Entitlements and local profile data are separate concerns.
- **Methodology blockers are scoped.** Unresolved methodology blocks only the affected feature/path.
- **Every phase has exit criteria.** Code alone is not completion.
- **Keep main releasable.** Use feature flags/stubs for methodology-blocked work rather than fake production astrology.

## Documents

- [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md) — current product/access/cost decision.
- [`ROADMAP.md`](ROADMAP.md) — phase order, dependencies and release gates.
- [`STATUS.md`](STATUS.md) — current phase, active task and decisions/blockers.
- [`TASK_CONVENTIONS.md`](TASK_CONVENTIONS.md) — task IDs/status/update rules.
- [`METHODOLOGY_TRACK.md`](METHODOLOGY_TRACK.md) — astrology-methodology research/sign-off.
- [`phases/`](phases/) — phase-by-phase implementation tasks.

## Current state

**Planning only. No production iOS implementation has started.**

Current phase: **Phase 00 — Technical Architecture & Implementation Planning**.

Immediate goal: finish the architecture contracts for the two-path content system (Free catalog vs provider-backed precision), then revise Claude Design access states before feature implementation.
