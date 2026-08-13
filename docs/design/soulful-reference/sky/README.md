# D3 — Sky + Calendar Reference Package

**Status:** D3.1 Current Sky approved visual reference; later D3 families remain separately gated.

This directory holds the Soulful Celestial reference packages for D3 — Sky + Calendar. Current Sky is visually approved. Calendar is a review candidate, while Event Detail remains future work. No D3 production implementation is completed by these packages.

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
- [Calendar Month + Week](calendar/README.md) — **REVIEW CANDIDATE — NOT APPROVED**

Event Detail remains D3.3 future work and is not part of the Calendar package.

## Approval gate

A D3 screen is not approved until its package includes:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- iPad landscape/adaptive notes;
- compact-width fallback behavior;
- recorded review and approval status.

Only Current Sky has passed this visual gate. Its approval does not complete `SKY-003`. Calendar must pass its own product-owner review before `SKY-004` implementation, and asset-catalog presence does not constitute visual approval.
