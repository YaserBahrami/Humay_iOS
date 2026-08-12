# Deviations

This file records deliberate departures from the normal development sequence. A deviation is historical context, **not current product, architecture or design authority**.

There are no active deviations as of 2026-08-12.

---

## DEV-001 — Mock-first implementation ahead of Phase 00 exit

**Status:** CLOSED  
**Opened:** 2026-08-11  
**Closed:** 2026-08-12

### What happened

A broad mock-first application was generated before the production architecture/design program was finalized. It included prototype Presentation, DesignSystem, mock provider/fixture, persistence and feature implementations.

### Why it is closed

The repository was intentionally reset before production development. The old mock-first application code, obsolete design system, fixture runtime and premature persistence/provider assumptions were removed.

Current reconciliation is documented in:

- [`../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md`](../architecture/PRODUCTION_BASELINE_RESET_2026-08-12.md)
- [`../START_HERE.md`](../START_HERE.md)
- [`STATUS.md`](STATUS.md)

### Rule going forward

Do not restore deleted prototype code merely because it existed previously. If a useful concept is needed again, implement it against the current product/access, Clean Architecture, cross-device and Soulful Celestial authorities.

Git history remains available for archaeology only.
