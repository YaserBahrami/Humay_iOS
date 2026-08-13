# Sky + Calendar Visual Refinement R1

**Status:** REVIEW CANDIDATE — NOT APPROVED  
**Scope:** visual design references only  
**Baseline:** `feature/foundation-clean-architecture` at `2b6185bbbb62c55faaeb82c46808b43ba496cf7c`

This package refines the implemented D3 Current Sky and Calendar visual hierarchy after review of the real simulator evidence. It does not replace the approved D3 authority and is not production implementation guidance until the product owner approves it.

## Candidate direction

- **Current Sky:** a shorter “Lunar Compass” hero with authored vector art and useful events visible much earlier.
- **Events:** compact rows, inline methodology, natural timing, fewer badge-like shapes.
- **Month:** six civil rows remain supported, but each date uses one 44 pt interaction band instead of a stretched card-like slot.
- **Week:** a compact 60 pt celestial date rail; Today and selected remain distinct by outline, fill, label, and shape.
- **Typography:** Newsreader is the recommended editorial UI face; SF Pro remains the interface face; Cormorant remains a wordmark candidate.
- **Bottom clearance:** compact references reserve 96 pt after final content for the floating tab bar and home-indicator region.

## Reference inventory

### Current Sky

- `current-sky-iphone-light.svg` / `.png`
- `current-sky-iphone-dark.svg` / `.png`
- `current-sky-ipad-light.svg` / `.png`
- `current-sky-ipad-dark.svg` / `.png`

### Calendar Month

- `calendar-month-iphone-light.svg` / `.png`
- `calendar-month-iphone-dark.svg` / `.png`
- `calendar-month-ipad-light.svg` / `.png`
- `calendar-month-ipad-dark.svg` / `.png`

### Calendar Week

- `calendar-week-iphone-light.svg` / `.png`
- `calendar-week-iphone-dark.svg` / `.png`
- `calendar-week-ipad-light.svg` / `.png`
- `calendar-week-ipad-dark.svg` / `.png`

### Studies and asset preview

- `IllustrationCurrentSky-light.svg` / `.png`
- `IllustrationCurrentSky-dark.svg` / `.png`
- `typography-comparison.svg` / `.png`
- `month-date-state-study.svg` / `.png`
- `week-date-state-study.svg` / `.png`

## Supporting documents

- [`design-spec.md`](design-spec.md) — dimensions, hierarchy, tokens, and candidate component rules.
- [`adaptive-notes.md`](adaptive-notes.md) — compact/regular behavior, Dynamic Type, safe areas, and input semantics.
- [`review-notes.md`](review-notes.md) — observed problems, decisions, risks, and approval boundary.
- [`typography-study.md`](typography-study.md) — Newsreader/Cormorant comparison and global pressure test.

## Regeneration

The generator is documentation tooling only. It embeds the repository Cormorant file and the OFL-licensed Newsreader reference font, emits accessible SVG sources, then renders PNG previews with `sharp`.

```bash
node docs/design/soulful-reference/sky/refinement-r1/generate-references.cjs
```

No files in `Humay/Presentation`, `Humay/Resources/Assets.xcassets`, `HumayTypography.swift`, or `Info.plist` are read as output targets or modified.

