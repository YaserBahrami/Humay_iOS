# D5.1 Ask UI-first implementation evidence

**Status: APPROVED VISUAL REFERENCE — IMPLEMENTED — CORE UI-FIRST BASELINE; R2 VISUAL REFINEMENT PENDING**
**Date:** 2026-08-14
**Branch:** `feature/foundation-clean-architecture`
**Starting HEAD:** `75f92383412da5fe1f2721cdc0b875ec7233051b`

## Authority

Visual authority is [`docs/design/soulful-reference/ask/foundation/`](../../soulful-reference/ask/foundation/README.md), with R1 decisions recorded in its design spec, adaptive notes, contract notes and review notes. Design Authority records D5.1 as approved for the UI-first presentation slice only.

## Implementation boundary

The slice is implemented in `Humay/Presentation/Ask/` and `Humay/Presentation/D5/` with a typed Humay-owned presentation contract and a `#if DEBUG` development fixture. Debug launch state arguments are parsed only by `DevelopmentD5Sample`/composition. Release composition is empty/production-unavailable and contains no sample answer payload.

Not implemented here: provider/backend/API/LLM calls, networking, rewarded-ad SDK, StoreKit/Premium entitlement, production cache/history/memory, astrology calculations or D6 work. No conversation-history surface was added.

## Captured matrix

Each primary state below has a real simulator screenshot for iPhone and iPad in Light and Dark. The fixtures are deterministic and use the stable iPhone 17 Pro and iPad simulator destinations.

| State | iPhone Light | iPhone Dark | iPad Light | iPad Dark |
|---|---|---|---|---|
| Entry | [`iphone-light-entry.png`](iphone-light-entry.png) | [`iphone-dark-entry.png`](iphone-dark-entry.png) | [`ipad-light-entry.png`](ipad-light-entry.png) | [`ipad-dark-entry.png`](ipad-dark-entry.png) |
| Access | [`iphone-light-access.png`](iphone-light-access.png) | [`iphone-dark-access.png`](iphone-dark-access.png) | [`ipad-light-access.png`](ipad-light-access.png) | [`ipad-dark-access.png`](ipad-dark-access.png) |
| Generating | [`iphone-light-generating.png`](iphone-light-generating.png) | [`iphone-dark-generating.png`](iphone-dark-generating.png) | [`ipad-light-generating.png`](ipad-light-generating.png) | [`ipad-dark-generating.png`](ipad-dark-generating.png) |
| Loaded answer | [`iphone-light-loaded.png`](iphone-light-loaded.png) | [`iphone-dark-loaded.png`](iphone-dark-loaded.png) | [`ipad-light-loaded.png`](ipad-light-loaded.png) | [`ipad-dark-loaded.png`](ipad-dark-loaded.png) |
| Offline cached | [`iphone-light-offline-cached.png`](iphone-light-offline-cached.png) | [`iphone-dark-offline-cached.png`](iphone-dark-offline-cached.png) | [`ipad-light-offline-cached.png`](ipad-light-offline-cached.png) | [`ipad-dark-offline-cached.png`](ipad-dark-offline-cached.png) |

Additional deterministic UI coverage exercises cached, offline no-cache, insufficient context, unsupported methodology, safety refusal and failed/unreadable-result states. The access Watch ad control is intentionally disabled because no rewarded handler exists in this slice; no fake success transition is possible.

## Reconciliation notes

- Entry keeps the composer early on iPhone and uses a width-based two-region composition on iPad.
- The folded-note/orbit illustration is the semantic `IllustrationAskStars` Light/Dark vector asset and is decorative to VoiceOver.
- The iPad duplicate inner “Ask” heading was removed; the existing root navigation title supplies the screen title, matching the approved reference hierarchy.
- Native `TextEditor` preserves typed content, supports internal multiline scrolling and keeps the Ask action reachable through focus/scroll behavior. Empty/whitespace-only input remains disabled.
- Answer content uses bounded editorial hierarchy: question identity, reading, disclosure, sections, reflection, basis facts and Ask another.
- Entry is reconciled with the approved two-region iPad layout. Regular-width iPad Answer currently preserves bounded reading width but does not yet implement the approved contextual question/basis rail; this is an explicit R2 visual-refinement item, not a D5 UI-first contract blocker.
- Release keeps the Ask action disabled with concise product-facing and accessibility copy when submission capability is unavailable; valid text cannot trigger a transition.
- Light/Dark surfaces, global typography roles, 44 pt actions, context disclosure and root-tab clearance use existing Humay tokens.

## Verification

- Full `HumayTests`: passed.
- D5 unit model tests: passed.
- D5 UI capture tests: passed on iPhone and iPad for Light/Dark.
- Current focused D5 UI rerun could not start on iPhone or iPad because the Xcode host reported `DebuggerVersionStore.StoreError` / `no debugger version` before test execution; no app failure was observed.
- Keyboard flow: passed on iPhone software keyboard; iPad uses native text input for hardware keyboard support.
- Dynamic Type accessibility flow: passed at `UICTContentSizeCategoryAccessibilityXXXL`.
- Debug iPhone/iPad builds and Release Simulator build: passed.
- Canonical typography, layering, nomenclature, diagnostics and foundation verifiers: passed.
