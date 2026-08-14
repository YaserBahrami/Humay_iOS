# D3 — Sky + Calendar Reference Package

**Status:** D3.1 Current Sky, D3.2 Calendar, and D3.3 Event Detail approved visual references.

This directory holds the Soulful Celestial reference packages for D3 — Sky + Calendar. Current Sky, Calendar, and Event Detail are visually approved. No D3 production implementation is completed by these packages.

## Authority

Use these sources in order:

1. [Humay Design Authority](../../DESIGN_AUTHORITY.md)
2. [Soulful Celestial Design Direction](../../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [Cross-Device Screen Design Plan](../../SCREEN_DESIGN_PLAN.md)
4. The approved screen package in this directory, once one exists

Product, methodology, accessibility, and device constraints override a mockup when they conflict.

## D3 scope

D3 eventually covers:

1. Current Sky
2. Calendar month
3. Calendar week
4. Event detail
5. Required loading, empty, unavailable, offline, and failed states

Calendar remains nested under Sky. It is not a sixth root destination.

## Package index

- [Current Sky](current-sky/README.md) — **APPROVED VISUAL REFERENCE**
- [Calendar Month + Week](calendar/README.md) — **APPROVED VISUAL REFERENCE**
- [Event Detail](event-detail/README.md) — **APPROVED VISUAL REFERENCE**

Event Detail is D3.3 and remains separately gated from production implementation.

## Approval gate

A D3 screen is not approved until its package includes:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- iPad landscape/adaptive notes;
- compact-width fallback behavior;
- recorded review and approval status.

Current Sky, Calendar, and Event Detail have passed this visual gate. Their approvals support `SKY-003`, `SKY-004`, and `SKY-005` implementation/reconciliation over Debug-only samples; `SKY-002` and `SKY-006` remain pending. Asset-catalog presence does not constitute visual approval.
