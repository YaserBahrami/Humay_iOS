# Humay Light + Dark Screen Design Plan

**Status:** Current and only screen-design plan  
**Active branch:** `design/soulful-light-dark`  
**Visual authority:** [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)

## Goal

Design every Humay product surface in the selected cosmic-editorial direction and produce an intentional **Light + Dark pair** before final visual implementation is frozen.

Every completed step must store its review imagery, design specification and reusable reference elements in the repository so later implementation agents do not have to infer visual details from chat history.

## Reference structure

```text
docs/design/soulful-reference/
  anchors/                 # D0 selected references
  onboarding/              # D1 current design packages + historical drafts
  components/              # shared UI + illustration boards
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

Repository design packages may contain SVG plus compressed high-quality WebP review imagery. Production artwork is exported separately into `Humay/Resources/Assets.xcassets/` only after approval.

## D0 — Visual anchor lock — APPROVED

| Screen | Light | Dark | Status |
|---|---|---|---|
| Today / Home | committed | committed | approved style source |
| Daily Horoscope | committed | committed | approved style source |
| Compatibility | committed | committed | approved style source |

D0 establishes warm cream vs midnight navy appearance, strong editorial serif + clean system UI typography, simple cute line/flat celestial illustration, disciplined coral/lavender/gold/blue/sage accents, soft rounded cards and sparse decoration.

## D1 — Onboarding — REDESIGN IN PROGRESS

The previous nine-screen onboarding exploration is stale. The current app implements four beats in `OnboardingFlowView.Step`, and D1 follows that product truth.

1. Welcome — **Light/Dark redesigned; ready for review**
2. Birth Date — **Light/Dark + elements + spec committed; ready for review**
3. Tradition — **next**
4. Profile Reveal — pending

Birth time and birth location are not onboarding steps. They are optional later inputs for precise chart features.

### Step 01 references

- `soulful-reference/onboarding/light/01-welcome.svg`
- `soulful-reference/onboarding/dark/01-welcome.svg`

### Step 02 package

`docs/design/soulful-reference/onboarding/step-02-birth-date/`

Contains:

- `birth-date-light-dark.webp`
- `birth-date-elements.webp`
- `README.md`
- `design-spec.json`
- `elements/*.svg`

The Birth Date package is reconciled with the current app behavior: native wheel date picker, 1900-01-01 through today, no birth-time/location collection, back to Welcome and Continue to Tradition.

Do not propagate any legacy nine-screen onboarding draft into implementation.

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

## D3 — Sky + Calendar

1. Current Sky
2. Calendar month
3. Calendar week
4. Event detail
5. Required empty/unavailable state

## D4 — Chart + astrology systems

1. Chart overview
2. Western chart
3. Placement/detail reading
4. Vedic chart
5. Chinese / BaZi chart
6. Compare Systems
7. Unknown birth-time state
8. Precision access/generation state where required

## D5 — Ask the Stars

1. Empty/question state
2. Conversation/answer state
3. Loading/generating state
4. Rewarded extension state
5. Provider/error/recovery state

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

Finalize wordmark, mark/app icon, launch Light/Dark, final token board, component inventory, illustration asset catalog, production export list, overview contact sheets and final authority reconciliation.

## Per-screen repository package

For each new screen/step, store:

- [ ] Light review image
- [ ] Dark review image
- [ ] side-by-side review board
- [ ] element/component board when the screen introduces reusable treatment
- [ ] editable reference elements where applicable
- [ ] canonical copy and behavior
- [ ] structured design spec / handoff data
- [ ] accessibility notes
- [ ] sample-data disclaimer
- [ ] links from the relevant design indexes

## Per-screen approval checklist

- [ ] canonical route/IA correct
- [ ] current access semantics
- [ ] Light design approved
- [ ] Dark design approved
- [ ] hierarchy matches D0
- [ ] simple/editorial illustration style; no painterly drift
- [ ] color has semantic purpose
- [ ] readable at accessibility sizes
- [ ] contrast checked separately
- [ ] mock astrology values remain illustrative
- [ ] reusable assets/components identified

## Review cadence

1. generate/compose Light;
2. correct hierarchy and product content;
3. compose Dark intentionally;
4. review side by side;
5. reconcile shared components/assets;
6. commit complete repository package;
7. mark phase approved;
8. continue to next phase.

Do not create a second parallel design plan.
