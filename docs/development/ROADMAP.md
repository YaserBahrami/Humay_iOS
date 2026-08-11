# Humay Development Roadmap

This roadmap is dependency-driven rather than date-driven. The current product/access authority is [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md). Current visual work is governed by [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md).

## Shipping phase summary

| Phase | Name | Primary outcome | Depends on |
|---|---|---|---|
| 00 | Technical Architecture | Two-path content architecture, provider/cache contracts, repo structure and implementation plan | Product/access decision + visual baseline |
| 01 | iOS Foundation | Buildable Humay app shell, design system, navigation, persistence/test scaffolding | 00 + approved visual system |
| 02 | Astrology Calculation Foundation | Typed provider-independent calculation contracts, validation/provenance and precision adapters | 00–01 |
| 03 | Onboarding & Local Profile | Birth-data capture/editing, uncertainty, local profile persistence | 01–02 contracts + D1 visual references |
| 04 | Chart | Provider-backed natal chart experience with Rewarded/Premium access and cache | 02–03 + D4 visual references |
| 05 | Today | Zero-runtime-cost Free catalog + precise personalized Today upgrade | 02–04 + D2 visual references |
| 06 | Sky & Calendar | Current sky/event calendar and cache strategy appropriate to each data source | 02–05 + D3 visual references |
| 07 | Circle & Compatibility | Saved People, free 144-key Western compatibility and precise compatibility upgrade | 02–06 + D2 visual references |
| 08 | Ask the Stars | Contextual provider-backed Q&A with explicit access/cost/safety boundary | 02–07 + D5 visual references |
| 09 | Monetization & Generation Entitlements | Rewarded one-generation semantics, Premium and cache-aware access | 01–08 + D7 visual references |
| 10 | Sharing, Widgets & Notifications | Share cards, widgets, Normal-only notifications | 05–09 + D8 visual references |
| 11 | Hardening & Release | Accessibility, performance, privacy, cost controls, QA and launch readiness | all shipping phases + D9 handoff |

## Visual redesign track — Light + Dark

The 2026-08-12 product direction supersedes the previous minimal appearance. The visual redesign is a parallel, explicit dependency for final production UI polish.

| Design phase | Scope | Primary outcome |
|---|---|---|
| D0 | Visual anchors | Today/Home, Daily Horoscope and Compatibility define shared Soulful Celestial Light/Dark language |
| D1 | Onboarding | 9 onboarding screens × Light/Dark; gradual art intensity through reveal |
| D2 | Today + Circle | Today states, people, Today Together, compatibility and precise/free/cached variants |
| D3 | Sky + Calendar | Current sky, month/week calendar, event detail and needed states |
| D4 | Chart | Overview, Western, placement detail, Vedic, Chinese/BaZi, Compare Systems, unknown-time/access states |
| D5 | Ask | Question, answer, loading, rewarded extension and failure/recovery states |
| D6 | Profile + Settings | Profile/settings, astrology, notifications, privacy and other retained utility surfaces |
| D7 | Monetization + Access | Paywall, rewarded gate, confirmation, plan detail, provider-failure/cached states |
| D8 | Sharing + Widgets + States | Share system, widget family, global loading/empty/error/offline references |
| D9 | Brand + Handoff | Light/Dark brand behavior, launch, token boards, asset catalog, contact sheets and final reconciliation |

See [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md) for the complete inventory and approval checklist.

### Design dependency rule

Architecture/service work may continue while design is in progress. A feature family should **not receive final production visual polish** until its relevant D-phase has approved Light + Dark references. This prevents the mock-first minimal UI from accidentally becoming the production visual baseline.

## Parallel track — Phase 01M

| Phase | Name | Primary outcome | Status |
|---|---|---|---|
| 01M | [Mock-First iOS Application](phases/01M-mock-first-app.md) | Launchable, navigable app with architecture, a11y-aware components and complete flows over mock content behind service protocols | Complete |

Phase 01M is still useful as a **structural, interaction and accessibility baseline**, but its minimal visual treatment has been superseded by the Soulful Celestial redesign.

It does not satisfy the exit criteria of Phase 00 or Phase 01 and advances no production provider/access feature by itself. When Phase 00 completes, `Humay/Data/Mock/` is replaced rather than extended.

## Product architecture invariant

Humay has two runtime paths:

- **Free catalog:** Humay-owned, pre-generated, versioned content; no paid astrology or LLM call during ordinary Free use.
- **Precision/personalized:** cache-first backend orchestration; Rewarded Access or Premium; astrology calculation provider + interpretation provider behind interfaces.

No phase or visual design may blur this boundary.

## Release milestones

### Milestone A — Architecture + foundation

Complete Phases 00–03 and relevant D0–D1 visual work.

Expected result:
- Humay app shell and production-ready design system foundation;
- profile/birth data stored safely;
- backend/provider/cache boundaries defined;
- Free catalog and precision paths distinct;
- onboarding has approved Light/Dark presentation;
- no fake astrology required.

### Milestone B — Core value build

Complete supported portions of Phases 04–06 and D2–D4.

Expected result:
- Rewarded/Premium natal Chart path;
- Free catalog Today;
- precise personalized Today only after access/cache checks;
- Sky/Calendar supported by validated data sources;
- core product screens visually approved in Light and Dark.

### Milestone C — Relationship + contextual build

Complete supported portions of Phases 07–08 and D2/D5.

Expected result:
- Saved People;
- free Western 12 × 12 compatibility catalog;
- precise compatibility behind Rewarded/Premium;
- Ask over structured context without uncontrolled Free provider spend;
- paired relationship/Ask visual references implemented.

### Milestone D — Monetized beta

Complete Phases 09–10 and D6–D8.

Expected result:
- Free / Rewarded generation / Premium behavior;
- cache-aware reopening of generated results;
- sharing/widgets/notifications;
- completed settings/access visual families in both appearances;
- no login required unless separately approved.

### Milestone E — Release candidate

Complete Phase 11 and D9 plus all methodology gates for included production features.

## Dependency rules

- Phase 00 freezes the production system boundary; Phase 01M remains the recorded mock-first exception.
- Free content generation/publishing is a backend/content-pipeline responsibility, not an on-device LLM feature.
- Provider-backed calculation facts and interpretation text are separately versioned/cacheable.
- No interpretation model may fabricate calculation facts.
- Chart and other natal-level precision features do not require a free calculated baseline.
- UI may use explicit fixtures while providers/methodology are incomplete; design mockup values are not validation truth.
- Chinese/BaZi or Vedic paths may expose Free catalog shortcuts only when methodology validates the coarse bucket model.
- Monetization enforces the product access model; it does not redefine it in SDK-specific code.
- Numeric compatibility presentation is allowed by current design authority, but the production scoring methodology must be explicitly defined and validated.
- Every shipping screen family requires approved Light + Dark references before final visual freeze.

## Definition of roadmap completion

The roadmap is complete when:
- shipping phase exit criteria are satisfied;
- D0–D9 design handoff is reconciled with implementation;
- included methodology gates are signed off;
- Free runtime cost invariants and cache behavior are tested/observable;
- release-candidate privacy/performance/accessibility/cost validation is complete;
- documentation reflects implemented product behavior and final Light/Dark visual authority.