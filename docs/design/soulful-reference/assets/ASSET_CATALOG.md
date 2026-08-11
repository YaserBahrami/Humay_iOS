# Soulful Celestial Asset Catalog

**Status:** design-source catalog; production promotion is explicit.

Humay's richer illustration language uses painterly raster artwork plus a small number of reusable vector/system primitives. Do not treat a screenshot crop as a shipping asset automatically.

## D0 artwork families

The first visual anchors identify these reusable art families:

| ID | Artwork | Likely reuse | Shipping form |
|---|---|---|---|
| `ART-TODAY-COSMIC-LANDSCAPE` | twilight celestial valley / cosmic-weather hero | Today hero, share derivatives | optimized raster, appearance-tested |
| `ART-TODAY-HIGHLIGHT-SUN` | warm sun/cloud highlight illustration | Today highlights/onboarding accents | optimized raster |
| `ART-LOVE-LOVEBIRDS` | paired birds + blossoms | Love category, relationship accents | optimized raster |
| `ART-CAREER-MOUNTAIN` | mountain/path/flag | Career category | optimized raster |
| `ART-FINANCE-ABUNDANCE` | moon/coin botanical pot | Finance category | optimized raster |
| `ART-HEALTH-MOON` | meditative moon/botanical scene | Health category | optimized raster |
| `ART-DAILY-SCORPIO` | Scorpio feature illustration | zodiac reading feature | optimized raster |
| `ART-COMPAT-SUN-MOON` | embracing sun/moon celestial composition | compatibility hero | optimized raster |
| `ART-COMPAT-LANDSCAPE` | couple viewing celestial landscape | compatibility summary/share | optimized raster |

These names are stable design identifiers. Final file names may gain size/variant suffixes during production export.

## Reusable non-raster primitives

Prefer SwiftUI/SF Symbols/vector drawing for simple primitives rather than baking them into images:

- orbit rings and dotted orbit paths;
- four-point/eight-point sparkles;
- small star field accents;
- category badges/icons where SF Symbols fit;
- zodiac glyphs when text/vector treatment is sufficient;
- simple celestial divider marks.

This keeps appearance, tint, accessibility and scale adaptable.

## Light/Dark policy

Do not create a duplicate Dark raster automatically.

For each approved artwork choose one of:

1. **same artwork** — asset is already luminous/transparent and works on both grounds;
2. **appearance variants** — composition/values genuinely require separate Light and Dark exports;
3. **single transparent foreground** — background/surface is drawn by SwiftUI and the artwork sits above it.

Prefer option 1 or 3 when visual quality is equal.

## Production checklist

Before moving an item into `Humay/Resources/Assets.xcassets/`:

- [ ] screen family approved in Light and Dark;
- [ ] crop/composition approved independently from screenshot;
- [ ] no important text embedded in art;
- [ ] correct scale and target pixel dimensions chosen;
- [ ] compression tested on device;
- [ ] transparency behavior verified if used;
- [ ] Light/Dark behavior selected intentionally;
- [ ] VoiceOver semantics handled by UI, not assumed from art;
- [ ] attribution/licensing/source provenance recorded if artwork is not fully owned/generated for Humay;
- [ ] asset name mapped back to this catalog/design screen.

## Current decision

D0 art remains **reference material** until the anchor pair receives final Dark refinement. No D0 painterly crop should be added to the shipping asset catalog merely because it appears in a concept screenshot.