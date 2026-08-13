# Compatibility Refresh Design Spec

**Status:** REVIEW CANDIDATE — NOT APPROVED

## 1. Current problem diagnosis

### Selection

`CompatibilitySelectionView` uses `GridItem(.adaptive(minimum: 170))`. At a representative compact content width of about 362 pt, two columns become roughly 175 pt each. After the card's 32 pt horizontal padding, 62 pt medallion, 44 pt selection control, and two 12 pt HStack gaps, only about 13 pt remains for the name/sign text column. SwiftUI therefore wraps ordinary words into vertical fragments such as `Ya / ser` and `Ge / min / i`.

The grid also makes the task read as independent card selection. It does not make the chosen relationship legible until the user infers it from two borders/checkmarks.

### Result top

The current pair header distributes `person A | connector | person B` across three flexible regions, then places the score, label, and summary below as separate elements. The basis banner sits above them as another independent block. Each element is individually understandable, but the pair has no shared visual field; identity, connection, and result do not read as one emotional composition.

## 2. Selection concept — Pair Composer

The screen says **Choose your connection** and immediately shows two named relationship slots. The composer is the source of truth for who will be compared; the saved-people list is the picker.

### Compact iPhone

- One column only.
- Pair composer spans the content width and uses two 66–72 pt medallions joined by a restrained orbit line and small heart node.
- Selected names and Sun signs remain under their own medallions with enough width for normal words.
- Saved people use full-width rows, approximately 66–76 pt high at the reference text size, and grow vertically with Dynamic Type.
- Each row includes initials/medallion, full name, Sun sign, and a selected-state icon.
- The full row is the target. Minimum target remains 44 pt.
- The rendered reference shows six saved people through the count and scroll context; long names/signs appear in visible rows.

### Regular-width iPad

- A bounded two-region layout replaces the enlarged phone stack.
- Left: instruction, pair composer, selection guidance, and CTA.
- Right: a one-column saved-people list with generous row width and six visible examples.
- In a narrower iPad window, the two regions collapse to the compact hierarchy before either column becomes text-hostile.

## 3. Selection states

### 0 selected

- Both composer slots use a dashed neutral ring, person placeholder glyph, and `Choose first person` / `Choose second person` labels.
- Connector is quiet and incomplete.
- CTA remains disabled and reads `Select two people`.
- VoiceOver announces `No people selected. Choose two people to compare.` before the list.

### 1 selected

- First slot contains the selected person's medallion, full name, and sign.
- Second slot remains visibly open with `Choose one more person`.
- Connector extends from the first slot toward the empty slot but the heart node remains outlined.
- CTA remains disabled; guidance reads `Choose one more person`.

### 2 selected

- Both slots are filled.
- Connector and small heart node become active.
- A redundant `2 selected` label and checkmark icons communicate state without color alone.
- Primary CTA becomes prominent and reads `See Compatibility`.

Selection remains capped at exactly two people. No third-person mode is implied.

## 4. CTA behavior

- On iPhone, use a safe-area action tray above the native tab bar. Content scrolls normally behind the tray with enough bottom inset to keep the final row reachable.
- The tray is not keyboard-dependent and must move with the safe area if a future editable/search state introduces the keyboard.
- On iPad, keep the CTA in the left pair-context region rather than pinning a full-window action.
- Disabled state uses both lower emphasis and explicit label change; it is not communicated by opacity alone.

## 5. Result concept — Relationship Field

The result hero becomes one rounded, softly layered field. Within that field:

1. the basis appears first as compact factual disclosure;
2. the pair is named in one full-width relationship title;
3. Sun signs appear as a secondary pair line;
4. two medallions share one restrained orbit/heart connector;
5. score and relationship label occupy the same visual axis as the pair;
6. summary closes the field as short editorial copy, without a detached pill.

The reference title is `Alexandria & Christopher`. This intentionally proves that names are not trapped in two tiny columns. At large Dynamic Type sizes the title may wrap to two balanced lines; it must never shrink to vertical fragments.

### iPhone

- The relationship field spans the readable width.
- Pair title owns the full width above the medallions.
- Medallions remain modest; the orbit connects them without becoming a synastry diagram.
- Score is large but anchored directly under the pair axis.
- Relationship label and two-line summary stay inside the field.
- Existing metric content begins immediately below as context.

### iPad

- One wide relationship field uses a deliberate horizontal composition.
- Pair title, signs, medallions, and connector occupy the left region.
- Score, label, and summary occupy the right region within the same field.
- A tonal shared background and orbit continuation make both regions one composition rather than two cards.
- Existing metrics and Our Take remain lower-page context only.

## 6. Identity, signs, connector, and score

- **Names:** primary relationship identity; full-width title; two-line maximum under pressure.
- **Signs:** secondary system text, formatted as `Sagittarius Sun · Capricorn Sun`; zodiac glyphs may accompany them only when semantically correct.
- **Medallions:** initials with coral/lavender tonal fields; no unlicensed portrait assumption.
- **Connector:** one thin orbit curve with small heart node and two endpoint nodes. It is decorative for VoiceOver and never says `VS`.
- **Score:** Cormorant Garamond, monospaced digits in implementation, visually anchored to the relationship axis.
- **Label:** emotionally expressive but restrained (`Magnetic Match` in the reference).
- **Summary:** short system-body copy integrated into the hero, not a large capsule.

## 7. Free and Precise basis

The hero reserves one stable disclosure location near its top edge:

- `Free · Sun-sign pair` plus `Sagittarius × Capricorn catalog · not natal synastry.`
- `Precise` plus provider/methodology-safe detail appropriate to the real implemented state.

The disclosure remains visible before the score, but its compact treatment prevents it from competing with pair identity. Free output must never imply natal synastry.

## 8. Visual language

### Light

- Ground `#FBF7F1`, warm surface `#FFFDFC`, ink `#151B28`.
- Coral and lavender mark the two people; restrained gold/blue support the orbit and basis.
- Large ambient relationship fields use very low-opacity coral/lavender shapes, not pink wash.
- Borders and soft elevation separate surfaces.

### Dark

- Ground `#101725`, surface `#171F30`, raised surface `#20283A`.
- Coral/lavender remain lively; gold/blue retain semantic support.
- Separation is tonal before shadow. No harsh light-mode inversion.
- Primary CTA uses the existing coral/lavender direction with dark readable foreground.

## 9. Typography and geometry

- Cormorant Garamond: screen/relationship titles and score.
- SF Pro/system: instructions, names, signs, rows, controls, basis, label, and summary.
- Compact screen gutter: 20 pt; regular bounded margins: 32–48 pt.
- Compact rows: 16–18 pt radius; hero: 24–28 pt radius.
- Primary action: minimum 56 pt high; all controls/rows: minimum 44 pt target.
- Reference sizes express hierarchy only. SwiftUI implementation must use semantic styles and Dynamic Type.

## 10. Scope boundary

No lower-result redesign is proposed. Metrics, Our Take, precise-access, cached/offline, and error content in the references are context placeholders for spacing only. The toolbar share control remains current context; the final visual share-card family belongs to D8.

