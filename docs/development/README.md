# Humay Development Plan

This directory is the persistent engineering roadmap for Humay. It is intended to let any future implementation session answer four questions quickly: **where are we, what is next, what is blocked, and what defines done?**

The product design is frozen through **Pass 6.1 — Final Engineering Freeze**. Design authority remains under [`../design/`](../design/). This development plan does not supersede design or astrology-methodology authority.

## How to use this plan

1. Read [`STATUS.md`](STATUS.md) first.
2. Read [`ROADMAP.md`](ROADMAP.md) for the full phase sequence.
3. Open the current phase file under [`phases/`](phases/).
4. Work tasks in dependency order; do not skip exit criteria.
5. At the end of each meaningful implementation session, update `STATUS.md` and the current phase checklist in the same commit or immediately afterward.
6. If architecture or product decisions change, record them in the appropriate architecture document and link the decision from the affected phase; do not silently rewrite completed history.

## Planning principles

- **Foundation before features.** Architecture, calculation contracts, persistence, design-system primitives and test infrastructure come before feature breadth.
- **Deterministic astrology before interpretation.** Calculated facts are produced by deterministic engines. Interpretation consumes those facts; it never invents positions, houses, aspects, dashas, pillars or timing.
- **No authentication for v1.** Local profile data, Premium entitlement and rewarded entitlements are separate concerns. Account/login infrastructure is deferred unless a later product decision requires it.
- **Methodology blockers are scoped.** Unresolved astrology methodology blocks only the affected feature, not unrelated foundation work.
- **Every phase has exit criteria.** A phase is not complete because code exists; its tests, documentation and acceptance criteria must also be complete.
- **Keep main releasable.** Prefer small, reviewable commits and feature flags/stubs for methodology-blocked work instead of partially-valid production astrology.

## Documents

- [`ROADMAP.md`](ROADMAP.md) — phase order, dependencies and release gates.
- [`STATUS.md`](STATUS.md) — current phase, active task, blockers and last completed task.
- [`TASK_CONVENTIONS.md`](TASK_CONVENTIONS.md) — task IDs, statuses, acceptance criteria and update rules.
- [`phases/00-technical-architecture.md`](phases/00-technical-architecture.md)
- [`phases/01-ios-foundation.md`](phases/01-ios-foundation.md)
- [`phases/02-astrology-engine-foundation.md`](phases/02-astrology-engine-foundation.md)
- [`phases/03-onboarding-profile.md`](phases/03-onboarding-profile.md)
- [`phases/04-chart.md`](phases/04-chart.md)
- [`phases/05-today.md`](phases/05-today.md)
- [`phases/06-sky-calendar.md`](phases/06-sky-calendar.md)
- [`phases/07-circle-compatibility.md`](phases/07-circle-compatibility.md)
- [`phases/08-ask.md`](phases/08-ask.md)
- [`phases/09-monetization.md`](phases/09-monetization.md)
- [`phases/10-sharing-widgets-notifications.md`](phases/10-sharing-widgets-notifications.md)
- [`phases/11-hardening-release.md`](phases/11-hardening-release.md)
- [`METHODOLOGY_TRACK.md`](METHODOLOGY_TRACK.md) — feature-specific research/sign-off track that can run in parallel.

## Current state

**Planning initialized. No production iOS implementation has started.**

The immediate next phase is **Phase 00 — Technical Architecture & Implementation Planning**.
