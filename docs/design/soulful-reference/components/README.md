# Shared UI & Illustration References

These boards support the recurring visual language extracted from current D0/D1 references.

- `ui-elements-light-dark.svg` — palette roles, hierarchy, action/chip/card/input examples and icon treatment.
- `illustration-icon-reference.svg` — simple celestial/object/icon vocabulary for the selected Humay style.

## Authority rule

These are **supporting visual boards**, not a second token/component specification. Production implementation uses:

1. `docs/design/DESIGN_AUTHORITY.md`;
2. `docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`;
3. current `assets/design-tokens.json`;
4. the approved screen package being implemented.

Some SVG `font-family` declarations use renderer-friendly fallback names from the board-generation environment. **Do not copy those names into production.** Canonical typography is Cormorant Garamond for editorial/display roles and SF Pro/system for UI/body roles.

Production components use semantic SwiftUI tokens and native accessibility behavior. Production images are exported separately only when a graphic cannot be expressed cleanly as native/vector UI.

The current illustration rule is **simple, cute, editorial and sparse** — line/flat, not painterly/watercolor, not 3D, and not cartoon-heavy.
