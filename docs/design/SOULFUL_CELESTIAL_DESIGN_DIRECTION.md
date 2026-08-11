# Soulful Celestial Design Direction

**Status:** Current visual authority  
**Approved:** 2026-08-12  
**Scope:** Humay iPhone UI, Light + Dark appearance, illustration language, motion and hierarchy

## 1. Product feeling

Humay should feel **alive, warm, charming and premium**.

The product is neither a serious utility wearing astrology symbols nor a cartoon astrology game. The visual idea is:

> **storybook-quality celestial art inside a polished modern iOS product.**

A user should feel curiosity and affection when opening Humay. Color, illustration and small moments of personality make it memorable while information architecture and reading remain clear.

### Personality balance

- soulful, not solemn;
- cute, not childish;
- colorful, not noisy;
- illustrated, not clip-art-like;
- magical, not generic purple-neon astrology;
- premium, not sterile;
- playful in selected moments, not on every control.

## 2. Visual intensity system

Not every surface gets the same amount of art.

### Level A — Hero

Use for the emotional center of a screen: Today hero, compatibility hero, onboarding reveal, major chart/system introductions and premium moments.

May include a large painterly celestial scene, expressive sun/moon art, a rich color field, restrained orbit/constellation detail and one strong editorial headline.

Normally use **one Level A moment per screen**.

### Level B — Illustrated feature

Use for meaningful cards and reading categories such as Love, Career, Finance, Health, relationship dimensions and Sky highlights.

May include one compact illustration, a category-specific accent, a soft tinted surface and sparse sparkle/star detail.

### Level C — Utility

Use for settings, forms, lists, technical chart data, metadata, buttons and dense information.

Keep mostly native and quiet: solid/lightly tinted surfaces, system or restrained custom symbols, strong typography and spacing, and little/no decorative illustration.

### Restraint rule

Do **not** put stars, gradients, faces or painterly art on every card. Delight works because it contrasts with calm utility surfaces.

## 3. Illustration language

### Approved

- painterly gouache/watercolor texture;
- rich celestial skies and landscapes;
- warm illustrated suns and moons with gentle expression, used selectively;
- symbolic mini-illustrations for categories;
- tasteful botanical/celestial combinations;
- semi-real editorial portraits for people/compatibility where useful;
- thin orbit lines, stars and constellations as secondary framing;
- subtle soft grain/paper texture.

### Avoid

- chibi characters;
- 3D emoji-like mascots;
- sticker-sheet density;
- thick cartoon outlines;
- generic glowing purple galaxy backgrounds;
- default glassmorphism;
- clip-art iconography;
- a face on every planet/icon;
- decorative art behind dense text.

Every generated or commissioned asset must look as if it came from one illustrator and one color world.

## 4. Color system

These are starting tokens and may be tuned after contrast testing.

### Light appearance

| Role | Starting value |
|---|---:|
| Ground | `#FFF8ED` |
| Surface | `#FFFDF8` |
| Ink | `#17213F` |
| Secondary ink | `#596070` |
| Coral | `#F06C5D` |
| Peach | `#F6AA83` |
| Gold | `#E6A12C` |
| Lavender | `#9B72DA` |
| Plum | `#57305F` |
| Celestial blue | `#4E8DBE` |
| Sage | `#78966D` |
| Rose | `#D95C78` |

Light mode should feel luminous and tactile, not stark white.

### Dark appearance

| Role | Starting value |
|---|---:|
| Ground | `#0D1220` |
| Surface | `#151B2C` |
| Raised surface | `#1B2236` |
| Ink | `#F8F1E7` |
| Secondary ink | `#B7BDCD` |
| Hairline | `#FFFFFF1A` |

Dark mode is **not an inversion**. Keep the celestial palette recognizable and maintain warmth/saturation in illustrations. Dark surfaces should feel like night around the artwork, not a gray accessibility skin.

### Color discipline

- Use color to identify content or emotion, not merely decorate.
- Establish one dominant accent family per screen with a small number of supporting colors.
- Long reading text remains high-contrast neutral.
- Never communicate state by color alone.

## 5. Typography

- **Cormorant Garamond** — wordmark, hero headings, major editorial reading titles and expressive percentages/scores.
- **SF Pro / system** — body copy, controls, navigation, settings, forms and most card text.
- **SF Mono / system** — degrees, coordinates and technical dates/times where mono improves scanning.

Expressive scale and italics are welcome where they strengthen hierarchy, but Dynamic Type must remain robust.

## 6. Surfaces, shape and elevation

### Cards

- Hero/feature cards: roughly 18–28 pt radius.
- Compact information cards: roughly 12–18 pt radius.
- Prefer tinted backgrounds and soft borders over a UI made entirely of white cards.

### Elevation

Light mode may use controlled soft shadows for separation. Dark mode relies more on tonal elevation, hairlines and selective luminosity from artwork.

### Texture

Paper/grain texture is allowed only at low intensity. Text and controls remain crisp.

## 7. Light and Dark parity

Every approved Humay screen must have a paired Light and Dark reference before visual freeze.

For Dark mode:

- redesign backgrounds and cards for night values;
- preserve illustration identity rather than applying a global filter;
- rebalance gold/coral/lavender accents for contrast;
- keep stars/orbit lines secondary;
- avoid pure black except where system UI requires it;
- keep major illustrations luminous against the midnight ground.

An automatic dark conversion is only a study, never the final design deliverable.

## 8. Canonical information architecture

**Today / Circle / Sky / Chart / Ask**

- Calendar is under Sky.
- Profile / Settings is reached through the header/profile entry.
- Compatibility is reached through Circle/people flows.
- A concept screenshot does not change navigation by itself.

## 9. Core-screen direction

### Today

Today is the warmest and most immediately lovable screen.

- One hero cosmic-weather illustration.
- A short emotional summary before dense reading text.
- Love, Career, Finance and Health may use Level B illustrated cards.
- Planet/transit mood may be colorful without becoming a mascot row.
- Free vs precise provenance/access stays clear.

### Daily Horoscope / reading detail

- Editorial headline plus one meaningful celestial scene.
- Long text lives on calm surfaces.
- Category cards reuse the Today visual language.
- Timing callouts appear only when methodology/calculation supports them.

### Circle and Compatibility

- Human connection feels romantic/warm rather than analytical.
- Portrait medallions, connective orbit lines and sun/moon imagery are appropriate Level A devices.
- Compatibility may present an overall percentage/score and dimension percentages as a presentation pattern.
- Qualitative language accompanies numbers.
- The real scoring algorithm remains separate product/methodology work.

### Sky

Use deeper blue/lavender celestial art where it improves orientation. Calendar grids and event lists remain utility-first.

### Chart

Chart remains data-first. Illustration introduces systems and major summaries; it does not sit behind technical values.

- Western: indigo/navy + gold celestial geometry.
- Vedic: saffron/gold + deep blue, respectful and non-pastiche.
- Chinese/BaZi: vermilion/jade/ink-inspired accents without decorative stereotypes.
- Compare Systems: neutral base with system-specific accents.

### Ask

Ask feels intimate and magical while retaining a familiar conversation structure. Concentrate illustration in the empty/hero and access moments; keep messages calm and readable.

### Settings

Settings are Level C: native hierarchy first, with small purposeful color accents or glyphs.

### Monetization

Premium/rewarded moments may carry richer art, but decoration may never obscure price, ad behavior, cache/reopen behavior or entitlement state.

## 10. Onboarding

Visual intensity increases gradually:

1. Welcome — strong brand/hero.
2. Value proposition — warm Level A/B.
3. Birth date — utility with small illustration.
4. Birth time — utility.
5. Unknown-time explanation — calm educational illustration.
6. Birth location — utility.
7. System selection — colorful system cards.
8. Calculation/progress — atmospheric motion.
9. Reveal — strongest celebratory Level A moment.

## 11. Motion

Good candidates:

- slow orbit/parallax on hero art;
- tiny sparkle appearance on reveal;
- subtle watercolor light shift;
- gentle card entrance/matched geometry;
- quiet haptic confirmation.

Avoid busy particle fields, bouncing mascots and decorative motion on utility screens. Respect Reduce Motion.

## 12. Accessibility

- Dynamic Type hierarchy survives accessibility sizes.
- Rows reflow instead of shrinking important text.
- Fixed-geometry art steps aside when it blocks content.
- Information is never encoded only by color or illustration.
- Light and Dark contrast are tested separately.
- Decorative artwork does not replace accessible text for factual information.

## 13. Asset strategy

During design exploration:

- screen references live under `docs/design/soulful-reference/`;
- reusable illustration/source references live under `docs/design/soulful-reference/assets/`;
- reference art is not automatically a production asset.

After approval for shipping:

- export optimized production artwork with explicit names and appearance behavior;
- add raster/vector assets to `Humay/Resources/Assets.xcassets/`;
- provide Light/Dark variants only when the artwork genuinely changes;
- never ship full screenshot crops as app assets.

## 14. Visual completion definition

A screen family is complete only when:

1. Light reference approved;
2. Dark reference approved;
3. hierarchy/copy/access state agree with product authority;
4. artwork matches the shared illustration system;
5. accessibility/contrast risks are resolved or recorded;
6. reusable production-asset candidates are identified separately from screenshot reference art.

See [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md) for the phased screen inventory.
