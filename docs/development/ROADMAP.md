# Humay Development Roadmap

This roadmap is dependency-driven rather than date-driven. Product/access authority is [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md). Visual work is governed by [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md) and the single current [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md).

## Shipping phase summary

| Phase | Name | Primary outcome | Depends on |
|---|---|---|---|
| 00 | Technical Architecture | Two-path content architecture, provider/cache contracts, repo structure and implementation plan | Product/access + visual authority |
| 01 | iOS Foundation | Buildable app shell, design system, navigation, persistence/test scaffolding | 00 + approved visual system |
| 02 | Astrology Calculation Foundation | Typed provider-independent calculation contracts, validation/provenance and precision adapters | 00–01 |
| 03 | Onboarding & Local Profile | Birth-data capture/editing, uncertainty, local profile persistence | 01–02 + D1 |
| 04 | Chart | Provider-backed natal chart with Rewarded/Premium access and cache | 02–03 + D4 |
| 05 | Today | Free catalog + precise personalized Today upgrade | 02–04 + D2 |
| 06 | Sky & Calendar | Current sky/event calendar and appropriate caching | 02–05 + D3 |
| 07 | Circle & Compatibility | Saved People, free 144-key Western compatibility, precise upgrade | 02–06 + D2 |
| 08 | Ask the Stars | Contextual provider-backed Q&A with explicit access/cost/safety boundary | 02–07 + D5 |
| 09 | Monetization & Generation Entitlements | Rewarded one-generation semantics, Premium, cache-aware access | 01–08 + D7 |
| 10 | Sharing, Widgets & Notifications | Share cards, widgets, Normal-only notifications | 05–09 + D8 |
| 11 | Hardening & Release | Accessibility, performance, privacy, cost controls, QA and launch readiness | all shipping phases + D9 |

## Visual design track — Light + Dark

This is the only active screen-design program.

| Design phase | Scope | Outcome |
|---|---|---|
| D0 | Visual anchors | Today/Home, Daily Horoscope and Compatibility define shared Soulful Celestial Light/Dark language |
| D1 | Onboarding | 9 onboarding screens × Light/Dark; gradual art intensity through reveal |
| D2 | Today + Circle | Today states, people, Today Together, compatibility and Free/precise/cached variants |
| D3 | Sky + Calendar | Current sky, month/week calendar, event detail and needed states |
| D4 | Chart | Overview, Western, placement detail, Vedic, Chinese/BaZi, Compare Systems, unknown-time/access states |
| D5 | Ask | Question, answer, loading, rewarded extension and failure/recovery states |
| D6 | Profile + Settings | Profile/settings, astrology, notifications, privacy and retained utility surfaces |
| D7 | Monetization + Access | Paywall, rewarded gate, confirmation, plan detail, provider-failure/cached states |
| D8 | Sharing + Widgets + States | Share system, widget family, loading/empty/error/offline references |
| D9 | Brand + Handoff | Light/Dark brand behavior, launch, token boards, asset catalog, contact sheets and final reconciliation |

See [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md) for complete coverage and approval criteria.

### Design dependency rule

Architecture/service work may continue while design is in progress. A feature family does **not receive final production visual polish** until its relevant D-phase has approved Light + Dark references.

## Completed mock-first track — Phase 01M

Phase 01M produced a launchable, navigable app over fixture content and remains useful for route coverage, service boundaries and accessibility testing. It is **not visual authority** and does not satisfy Phase 00/01 production exit criteria.

When production services land, `Humay/Data/Mock/` is replaced rather than extended.

## Product architecture invariant

Humay has two runtime paths:

- **Free catalog:** Humay-owned, pre-generated, versioned content; ordinary Free usage makes no paid astrology/LLM call.
- **Precision/personalized:** cache-first backend orchestration; Rewarded Access or Premium; structured astrology calculation + interpretation behind interfaces.

No engineering phase or UI design may blur this boundary.

## Release milestones

### Milestone A — Architecture + foundation

Complete Phases 00–03 and D0–D1.

Expected result: app shell/design-system foundation, profile/birth storage, backend/provider/cache boundaries, distinct Free/precision paths and approved Light/Dark onboarding.

### Milestone B — Core value build

Complete supported portions of Phases 04–06 and D2–D4.

Expected result: Rewarded/Premium Chart, Free/precise Today, validated Sky/Calendar sources and approved core product UI in Light/Dark.

### Milestone C — Relationship + contextual build

Complete supported portions of Phases 07–08 and D2/D5.

Expected result: Saved People, free Western 12 × 12 compatibility, precise compatibility, Ask over structured context and paired relationship/Ask UI.

### Milestone D — Monetized beta

Complete Phases 09–10 and D6–D8.

Expected result: Free/Rewarded/Premium behavior, cached reopening, settings, sharing/widgets/notifications and completed access UI in both appearances.

### Milestone E — Release candidate

Complete Phase 11, D9 and all methodology gates for included production features.

## Dependency rules

- Phase 00 freezes the production system boundary; completed Phase 01M is the recorded mock-first exception.
- Free content generation/publishing is a backend/content-pipeline responsibility, not an on-device LLM feature.
- Calculation facts and interpretation text are separately versioned/cacheable.
- No interpretation model may fabricate calculation facts.
- UI may use explicit fixtures while providers/methodology are incomplete; mock values are not validation truth.
- Chinese/BaZi or Vedic Free shortcuts require methodology validation of the coarse bucket model.
- Monetization enforces the product access model rather than redefining it in SDK-specific code.
- Numeric compatibility presentation is allowed, but production scoring methodology must be explicitly defined and validated.
- Every shipping screen family requires approved Light + Dark references before final visual freeze.

## Definition of roadmap completion

The roadmap is complete when:

- shipping phase exit criteria are satisfied;
- D0–D9 design handoff is reconciled with implementation;
- included methodology gates are signed off;
- Free runtime cost and cache behavior are tested/observable;
- release-candidate privacy/performance/accessibility/cost validation is complete;
- documentation reflects implemented product behavior and final Light/Dark authority.
