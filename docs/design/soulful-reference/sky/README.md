# D3 — Sky + Calendar Reference Package

**Status:** design-preparation scaffolding only; no D3 visual reference is approved.

This directory will hold the approved Soulful Celestial references for D3 — Sky + Calendar. It currently contains specifications only. It does not contain final screenshots, implementation evidence, or approval.

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

- [Current Sky](current-sky/README.md) — requirements ready for visual design; references pending

Future Calendar and event-detail packages should be added only when their design work begins.

## Approval gate

A D3 screen is not approved until its package includes:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- iPad landscape/adaptive notes;
- compact-width fallback behavior;
- recorded review and approval status.

No D3 production SwiftUI may be implemented from this scaffolding. Asset-catalog presence also does not constitute visual approval.
