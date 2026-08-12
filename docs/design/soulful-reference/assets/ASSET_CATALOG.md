# Soulful Celestial Asset Catalog

**Status:** current design-source catalog; production promotion is explicit.

Humay's approved illustration language is **simple line/flat celestial art with restrained color blocking and minimal shading**. The previous painterly/watercolor asset exploration is superseded and must not be used for production implementation.

Do not treat screenshot crops as shipping assets.

## Current reusable art families

These are design categories, not a promise that each becomes a raster asset:

| ID | Motif | Typical use | Preferred shipping form |
|---|---|---|---|
| `ART-CELESTIAL-SUN` | friendly restrained sun/sparkles | Today, highlights | SwiftUI/vector or transparent asset |
| `ART-CELESTIAL-MOON` | crescent/moon with minimal expression | Today, Health, onboarding | SwiftUI/vector or transparent asset |
| `ART-ORBIT-PLANET` | small planet + orbit line | onboarding, system/category accents | vector/SwiftUI |
| `ART-COSMIC-COFFEE` | compact coffee/celestial object | Welcome/Roast moments | vector/transparent asset |
| `ART-CALENDAR-CELESTIAL` | calendar + sun/moon accent | Birth Date | vector/SwiftUI |
| `ART-COMPAT-SUN-MOON` | paired celestial relationship motif | Compatibility | vector/transparent asset |
| `ART-ROAST-OBJECT` | one playful celestial/object character | Roast surfaces | vector/transparent asset |
| `ART-ZODIAC-ACCENT` | simple sign-specific line/flat motif | reading identity | vector/transparent asset |

Add new IDs only when an approved screen establishes a reusable motif.

## Prefer native/vector primitives

Use SwiftUI, SF Symbols or vector assets for:

- orbit rings and dotted paths;
- four/eight-point sparkles;
- sparse star accents;
- category circles/icons where appropriate;
- zodiac glyphs when text/vector treatment is sufficient;
- dividers/progress marks;
- simple calendar/sun/moon motifs.

This keeps tint, accessibility, scale and iPad adaptation flexible.

## Raster-image rule

Raster artwork is allowed only when the approved illustration genuinely needs detail that is impractical to reproduce cleanly as vector/native UI. Do not introduce raster artwork merely because an old concept used it.

## Light/Dark policy

For each approved artwork choose deliberately:

1. **one shared transparent/vector asset** when it works on both appearances;
2. **appearance variants** only when values/composition materially need them;
3. **native background + foreground asset** when the surface should remain semantic SwiftUI.

Dark mode is composed intentionally; do not auto-invert art.

## Cross-device policy

Artwork must respond to container space rather than fixed device dimensions. iPad may give hero art more room, but artwork does not scale proportionally just because the canvas is larger.

## Production checklist

Before moving an item into `Humay/Resources/Assets.xcassets/`:

- [ ] owning screen/package approved for required iPhone/iPad Light/Dark states;
- [ ] asset is truly reusable/shippable rather than a screenshot crop;
- [ ] no important UI text is embedded in art;
- [ ] no unvalidated astrology fact is embedded in art;
- [ ] correct scale/vector/raster form chosen;
- [ ] Light/Dark behavior verified;
- [ ] iPhone/iPad layout behavior verified;
- [ ] VoiceOver semantics are provided by UI where meaningful;
- [ ] source/licensing/provenance recorded when applicable;
- [ ] asset name maps back to its approved reference package.

## Current decision

The committed D0/D1 mockups are **design references**. Only isolated motifs explicitly approved during implementation are promoted into the shipping asset catalog.
