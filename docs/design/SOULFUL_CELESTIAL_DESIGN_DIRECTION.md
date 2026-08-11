# Soulful Celestial Design Direction

**Status:** Current visual authority  
**Approved:** 2026-08-12  
**Scope:** Humay iPhone UI, Light + Dark appearance, illustration language, motion and visual hierarchy

This document supersedes `MINIMAL_DESIGN_DIRECTION.md` for visual and layout decisions. The older minimal direction remains archived because several of its accessibility and structural lessons are still useful, but it is no longer the target appearance.

## 1. Product feeling

Humay should feel **alive, warm, charming and premium**.

The target is not a serious utility wearing astrology symbols, and it is not a cartoon astrology game. The visual idea is:

> **storybook-quality celestial art inside a polished modern iOS product.**

A user should feel curiosity and affection when opening Humay. Color, illustration and small moments of personality should make the product memorable, while the information architecture and reading experience stay clear.

### Personality balance

- soulful, not solemn;
- cute, not childish;
- colorful, not noisy;
- illustrated, not clip-art-like;
- magical, not generic purple-neon astrology;
- premium, not sterile;
- playful in selected moments, not on every control.

## 2. Visual intensity system

Not every surface deserves the same amount of art. Humay uses three intensity levels.

### Level A — Hero

Use for the emotional center of a screen: Today hero, compatibility hero, onboarding reveal, major chart/system introductions, premium moments.

May include:
- large painterly celestial landscape;
- expressive sun/moon art;
- rich color field;
- decorative orbit line or constellation detail;
- one strong editorial headline.

A screen should normally have **one** Level A moment.

### Level B — Illustrated feature

Use for meaningful cards and reading categories: Love, Career, Finance, Health, relationship dimensions, Sky event highlights, onboarding steps.

May include:
- one compact illustration;
- category-specific accent color;
- soft tinted surface;
- small decorative star/sparkle details.

### Level C — Utility

Use for settings, forms, lists, technical chart data, metadata, buttons, controls and dense information.

Keep mostly native and quiet:
- solid or lightly tinted surfaces;
- system icons or restrained custom symbols;
- no decorative illustration unless it helps comprehension;
- strong typography and spacing do the work.

### Mandatory restraint

Do **not** put stars, gradients, faces or painterly art on every card. Repetition kills the sense of magic. Visual delight must have contrast against calm utility surfaces.

## 3. Illustration language

### Approved

- painterly gouache / watercolor texture;
- rich celestial skies and landscapes;
- warm illustrated suns and moons with gentle human expression;
- symbolic mini-illustrations for categories;
- tasteful botanical/celestial combinations;
- semi-real editorial portraits for people/compatibility where useful;
- thin orbit lines, stars and constellations as secondary framing;
- soft grain/paper texture when subtle.

### Avoid

- chibi characters;
- 3D emoji-like mascots;
- sticker-sheet density;
- thick cartoon outlines;
- generic glowing purple galaxy backgrounds;
- glassmorphism as the default surface language;
- clip-art iconography;
- a face on every planet/icon;
- decorative art behind dense text that harms legibility.

### Art consistency

Every generated or commissioned asset must look as if it belongs to one illustrator and one color world. Individual screens must not introduce unrelated rendering styles.

## 4. Color system

These are visual starting points; implementation tokens may be tuned after contrast testing.

### Light appearance

| Role | Starting value | Use |
|---|---:|---|
| Ground | `#FFF8ED` | warm cream app background |
| Surface | `#FFFDF8` | elevated neutral cards |
| Ink | `#17213F` | primary navy text |
| Secondary ink | `#596070` | supporting text |
| Coral | `#F06C5D` | warmth, love, selected emphasis |
| Peach | `#F6AA83` | soft emotional surfaces |
| Gold | `#E6A12C` | celestial accent, highlights |
| Lavender | `#9B72DA` | intuition, chart/cosmic accents |
| Plum | `#57305F` | deep expressive accent |
| Celestial blue | `#4E8DBE` | health/sky/calm surfaces |
| Sage | `#78966D` | grounded/finance/nature surfaces |
| Rose | `#D95C78` | romance and affectionate moments |

Light mode should feel luminous and tactile, not stark white.

### Dark appearance

| Role | Starting value | Use |
|---|---:|---|
| Ground | `#0D1220` | midnight navy background |
| Surface | `#151B2C` | primary card surface |
| Raised surface | `#1B2236` | prominent card/overlay |
| Ink | `#F8F1E7` | warm ivory primary text |
| Secondary ink | `#B7BDCD` | supporting text |
| Hairline | `#FFFFFF1A` | restrained borders |

Dark mode **is not an inversion** of Light mode. Keep the celestial accent palette recognizable and maintain the saturation and warmth of illustrations. Dark surfaces should feel like night around the artwork, not a gray accessibility theme.

### Color discipline

- Use color to identify content or emotion, not merely decorate.
- A screen should establish one dominant accent family and a small number of supporting colors.
- Large reading paragraphs remain high-contrast neutral text.
- Never communicate state by color alone.

## 5. Typography

Keep the existing strong type foundation:

- **Cormorant Garamond** — Humay wordmark, hero headings, major editorial reading titles and expressive percentages/scores.
- **SF Pro / system** — body copy, controls, navigation, settings, forms and most card text.
- **SF Mono / system** — degrees, coordinates, technical dates/times and chart data where a mono face improves scanning.

The new design allows more expressive scale and italics than the old minimal direction, but hierarchy must survive Dynamic Type.

## 6. Surfaces and shape

The old square-by-default/no-shadow visual lock is superseded.

### Cards

- Hero and feature cards: approximately 18–28 pt corner radius.
- Compact information cards: approximately 12–18 pt.
- Use tinted backgrounds and soft borders rather than filling the UI with white cards.

### Elevation

Light mode may use controlled soft shadows when they improve separation. Dark mode should rely more on tonal elevation, hairlines and selective glow from artwork.

### Texture

Paper/grain texture is allowed only at low intensity. Text and controls must never lose crispness.

## 7. Light and Dark parity

Every approved Humay screen must have a paired Light and Dark reference before implementation is considered visually frozen.

For Dark mode:
- redesign backgrounds and cards for night values;
- preserve the original illustration identity rather than applying a global filter;
- re-balance gold/coral/lavender accents for contrast;
- ensure small stars/orbit lines remain secondary;
- avoid pure black except where required by system UI;
- keep large illustrations luminous against the midnight ground.

A Light screenshot plus an automatic dark conversion is not a final design deliverable. Initial conversions may be used as translation studies only.

## 8. Canonical information architecture

The redesign does **not** change the product IA by itself.

Current primary IA remains:

**Today / Circle / Sky / Chart / Ask**

- Calendar is under Sky.
- Profile / Settings is reached through the header/profile entry.
- Compatibility is reached through Circle/people flows.
- Any concept screenshot showing temporary tabs such as `Compatibility` or `Library` is a visual-style exploration, not an IA decision.

## 9. Core-screen direction

### Today

Today should be the warmest and most immediately lovable screen.

- One hero cosmic-weather illustration.
- A short emotional summary before dense reading text.
- Love, Career, Finance and Health may use Level B illustrated cards.
- Planet/transit mood may be colorful but should not become a row of cartoon mascots.
- Free vs precise provenance/access must remain clear.

### Daily Horoscope / reading detail

- Editorial headline plus one meaningful celestial scene.
- Long text lives on calm surfaces.
- Category cards may reuse the Today visual language.
- Timing callouts appear only when calculation/methodology supports them.

### Circle and Compatibility

- Human connection should feel romantic/warm rather than analytical.
- Portrait medallions, connective orbit lines and sun/moon imagery are appropriate Level A devices.
- Compatibility may present an overall percentage/score and dimension percentages as an approved **presentation pattern**.
- The production algorithm, weights and semantics of any numeric score remain methodology/product work; mockup percentages are never calculation truth.
- Qualitative language should accompany numbers so the result is interpretable rather than gamified.

### Sky

- Use deeper blue/lavender/celestial art where it adds orientation.
- Calendar and event lists remain utility-first.
- A current-sky hero may carry more art; month/week grids should not.

### Chart

Chart remains data-first. Use illustration to introduce systems and major summaries, not behind technical values.

- Western: indigo/navy + gold celestial geometry.
- Vedic: saffron/gold + deep blue, respectful and non-pastiche.
- Chinese/BaZi: vermilion/jade/ink-inspired accent family, avoiding decorative stereotypes.
- Compare Systems: shared neutral base with system-specific accents.

### Ask

Ask should feel intimate and magical but retain a familiar conversational structure. Use one atmospheric illustration/empty-state moment, then keep messages readable and calm.

### Settings

Settings are Level C. Native hierarchy first; tiny color accents or category glyphs are enough.

### Monetization

Premium/rewarded moments can use richer celestial artwork, but the access choice must stay transparent. No decorative treatment may obscure price, ad behavior, cache/reopen behavior or entitlement state.

## 10. Onboarding

Onboarding should increase visual intensity gradually:

1. welcome — strong brand/hero;
2. value proposition — warm Level A/B;
3. birth date — mostly utility with a small illustration;
4. birth time — utility;
5. unknown-time explanation — calm educational illustration;
6. birth location — utility;
7. system selection — colorful system cards;
8. calculation/progress — atmospheric motion;
9. reveal — strongest celebratory Level A moment.

## 11. Motion

Motion should reinforce soul without becoming toy-like.

Good candidates:
- slow orbit/parallax on hero art;
- tiny sparkle appearance on reveal;
- subtle watercolor light shift;
- gentle card entrance and matched geometry;
- quiet haptic confirmation.

Avoid continuous busy particle fields, bouncing mascots and decorative motion on utility screens. Respect Reduce Motion.

## 12. Accessibility

The redesign keeps the strongest lessons from the previous minimal implementation:

- Dynamic Type hierarchy must survive accessibility sizes;
- rows reflow instead of shrinking text;
- fixed-geometry art steps aside when it blocks content;
- information is never encoded only by color or illustration;
- Light and Dark contrast are tested separately;
- artwork is decorative unless it communicates an explicit fact, in which case that fact must have accessible text.

## 13. Asset strategy

During design exploration:

- screen references live under `docs/design/soulful-reference/`;
- reusable illustration crops/source references live under `docs/design/soulful-reference/assets/`;
- these are **design references**, not automatically production assets.

After an asset is approved for shipping:

- export optimized production artwork with an explicit name and appearance behavior;
- place raster/vector assets in `Humay/Resources/Assets.xcassets/`;
- provide Light/Dark variants only when the artwork genuinely changes by appearance;
- do not ship full screenshot crops as app assets.

## 14. Definition of visual completion

A screen family is visually complete only when:

1. Light reference approved;
2. Dark reference approved;
3. hierarchy, copy and access state agree with product authority;
4. artwork style matches the shared Humay illustration system;
5. accessibility/contrast risks are recorded;
6. reusable production-asset candidates are identified separately from screenshot reference art.

See [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md) for the phased screen inventory.