# D1 Step 02 — Birth Date

Status: **iPhone Light/Dark approved; iPad companions pending**

This is the repository-owned design package for the canonical second Humay onboarding beat. It follows the approved D0 Soulful Celestial references and current product behavior.

## Canonical visual references

- `birth-date-light.svg` — iPhone Light reference.
- `birth-date-dark.svg` — iPhone Dark reference.
- `birth-date-light-dark.svg` — side-by-side iPhone review board.
- `birth-date-elements.svg` — reusable component / visual-element board.

The SVG references are editable, GitHub-viewable and use canonical Humay tokens. The side-by-side board is the primary iPhone review shot.

## Cross-device status

- iPhone Light: approved
- iPhone Dark: approved
- iPad Light: pending
- iPad Dark: pending
- iPad adaptive/landscape notes: pending

Do not treat the iPhone canvas as an iPad layout. The iPad companion design must use a bounded content composition and preserve native date-picker ergonomics.

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
5. hairline divider;
6. explanatory notes;
7. primary Continue action.

The screen is deliberately utility-led. Personality comes from illustration, typography and disciplined accent color rather than decoration around every control.

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
