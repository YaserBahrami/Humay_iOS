# D5.1 Ask visual foundation — review notes

**Status: REVIEW CANDIDATE — NOT APPROVED**

## Review boundary

This package is the first complete D5 visual and contract candidate. It is intentionally not self-approved. Product-owner review is required before feature-specific implementation.

The package preserves the current authority order:

1. Product Access & Cost Model;
2. Design Authority;
3. Soulful Celestial direction;
4. Screen Design Plan;
5. approved screen references;
6. methodology and architecture contracts.

## Visual findings

### Celestial Correspondence

Ask is designed as one focused question followed by one considered reading. The primary hierarchy avoids a transcript and avoids a large hero that pushes the composer below the fold.

### Entry

The composer is the action center. Suggested questions explain the product without becoming a prompt library. Context scope is quiet and relevant rather than a full profile summary.

### Answer

The original question remains visible as identity. Interpretation sections stay open on the reading ground. `What this answer used` is a separate basis region, making the calculation/interpretation boundary visible without exposing provider internals.

### Access

Rewarded Access is one calm generation gate. Premium is shown only as an alternative path; the full paywall belongs to D7. Cached reopen is treated as a result state, not another access event.

### States

Offline, provider failure, insufficient context, unsupported methodology and safety refusal have separate concepts and copy pressure. Reward-completed/provider-failed is retained as a future fairness requirement, not implemented entitlement behavior.

## Fixture review

The answer references use only explicitly supplied sample factors:

- Western;
- Tropical;
- Moon in Libra;
- `14° 27′`;
- 5th house;
- known-time development fixture.

The references do not imply these facts belong to the current user. The one quiet answer disclosure is **Development sample · not generated**. No provider-generated, calculated or verified-personalized claim is made.

## Accessibility review boundary

The candidate documents Dynamic Type, VoiceOver order, minimum targets, keyboard avoidance, focus transitions, Reduce Motion, Increase Contrast, color redundancy, long questions and long answers. Runtime Accessibility Inspector and simulator verification remain implementation-time work and are not claimed here.

## Existing foundation alignment

The candidate maps to existing Humay conventions:

- `HumayTypography` semantic Newsreader/system roles;
- current cream/navy color tokens;
- existing 18–24 pt feature surface geometry;
- bounded `HumayContentWidth` approach;
- native NavigationStack/TabView/text-input direction;
- current `D2WordmarkHeader`, `HumaySurface`, `HumayCosmicSurface` and state-banner language as future reuse candidates.

No production component or asset is changed in this pass.

## Phase 08 dependency recommendation

Keep the production dependency exactly as written: ASK-003 depends on ASK-002 and approved D5. The visual candidate can inform a later UI-first Presentation decision only after product-owner approval and only with Humay-owned Debug-only sample contracts.

Production Ask remains gated by ASK-001, ASK-002, ARCH-007, backend/provider, cache/idempotency, privacy and safety integration. Do not mark ASK-002 complete. Do not treat references as methodology or provider evidence.

## Open product/architecture decisions

- final ASK-001 field names and stable fact-reference vocabulary;
- exact safety taxonomy and redirect copy;
- reward-completed/provider-failed recovery behavior under ARCH-007;
- Premium cached-result visibility after entitlement expiry;
- anonymous backend identity and privacy retention/deletion/export policy;
- final provider/model policy and prompt/safety versions;
- production source/ownership of the folded-note illustration;
- final Ask navigation/action behavior after answer completion;
- whether context basis is inline disclosure or a later native disclosure route.

## Explicit non-actions

- No `Humay/App/` changes.
- No `Humay/Presentation/` changes.
- No `Humay/Domain/` changes.
- No `Humay/Data/` changes.
- No `HumayTests/` or `HumayUITests/` changes.
- No `Assets.xcassets` changes.
- No provider, backend/API, LLM, rewarded-ad, subscription or entitlement code.
- No conversation persistence/history design.
- No D6 Settings work.
- No D5 approval claim.

## Review checklist

- [ ] product owner approves Celestial Correspondence direction;
- [ ] product owner approves entry/composer hierarchy;
- [ ] product owner approves answer/basis separation;
- [ ] product owner approves Rewarded/Premium presentation boundary;
- [ ] product owner approves cached/offline/failure/context/safety state distinctions;
- [ ] product owner approves iPhone/iPad/landscape/Split View behavior;
- [ ] product owner approves accessibility and keyboard notes;
- [ ] product owner approves the reference-only illustration concept;
- [ ] ASK-001/ARCH-007 owners reconcile contract open questions;
- [ ] D5.1 is explicitly promoted from review candidate before implementation.
