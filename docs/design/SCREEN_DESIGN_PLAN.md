# Humay Light + Dark Screen Design Plan

**Active design branch:** `design/soulful-light-dark`  
**Visual authority:** [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)

## Goal

Redesign every Humay product surface in the approved soulful celestial direction and produce an intentional **Light + Dark pair** for each screen before implementation is visually frozen.

This is a phased design pass, not a single bulk-generation exercise. Each phase establishes reusable art/layout rules for the next phase so the product does not drift into unrelated illustration styles.

## Reference structure

```text
docs/design/soulful-reference/
  README.md
  anchors/
    light/
    dark/
  onboarding/
    light/
    dark/
  today/
    light/
    dark/
  circle/
    light/
    dark/
  sky/
    light/
    dark/
  chart/
    light/
    dark/
  ask/
    light/
    dark/
  settings/
    light/
    dark/
  monetization/
    light/
    dark/
  sharing-widgets/
    light/
    dark/
  brand/
  assets/
```

Approved production artwork is later exported separately into `Humay/Resources/Assets.xcassets/`. Reference screenshots/crops are not production assets by default.

## D0 — Visual anchor lock

Purpose: establish the shared visual language before redesigning the full app.

| Screen | Light | Dark | Status |
|---|---|---|---|
| Today / Home visual anchor | required | required | Initial pair created |
| Daily Horoscope / reading detail | required | required | Initial pair created |
| Compatibility visual anchor | required | required | Initial pair created |

The Light images are the selected product direction. The first Dark images are translation studies that define midnight surfaces and retained color; they must receive a dedicated refinement pass before Dark mode becomes implementation-final.

D0 also establishes:
- painterly celestial illustration language;
- navy/ivory editorial typography relationship;
- coral/gold/lavender/blue/sage category accents;
- card radius/elevation behavior;
- light cream and dark midnight grounds;
- art intensity A/B/C rules.

## D1 — Onboarding

Generate and review each in both appearances:

1. Welcome
2. Value proposition
3. Birth date
4. Birth time
5. Unknown birth-time path
6. Birth location
7. Astrology system selection
8. Calculation/progress
9. Big Three / first reveal

**Deliverable:** 18 screen references plus any reusable welcome/reveal/system artwork.

Design rule: visual intensity rises toward the reveal; data-entry steps stay calmer.

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
6. Unknown/insufficient birth-data compatibility state where applicable

**Deliverable:** paired references for all final states plus reusable Love/Career/Finance/Health and relationship art.

## D3 — Sky + Calendar

1. Current Sky
2. Calendar month
3. Calendar week
4. Event detail
5. Relevant empty/unavailable state if required by the product flow

**Deliverable:** Light/Dark pairs; calendar remains utility-first while Current Sky/Event Detail may carry richer celestial art.

## D4 — Chart + astrology systems

1. Chart overview
2. Western chart
3. Placement/detail reading
4. Vedic chart
5. Chinese / BaZi chart
6. Compare Systems
7. Unknown birth-time state
8. Precision access/generation state where Chart requires it

**Deliverable:** paired references and system-specific color/art rules without compromising technical readability.

## D5 — Ask the Stars

1. Ask empty/question state
2. Conversation/answer state
3. Loading/generating state
4. Rewarded extension state
5. Provider/error/recovery state where user action differs

**Deliverable:** paired references. Conversation UI stays familiar; illustration is concentrated in the empty/hero and access moments.

## D6 — Profile + Settings

At minimum:

1. Profile / settings cover
2. Astrology settings
3. Notification settings
4. Privacy/data settings
5. Birth details editor if visually separate
6. Appearance/tone controls if retained
7. Saved People management if not already fully represented in Circle

**Deliverable:** paired references. These are primarily Level C utility surfaces.

## D7 — Monetization + access

1. Premium paywall
2. Rewarded generation gate
3. Ask rewarded extension
4. Generation/unlocked confirmation
5. Premium sheet / plan detail
6. Provider failure after rewarded completion
7. Cached-result reopen state if user-facing treatment differs

**Deliverable:** paired references consistent with `PRODUCT_ACCESS_MODEL.md`. Decorative art must never obscure the exact entitlement/action.

## D8 — Sharing, widgets and global states

1. Share-card system
2. Widget size family
3. Loading / empty / error state board
4. Offline/cached state if required
5. Notification visual examples if useful for implementation

**Deliverable:** paired appearance references where iOS supports appearance variants, plus export guidance for share surfaces that may use their own fixed theme.

## D9 — Brand + production handoff

Finalize:

- Humay wordmark behavior on Light/Dark;
- mark/app-icon direction;
- launch screen Light/Dark;
- palette/type/component token board;
- illustration asset catalog;
- production asset export list;
- overview contact sheets;
- screen index with approval status;
- final authority reconciliation.

## Expected reference volume

The historical archive contains 46 individual/reference screen captures plus overview sheets. The new pass adds additional access/cache/error states and pairs every appearance.

Expected scope is **at least ~82 Light/Dark product-screen references**, plus brand/token boards, reusable art references and contact sheets. The exact total follows final state inventory; completeness matters more than matching a target number.

## Per-screen checklist

Before a screen is marked approved:

- [ ] correct canonical IA / route
- [ ] current product/access semantics
- [ ] Light design approved
- [ ] Dark design approved
- [ ] only one dominant Level A hero when appropriate
- [ ] illustration style matches shared Humay art language
- [ ] color has semantic purpose
- [ ] readable at normal and accessibility text sizes
- [ ] contrast checked separately in Light and Dark
- [ ] mock astrology values clearly treated as illustrative
- [ ] production-asset candidates identified

## Review cadence

Do not generate the entire product and review at the end. Work phase by phase:

1. generate Light composition;
2. correct hierarchy/content;
3. design Dark counterpart intentionally;
4. compare side by side;
5. freeze reusable illustration/component rules;
6. commit references/assets;
7. proceed to the next phase.

This cadence is the mechanism for preventing visual drift across dozens of screens.