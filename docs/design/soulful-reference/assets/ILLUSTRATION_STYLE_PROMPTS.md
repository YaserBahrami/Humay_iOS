# Humay Illustration Style Reference

This file keeps future design/image work aligned with the approved Soulful Celestial visual language.

## Base art direction

Use this core direction:

> A premium editorial celestial illustration for Humay using clean flat/vector shapes or fine hand-drawn linework, minimal shading, controlled coral/lavender/solar-gold/celestial-blue/sage color blocking, sparse stars/sparkles/orbit details, graceful negative space, and one clear subject. Friendly and slightly cute where appropriate, but refined rather than childish. Occasional simple facial expression is allowed on selected sun/moon/object motifs. No typography inside the artwork. Designed to sit naturally beside or inside a modern SwiftUI composition on warm cream or midnight-navy surfaces.

## Required style rules

- One clear subject or compact relationship between subjects.
- Simple silhouette and readable shape at small sizes.
- Minimal shading; avoid rendering detail that fights UI hierarchy.
- Keep decorative stars/orbits sparse.
- Keep important subjects away from crop edges.
- Do not embed UI labels, percentages or factual astrology text in artwork.
- Prefer transparent/vector foreground art where practical.
- Use faces sparingly; utility/category motifs may remain faceless.
- Test against both Light and Dark surfaces.

## Explicitly avoid

- watercolor/gouache/painterly storybook rendering;
- textured paper-grain illustration as a default;
- elaborate landscape scenes;
- dense botanical scenery;
- 3D emoji/glossy mascot rendering;
- chibi proportions;
- thick cartoon outlines;
- sticker-sheet density;
- generic neon-purple galaxy aesthetics;
- glassmorphism baked into artwork.

## Current motif prompts

### ART-CELESTIAL-SUN

A small warm solar-gold sun with clean rounded rays, minimal coral accent and optional restrained friendly expression; two or three tiny sparkle marks; flat/vector line-art hybrid, clear negative space, transparent background, no text.

### ART-CELESTIAL-MOON

An ivory or pale-lavender crescent moon with one fine navy line detail, optional subtle expression, two tiny stars, minimal celestial-blue accent; elegant flat/vector form, transparent background, no text.

### ART-ORBIT-PLANET

A compact lavender or celestial-blue planet with a fine orbit ring and one gold sparkle; minimal shading, clean vector silhouette, no text.

### ART-COSMIC-COFFEE

A refined warm coffee cup with a small crescent/steam motif and two sparse sparkles; coral/gold accents, simple line/flat shapes, playful but premium, no text.

### ART-CALENDAR-CELESTIAL

A compact calendar page with a small solar-gold sun and lavender crescent accent, clean linework, minimal color blocks, readable at small size, no embedded date text unless the date is purely decorative and not presented as factual UI.

### ART-COMPAT-SUN-MOON

A warm sun and cool crescent moon gently oriented toward each other, connected by a restrained dotted/orbit motif; coral/lavender/gold accents, affectionate but not cartoonish, clean flat/vector treatment, no text.

### ART-ROAST-OBJECT

One celestial/object character with a slightly mischievous expression, simple outline and controlled accent palette; humorous through pose/expression rather than props or sticker clutter, no text.

### ART-ZODIAC-ACCENT

A sign-specific line/flat celestial motif using one dominant accent plus a small sparkle/orbit cue. Maintain a clean silhouette and avoid ornate occult clip-art styling.

## Dark appearance guidance

Do not ask an image model to simply “make it dark” or invert an asset. Instead:

- preserve the subject identity/palette;
- brighten accent values only as needed against midnight surfaces;
- use transparent foreground assets where possible;
- avoid adding glow/neon merely because the background is dark;
- verify against canonical `#101725`, `#171F30` and `#20283A` surfaces.

## Cross-device guidance

The same motif may be used at different scales on iPhone/iPad, but composition is container-driven. Do not add detail solely because iPad offers more pixels.

## Generation review questions

1. Does it match the D0/D1 line/flat illustration language?
2. Is there one clear subject rather than decorative clutter?
3. Is it charming without becoming childish?
4. Can UI text remain readable around it?
5. Does it work intentionally in Light and Dark?
6. Is any factual astrology accidentally embedded in the art?
7. Could a simpler SwiftUI/SF Symbol/vector primitive replace it without losing character?
