# Humay Current Design References

This directory is the repository-owned visual reference set for the current Humay Light/Dark design.

## Authority

1. [`../DESIGN_AUTHORITY.md`](../DESIGN_AUTHORITY.md)
2. [`../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`../SCREEN_DESIGN_PLAN.md`](../SCREEN_DESIGN_PLAN.md)
4. The committed screen packages in this directory

## D0 — selected anchors

`anchors/` contains the approved visual source for:

- Today / Home
- Daily Horoscope
- Compatibility

Each is represented in Light and Dark. These references define the current visual language: warm cream / deep navy, editorial serif hierarchy, simple line/flat cute cosmic art, soft cards and disciplined accent color. Navigation labels shown inside a reference image do not override canonical IA.

## D1 — onboarding

D1 is being rebuilt against the approved D0 visual language and the **current four-beat onboarding flow** in the app.

Canonical screens:

1. Welcome
2. Birth Date
3. Tradition
4. Profile Reveal

Current status:

- Welcome Light — redesigned and committed; ready for review
- Welcome Dark — redesigned and committed; ready for review
- Birth Date Light — full SVG committed; ready for review
- Birth Date Dark — full SVG committed; ready for review
- Birth Date side-by-side review board — committed
- Birth Date element board + isolated vector reference elements — committed
- Birth Date behavior/copy/accessibility spec — committed
- Tradition — next
- Profile Reveal — pending

### Step 02 package

`onboarding/step-02-birth-date/` is a self-contained handoff package with:

- individual Light and Dark screen references;
- paired Light/Dark review board;
- element board;
- structured `design-spec.json`;
- complete README/specification and source metadata;
- editable SVG reference motifs.

This package is the design authority for the Birth Date step, subject to the higher-level D0/design-direction rules.

The older nine-screen onboarding concept files are superseded historical drafts and must not be used as implementation authority.

## Components

`components/` contains shared design-system boards:

- `ui-elements-light-dark.svg` — shared colors, typography, buttons, chips, cards, inputs, state/progress and icon treatment;
- `illustration-icon-reference.svg` — current simple celestial illustration/icon language.

Per-screen reusable reference elements can also live inside that screen's package until approved for promotion into the shared component/asset set.

## Asset promotion

Reference mockups and per-step SVGs are documentation assets. They are **not automatically shippable application assets**.

After design approval:

1. reconcile the reusable artwork against the shared component system;
2. optimize/export only the required pieces;
3. add production assets to `Humay/Resources/Assets.xcassets/`;
4. keep the original repository reference package for traceability.

## Astrology values

Dates, signs, scores and readings shown in mockups are illustrative unless separately validated by Humay's calculation/methodology layer. Design references define presentation and interaction, not astronomical truth.
