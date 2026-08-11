# Humay Illustration Style Reference

This file exists so future design agents can generate new artwork without drifting away from the approved D0 visual world.

## Base art direction

Use this as the shared core for painterly assets:

> A premium editorial celestial illustration for Humay, hand-painted gouache/watercolor feel with refined storybook detail, warm luminous highlights, deep navy/indigo celestial shadows, coral/peach/lavender/gold/sage accents, subtle paper grain, delicate star and orbit-line details, graceful botanical accents where relevant, elegant composition with clear negative space, sophisticated and emotionally warm. Charming and slightly cute where appropriate, but never chibi, childish, 3D emoji-like, sticker-like or thick-cartoon outlined. No typography inside the artwork. No generic neon-purple galaxy aesthetic. Designed to sit naturally inside a polished iOS card or hero frame.

## Consistency rules

- Preserve one illustrator/rendering style across every feature family.
- Prefer strong silhouette and composition over adding more decorative objects.
- Keep important subjects away from crop edges.
- Do not embed UI labels, percentages or explanatory text in raster art.
- Use facial expression on major sun/moon art selectively; utility/category symbols may remain faceless.
- Keep star density moderate and intentional.
- Art should remain attractive on both cream and midnight-navy surfaces.
- Generate transparent foreground art when it can avoid unnecessary Light/Dark duplicates.

## D0 art prompts

### ART-TODAY-COSMIC-LANDSCAPE

A vertical oval celestial landscape at twilight: deep indigo star field flowing into coral, peach and lavender sunset clouds; winding river through layered purple mountains; small wildflowers in foreground; a gentle crescent moon high in the sky; delicate gold orbit rings and sparse sparkle accents around the frame. Rich but calm, premium storybook gouache, high visual depth, no text.

### ART-TODAY-HIGHLIGHT-SUN

Warm golden sun with a gentle serene expression rising through soft peach/cream clouds, subtle watercolor bloom and tiny gold sparkles. Refined rather than baby-like. Plenty of clean edge/negative space for use in a rounded feature card. No text.

### ART-LOVE-LOVEBIRDS

Two elegant rose/coral birds leaning toward each other on a blossoming branch, tiny heart-shaped negative-space cue and sparse gold sparkles, blush watercolor field, refined botanical linework, romantic but not cartoonish. No text.

### ART-CAREER-MOUNTAIN

Lavender/indigo mountain with a luminous winding path leading to a small warm flag at the summit, soft clouds and several purposeful stars, visual metaphor for ambition/progress, premium gouache, no text.

### ART-FINANCE-ABUNDANCE

Deep navy celestial vessel with subtle moon/star motif holding warm gold coins, sage botanical stems growing around it, small crescent and restrained sparkles, grounded abundance rather than casino/wealth imagery, no text.

### ART-HEALTH-MOON

Peaceful ivory crescent moon in a restrained meditative pose among blue/sage leaves and tiny stars, calm celestial-blue watercolor field, wellness and restoration rather than medical imagery, sophisticated storybook rendering, no text.

### ART-DAILY-SCORPIO

Elegant indigo Scorpio illustration framed by a warm crescent arc, lavender crystalline/botanical accents and sparse gold constellations, mystical but refined, clear silhouette suitable for a reading card, no text.

### ART-COMPAT-SUN-MOON

Warm golden sun and cool ivory/lavender crescent moon gently meeting in an affectionate celestial composition, deep navy circular night-sky field, fine gold stars/orbit rings, romantic and soulful without cartoon exaggeration, no text.

### ART-COMPAT-LANDSCAPE

A couple seen from behind sitting together above a reflective mountain lake at sunset, coral/peach sky, lavender mountains, dark pines and small foreground flowers, quiet intimacy, luminous horizon, painterly premium storybook detail, no text.

## Dark appearance guidance

Do not ask an image model to simply `make it dark` or invert the asset. Instead:

- preserve the subject palette;
- deepen only environmental shadows/backgrounds where useful;
- keep gold/coral highlights luminous;
- maintain recognizable skin tones in portrait art;
- avoid crushing watercolor texture into black;
- preview against `#0D1220` and `#151B2C`.

Where the same transparent artwork works on both appearances, use one master rather than generating two stylistically divergent copies.

## Generation review questions

1. Does this look like it came from the same illustrator as the D0 anchors?
2. Does it have one clear subject rather than decorative clutter?
3. Is it charming without becoming childish?
4. Can UI text remain readable around it?
5. Would it still look intentional in Dark mode?
6. Is there any text or accidental factual astrology embedded in the art?
7. Can a simpler SwiftUI/vector primitive replace this raster without loss of character?
