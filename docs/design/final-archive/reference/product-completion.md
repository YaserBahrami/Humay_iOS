# Product Completion — Profile, Settings, Sharing, Widgets, States

**Purpose:** The remaining product surfaces: Profile & astrology settings, Notifications, Privacy & Data, sharing, widgets, and shared loading/empty/error language.

**Current authority:** Pass 4 remains the visual-layout reference. **Pass 6 / Pass 6.1 override Pass 4 where explicitly stated**, especially notification tone, local-profile wording, Saved People monetization, and architecture boundaries.

**Source artifact:** `Product Design - Pass 4.dc.html`, with Pass 6 / 6.1 corrections.

**Final decisions:**
- Notifications are **Normal only** — no Roast tone reaches a system notification regardless of the user's in-app tone setting.
- Saved People capacity is **not** rewarded-gated. Pass 4.1 left that mechanic under review; Pass 6 temporarily approved it; Pass 6.1 rejects it. Free has a base limit and Premium a larger limit; exact values remain product configuration.
- No account/login infrastructure is assumed in Profile or Privacy. Use **local profile** where local user data is meant.
- Privacy & Data remains available without monetization gates.
- Sharing and widgets may expose only content the user is already entitled to view.

**Visual references:**
- [Profile home](../previews/settings/settings-01-profile.png)
- [Astrology settings](../previews/settings/settings-02-astrology-settings.png)
- [Notifications — pre-freeze visual reference](../previews/settings/settings-03-notifications.png)
- [Privacy overview](../previews/settings/settings-04-privacy.png)
- [Sharing system](../previews/sharing-widgets/sharing-01-share-system.png)
- [Widget sizes](../previews/sharing-widgets/widgets-01-widget-sizes.png)
- [Loading / empty / error states](../previews/sharing-widgets/states-01-loading-empty-error.png)

**Known visual exception:** `settings-03-notifications.png` was captured from the older Pass 4 screen and still shows the superseded Normal/Roast notification control. **Do not implement that toggle.** The final behavior is Pass 6's ruling: notifications are always Normal. The screenshot is retained only as the closest layout reference.

**Supersession notes:** Saved People is not a flat, non-monetized limit: Free and Premium may have different capacity limits. The only rejected mechanic is increasing capacity through Rewarded Access.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
