# Humay Design Authority

**Status:** Current and exclusive design authority  
**Effective:** 2026-08-12  
**Repository authority:** `main`

`main` contains one current design program only. Temporary feature/design branches must merge back here and must not become separate authorities.

## 1. Authority order

For implementation, use this order:

1. [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md) — access/cost behavior.
2. This document — design authority and non-negotiable product/device constraints.
3. [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — current visual language.
4. [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md) — screen inventory and sequencing.
5. Approved references under [`soulful-reference/`](soulful-reference/README.md).
6. [`../development/METHODOLOGY_TRACK.md`](../development/METHODOLOGY_TRACK.md) — methodology gates for real astrology output.

If a mockup conflicts with product access, methodology, device behavior or accessibility, the mockup is corrected.

## 2. Canonical information architecture

Primary navigation remains:

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is opened from the profile/header entry.
- Compatibility is reached through Circle/people flows.
- Reference screenshots may contain temporary navigation labels; they do not redefine IA.

## 3. Current visual direction

The selected Humay style is **cosmic editorial with selective cute illustration**:

- warm cream Light mode and deep navy Dark mode;
- strong serif editorial headlines with clean system UI typography;
- restrained coral/lavender/gold/blue/sage accents;
- soft rounded cards and simple line/flat illustrations;
- friendly celestial characters/objects used sparingly;
- clean utility surfaces with minimal decoration;
- intentional Light and Dark composition.

The D0 Today, Daily Horoscope and Compatibility references under `soulful-reference/anchors/` define the visual source of truth.

The old Paper/minimal direction and painterly/watercolor explorations are superseded and must not be used for implementation.

## 4. Appearance requirement

Every shipping screen requires deliberate Light and Dark treatment. Dark mode is not inversion: it uses midnight grounds, tonal card elevation, warm light text and slightly brighter accents.

The application follows the system appearance by default. Do not hard-force Light or Dark globally.

## 5. Device requirement — iPhone + iPad

**iPhone and iPad are first-class shipping platforms from this baseline forward.**

Every approved screen family must account for:

- iPhone portrait;
- iPad portrait;
- iPad landscape;
- compact and regular horizontal size classes where they materially change composition;
- split-view / reduced iPad window widths where the layout can encounter them.

A phone layout must not simply be stretched across an iPad canvas. iPad should use width deliberately: bounded reading columns, side-by-side regions where useful, larger art only when it improves hierarchy, and stable navigation behavior.

### Design-reference minimum

Before a screen is considered ready for final visual implementation, the repository must contain:

1. iPhone Light reference;
2. iPhone Dark reference;
3. iPad Light reference;
4. iPad Dark reference;
5. notes for iPad landscape/adaptive behavior if the static portrait reference is insufficient.

Existing approved iPhone D0/D1 references remain valid. The complete D1 cross-device package was approved on 2026-08-12 and is now the production onboarding implementation authority.

## 6. Typography

- **Cormorant Garamond** — wordmark, hero/editorial headlines and selected large scores.
- **SF Pro / system** — body copy, controls, navigation, forms and settings.
- **SF Mono / system** — technical degrees/coordinates/dates/times where beneficial.

Dynamic Type is mandatory. iPad does not justify fixed text sizes or oversized empty layouts.

## 7. Illustration and visual intensity

- **Level A:** one major emotional moment on Today, Compatibility, onboarding welcome/reveal and selected premium surfaces.
- **Level B:** one compact simple illustration for meaningful feature/category cards.
- **Level C:** quiet native utility surfaces for forms, settings and dense technical data.

Approved illustration is simple line/flat cosmic art with minimal shading, small stars/orbit details and occasional friendly faces. Avoid chibi, 3D emoji, sticker density, painterly landscapes, thick cartoon outlines and generic purple-neon galaxy styling.

## 8. Product and astrology boundaries

User-facing access remains **Free → optional Rewarded Access → Premium**. Design cannot redefine entitlement behavior.

Mock dates, signs, scores and readings in visual references are illustrative. Production placements, houses, aspects, timing, dashas, pillars and relationship facts require validated structured calculation/provider data. Unknown birth time is never replaced with a hidden fake time.

## 9. Roast and notifications

- Roast changes expression, not calculated facts.
- Roast is an in-app register.
- Notifications remain Normal-register copy unless product policy is explicitly changed.

## 10. Accessibility and input

- minimum 44 pt hit targets;
- Dynamic Type through accessibility sizes;
- VoiceOver labels for meaningful non-text UI;
- Light/Dark contrast checked separately;
- color is never the only carrier of meaning;
- Reduce Motion respected;
- iPad pointer/keyboard behavior must remain functional where native controls provide it.

## 11. Current implementation status

The old mock-first Presentation, DesignSystem and mock provider implementation were removed on 2026-08-12 before production UI implementation. The Xcode/project foundation was retained and now targets iPhone + iPad.

Production implementation proceeds only from approved repository references, family by family.

## 12. Current design status

- **D0:** approved iPhone Light/Dark style anchors; iPad companions remain a later D0 task.
- **D1:** approved cross-device on 2026-08-12 for Welcome, Birth Date, Tradition and Profile Reveal; production UI is implemented under `Humay/Presentation/Onboarding/`.

Current D1 implementation evidence lives under `implementation-evidence/d1-onboarding/`. Completion is in-memory only until PROFILE-005; no provider-backed astrology is used by Profile Reveal.
- Remaining families follow [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md).

No alternate design authority should be added alongside this one.
