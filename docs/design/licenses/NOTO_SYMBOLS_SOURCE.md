# Noto Symbols Source Record

Humay's bundled zodiac, supported-planet, and aspect SVG glyphs are outline derivatives of fonts from the official Noto Symbols repository:

- Repository: `https://github.com/notofonts/symbols`
- Noto Sans Symbols version: 2.003, weight 400
- Noto Sans Symbols 2 version: 2.008, regular
- License: SIL Open Font License 1.1
- Local license copy: `NotoSymbols-OFL-1.1.txt`

The build-time source fonts are not runtime dependencies. Selected Unicode glyph outlines were exported to SVG, normalized to a shared `0 0 1024 1024` viewBox, optically bounded for app-size use, and stripped of generator metadata. No raster images, filters, external references, or live font dependency are embedded.

Glyph-to-code-point mappings and family ownership are recorded in `../ASSET_INVENTORY.md`.
