# D5.1 Ask adaptive and accessibility notes

**Status: REVIEW CANDIDATE — NOT APPROVED**

## iPhone

- Portrait-first, one bounded reading column with the shared 20–24 pt content gutter.
- Ask identity, invitation, composer and first suggestion/context treatment appear in the first fold.
- The illustration remains compact and yields space to the composer.
- Answer order is question identity, disclosure when applicable, interpretation, basis, then new-question action.
- The native five-destination shell remains selected on Ask.
- Composer action and bottom content reserve safe-area space; the keyboard never covers the action.

## iPad portrait

- Regular width uses two bounded regions for entry: invitation/context/suggestions on the leading side, composer/illustration on the main side.
- Regular width answer uses a narrow question/basis rail plus a readable main answer column.
- The rail is contextual, not a conversation-history sidebar.
- Long-form body copy stays inside a comfortable measure. Extra width creates breathing room and relationship between regions, not oversized type or full-width paragraphs.

## iPad landscape

- Entry keeps the composer as the visual action center; the invitation/context region remains bounded on the leading side.
- Answer keeps the main reading column near a comfortable maximum and uses landscape width for the question/basis rail.
- The primary answer never stretches across the full canvas.
- If height becomes constrained, scroll content rather than shrinking question, basis, warning or action text.
- Navigation remains native and stable. No second root tab bar or custom history rail.

## Narrow Split View / compact regular width

Collapse in this order:

1. hide or reduce decorative illustration;
2. move context/suggestions below the composer or question;
3. place basis below the answer rather than beside it;
4. collapse to one ordered reading column;
5. preserve question text, safety/context limitation, answer action and composer usability.

Breakpoints follow content fit, not iPad model checks. Accessibility sizes may force the compact composition even when the geometric width is regular.

## Composer and keyboard

- Use a native multiline text editor with a visible accessible label such as `Ask a focused question`.
- Placeholder copy is not the only label; VoiceOver receives purpose and current value.
- Expand to roughly 2–5 visible lines, then let the text area scroll internally.
- Keep `Ask` in the same focus group as the composer but as an independently focusable action.
- When keyboard appears, scroll/adjust the form so the composer bottom and Ask action remain visible above the keyboard.
- After sending, focus moves to the generating status or submitted-question identity, not to a hidden field.
- When an answer arrives, focus moves to the answer heading or a concise completion announcement according to native accessibility behavior; do not steal focus during ordinary incremental content changes.
- Hardware keyboard behavior remains native. Return/Space activation follows native controls. No unsupported shortcut is promised by this package.
- If a future command shortcut is added, it needs a product decision and a discoverable keyboard-equivalent label.

## VoiceOver order

### Entry

1. Ask heading and profile/settings.
2. Invitation and supporting explanation.
3. Composer label, current value and Ask action.
4. Suggested-question heading and rows.
5. Available context and access explanation.
6. Root navigation.

### Answer

1. Ask heading and route context.
2. Original question.
3. Development/cached/offline disclosure when present.
4. Answer heading and opening.
5. Reading section headings and body in order.
6. Practical/reflection action.
7. `What this answer used` heading, basis rows and validity/source disclosure.
8. Ask another question action.

Decorative orbit lines, stars and folded-note marks are hidden. The question, answer sections, basis and state warnings are meaningful text elements, not one opaque image.

## Dynamic Type and long content

- Newsreader headings wrap before the illustration or action loses space.
- Question text wraps naturally; no vertical word fragments and no hard one-line truncation.
- Composer height grows before its internal text scrolls.
- Suggested-question rows grow vertically and remain full-row targets.
- Answer sections stack; they do not shrink body text below the system role.
- Basis values wrap and retain full degree/methodology wording.
- Safety and insufficient-context messages remain fully readable before decorative art.
- Long questions retain the complete value on the answer screen.
- Long answers remain scrollable and keep section headings discoverable.

## Targets and pointer/keyboard focus

- Interactive rows, composer, Ask, access and recovery actions are at least 44 pt.
- The complete suggested-question row is the target, not only its trailing icon.
- iPad pointer hover/focus applies to the complete row or card.
- Native Button, Link, TextField/TextEditor, NavigationStack and ScrollView behavior is preferred.
- Focus rings and selection cues remain visible in Light, Dark and Increase Contrast.
- Color never carries the only meaning for access, cache, offline, context, safety or failure state; pair color with labels, symbols and text.

## Generating and motion

- Generating can use one slow orbit or gentle note movement.
- No percentage progress, fake calculation dial, typing dots or fabricated answer text.
- Reduce Motion removes movement and leaves a complete static generating state.
- Generating animation is never the sole state indicator; text identifies the state.

## Light, Dark and Increase Contrast

- Light: warm cream ground, off-white composer/reading surfaces, subtle hairlines and a controlled coral action.
- Dark: midnight ground, raised navy surfaces, warm ivory text and brighter but bounded accents.
- Dark is not a color inversion of Light.
- Increase Contrast strengthens borders, focus outlines, action separation and state grouping.
- Context, safety and offline states retain readable text labels even if accent colors are unavailable.

## Safe areas and tab shell

- Background may extend under system areas.
- Header, composer, content and actions stay inside safe areas.
- Phone answer/entry content reserves bottom breathing room above the native root tab shell.
- The keyboard inset takes precedence over the tab shell; no action is obscured.
- iPad top navigation remains native/adaptive and does not turn into a full-width chat rail.

## Answer completion and new-question action

- Every completed answer includes **Ask another question** after the factual-basis region.
- On iPhone, the action belongs below **WHAT THIS ANSWER USED** in the canonical scroll order. A small scroll is acceptable; reading text and section spacing do not get compressed to force the action into the first viewport.
- On iPad, the same semantic action sits in the bounded reading area beneath the editorial reading. The bounded question/basis rail remains; no device-specific navigation behavior is introduced.
- Activating the action opens a fresh Ask composer for a new focused question. It does not create a persistent chat thread, conversation-history sidebar or long-term conversational memory.
- Native Back may return to the previous answer during the current `NavigationStack` session.

## Navigation reference

Static iPhone/iPad navigation drawings are schematic. They do not authorize a custom tab or navigation control. Implementation retains the existing native `TabView(.sidebarAdaptable)` and current root hierarchy:

**Today / Circle / Sky / Chart / Ask**

Calendar remains nested under Sky. Profile and Settings remain reachable from the existing profile/header entry. Ask remains one root destination in that shell.
