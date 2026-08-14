# D5.1 — Ask the Stars visual foundation

**Status: REVIEW CANDIDATE — NOT APPROVED**

This package defines the first complete D5 Ask the Stars cross-device visual family and the minimum provider-independent presentation boundary needed for later review. It is a design and contract review artifact only.

No production Ask SwiftUI, provider, backend/API, rewarded-ad, subscription, entitlement, conversation persistence or production asset work is included. Ask remains `MainDestinationPlaceholderView` until product-owner approval and the later implementation gates are satisfied.

## Product concept

**Celestial Correspondence**: the user brings one focused question to Humay; Humay returns a structured personal reading. The visual rhythm is **question → considered reading**, not a chat transcript.

Ask is:

- personal, warm, thoughtful and premium;
- conversational without becoming a messaging product;
- grounded in the astrology context Humay is actually allowed to use;
- slightly magical through one restrained folded-note/orbit illustration;
- explicit about facts, interpretation, access and uncertainty.

Ask is not an iMessage clone, generic ChatGPT clone, support chatbot, persistent conversation product or mystical fortune-teller terminal.

## Primary references

Each primary reference has synchronized SVG and PNG output. Phone canvases are `430 × 932` pt; iPad canvases are `1024 × 1366` pt.

| Family | iPhone | iPad |
|---|---|---|
| Question / empty | [`question-entry-iphone-light.png`](question-entry-iphone-light.png), [`question-entry-iphone-dark.png`](question-entry-iphone-dark.png) | [`question-entry-ipad-light.png`](question-entry-ipad-light.png), [`question-entry-ipad-dark.png`](question-entry-ipad-dark.png) |
| Answer / reading | [`answer-reading-iphone-light.png`](answer-reading-iphone-light.png), [`answer-reading-iphone-dark.png`](answer-reading-iphone-dark.png) | [`answer-reading-ipad-light.png`](answer-reading-ipad-light.png), [`answer-reading-ipad-dark.png`](answer-reading-ipad-dark.png) |
| Generating | [`generating-iphone-light.png`](generating-iphone-light.png), [`generating-iphone-dark.png`](generating-iphone-dark.png) | [`generating-ipad-light.png`](generating-ipad-light.png), [`generating-ipad-dark.png`](generating-ipad-dark.png) |
| Rewarded access | [`rewarded-access-iphone-light.png`](rewarded-access-iphone-light.png), [`rewarded-access-iphone-dark.png`](rewarded-access-iphone-dark.png) | [`rewarded-access-ipad-light.png`](rewarded-access-ipad-light.png), [`rewarded-access-ipad-dark.png`](rewarded-access-ipad-dark.png) |

The answer references use one clearly marked development fixture:

> “How can I work with my Moon in Libra?”

Supplied sample basis only: Western, Tropical, Moon in Libra, `14° 27′`, 5th house, known-time development fixture. The answer is sample interpretation. It does not describe the current user.

The answer family contains one quiet disclosure: **Development sample · not generated**. Other primary states do not scatter debug notices through the interface.

## Focused boards

- [`answer-anatomy.png`](answer-anatomy.png) — question, interpretation, practical reflection and factual basis separation.
- [`composer-keyboard.png`](composer-keyboard.png) — empty, multiline, keyboard, long-question, disabled/enabled, Dynamic Type and hardware-keyboard pressure.
- [`access-cache-states.png`](access-cache-states.png) — Free generation-needed, Rewarded, Premium, cached reopen and reward-completed/provider-failed concepts.
- [`error-context-safety.png`](error-context-safety.png) — offline, provider failure, insufficient context, unsupported methodology, safety refusal and malformed/validation failure.
- [`accessibility-long-content.png`](accessibility-long-content.png) — reading order, focus, Dynamic Type, VoiceOver, Reduce Motion, contrast and long-content pressure.
- [`ipad-adaptive.png`](ipad-adaptive.png) — regular iPad, landscape, narrow Split View and keyboard-present collapse rules.
- [`illustration-ask-stars-light.png`](illustration-ask-stars-light.png) and [`illustration-ask-stars-dark.png`](illustration-ask-stars-dark.png) — reference-only folded note/celestial correspondence illustration concept.

## Read with

1. [`design-spec.md`](design-spec.md) — visual hierarchy, surfaces, states, fixture and primary-reference decisions.
2. [`adaptive-notes.md`](adaptive-notes.md) — iPhone/iPad, landscape/Split View, keyboard, Dynamic Type and accessibility behavior.
3. [`contract-notes.md`](contract-notes.md) — ASK-001 minimum Humay-owned presentation contract, data minimization and prompt-injection boundary.
4. [`review-notes.md`](review-notes.md) — review boundary, open decisions, non-actions and Phase 08 recommendation.
5. [`generate-references.cjs`](generate-references.cjs) — deterministic SVG/PNG generator.

## Authority boundary

This candidate follows [`../../../DESIGN_AUTHORITY.md`](../../../DESIGN_AUTHORITY.md), [`../../../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../../../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md), [`../../../SCREEN_DESIGN_PLAN.md`](../../../SCREEN_DESIGN_PLAN.md), [`../../../../development/PRODUCT_ACCESS_MODEL.md`](../../../../development/PRODUCT_ACCESS_MODEL.md), [`../../../../architecture/INTERPRETATION_LAYER.md`](../../../../architecture/INTERPRETATION_LAYER.md), [`../../../../architecture/RESULT_CACHE_OFFLINE.md`](../../../../architecture/RESULT_CACHE_OFFLINE.md) and [`../../../../architecture/SYSTEM_ARCHITECTURE.md`](../../../../architecture/SYSTEM_ARCHITECTURE.md).

Those documents remain higher authority. This package cannot approve itself, redefine Free/Rewarded/Premium semantics, freeze a provider, or close unresolved methodology/safety/entitlement decisions.

## Generation and verification

Run from the repository root:

```bash
node docs/design/soulful-reference/ask/foundation/generate-references.cjs
```

The generator uses the repository's existing Newsreader font binary and system-font fallbacks. It creates no production asset. Run it twice and compare hashes; validate SVG XML, PNG dimensions, Light/Dark pairs and `git diff --check` before review.

## Review gate

Product-owner review is the next step. Approval would permit a later UI-first Presentation decision only when typed Humay-owned development/sample contracts also exist. It would not approve production provider/API/access implementation.
