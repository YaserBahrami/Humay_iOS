# Humay — Entertainment-First Product Direction

**Status:** active product/design direction for the entertainment-first redesign.
Supersedes the Soulful Celestial screen program where they conflict; Soulful Celestial
tokens (palette, type, spacing) remain the material foundation underneath it.

## Thesis

> Build the astrology app for people who don't take astrology too seriously.

Astrology is the **content engine**, not the destination. Humay is a personalized
entertainment feed: playful predictions, ridiculous meters, relationship chemistry,
roasts, and shareable moments — self-aware enough that skeptics enjoy it.

North star: *funny enough to share, beautiful enough to keep, interactive enough to
explore, personal enough to return to.*

## Voice

Smart + mischievous + premium + playful + self-aware. Never mystical fortune-teller,
never crystal-shop, never fake science. Contrast is intentional: quiet editorial
moments make the jokes land harder.

## Information architecture

Four primary tabs + profile sheet:

| Tab | Purpose |
|---|---|
| **Today** | Cosmic Feed — rotating modular daily content |
| **Chemistry** | People, compatibility collisions, comparisons |
| **You** | Identity (Big Three + archetype), interactive year timeline |
| **Sky** | Humanized cosmic events + calendar |

Profile/settings stay in a sheet from the header (auxiliary route), not a fifth tab.

Onboarding: Welcome → Birth Date → Name → Tradition → Reveal.

## Content architecture

Three information classes remain strictly separated (existing repo rule):

1. **Deterministic astrology facts** — Sun sign from date (deterministic table);
   Moon/Rising require real calculation and are honestly withheld until available.
2. **Interpretation** — today produced by the deterministic `HumayContentEngine`
   fixture generator; later replaced by AI generation behind the same boundaries.
3. **Humay-original entertainment metrics** — Chaos, Delusion, Main Character Energy,
   Social Battery, Don't Text Them… explicitly invented, explicitly playful.

### Modular feed

`FeedItem` models one piece of feed content (headline, meter set, reveal, roast,
cosmic weather, forecast teaser…). New entertainment formats are new cases +
renderers — no app redesign.

### Personality modes

`PersonalityMode`: normal · bestie · roast · savage · delulu · drama · soft
(replaces `Tone`). Modes change expression only, never underlying data.

### Yearly dataset (AI-ready)

`YearlyForecast` holds ~365 `DailyMood`s across named dimensions with explicit
provenance (`generatorVersion`, `generatedAt`, basis). Today: deterministic seeded
fixture generation per profile. Later: AI-generated datasets drop in behind the same
model boundary, cached locally, versioned, never required for daily use at runtime.

## Motion language

- Springs over eases (`HumayMotion` presets); animation serves meaning.
- Hold-to-reveal secret cards with haptic ramp.
- Compatibility "collision" choreography for two people.
- Interactive year timeline scrubbing.
- Centralized haptics (`HumayHaptics`) with reduced-motion/lightweight fallbacks.
- Rare chaos moments (collision impact) — surprising, not ambient.

## Sharing

Dedicated `ImageRenderer` compositions (Today card, Compatibility card, Year card).
Never a raw screenshot of app UI.

## What changes vs the previous program

- Tabs: Today/Circle/Sky/Chart/Ask → Today/Chemistry/You/Sky.
- `Tone` (normal/roast) → `PersonalityMode` (7 modes).
- Fixed Today card layout → modular `FeedItem` feed.
- Ephemeral in-memory people → persisted connections (schema v2).
- Static compatibility score → collision experience + fun metrics.
- No chart wheel UI until a real calculation engine exists (honest withholding).

## Dependencies

None added this phase. SwiftUI native (Canvas, ImageRenderer, gestures, haptics)
covers the motion/sharing needs. Rive/Lottie reconsidered only if a specific
experience demonstrably exceeds native quality.
