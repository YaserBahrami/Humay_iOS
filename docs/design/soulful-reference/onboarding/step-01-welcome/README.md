# D1 Step 01 — Welcome

Status: **iPhone Light/Dark approved; iPad companion references ready for review**

This package completes the missing iPad design work for Humay's canonical Welcome beat without changing the already-approved iPhone references.

## Canonical references

Existing approved iPhone:
- `../light/01-welcome.svg`
- `../dark/01-welcome.svg`

New iPad review references:
- `welcome-ipad-portrait-light.svg`
- `welcome-ipad-portrait-dark.svg`
- `welcome-ipad-landscape-light.svg`
- `welcome-ipad-landscape-dark.svg`

## Product truth

Route:

`Welcome → Birth Date → Tradition → Profile Reveal`

Welcome:
- contains no login/account path;
- contains no birth-time or birth-location input;
- presents Humay's personality and product promise;
- primary action is `Begin`;
- proceeds directly to Birth Date.

Humay V1 is accountless. The reference note “No account needed” is informational only and must not turn into an authentication surface.

## Canonical copy

Headline:
`Read the sky. Keep the fun.`

Supporting:
`Astrology that feels human — with the reasoning close enough to open whenever you want it.`

Hero:
- eyebrow: `YOUR COSMIC COMPANION`
- line 1: `Clear when it matters.`
- line 2: `Playful when it can be.`
- supporting: `A little perspective. Zero cosmic homework.`

Feature cues:
- `Daily readings`
- `Compatibility`
- `Three traditions`

Primary action:
`Begin`

## iPad composition

### Portrait
- bounded content region rather than stretched phone width;
- editorial headline remains top-led;
- hero surface spans the main reading width;
- the three feature cues form a compact three-column row;
- CTA remains centered and bounded.

### Landscape
- two-region composition;
- editorial copy, feature cues and CTA sit in the left region;
- hero art becomes the right emotional region;
- no proportional scaling of phone geometry.

### Compact iPad / multitasking
At narrower widths the layout collapses toward the approved iPhone hierarchy:
1. headline;
2. supporting copy;
3. hero;
4. feature cues;
5. CTA.

Use container width, not `UIDevice` checks.

## Appearance

Light uses warm cream ground, dark navy text and a deep hero surface.

Dark uses midnight navy ground, warm light text and a tonal hero surface. The enabled primary CTA uses the approved Coral → Lavender gradient with dark semantic foreground.

## Accessibility

- Dynamic Type must reflow rather than shrink the hero copy;
- CTA target remains at least 44 pt;
- decorative coffee/star art is hidden from VoiceOver;
- feature cue labels remain textual;
- Reduce Motion is respected if hero motion is introduced later.

These are design references, not automatically shipping assets.
