# D1 Step 02 — Birth Date

Status: **iPhone Light/Dark approved; iPad companion references ready for review**

This is the repository-owned design package for the canonical second Humay onboarding beat. It follows the approved D0 Soulful Celestial references and current product behavior.

## Canonical visual references

Approved iPhone:
- `birth-date-light.svg`
- `birth-date-dark.svg`
- `birth-date-light-dark.svg`
- `birth-date-elements.svg`

New iPad review board:
- `birth-date-ipad-review.svg` — Portrait Light/Dark + Landscape Light/Dark + adaptive note.

The SVG references are editable, GitHub-viewable and use canonical Humay tokens.

## Cross-device status

- iPhone Light: approved
- iPhone Dark: approved
- iPad Portrait Light: ready for review
- iPad Portrait Dark: ready for review
- iPad Landscape Light: ready for review
- iPad Landscape Dark: ready for review
- iPad adaptive notes: defined

## Product truth

Route:

`Welcome → Birth Date → Tradition → Profile Reveal`

The Birth Date screen:

- returns to Welcome through the back control;
- continues to Tradition;
- collects date only;
- does **not** request birth time or birth location;
- uses native date-input semantics;
- allows dates from 1900-01-01 through the current date unless product policy changes;
- keeps Continue clearly reachable;
- remains scrollable/reflowable at large Dynamic Type sizes.

Birth time and place may be added later from Profile for precision-dependent features.

## Canonical copy

### Step label

`01 · Birth date`

### Heading

`When were you born?`

### Supporting note

`Your date is enough to start.`

### Explanation 1

`This is all the general reading needs — your Sun sign, your Chinese year and sign-to-sign compatibility all follow from the date alone.`

### Explanation 2

`Birth time and place are not required now. You can add them later in Profile, and they unlock the parts of a chart that genuinely depend on them.`

### Action

`Continue`

Copy remains subject to product/methodology reconciliation if a statement becomes too broad for a specific tradition, but no implementation should silently add a time/location onboarding step.

## Layout hierarchy

1. top chrome — back control + compact step label + subtle progress treatment;
2. large editorial question;
3. date picker on a quiet contained surface;
4. one restrained calendar/celestial illustration;
5. explanatory notes;
6. primary Continue action.

The screen is deliberately utility-led. Personality comes from illustration, typography and disciplined accent color rather than decoration around every control.

## iPad composition

### Portrait

A bounded two-region middle section pairs the date picker with a smaller explanatory/motif region. The detailed explanation remains below the picker, separated by a hairline. CTA stays centered and bounded.

### Landscape

Editorial question and optional-precision explanation occupy the left region. The date picker, validation/explanation notes and CTA occupy the right region.

### Compact iPad / multitasking

Collapse toward the approved iPhone hierarchy. Keep native date-input ergonomics and let explanatory copy reflow/scroll rather than reducing type size.

## Appearance

### Light

- warm cream ground;
- ivory picker surface;
- dark ink headline/body;
- pale warm selection band;
- coral/lavender/solar-gold accents;
- soft hairlines and no heavy shadow.

### Dark

- midnight-navy ground, never black;
- deep navy picker surface;
- warm ivory type;
- muted raised selection band;
- slightly more luminous coral/lavender/gold;
- approved Coral → Lavender primary CTA;
- intentionally composed dark treatment rather than inversion.

## Typography

- Cormorant Garamond for large editorial hierarchy;
- SF Pro / system for UI and body copy;
- SF Mono only where technical values genuinely benefit from monospacing.

## Color authority

Production tokens remain governed by `SOULFUL_CELESTIAL_DESIGN_DIRECTION.md` and are repeated in `design-spec.json` for this handoff.

| Role | Light | Dark |
|---|---|---|
| Ground | `#FBF7F1` | `#101725` |
| Surface | `#FFFDFC` | `#171F30` |
| Raised / secondary | `#F7F0E8` | `#20283A` |
| Primary text | `#151B28` | `#F5F0EA` |
| Secondary text | `#6C6A6C` | `#B8B2B2` |
| Hairline | `#E9E0D8` | `#30394B` |
| Coral | `#F06F67` | `#F77476` |
| Lavender | `#9A82C8` | `#B06BD4` |
| Solar gold | `#D5A253` | `#E5AA55` |

## Reusable elements

`elements/` stores standalone vector references:

- `birth-date-motif-light.svg`
- `birth-date-motif-dark.svg`
- `progress-light.svg`
- `progress-dark.svg`

These are documentation/reference assets, not automatically shipping assets. Promote approved production artwork separately to `Humay/Resources/Assets.xcassets/`.

## Accessibility / implementation notes

- preserve native date-picker accessibility semantics;
- minimum hit target remains 44 pt;
- do not shrink the editorial heading to force a fixed layout;
- content scrolls/reflows when Dynamic Type requires it;
- color cannot be the only indicator of selection;
- date values remain available as text, never illustration-only;
- preserve the explicit no-fake-precision explanation about birth time/place.

## Sample-data note

The displayed sample date `March 14, 1994` is a design fixture only.
