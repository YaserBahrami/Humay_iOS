# Current Sky Visual-Design Specification

**Design phase:** D3.1 — Current Sky

**Status:** design requirements only; no visual reference or implementation is approved

**Visual direction:** Soulful Celestial

**Platforms:** iPhone and iPad, Light and Dark

## 1. Purpose and approval boundary

Design a Current Sky screen that presents timely celestial context with a warm editorial hierarchy, concise event scanning, methodology awareness, and a clear path into Calendar.

This specification is not a final composition. It intentionally leaves visual judgment to the reference-design and review pass. Do not infer approval from this document, existing sample values, the existing Sky placeholder, or asset-catalog inventory.

No Current Sky, Calendar, or event-detail SwiftUI may be implemented until the required Current Sky reference set is reviewed and approved.

## 2. Required visual package

The package must eventually include:

1. iPhone Light
2. iPhone Dark
3. iPad Light
4. iPad Dark
5. iPad landscape/adaptive notes
6. Compact-width fallback behavior

All four main references are required for approval. A complete package must also explain state treatment, Dynamic Type pressure, safe-area behavior, and the change between compact and sufficiently wide layouts.

## 3. Product and navigation context

- Current Sky is the primary surface inside the existing Sky root destination.
- Use the Humay title/navigation language and profile/settings entry established by the current primary shell.
- Do not add a root destination.
- Calendar is a child of Sky and needs a clear, native, obvious entry from Current Sky.
- Do not introduce a new route or interaction model during this visual-preparation task.

## 4. Information hierarchy

The visual pass should support the following hierarchy. Exact grouping and placement remain subject to cross-device review.

### 4.1 Header

- Sky title or approved Humay navigation language consistent with the primary shell.
- Profile/settings entry consistent with existing header behavior.
- Native, recognizable controls with at least 44 by 44 pt targets.
- No duplicate title treatment that competes with the hero.

### 4.2 Current celestial hero

Use one strong but restrained Level A Soulful Celestial moment. It may communicate:

- the current celestial character;
- important lunar or planetary context;
- a concise editorial headline;
- supporting timing, observation, or location context when factual and relevant.

The hero must not become:

- a scientific planetarium;
- a dense natal wheel;
- a neon galaxy dashboard;
- a generic horoscope card;
- an overly cartoonish illustration scene.

Keep factual labels distinct from decorative art. The hero should provide identity without pushing all useful events below the initial viewport on common iPhone sizes.

### 4.3 Current events

Support scan-friendly event cards or rows for event families such as:

- lunar phase;
- planetary ingress;
- planetary aspect;
- planetary station;
- seasonal transition;
- methodology-specific event when valid.

Do not freeze provider-native terminology or assume every event is a Western transit. Rows must tolerate missing summaries, multiple timing forms, long titles, and localized variable-length text.

### 4.4 Calendar entry

Provide a clear route into Calendar within Sky. The control must look interactive, use native disclosure/action language, and remain visible without turning Calendar into a competing root destination.

Its final placement may be near the hero, beside secondary context on wide iPad layouts, or after current events on compact layouts. The reference pass must validate discoverability.

### 4.5 Upcoming events

Support a concise upcoming-events list or rail. Prioritize the next useful events instead of displaying every available item. The design must demonstrate a controlled content limit and a route to deeper Calendar exploration.

Do not rely on horizontal scrolling as the only way to discover important content. If a rail is explored, it must remain usable with Dynamic Type, VoiceOver, and pointer input.

## 5. Event semantics

### 5.1 Timing

The design must visibly distinguish these mutually exclusive timing states:

| Timing state | Required presentation behavior |
|---|---|
| Exact instant | A clock time may appear. Show timezone or observation context when omission could mislead. |
| Interval | Present a clear start/end range or duration treatment. Do not collapse it to one time. |
| Date-only | Present only the civil date or day language. Never invent midnight, noon, or another clock time. |
| Unavailable | Use an explicit quiet unavailable/explanation treatment. Never leave a blank that resembles a rendering defect. |

Timing labels must remain understandable without color. Mono typography is optional and only appropriate when it materially improves technical time or degree scanning.

### 5.2 System and methodology

When relevant, the design must be able to distinguish:

- astronomical context;
- Western astrology;
- Vedic astrology;
- future supported systems.

System labels should be quiet but available where omission would conflate methodologies. Do not flatten all content into Western terminology. Do not invent methodology claims for an event whose methodology is unavailable or not approved.

### 5.3 Reliability and availability

The design must support:

- reliable;
- approximate;
- unverified development sample;
- unavailable methodology or timing.

Reliability must not depend on color alone. Reliable content may use the quiet default treatment; approximate content needs a visible qualifier; unavailable content needs a meaningful explanation; unverified development content needs a visible Debug disclosure.

The Debug disclosure should be noticeable in development screenshots without dictating the production hierarchy. Release references and production composition must never present sample astrology as real output.

## 6. Required screen states

The package must address every state below, even when several share one component family.

| State | Reference strategy |
|---|---|
| Loaded/default | Distinct primary reference. It establishes the full hierarchy on all four main device/appearance references. |
| Loading | Distinct state treatment. It may share the loaded layout skeleton, but must show stable hierarchy and avoid fake event data. |
| Empty | May share the quiet centered or bounded status composition used by unavailable states, but needs empty-specific copy and next action. |
| Unavailable | May share the empty-state shell, but must remain semantically distinct because methodology, timezone, location, or source availability may require different guidance. |
| Offline with cached content | May share the loaded layout. Add a persistent, quiet cached/offline disclosure and avoid implying freshness. |
| Offline with no cached content | May share the unavailable/error status shell, but needs explicit offline recovery copy and must not resemble an empty celestial day. |
| Failed/error | Distinct recovery treatment with a clear retry path. It may reuse the status shell but must not be conflated with unsupported methodology or legitimate empty content. |

At minimum, create a dedicated state board or annotated reference covering loading, empty, unavailable, both offline variants, and failed/error. The four main references may remain loaded/default. State annotations must explain appearance and compact/regular adaptation rather than requiring four full screenshots for every state unless review finds a meaningful compositional difference.

## 7. iPhone behavior

- Design portrait first and validate at the smallest supported practical width, not only a Pro Max canvas.
- Use one reading column with a clear top-to-bottom scan.
- Respect safe areas and current shell/tab behavior.
- Keep horizontal screen margins and all interactive targets consistent with the app foundation.
- Make the hero visually strong but short enough that useful celestial events remain discoverable near the fold.
- Use Cormorant Garamond selectively for editorial emphasis and system typography for interface/data.
- Keep celestial art restrained and subordinate to factual content.
- Keep event rows/cards scan-friendly with clear timing and system metadata.
- Keep primary links/actions native, obvious, and at least 44 by 44 pt.
- Avoid excessive stars, decoration, nested cards, and competing accent colors.
- Validate Dynamic Type through accessibility sizes; allow rows to reflow rather than truncating critical timing or reliability labels.

## 8. iPad and adaptive behavior

iPad must not be a scaled phone.

For sufficiently wide layouts, evaluate an intentional two-region composition. One possible design objective is a bounded Current Sky hero/celestial context region paired with an upcoming-event timeline, with Calendar entry and secondary information placed where they preserve hierarchy. Another composition is acceptable if it uses the extra width more clearly.

Requirements:

- Bound reading text to a comfortable measure.
- Avoid full-width utility cards and event rows when the width harms scanning.
- Use additional width for hierarchy, comparison, or parallel context rather than enlarged empty space.
- Document portrait and landscape behavior explicitly.
- Preserve selection, reading order, and route ownership when regions rearrange.
- Keep profile/settings and Calendar interactions native for pointer and keyboard input.
- Do not enlarge every card, icon, radius, or body style proportionally.
- At compact iPad or split-screen widths, collapse toward the iPhone single-column hierarchy.

Do not freeze an exact iPad composition in this specification. The cross-device design review must choose it after comparing at least one wide-layout exploration with the compact fallback.

## 9. Soulful Celestial visual language

### Overall qualities

- warm;
- alive;
- premium;
- editorial;
- selectively playful;
- not childish;
- not overly serious;
- restrained in color and decoration;
- selective cute celestial line/flat illustration.

### Light mode

- Warm cream ground.
- Soft raised surfaces and subtle hairlines/elevation.
- Restrained coral, lavender, solar gold, celestial blue, and sage accents.
- Dark readable ink with independently verified contrast.

### Dark mode

- Midnight/navy composition with tonal surface separation.
- Warm light text and deliberately tuned accents.
- Preserve warmth and color; do not invert the Light reference mechanically.
- Prefer tonal elevation before heavy shadow or glass effects.

### Typography

- Cormorant Garamond for the hero/editorial emphasis.
- SF/system typography for navigation, controls, labels, metadata, and body copy.
- Mono only when technical time/degree scanning genuinely benefits.
- Use Dynamic Type-aware hierarchy and test the largest accessibility sizes.

## 10. Accessibility and native-platform review

The approved package must account for:

- logical VoiceOver reading order across hero, current events, Calendar entry, and upcoming events;
- meaningful labels for non-text celestial glyphs;
- decorative art hidden from accessibility when it adds no information;
- 44 by 44 pt minimum targets;
- 4.5:1 contrast for normal text and 3:1 for large text and meaningful UI graphics;
- Light/Dark and Increase Contrast review;
- Dynamic Type reflow without clipped factual content;
- meaning not carried by color alone;
- Reduce Motion behavior for any future orbit, sparkle, or entrance motion;
- safe areas, native back behavior, iPad pointer, and keyboard navigation.

The HIG review target is 10/10. Current Current Sky visual score is 0/10 because no references exist yet, not because an interface was reviewed and failed. Reaching 10/10 requires approved references that satisfy safe areas, touch targets, Dark Mode, Dynamic Type, VoiceOver, native navigation, semantic color, native controls, standard gestures, and appropriate system/vector icon use.

## 11. Existing asset audit

Asset-catalog presence is inventory, not approval. Existing art must not force the final design or become production Current Sky art solely because it already ships in the catalog.

### Candidate illustrations requiring visual review

| Asset or family | Possible role | Constraint |
|---|---|---|
| IllustrationCurrentSky | Hero, compact feature art, or quiet placeholder motif | Existing Light/Dark original-color vector and current Sky-placeholder art. Candidate only; compare against the approved hero direction before reuse. |
| IllustrationCalendarCelestial | Calendar entry or Calendar empty-state motif | Existing Light/Dark original-color vector already used by Birth Date. Reuse only if it does not blur onboarding and Sky meanings. |
| IllustrationCelestialMoon / IllustrationCelestialSun | Selective celestial context | Level B accents, not default decoration on every event. |
| IllustrationFullMoon / IllustrationNewMoon | Important lunar-event moment | Do not use for generic phases or imply a factual phase without supplied data. |
| IllustrationRetrograde / IllustrationEclipse / IllustrationMeteorShower | Specific event emphasis | Use only when the event type and methodology support the meaning. Avoid a feed of large illustrations. |

### Generic utility glyphs

- Moon-phase template vectors: New, Waxing Crescent, First Quarter, Waxing Gibbous, Full, Waning Gibbous, Last Quarter, and Waning Crescent.
- Planet/node template vectors: Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto, North Node, and South Node.
- NavSky template vector for the existing Sky root navigation language.

These are likely reusable for compact factual identification because they preserve vector representation and use template rendering. Confirm semantic accuracy, tint/contrast, optical sizing, and accessibility labels in the approved design.

### Generic celestial decorations

- Crescent;
- Orbit;
- SparkleFour;
- SparkleFilled;
- StarCluster;
- DottedConnector.

These template vectors may support sparse decoration or structure. Do not treat them as factual event glyphs unless their meaning is explicit. Avoid decorative-star density, and do not let decoration compete with timing or methodology.

### Production-promotion rule

No asset in this audit is automatically approved for D3. The visual pass may reject, redraw, or omit an existing asset if it is weaker than the approved direction. Do not regenerate or modify assets until the reference package determines an owning use.

## 12. Development sample values are non-authoritative

DevelopmentD3Sample exists only to exercise typed states and future UI behavior.

- Sample event names and times are illustrative.
- Sample values do not define real astronomy or astrology calculations.
- Sample reliability is unverified.
- Layouts must work with realistic, variable-length production titles, summaries, system labels, timing, and unavailable explanations.
- No screenshot may be treated as methodology authority.
- Debug screenshots must disclose sample content visibly.
- Release must contain no sample astrology payload.

## 13. Design risks and unresolved product questions

Resolve or explicitly defer these during visual review:

1. **Hero content contract:** current Domain contracts expose a snapshot and events, but no dedicated editorial hero headline or celestial-character field. Decide whether the hero derives from a selected event or needs a future Humay-owned presentation contract; do not encode sample copy as the answer.
2. **Current versus upcoming grouping:** SkySnapshot carries events without a frozen grouping or display limit. Define design behavior for ordering, current relevance, and the concise upcoming cutoff without turning it into provider logic.
3. **System-label policy:** decide when astronomical/Western/Vedic labels are always visible, conditionally visible, or grouped, while preserving methodology clarity.
4. **Reliability copy:** define user-facing wording for approximate and unavailable states. Keep unverified wording development-only and visible in Debug.
5. **Observation context:** decide when timezone and location appear in the hero, event row, or detail entry so exact timing is not misleading.
6. **Calendar entry behavior:** Calendar ownership is fixed under Sky, but the visual pass still needs to choose prominence and default month/week language.
7. **Recovery actions:** retry, refresh, and settings/location guidance depend on future pipeline capabilities. References must not promise actions that contracts cannot later support.
8. **Asset suitability:** IllustrationCurrentSky and other existing celestial art may be too generic or too prominent for the final hero. Approval must judge the composition, not reward reuse.
9. **Long and localized content:** references must stress-test long event names, missing summaries, multiple methodologies, accessibility text sizes, and constrained iPad windows.

## 14. Visual review checklist

- [ ] All four main references exist.
- [ ] iPad landscape and compact-width behavior are explicit.
- [ ] Header and profile/settings entry match the primary shell.
- [ ] Calendar remains nested under Sky.
- [ ] Hero is strong, restrained, and does not hide useful events.
- [ ] Current and upcoming events remain concise and scan-friendly.
- [ ] Exact, interval, date-only, and unavailable timing are distinguishable.
- [ ] Astronomical and methodology-specific events are not flattened.
- [ ] Reliability and development-sample disclosures are accurate.
- [ ] All required state variants are covered.
- [ ] Light and Dark modes are intentionally composed.
- [ ] Dynamic Type, VoiceOver, contrast, hit targets, safe areas, pointer, and keyboard risks are addressed.
- [ ] Existing assets are treated as candidates rather than authority.
- [ ] Sample values remain illustrative and unverified.
- [ ] No implementation claim or approval claim appears before review.
