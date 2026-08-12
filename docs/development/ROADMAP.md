# Humay Development Roadmap

This roadmap is dependency-driven rather than date-driven. Product/access authority is [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md). Visual work is governed by [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md) and [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md).

The old mock-first runtime was removed during the 2026-08-12 production-baseline reset. Production implementation now starts from a minimal iPhone + iPad project foundation.

## Shipping phase summary

| Phase | Name | Primary outcome | Depends on |
|---|---|---|---|
| 00 | Technical Architecture | Two-path content architecture, provider/cache contracts and implementation plan | Product/access + visual authority |
| 01 | Apple Platform Foundation | iPhone+iPad app shell, cross-device design system, navigation, persistence/test scaffolding | 00 + approved visual system |
| 02 | Astrology Calculation Foundation | Typed provider-independent calculation contracts, validation/provenance and precision adapters | 00–01 |
| 03 | Onboarding & Local Profile | Four-beat onboarding, birth-date capture, local profile persistence | 01–02 + D1 |
| 04 | Chart | Provider-backed natal chart with Rewarded/Premium access and cache | 02–03 + D4 |
| 05 | Today | Free catalog + precise personalized Today upgrade | 02–04 + D2 |
| 06 | Sky & Calendar | Current sky/event calendar and appropriate caching | 02–05 + D3 |
| 07 | Circle & Compatibility | Saved People, free 144-key Western compatibility, precise upgrade | 02–06 + D2 |
| 08 | Ask the Stars | Contextual provider-backed Q&A with explicit access/cost/safety boundary | 02–07 + D5 |
| 09 | Monetization & Generation Entitlements | Rewarded one-generation semantics, Premium, cache-aware access | 01–08 + D7 |
| 10 | Sharing, Widgets & Notifications | Share cards, widgets, Normal-register notifications | 05–09 + D8 |
| 11 | Hardening & Release | Cross-device accessibility, performance, privacy, cost controls, QA and launch readiness | all phases + D9 |

## Visual design track — iPhone + iPad, Light + Dark

| Design phase | Scope | Outcome |
|---|---|---|
| D0 | Visual anchors | Today/Home, Daily Horoscope and Compatibility define Soulful Celestial language; iPad companions added before cross-device freeze |
| D1 | Onboarding | Welcome, Birth Date, Tradition, Profile Reveal for iPhone+iPad, Light+Dark |
| D2 | Today + Circle | Today states, people, Today Together, compatibility and access/cache variants |
| D3 | Sky + Calendar | Current sky, month/week calendar, event detail and needed states |
| D4 | Chart | Overview, Western, placement detail, Vedic, Chinese/BaZi, Compare Systems, unknown-time/access states |
| D5 | Ask | Question, answer, loading, rewarded extension and failure/recovery states |
| D6 | Profile + Settings | Profile/settings, astrology, notifications, privacy and utility surfaces |
| D7 | Monetization + Access | Paywall, rewarded gate, confirmation, plan detail, provider-failure/cached states |
| D8 | Sharing + Widgets + States | Share system, widget family, loading/empty/error/offline references |
| D9 | Brand + Handoff | Light/Dark brand behavior, launch, token boards, asset catalog, iPhone/iPad contact sheets and reconciliation |

Every shipping screen requires iPhone Light/Dark + iPad Light/Dark. iPad landscape/adaptive behavior must be documented when the composition changes.

## Design → implementation rule

Architecture/provider work may continue while design is in progress. User-facing production UI follows this cadence:

1. design next family for iPhone+iPad, Light+Dark;
2. approve;
3. implement;
4. capture real cross-device screenshots;
5. reconcile implementation;
6. continue.

Do not let production UI get ahead of approved cross-device references.

## Product architecture invariant

Humay has two runtime paths:

- **Free catalog:** Humay-owned, pre-generated, versioned content; ordinary Free usage makes no paid astrology/LLM call.
- **Precision/personalized:** cache-first backend orchestration; Rewarded Access or Premium; structured astrology calculation + interpretation behind interfaces.

No engineering phase or UI design may blur this boundary.

## Release milestones

### Milestone A — Architecture + foundation

Complete Phases 00–03 and D0–D1.

Expected result: cross-device design-system/app foundation, profile/birth storage, backend/provider/cache boundaries and approved four-step onboarding on iPhone+iPad in both appearances.

### Milestone B — Core value build

Complete supported portions of Phases 04–06 and D2–D4.

Expected result: Rewarded/Premium Chart, Free/precise Today, validated Sky/Calendar sources and approved core UI across iPhone+iPad.

### Milestone C — Relationship + contextual build

Complete supported portions of Phases 07–08 and D2/D5.

Expected result: Saved People, free Western 12×12 compatibility, precise compatibility and Ask over structured context.

### Milestone D — Monetized beta

Complete Phases 09–10 and D6–D8.

Expected result: Free/Rewarded/Premium behavior, cached reopening, settings, sharing/widgets/notifications and access UI in both appearances and device families.

### Milestone E — Release candidate

Complete Phase 11, D9 and all methodology gates for included production features.

## Dependency rules

- Free content generation/publishing is backend/content-pipeline responsibility, not an on-device LLM feature.
- Calculation facts and interpretation text are separately versioned/cacheable.
- No interpretation model may fabricate calculation facts.
- Preview/sample values are never production truth.
- Chinese/BaZi or Vedic Free shortcuts require methodology validation of the coarse bucket model.
- Monetization enforces the product access model rather than redefining it in SDK-specific code.
- Numeric compatibility presentation is allowed, but production scoring methodology must be explicitly defined and validated.
- Unknown birth time is never silently replaced with a guessed time.

## Definition of roadmap completion

The roadmap is complete when shipping phase exit criteria are satisfied, D0–D9 handoff is reconciled with implementation, included methodology gates are signed off, runtime cost/cache behavior is tested, release-candidate privacy/performance/accessibility validation is complete, and documentation reflects the implemented iPhone+iPad product.
