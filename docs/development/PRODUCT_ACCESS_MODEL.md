# Humay Product Access & Cost Model

Status: **CURRENT PRODUCT DECISION**

Decision date: **2026-08-11**  
Reconciled with the current Soulful Celestial roadmap/design authority: **2026-08-12**

This document defines the current product/access model and cost boundary for product design, app architecture and backend/provider implementation.

If a visual reference or implementation detail conflicts with this document on Free / Rewarded Access / Premium behavior, this document wins and the conflicting artifact must be corrected.

## 1. Core principle

**A Free user must not cause a paid astrology-calculation or paid LLM request during normal use.**

The target is near-zero marginal backend/AI cost for Free usage. Free content therefore comes from finite, pre-generated, versioned catalogs served from Humay-owned backend/static/cache storage.

This is a runtime-cost rule, not a claim that preparing/editorially reviewing the catalog has literally zero cost.

### V1 identity and user-owned data

Humay V1 does **not** require a Humay user account. There is no email/password registration, Sign in with Apple, login screen or "already have an account" onboarding path.

User-owned profile, preferences and saved-person data follow an Apple-platform-native persistence direction:

- local app storage is the immediate runtime source;
- private iCloud/CloudKit-backed persistence is planned for sync and restore across the user's Apple devices;
- private astrology/profile data must not use the public CloudKit database;
- transient caches that do not need device sync may remain local;
- precision requests may later use an anonymous app/backend identity without introducing user login;
- Humay account infrastructure is deferred unless future cross-platform or server-account features require it.

This records direction only. CloudKit, persistence schemas, backend identity and authentication are not implemented in the current runtime. These choices do not change Free / Rewarded Access / Premium semantics.

## 2. Free path

### Daily horoscope

Free daily horoscope is intentionally coarse.

- It uses birth date/system category only for the reading key.
- Birth hour and birth location are not used to calculate a Free natal chart.
- Humay may store time/location later when the user explicitly adds them for precision-dependent features.
- The UI must describe Free readings as limited/coarse rather than natal-level personalized astrology.

For Western astrology:

- key by the 12 Sun signs;
- 12 daily horoscope entries per date/content variant are sufficient;
- content sections must remain consistent with the same coarse sign-based basis.

For Vedic/Chinese/other systems:

- use finite catalog buckets only where methodology validates the available coarse inputs;
- exact bucket definitions/cardinality remain methodology decisions;
- do not invent a Vedic or BaZi shortcut merely to force the same 12-sign model.

### Free Western compatibility

Free compatibility is a coarse Sun-sign pairing product:

- 12 signs × 12 signs = **144 catalog keys**;
- no natal synastry, houses, exact aspects or birth-time/location calculations;
- the UI must distinguish this from precise compatibility.

### Catalog generation

- Catalog content is generated ahead of runtime, with AI-assisted batch generation permitted as an editorial/content-production tool.
- Generated catalog content is reviewed/versioned and stored/published to Humay-owned backend/static storage.
- Runtime Free requests read only Humay-owned stored/cached data.
- Catalog content includes the version dimensions needed to invalidate or reproduce it: locale, system/bucket, date/period and tone/variant where applicable.
- Free serving must continue to work if external astrology/LLM providers are unavailable.

## 3. Precision / personalized path

Provider-backed features are available through **Rewarded Access or Premium**, not ordinary Free runtime requests.

Examples include:

- natal chart;
- precise personalized daily horoscope;
- precise compatibility/synastry;
- provider-backed Today Together;
- provider-backed Ask answers;
- other features that require individual chart/timing calculations or uncached model generation.

### Initial provider direction

The current initial direction is:

1. **Astrology calculation provider:** a structured astrology service (the Astrologer/RapidAPI option remains under evaluation) produces calculation facts.
2. **Interpretation provider:** DeepSeek V4 Flash is the current low-cost interpretation direction, behind a replaceable interface.
3. **Humay backend:** owns secrets, orchestration, access checks, cache lookup/write, versioning, normalization and provider failure handling.
4. **Apple app:** never receives provider secrets and never calls paid providers directly.

Provider choices are implementation decisions behind Humay-owned contracts. Domain and Presentation models must not depend on vendor response shapes.

## 4. Rewarded Access semantics

A rewarded ad grants **one provider-backed generation for the selected feature/result key**.

Rules:

- check Humay cache before consuming a reward or calling providers;
- if the exact valid result is already cached, reopen it without another generation;
- if generation is needed, a successfully completed rewarded ad authorizes that one generation;
- after successful generation, cache the result so reopening does not require another ad/provider call;
- a materially different input, date/period, person pair, question or methodology/version may be a new generation key;
- failed/cancelled ads grant nothing;
- provider failure after a valid reward requires fair, idempotent recovery so the user is not left with no result and a consumed opportunity.

Rewarded Access is not temporary Premium and is not a bankable coin/token wallet.

## 5. Premium semantics

Premium provides access to included provider-backed personalized features while the subscription entitlement is valid.

Rules:

- cache first even for Premium;
- do not regenerate identical valid results unnecessarily;
- Premium removes the per-generation rewarded-ad requirement for included features;
- provider/rate/abuse limits may exist as operational safeguards but must not be presented as arbitrary hidden astrology limits;
- behavior for viewing previously generated cached Premium results after subscription expiry remains a product decision to finalize before entitlement implementation.

## 6. Cache model

The exact storage technology is an architecture choice, but cache identity must be explicit.

A result key includes only dimensions that can change the result, for example:

- feature type;
- normalized relevant birth inputs/person IDs or a privacy-safe identity/hash;
- selected astrology system/methodology version;
- date/period/event context when relevant;
- calculation-provider/version provenance;
- interpretation prompt/model version;
- locale;
- Normal/Roast expression variant when text differs.

Calculation facts and interpretation text should be separable so a tone/copy change does not require paying to recalculate astrology.

## 7. Normal and Roast

- Normal and Roast use the same underlying astrology facts.
- Roast must not change calculated meaning to manufacture jokes.
- Calculation results should be cached independently from tone where practical.
- Notifications remain Normal-register copy unless product policy is explicitly changed.

## 8. Cost invariants

Engineering tests/observability must make these invariants measurable:

- a normal Free catalog request makes **0 paid provider calls**;
- a Free cache miss falls back to Humay-owned stored catalog content/error behavior, not a paid provider;
- a cached personalized result makes **0 new astrology/LLM calls**;
- one rewarded generation cannot fan out into uncontrolled duplicate provider calls;
- provider retries are bounded/idempotent;
- Premium still uses cache before generation.

## 9. Privacy boundary

Birth date/time/location and saved-person data are sensitive product data even without account login.

- send only fields required for the requested precision feature;
- keep provider secrets server-side;
- redact sensitive inputs from logs;
- define retention/deletion/export policy before production provider rollout;
- do not send Free users' full birth data to paid providers merely to serve a coarse catalog reading.

## 10. Current design implications

The current D0–D9 design program must represent, where relevant:

- Free coarse/sign-based Today vs precise personalized Today;
- Chart as a precision feature rather than a Free natal-chart baseline;
- coarse 144-key Western compatibility vs precise compatibility;
- Rewarded Access as one personalized generation with cached-result reopening;
- Premium access to provider-backed personalization;
- clear limited-accuracy/basis disclosure for Free content;
- cache/reopen states that do not repeatedly ask for ads;
- failure/retry states when reward completion succeeds but provider generation fails.

These access semantics are implemented only when their owning feature/monetization phases begin; the Apple-platform foundation must preserve the boundary without prematurely building feature-specific access UI.
