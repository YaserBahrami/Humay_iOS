# Humay Cross-Device Screen Design Plan

**Status:** Current and only screen-design plan  
**Repository authority:** `main`  
**Visual authority:** [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)

## Goal

Design every Humay product surface in the selected Soulful Celestial direction and produce an intentional cross-device reference set before final implementation is frozen.

Every shipping screen requires:

- iPhone Light;
- iPhone Dark;
- iPad Light;
- iPad Dark;
- adaptive/landscape notes where the iPad composition changes materially.

The iPad design is not a scaled-up phone screenshot.

## Reference structure

```text
docs/design/soulful-reference/
  anchors/
  onboarding/
  components/
  today/
  circle/
  sky/
  chart/
  ask/
  settings/
  monetization/
  sharing-widgets/
  brand/
  assets/
```

Per-screen packages should use device-specific folders or unambiguous filenames, for example:

```text
screen-name/
  iphone-light.svg
  iphone-dark.svg
  ipad-light.svg
  ipad-dark.svg
  README.md
  design-spec.json
  elements/
```

Only current/approved references belong in the active reference tree. Superseded screen drafts should be removed; git history is the archive.

## D0 — Visual anchor lock

| Screen | iPhone | iPad | Status |
|---|---|---|---|
| Today / Home | Light + Dark approved | companion designs pending | style source |
| Daily Horoscope | Light + Dark approved | companion designs pending | style source |
| Compatibility | Light + Dark approved | companion designs pending | style source |

D0 establishes warm cream vs midnight navy appearance, editorial serif + clean system typography, restrained celestial illustration, disciplined accent color and soft rounded surfaces.

## D1 — Onboarding

Canonical flow:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Birth time and birth location are not onboarding steps.

### Current state

| Step | iPhone | iPad | Status |
|---|---|---|---|
| Welcome | Light + Dark approved | Light + Dark approved | implemented; evidence captured |
| Birth Date | Light + Dark approved + documented package | Light + Dark approved | implemented; evidence captured |
| Tradition | Light + Dark approved | Light + Dark approved | implemented; evidence captured |
| Profile Reveal | Light + Dark approved | Light + Dark approved | implemented; evidence captured |

D1 cross-device approval date: **2026-08-12**. Production implementation is `Humay/Presentation/Onboarding/`. PROFILE-005 persists the local profile/settings aggregate and restores the completed root on relaunch. D2 is now implemented as a development-sample presentation slice. D3 has only a non-visual engineering/sample foundation; D3 production UI and later screen families remain unimplemented.

The iPad landscape two-region paths are covered by the UI test. iOS 26.5 simulator landscape screenshot export produced an orientation-rotated framebuffer, so those raw captures are documented but not presented as repository evidence; see [`implementation-evidence/d1-onboarding/README.md`](implementation-evidence/d1-onboarding/README.md).

## D2 — Today + Circle

### Today
1. Today primary/home
2. Astrological basis / why this reading
3. Roast expression example
4. Daily reading detail if separate in final navigation
5. Free catalog state
6. Precise/personalized state
7. Cached precise-result state where visually distinct

### Circle
1. People list
2. Person detail
3. Today Together
4. Compatibility overview
5. Deeper compatibility
6. Unknown/insufficient birth-data state where applicable

### D2 implementation status

- Approved iPhone Light/Dark composites: [`soulful-reference/today-circle/`](soulful-reference/today-circle/README.md).
- Later approved Compatibility refinement: [`soulful-reference/today-circle/compatibility-refresh/`](soulful-reference/today-circle/compatibility-refresh/README.md). It supersedes only the older Compatibility-selection and result-hero portions and is implemented in `Humay/Presentation/Circle/CompatibilitySelectionView.swift` and `Humay/Presentation/Circle/CompatibilityView.swift`.
- Implemented: Today, Daily Horoscope, Circle, minimal Add Person, compatibility selection/result and explicit sample/access/cache/offline/error states.
- Real portrait simulator evidence: [`implementation-evidence/d2-today-circle/`](implementation-evidence/d2-today-circle/README.md), with final Compatibility selection/result evidence under [`implementation-evidence/d2-today-circle/compatibility-refresh/`](implementation-evidence/d2-today-circle/compatibility-refresh/README.md).
- iPad uses width-driven two-region layouts and native adaptive tabs/sidebar; compact widths collapse to one column.
- Static approved D2 iPad mockups were not supplied for the older D2 composite family, so pixel-perfect iPad reconciliation is not claimed for unrelated D2 screens. The later Compatibility refinement includes approved iPad Light/Dark references and reconciled simulator evidence.
- iOS 26.5 landscape UI tests pass, but XCTest exports the landscape framebuffer rotated/cropped; raw artifacts are retained and labeled rather than presented as valid visual matches.
- Today Together is not implemented; it remains CIRCLE-006 and was not invented from an unfrozen design.
- Backend/API/provider, Saved People persistence and monetization remain outside D2.

## D3 — Sky + Calendar

1. Current Sky
2. Calendar month
3. Calendar week
4. Event detail
5. Required empty/unavailable state

### Current state

- D3.1 Current Sky Lunar Meridian is the approved visual reference package: [`soulful-reference/sky/current-sky/`](soulful-reference/sky/current-sky/README.md).
- Current Sky iPhone Light/Dark, iPad Light/Dark, adaptive behavior, and state language are approved as visual guidance; `SKY-003` remains TODO.
- D3.2 Calendar Month + Week Meridian Almanac is the approved visual reference package: [`soulful-reference/sky/calendar/`](soulful-reference/sky/calendar/README.md). Approval covers Month iPhone Light/Dark, Month iPad Light/Dark, Week iPhone Light/Dark, Week iPad Light/Dark, the calendar state board, stress board, and Meridian Almanac visual direction; `SKY-004` remains TODO.
- D3.3 Event Detail is a review candidate and is not approved: [`soulful-reference/sky/event-detail/`](soulful-reference/sky/event-detail/README.md).
- Non-visual Domain/Presentation contracts and Debug-only deterministic sample states are implemented.
- Current Sky, month/week Calendar and event-detail SwiftUI remain intentionally unimplemented.
- SKY-003, SKY-004 and SKY-005 remain TODO; no visual completion or reconciliation is claimed.

## D4 — Chart + astrology systems

1. Chart overview
2. Western chart
3. Placement/detail reading
4. Vedic chart
5. Chinese / BaZi chart
6. Compare Systems
7. Unknown birth-time state
8. Precision access/generation state where required

Chart screens require explicit iPad landscape treatment because the extra width can materially improve chart + detail composition.

## D5 — Ask the Stars

1. Empty/question state
2. Conversation/answer state
3. Loading/generating state
4. Rewarded extension state
5. Provider/error/recovery state

On iPad, conversation width must be bounded; do not run text bubbles across the full screen.

## D6 — Profile + Settings

1. Profile/settings cover
2. Astrology settings
3. Notification settings
4. Privacy/data settings
5. Birth-details editor if separate
6. Appearance/tone controls if retained
7. Saved People management if needed

## D7 — Monetization + access

1. Premium paywall
2. Rewarded generation gate
3. Ask rewarded extension
4. Generation/unlocked confirmation
5. Premium plan detail
6. Provider failure after rewarded completion
7. Cached-result reopen state if visually distinct

## D8 — Sharing, widgets and global states

1. Share-card system
2. Widget size family
3. Loading / empty / error state board
4. Offline/cached state where required
5. Notification visual examples

## D9 — Brand + production handoff

Finalize wordmark, mark/app icon, launch Light/Dark, final token board, component inventory, illustration asset catalog, production export list, iPhone/iPad overview contact sheets and final authority reconciliation.

## Per-screen approval checklist

- [ ] canonical route/IA correct
- [ ] current access semantics correct
- [ ] iPhone Light approved
- [ ] iPhone Dark approved
- [ ] iPad Light approved
- [ ] iPad Dark approved
- [ ] iPad portrait/landscape behavior defined where necessary
- [ ] compact/regular width adaptation defined
- [ ] hierarchy matches D0
- [ ] illustration style has not drifted
- [ ] color has semantic purpose
- [ ] Dynamic Type / VoiceOver / hit targets considered
- [ ] mock astrology values remain illustrative
- [ ] reusable assets/components identified

## Design → implementation cadence

1. design the next screen family for iPhone + iPad, Light + Dark;
2. review and approve;
3. implement only the approved family;
4. capture actual iPhone and iPad simulator/device screenshots;
5. reconcile implementation against references;
6. commit implementation evidence and notes;
7. move to the next family.

Architecture and shared foundation work may proceed before every screen is designed, but **feature-specific production UI must not get ahead of approved cross-device references**.
