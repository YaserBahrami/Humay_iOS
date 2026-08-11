# D1 Step 02 — Birth Date

Status: **LIGHT/DARK DESIGN GENERATED — READY FOR REVIEW**

This is the complete repository-owned design package for the canonical second Humay onboarding beat. It follows the approved D0 Soulful Celestial references and the product behavior already implemented by `OnboardingBirthDateView`.

## Canonical visual references

- `birth-date-light.svg` — full Light screen reference.
- `birth-date-dark.svg` — full Dark screen reference.
- `birth-date-light-dark.svg` — side-by-side review board.
- `birth-date-elements.svg` — reusable component / visual-element board.

The SVG references are editable, GitHub-viewable and use canonical Humay tokens. The side-by-side board is the primary review shot; the individual Light/Dark files preserve implementation-level screen detail.

## Product truth

Route:

`Welcome → Birth Date → Tradition → Profile Reveal`

The Birth Date screen:

- returns to Welcome through the back control;
- continues to Tradition;
- collects date only;
- does **not** request birth time or birth location;
- uses a native wheel date picker;
- allows dates from 1900-01-01 through the current date;
- keeps the primary action pinned by the shared onboarding scaffold;
- remains scrollable at large Dynamic Type sizes.

## Canonical copy

### Step label

`01 · Birth date`

### Heading

`When were you born?`

### Supporting note

The approved reference uses:

`Your date is enough to start.`

This line is presentation copy and should only be added to production if retained during implementation reconciliation.

### Explanation 1

`This is all the general reading needs — your Sun sign, your Chinese year and sign-to-sign compatibility all follow from the date alone.`

### Explanation 2

`Birth time and place are not required now. You can add them later in Profile, and they unlock the parts of a chart that genuinely depend on them.`

### Action

`Continue`

## Layout hierarchy

1. top chrome — back control + compact step label + subtle progress treatment;
2. large editorial question;
3. wheel date picker on a quiet contained surface;
4. one restrained calendar/celestial illustration;
5. hairline divider;
6. two explanatory notes with small sun/moon accents;
7. primary Continue action.

The screen is deliberately utility-led. Personality comes from the illustration, typography and disciplined accent color rather than decoration around every control.

## Appearance

### Light

- warm cream ground;
- ivory picker surface;
- dark ink headline/body;
- pale warm selection band;
- coral sun accent;
- lavender secondary accent;
- solar-gold illustration accent;
- very soft hairlines and no heavy shadow.

### Dark

- midnight-navy ground, never black;
- deep navy picker surface;
- warm ivory type;
- muted raised selection band;
- slightly more luminous coral/lavender/gold;
- calendar + crescent motif remains colorful;
- primary action uses the stronger coral→lavender emphasis established by the current dark D1 direction.

## Typography

Production typography remains governed by `SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`:

- Cormorant Garamond for large editorial hierarchy;
- SF Pro / system for UI and body copy;
- SF Mono only where technical values genuinely benefit from monospacing.

## Color authority

Production color tokens remain the canonical values in `SOULFUL_CELESTIAL_DESIGN_DIRECTION.md` and are repeated in `design-spec.json` for this handoff.

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

`elements/` stores small standalone vector references:

- `birth-date-motif-light.svg`
- `birth-date-motif-dark.svg`
- `progress-light.svg`
- `progress-dark.svg`

These are documentation/reference assets. They are **not automatically shipping assets**. Promote approved production artwork separately to `Humay/Resources/Assets.xcassets/`.

## Accessibility / implementation notes

- keep native wheel-picker semantics and accessibility labeling;
- minimum hit target remains 44 pt;
- do not shrink the editorial heading to force a fixed layout;
- content must scroll when Dynamic Type requires it;
- color cannot be the only indicator of selection;
- use text labels for date values rather than relying on illustration;
- preserve the explicit no-fake-precision explanation about birth time/place.

## Sample-data note

The displayed sample date `March 14, 1994` is a design fixture only.
