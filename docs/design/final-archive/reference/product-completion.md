# Product Completion — Profile, Settings, Sharing, Widgets, States

**Purpose:** The "rest of the product" surfaces: Profile & astrology settings, Notifications, Privacy & data, sharing, widgets, and the shared state language (loading/empty/error).

**Current authority:** Pass 4 for visual layouts; **Pass 6.1 overrides Pass 4's notifications visual** — notifications are Normal-tone only, with no Roast toggle. The captured `settings-03-notifications.png` frame predates this correction and shows Pass 4's original design; treat the toggle as removed per Pass 6.1.

**Source artifacts:** `Product Design - Pass 4.dc.html` (Profile & settings, Notifications, Privacy & data, Sharing system, Widgets, state language sections).

**Final decisions:**
- Notifications are **Normal only** — no Roast tone reaches a system notification, regardless of the user's in-app tone setting (Pass 6 ruling, reversing any earlier Roast-notification exploration).
- Saved People capacity is **not** rewarded-gated — Pass 4.1's "+1 slot per ad" and any Pass 6 approval of it are reversed in Pass 6.1 §"Saved People capacity is not rewarded-gated."
- No account/login is assumed anywhere in Profile or Privacy; copy should say "local profile," not "account."
- Privacy & data stays plain-language, not legalistic, especially regarding a saved person's data (who has not consented to anything themselves).

**Canonical screens:**
| Screen | File |
|---|---|
| Profile home | `previews/settings/settings-01-profile.png` |
| Astrology settings | `previews/settings/settings-02-astrology-settings.png` |
| Notifications *(pre-correction visual — see note above)* | `previews/settings/settings-03-notifications.png` |
| Privacy overview | `previews/settings/settings-04-privacy.png` |
| Sharing system (representative) | `previews/sharing-widgets/sharing-01-share-system.png` |
| Widgets (representative sizes) | `previews/sharing-widgets/widgets-01-widget-sizes.png` |
| Loading / empty / error states | `previews/sharing-widgets/states-01-loading-empty-error.png` |

**Supersession notes:**
- Notifications visual: Pass 4's Roast toggle is removed per Pass 6.1 — engineering should build the Normal-only version, not the pictured toggle.
- Saved People capacity: Pass 4.1 §"+1 slot per ad" is reversed; Pass 6's approval of it is also reversed. Capacity is a flat, non-monetized limit.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
