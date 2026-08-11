# Humay Development Roadmap

This roadmap is dependency-driven rather than date-driven. The current product/access authority is [`PRODUCT_ACCESS_MODEL.md`](PRODUCT_ACCESS_MODEL.md).

## Phase summary

| Phase | Name | Primary outcome | Depends on |
|---|---|---|---|
| 00 | Technical Architecture | Two-path content architecture, provider/cache contracts, repo structure and implementation plan | Product/access decision + visual baseline |
| 01 | iOS Foundation | Buildable Humay app shell, design system, navigation, persistence/test scaffolding | 00 |
| 02 | Astrology Calculation Foundation | Typed provider-independent calculation contracts, validation/provenance and precision adapters | 00–01 |
| 03 | Onboarding & Local Profile | Birth-data capture/editing, uncertainty, local profile persistence | 01–02 contracts |
| 04 | Chart | Provider-backed natal chart experience with Rewarded/Premium access and cache | 02–03 |
| 05 | Today | Zero-runtime-cost Free catalog + precise personalized Today upgrade | 02–04 |
| 06 | Sky & Calendar | Current sky/event calendar and cache strategy appropriate to each data source | 02–05 |
| 07 | Circle & Compatibility | Saved People, free 144-key Western compatibility and precise compatibility upgrade | 02–06 |
| 08 | Ask the Stars | Contextual provider-backed Q&A with explicit access/cost/safety boundary | 02–07 |
| 09 | Monetization & Generation Entitlements | Rewarded one-generation semantics, Premium and cache-aware access | 01–08 |
| 10 | Sharing, Widgets & Notifications | Share cards, widgets, Normal-only notifications | 05–09 |
| 11 | Hardening & Release | Accessibility, performance, privacy, cost controls, QA and launch readiness | all shipping phases |

### Parallel track

| Phase | Name | Primary outcome | Depends on |
|---|---|---|---|
| 01M | [Mock-First iOS Application](phases/01M-mock-first-app.md) | Launchable, navigable app with architecture, design system, all major screens and complete flows over mock content behind service protocols | — (authorized by [`DEVIATIONS.md`](DEVIATIONS.md) `DEV-001`) |

Phase 01M runs ahead of the Phase 00 dependency gate by explicit direction. **It does not satisfy the exit criteria of Phase 00 or Phase 01**, and it advances no `ARCH-###` or feature task. Phase 01 still requires the reconciled design revision and real access-state primitives; Phase 00 still owns the provider, cache, entitlement and privacy contracts.

When Phase 00 completes, `Humay/Data/Mock/` is replaced rather than extended.

## Product architecture invariant

Humay has two runtime paths:

- **Free catalog:** Humay-owned, pre-generated, versioned content; no paid astrology or LLM call during ordinary Free use.
- **Precision/personalized:** cache-first backend orchestration; Rewarded Access or Premium; astrology calculation provider + interpretation provider behind interfaces.

No phase may accidentally bypass this boundary.

## Release milestones

### Milestone A — Architecture + foundation

Complete Phases 00–03.

Expected result:
- Humay project/app shell exists;
- profile/birth data can be stored safely;
- backend/provider/cache boundaries are defined;
- Free catalog and provider-backed precision contracts are distinct;
- no fake astrology is required.

### Milestone B — Core value build

Complete supported portions of Phases 04–06.

Expected result:
- Rewarded/Premium natal Chart path;
- Free sign/system-based Today served from pre-generated backend content;
- precise personalized Today generated only after access approval/cache lookup;
- Sky/Calendar supported by validated data sources.

### Milestone C — Relationship + contextual build

Complete supported portions of Phases 07–08.

Expected result:
- Saved People;
- free Western 12 × 12 compatibility catalog;
- precise compatibility behind Rewarded/Premium;
- Ask over structured context without uncontrolled Free provider spend.

### Milestone D — Monetized beta

Complete Phases 09–10.

Expected result:
- Free / Rewarded generation / Premium behavior;
- cache-aware reopening of already generated results;
- sharing/widgets/notifications;
- no login required unless separately approved.

### Milestone E — Release candidate

Complete Phase 11 and all methodology gates for included production features.

## Dependency rules

- Phase 00 must freeze the system boundary before production feature code starts. Phase 01M is the single recorded exception; it ships no production feature path.
- Free content generation/publishing is a backend/content-pipeline responsibility, not an on-device LLM feature.
- Provider-backed calculation facts and interpretation text must be separately versioned/cacheable.
- No interpretation model may fabricate calculation facts.
- Chart and other natal-level precision features are not required to have a free calculated baseline.
- UI can use explicit fixtures while providers/methodology are incomplete; design mockup values are not validation truth.
- Chinese/BaZi or Vedic paths may only expose Free catalog shortcuts if the methodology team explicitly validates the chosen coarse bucket model.
- Monetization must enforce the product access model; it must not redefine it in SDK-specific code.

## Definition of roadmap completion

The roadmap is complete when:
- shipping phase exit criteria are satisfied;
- included methodology gates are signed off;
- Free runtime cost invariants and cache behavior are tested/observable;
- release-candidate privacy/performance/cost validation is complete;
- documentation reflects the implemented product behavior.
