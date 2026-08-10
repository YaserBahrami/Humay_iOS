# Development Roadmap

This roadmap defines the implementation sequence for Humay. It is intentionally dependency-driven rather than date-driven. Estimates are not locked here; scope and correctness matter more than artificial deadlines.

## Phase summary

| Phase | Name | Primary outcome | Depends on |
|---|---|---|---|
| 00 | Technical Architecture | Architecture decisions, contracts, repo structure, implementation plan | Frozen design |
| 01 | iOS Foundation | Buildable app shell, design system, navigation, persistence/test scaffolding | 00 |
| 02 | Astrology Engine Foundation | Deterministic calculation boundary, validated fixtures, engine adapters | 00–01 |
| 03 | Onboarding & Local Profile | Birth-data capture/editing, location/time handling, profile persistence | 01–02 contracts |
| 04 | Chart | Western-first chart experience and safe partial-data behavior | 02–03 |
| 05 | Today | Daily personalized reading pipeline, basis disclosure, Normal/Roast | 02–04 |
| 06 | Sky & Calendar | Current sky, event calendar, event detail, caching | 02–05 |
| 07 | Circle & Compatibility | Saved people, relationship models, supported compatibility paths | 02–06 |
| 08 | Ask the Stars | Contextual Q&A over structured facts, access states, safety | 02–07 |
| 09 | Monetization | Premium + rewarded-access entitlement behavior | 01–08 |
| 10 | Sharing, Widgets & Notifications | Share cards, widgets, Normal-only notifications | 05–09 |
| 11 | Hardening & Release | Accessibility, performance, privacy, migration, QA, launch readiness | all shipping phases |

## Release strategy

The roadmap supports incremental internal builds. A phase may be internally testable before all later product areas exist, but no methodology-blocked astrology should ship as authoritative production output.

### Milestone A — Foundation build

Complete Phases 00–03.

Expected result:
- app launches with final Humay shell and navigation;
- local birth profile can be created and edited;
- persistence and calculation interfaces exist;
- no fake production astrology is required.

### Milestone B — Useful astrology build

Complete Phases 04–06 for the supported Western path.

Expected result:
- validated Chart foundation;
- Today reading pipeline;
- Sky + Calendar;
- unknown-time degradation behavior;
- deterministic facts separated from interpretation.

### Milestone C — Social/contextual build

Complete Phases 07–08 for methodologies that are signed off.

Expected result:
- Circle and saved people;
- supported compatibility;
- Ask the Stars over structured facts.

### Milestone D — Monetized beta

Complete Phases 09–10.

Expected result:
- Free / Rewarded Access / Premium behavior;
- sharing;
- widgets;
- notifications;
- no login required.

### Milestone E — Release candidate

Complete Phase 11 and all methodology gates for features included in the release.

## Dependency rules

- Phase 01 may begin once Phase 00 has frozen the core architecture decisions required for the app shell.
- Phase 02 must define trustworthy calculation contracts before any feature consumes astrology values as production truth.
- UI work may use explicit fixture/demo data while engine work is incomplete, but fixtures must be marked and must never be copied from unvalidated design mockups.
- Chinese/BaZi production screens may be implemented structurally behind a feature flag, but production calculation output remains blocked until its methodology track is signed off.
- Western composite readings, Vedic non-romantic compatibility, advanced BaZi Luck Cycles and full Compare Systems parity remain independently gated by methodology.
- Monetization implementation must not be used to decide product access semantics; those semantics are already frozen by design authority.

## Definition of roadmap completion

The development roadmap is complete when:
- all shipping phase exit criteria are satisfied;
- all included methodology gates are signed off;
- release-candidate validation is complete;
- documentation accurately reflects the implemented architecture and product behavior.
