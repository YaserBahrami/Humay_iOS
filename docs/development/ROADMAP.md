# Humay Development Roadmap

This roadmap is dependency-driven rather than date-driven. Product/access authority is [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md). Visual work is governed by [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md) and [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md).

The old mock-first runtime was removed during the 2026-08-12 production-baseline reset. Production implementation now includes the iPhone + iPad foundation, D1 onboarding and the D2 Today/Circle presentation shell. D3 Current Sky, Calendar and Event Detail UI exist over typed development samples. Approved feature UI may be developed before backend/API wiring by using explicit development sample data behind Humay-owned contracts; that is not a return to a production mock-provider architecture.

## Shipping phase summary

| Phase | Name | Primary outcome | Depends on |
|---|---|---|---|
| 00 | Technical Architecture | Free/precision provider, backend, cache, entitlement, privacy and cost contracts | Product/access + visual authority |
| 01 | Apple Platform Foundation | SwiftUI + Clean Architecture app shell, cross-device design-system foundation, root navigation/state, test/config/persistence boundaries | Phase 00 foundation start gate + current design authority |
| 02 | Astrology Calculation Foundation | Typed provider-independent calculation contracts, validation/provenance and precision adapters | relevant Phase 00 provider contracts + Phase 01 |
| 03 | Onboarding & Local Profile | Four-beat onboarding, birth-date/tradition capture, local profile persistence, later optional time/place editing | Phase 01 + approved D1 + required reveal methodology |
| 04 | Chart | Provider-backed natal chart with Rewarded/Premium access and cache | Phase 02 + Phase 03 + D4 |
| 05 | Today | Free catalog + precise personalized Today upgrade | Phase 02 + profile foundation + D2 |
| 06 | Sky & Calendar | Current sky/event calendar and appropriate caching | Phase 02 + D3 |
| 07 | Circle & Compatibility | Saved People, free 144-key Western compatibility, precise upgrade | profile foundation + relevant Phase 02 contracts + D2 |
| 08 | Ask the Stars | Contextual provider-backed Q&A with explicit access/cost/safety boundary | relevant provider/context foundations + D5 |
| 09 | Monetization & Generation Entitlements | Rewarded one-generation semantics, Premium, cache-aware access | Phase 00 entitlement contract + implemented provider-backed features + D7 |
| 10 | Sharing, Widgets & Notifications | Share cards, widgets, Normal-register notifications | owning feature phases + D8 |
| 11 | Hardening & Release | Cross-device accessibility, performance, privacy, cost controls, QA and launch readiness | all shipping phases + D9 |

Phase numbers express ownership, not an artificial requirement that every earlier feature be finished before any later independent slice can begin. Explicit task dependencies inside phase files are authoritative.

## Parallel-work rule

Platform, architecture and approved UI work can proceed independently where their contracts are already sufficient.

Provider-backed production runtime may not invent unresolved Phase 00 entitlement/privacy rules or unresolved astrology methodology.

### Current architecture gate — 2026-08-12

- ARCH-001 is complete in [`../architecture/SYSTEM_ARCHITECTURE.md`](../architecture/SYSTEM_ARCHITECTURE.md): Free catalog and precision are separate logical cost/trust paths, and a Free miss cannot fall through to paid generation.
- ARCH-003 is complete in [`../architecture/ASTROLOGY_ENGINE.md`](../architecture/ASTROLOGY_ENGINE.md): calculation adapters are provider-independent, facts are typed/versioned/provenanced, unknown-time uncertainty is preserved, and provider fallback requires validated methodology equivalence.
- ARCH-004 is complete in [`../architecture/RESULT_CACHE_OFFLINE.md`](../architecture/RESULT_CACHE_OFFLINE.md): calculation and interpretation artifacts have separate identities, server precision cache/idempotency is authoritative, and offline behavior never creates a paid fallback.
- ARCH-005 is complete in [`../architecture/INTERPRETATION_LAYER.md`](../architecture/INTERPRETATION_LAYER.md): interpretation receives validated facts, is independently versioned/cacheable, and cannot invent deterministic astrology facts.
- ARCH-006 is complete in [`../architecture/BACKEND.md`](../architecture/BACKEND.md): Free catalog publishing/serving, precision orchestration, provider adapters, observability and normalized API ownership are server responsibilities.
- ARCH-007/ARCH-008 remain required before production rewarded/Premium provider rollout and before sensitive provider data handling is considered final.
- No concrete calculation/interpretation/hosting vendor is frozen yet.

## Development sequence — UI first, backend/API second

For the next feature families, the preferred implementation sequence is:

```text
UI design + approval
        ↓
SwiftUI implementation with development sample data
        ↓
real simulator screenshot reconciliation
        ↓
stabilize feature-facing/domain contracts
        ↓
backend/API implementation
        ↓
real Data/API adapter integration
        ↓
provider/cache/access/privacy validation
```

This sequence applies to Today, Circle/Compatibility, Sky/Calendar, Chart, Ask and later access/settings surfaces where practical.

### Development sample-data rules

- sample data must use Humay-owned feature/domain contracts, not vendor response shapes;
- sample output is explicitly development/preview/test content;
- feature UI should cover realistic loaded/loading/cache-hit/offline/limited/error/access states from approved designs;
- Release runtime must not present sample astrology as if it were calculated or provider-generated;
- the old deleted `Mock*` provider/runtime architecture is not restored;
- the later backend adapter replaces the development source at composition rather than forcing Presentation redesign.

This lets UI/product behavior mature before backend implementation while preserving clean runtime boundaries.

### Current UI-first checkpoint — D2 plus D3 foundation

The approved D2 Today + Circle family is implemented with explicit Debug-only development sample composition:

- Today and Daily Horoscope;
- Circle, person overview/detail and minimal Add Person;
- Free and precise-presentation Compatibility;
- loading, locked, loaded, cached, offline, failed and empty states where applicable;
- real iPhone/iPad Light/Dark portrait evidence and passing adaptive landscape UI tests.

Phase 05 and Phase 07 remain partial because production Free catalogs, Saved People persistence, backend/API/provider generation and entitlement/monetization runtime are still deferred.

D3 Current Sky, Calendar Month/Week, and Event Detail user-facing UI are implemented over typed Debug-only deterministic samples and approved cross-device references. Provider, calculation, cache and persistence implementation remains pending; D4 and D5 remain unstarted.

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

Every shipping screen requires iPhone Light/Dark + iPad Light/Dark. iPad landscape/adaptive behavior must be documented when composition changes.

### D8 requirement — Compatibility Visual Share Card

Final Compatibility sharing must **not** be plain-text-only. The intended primary artifact is a Humay-branded rendered share card/image, designed as part of the D8 visual share-card family and shared through the system share sheet.

The card must be capable of including:

- both people's display names or user-approved share names;
- medallions/initials;
- Sun signs when relevant;
- overall compatibility score;
- relationship label;
- a short share-safe summary;
- Humay branding.

By default, the card must **not** include:

- birth time;
- birth location;
- exact birth date;
- private precision/calculation details;
- internal methodology or debug metadata;
- provider information.

Optional supporting text or a deep link may be added later, but the rendered visual card remains the primary share artifact. The current production plain-text `ShareLink` is temporary/non-final UI. Do not implement the visual card or image rendering before the D8 family is designed and approved.

## UI design → implementation rule

Feature-specific user-facing UI follows this cadence:

1. design next family for iPhone+iPad, Light+Dark;
2. approve;
3. implement the real SwiftUI hierarchy/state model with development sample data when backend data is not ready;
4. capture real cross-device screenshots;
5. reconcile implementation;
6. continue.

No feature-specific production UI gets ahead of approved cross-device references.

## Backend/API implementation rule

Backend/API work follows the UI-first pass for the relevant feature family unless a non-visual backend prerequisite must be completed earlier for correctness.

When backend work begins:

- implement Humay-owned API contracts, not UI-specific vendor DTOs;
- implement Free catalog serving separately from precision generation;
- preserve authoritative server cache/idempotency;
- enforce ARCH-007/008 before production paid-provider rollout;
- replace development sample sources at the app composition/Data boundary;
- validate real provider results independently from values used in UI mockups.

## Product architecture invariant

Humay has two runtime paths:

- **Free catalog:** Humay-owned, pre-generated, versioned content; ordinary Free usage makes no paid astrology/LLM call.
- **Precision/personalized:** cache-first backend orchestration; Rewarded Access or Premium; structured astrology calculation + interpretation behind interfaces.

No engineering phase or UI design may blur this boundary.

## Release milestones

### Milestone A — Architecture + foundation

Complete the Phase 01 platform foundation, required Phase 00 architecture contracts, Phase 03 onboarding/profile slice, and D0–D1 cross-device design requirements.

Expected result: buildable iPhone+iPad foundation, current design system, durable profile/birth storage, backend/provider/cache boundaries and approved four-step onboarding.

### Milestone B — UI-complete core value shell

Complete approved D2–D5 feature UI families with typed development sample data and real cross-device screenshot reconciliation before backend integration is considered visually complete.

Expected result: Today, Circle/Compatibility, Sky/Calendar, Chart and Ask can be exercised across their important UI states without relying on a production provider.

### Milestone C — Core backend/API integration

Implement the required Free catalog, precision cache/orchestration, validated calculation provider(s), interpretation adapter(s), access/privacy contracts and app Data/API adapters.

Expected result: development sample sources can be replaced by real Humay APIs without redesigning Presentation.

### Milestone D — Monetized beta

Complete monetization plus sharing/widgets/notifications and D6–D8.

Expected result: Free/Rewarded/Premium behavior, cached reopening, settings, sharing/widgets/notifications and access UI in both appearances and device families.

### Milestone E — Release candidate

Complete Phase 11, D9 and all methodology gates for included production features.

## Dependency rules

- Free content generation/publishing is a backend/content-pipeline responsibility, not an on-device LLM feature.
- Calculation facts and interpretation text are separately versioned/cacheable.
- No interpretation model may fabricate calculation facts.
- Development/sample values are never production truth or methodology validation.
- Chinese/BaZi or Vedic Free shortcuts require methodology validation of the coarse bucket model.
- Monetization enforces the product access model rather than redefining it in SDK-specific code.
- Numeric compatibility presentation is allowed, but production scoring methodology must be explicitly defined and validated.
- Unknown birth time is never silently replaced with a guessed time.

## Definition of roadmap completion

The roadmap is complete when shipping phase exit criteria are satisfied, D0–D9 handoff is reconciled with implementation, included methodology gates are signed off, runtime cost/cache behavior is tested, release-candidate privacy/performance/accessibility validation is complete, and documentation reflects the implemented iPhone+iPad product.
