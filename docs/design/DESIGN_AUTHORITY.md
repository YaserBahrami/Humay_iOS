# Design Authority & Supersession Map

This map defines which artifacts govern Humay implementation. Historical Claude artifacts remain preserved. Newer explicit product decisions override older conflicting decisions only within the scope they address.

## 01 — Current authority order

For implementation, use this order:

1. Current explicit product decisions in [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md) for Free/Rewarded/Premium, runtime-cost and precision-vs-catalog behavior.
2. This authority map for supersession rules.
3. **[`MINIMAL_DESIGN_DIRECTION.md`](MINIMAL_DESIGN_DIRECTION.md) for all visual and layout decisions** — the full statement of the minimal Humay direction summarised in §03A.
4. Pass 6.1 and the final archive for interaction/structure baseline where not superseded.
5. Older Claude passes for historical/detail reference only when no newer authority conflicts.

The 2026-08-11 product/access decision requires a new Claude Design revision for affected surfaces. Until then, Pass 6.1 is **not** implementation-final for access/monetization/personalization states.

## 02 — Information architecture

Current primary IA remains:

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is reached through the header/profile entry.
- Profile / Settings is not a sixth primary tab.

This remains the baseline unless the next Claude Design pass explicitly changes it.

## 03 — Visual/core screen reference

- Onboarding: `Onboarding.dc.html` plus later corrections.
- Pass 2 / Pass 3: foundational exploration/historical reference.
- Pass 4 / 4.1: broad product and monetization exploration, historical where superseded.
- Pass 6: engineering-handoff/audit record.
- Pass 6.1: latest frozen visual/interaction correction layer before the 2026-08-11 access-model change.
- `final-archive/`: GitHub-friendly derived screenshots/Markdown; never calculation truth.

## 03A — Minimal Humay direction — current visual authority

Recorded 2026-08-11 alongside [`../development/DEVIATIONS.md`](../development/DEVIATIONS.md) `DEV-001`. Stated in full in [`MINIMAL_DESIGN_DIRECTION.md`](MINIMAL_DESIGN_DIRECTION.md), which is the reference an implementation is checked against; this section remains the supersession record.

**The minimal Humay direction governs all visual and layout decisions.** `claude-reference/Humay Product Prototype - Consolidated.dc.html` and the earlier passes remain authoritative for **product concepts, feature behavior, terminology and copy**, but are no longer the visual or layout authority. Where the prototype conflicts visually with the minimal direction, the minimal direction wins.

Characteristics: extremely clean, premium but restrained, editorial. Generous whitespace. Warm off-white ground, near-black text, restrained gold accent. Minimal surfaces, subtle borders, limited card usage, minimal shadows, no decorative gradients. Typography carries the visual identity. Astrology symbols used selectively. Elegant motion only where it does work. Native iOS interaction patterns throughout.

Three specific locks supersede the frozen prototype:

### Surfaces — All Paper

Every screen renders on Paper. The prototype's per-screen ink/paper split — welcome, reveal, precise Today, full chart and Sky on `#12151C` — is superseded. Precision and tier are differentiated by badge, hairline and typographic weight rather than by a dark ground.

Ink and Paper remain semantic tokens rather than a light/dark theme pair. A dark appearance is a separate future decision and must not be implemented by inverting these tokens.

### Typography

- **Cormorant Garamond** — wordmark, major titles, important editorial headlines. Weights 300–400 only.
- **SF Pro (system)** — all body copy, navigation, buttons, forms, settings and general UI.
- **SF Mono (system)** — degrees, coordinates, dates and technical chart data only.

**Lora, IBM Plex Sans and IBM Plex Mono are removed.** The prototype's Lora reading paragraphs become SF Pro; its IBM Plex UI and mono become the system faces. This keeps the type system minimal, Dynamic Type-friendly and native, with Cormorant carrying the identity.

The Pass 5.1 wordmark construction, occultation mark geometry, palette, ink opacity ramp, square-by-default radii, hairline borders, no-shadow rule and motion verbs all remain in force. §05's brand-lock reference stands except where this section names a replacement.

### Device scope

**V1 targets iPhone in portrait.** iPad is a planned dedicated design and implementation phase, not a stretched phone layout — Chart, Circle, Sky and Compatibility should use genuinely different compositions on larger screens, including two-column layouts.

The iPhone implementation must not make that harder: no hard-coded device dimensions, semantic spacing tokens throughout, reusable layout components, adaptable navigation architecture, chart visualizations responsive to their container, and content separated from presentation. No speculative iPad layouts in this phase.

## 04 — Product access model — supersedes old monetization semantics where conflicting

The hierarchy is still conceptually:

**Free → optional Rewarded Access → Premium**

But the behavior is now defined as follows.

### Free

- Ordinary Free runtime usage must not call a paid astrology or LLM provider.
- Free daily horoscope is a coarse, pre-generated catalog experience based on birth date/system bucket rather than a natal chart.
- Western baseline uses 12 Sun-sign daily entries.
- Free Western compatibility uses 12 × 12 = 144 pre-generated sign-pair keys.
- Free has no natal-chart calculation.
- Vedic/Chinese coarse catalogs exist only if methodology validates a finite bucket model.

### Rewarded Access

- One completed rewarded ad authorizes one needed provider-backed generation for the selected feature/result key.
- Cache is checked before ad/provider generation.
- After successful generation, that result is cached and can be reopened without another provider generation/ad for the same valid key.
- A materially different result key can require a new reward.
- Rewarded Access is not temporary Premium and not a token/coin wallet.
- Provider failure after ad completion requires a fair idempotent recovery flow.

This supersedes the older generic 'persistent per-section unlock' model where it conflicts.

### Premium

- Premium provides provider-backed personalized/precision features while subscription entitlement is valid.
- Premium still uses cache first.
- Premium avoids the per-generation rewarded-ad requirement for included features.
- Post-expiry visibility of previously generated cached Premium results remains to be finalized.

### Saved People

- Rewarded Access is not used as a Saved People slot currency.
- Exact Free/Premium capacities remain product configuration.

### Ask

- Provider-backed Ask must pass cache/access checks before paid generation.
- A rewarded completion can authorize one additional question generation.
- No bankable balance/token/currency system.

## 05 — Brand/name authority

**Humay** is the product name, repository name and current internal project name.

| Name | Status |
|---|---|
| Astara | Historical former working/repository name only |
| Ortus | Historical placeholder |
| Ecliptic | Rejected historical recommendation |
| Eclipse | Visual/design direction only — not product name |
| Humay | Current product/project/repository name |

Pass 5.1 remains the baseline brand-lock reference for wordmark/mark/icon/palette/typography/voice/Roast/motion, subject to future explicit Humay design revisions.

## 06 — Roast and notifications

- Roast is an in-app expression only.
- Push notifications are always Normal-register copy.
- Normal and Roast consume the same astrology facts; tone must not alter calculated meaning.
- The old Normal/Roast notification toggle must not be implemented.

## 07 — Astrology data authority

### Free catalog

- Free catalog text is intentionally coarse and pre-generated.
- It must disclose its limited basis and never present itself as natal-level precision.
- Catalog content is product/editorial content, not a source of astronomical facts.

### Precision features

- Exact placements, aspects, houses, timing, dashas, pillars and relationship facts come from the structured calculation layer/provider and validated methodology.
- Design mockup values are prototype content unless independently validated.
- Interpretation/LLM consumes structured facts; it must not invent positions, degrees, houses, Ascendant, aspects, nakshatras, dashas, pillars or timing.
- Exact clock times appear only when deterministically/calculationally supported.

## 08 — Unknown birth time

For precision features, unknown birth time degrades only the facts actually dependent on time/uncertainty; it is never replaced with a hidden fake time.

- Western: Rising/houses require sufficient time; Moon/aspects may become uncertain near boundaries.
- Vedic: Lagna/Bhavas and some Moon/timing outputs depend on time/uncertainty.
- Chinese/BaZi: Hour Pillar is unavailable without time; other pillar reliability depends on signed-off calendar/day-boundary methodology.

Free coarse catalog paths do not use birth time merely to imitate precision.

## 09 — Methodology status

Any choice that changes calculated output requires domain/methodology validation.

Research/sign-off remains required for items tracked in [`../development/METHODOLOGY_TRACK.md`](../development/METHODOLOGY_TRACK.md), including Western house/composite choices, Vedic conventions/non-romantic compatibility, Chinese/BaZi calendar/Four-Pillars/Luck-Cycle rules and cross-system timing mapping.

A provider response does not automatically constitute methodology sign-off.

## 10 — Design vs technical architecture

Product/design locks user-visible behavior and access meaning. Architecture decides:

- exact backend/storage technology;
- provider adapters and vendor configuration;
- StoreKit/ad SDK details;
- reward verification/recovery;
- cache identity/TTL/retention;
- notification delivery mechanics;
- privacy/security implementation.

Architecture may optimize cost but may not silently turn Free requests into paid provider calls.

## 11 — External brand clearance

Humay is the current internal product/project name. Trademark, App Store/Google Play naming, domains, handles and cultural/linguistic clearance remain external launch tasks.

## 12 — Current design status

- The minimal Humay direction (§03A, stated in full in [`MINIMAL_DESIGN_DIRECTION.md`](MINIMAL_DESIGN_DIRECTION.md)) is the current visual/layout authority.
- Pass 6.1 is preserved as the latest completed interaction/UX baseline; its visual treatment is superseded by §03A where they conflict.
- The 2026-08-11 product/access change supersedes conflicting Pass 6.1 monetization/access behavior.
- **A new Claude Design revision is required** for Chart, Today, Compatibility, Ask and paywall/rewarded/cached-result states before those surfaces are implementation-final.
- Unaffected visual/IA work can still use Pass 6.1 as reference.

### Reconciliation pass — 2026-08-11

The Phase 01M application was reviewed screen by screen against the minimal direction and brought into line. Recorded in [`../development/phases/01M-mock-first-app.md`](../development/phases/01M-mock-first-app.md) as `IOS-012`; screenshots of the result are in [`review/`](review/README.md).

Decisions taken during that pass, now part of the visual authority:

- **Only the precise tier is outlined.** A general badge appeared on nearly every screen and distinguished nothing, so it is a plain mono kicker. The outline is reserved for precision.
- **One page component.** Every screen — tab root, pushed screen, settings page and sheet — is built on the same scrolling page, so the gutter, top inset, bottom inset and ground colour cannot drift apart. Tab roots take the large title; everything else takes the inline title.
- **Type ceilings are staggered rather than flat.** A single 1.4× cap across every display and title role inverted the hierarchy at the accessibility text sizes: a row title came out smaller than its own subtitle. Row titles are uncapped; the editorial display roles cap at increasing multiples that keep them above body copy.
- **Rows reflow rather than shrink.** A label-and-value row becomes a stacked pair at the accessibility sizes; the chart triad and the four BaZi pillars turn from columns into rows. Nothing important is scaled down to fit.
- **Fixed-geometry drawings step aside.** The Circle drawing is dropped at the accessibility sizes, where the list beneath already carries the whole of its meaning. Calendar dates are set in mono, which is both the typographic rule for a date and what keeps seven columns legible.
- **A withheld triad value keeps its slot** but is drawn at the disabled weight, so the placeholder does not read as a mark that means something.

## 13 — Next step

After the GitHub product/roadmap documentation is reconciled, continue Claude Design using [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md) as a mandatory input and update the final archive/authority map after the new design pass is approved.
