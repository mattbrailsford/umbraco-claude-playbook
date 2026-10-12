---
name: umbraco-backoffice-ux
description: >-
  How an Umbraco backoffice screen should look and behave for the editor using it — matching
  existing screens, pickers vs select boxes, the five moments every UI needs (first run,
  mistake, wait, finish, return), components that appear in more than one place, and the small
  details that most often get sent back (icon buttons, contrast, labels, table columns). Use
  when designing, building or reviewing any backoffice UI. Not for package structure, compiler
  setup or public API surface (`umbraco-backoffice-conventions`), and not for how a specific
  extension point works (the official Backoffice Skills plugin).
---

# Backoffice UX

## 🎯 Why: Design for Change

A backoffice extension has a real user: the editor sitting in front of it. A feature that
technically works but leaves them guessing is still a bug, just one the build and test suite
can't see. UI fixes found after the build are the most expensive kind: each one is a
change-rebuild-recheck round trip, and they arrive in a pile at the end. Every rule below comes
from a correction that kept being made by hand.

## Match what's already there

The single most common UI correction is "that doesn't feel like Umbraco". Before inventing an
interaction, find how Umbraco or the host product already does the same kind of thing, and
copy it.

1. **Docs first.** If `CLAUDE.md` or the official Backoffice Skills plugin names the pattern,
   that's ground truth.
2. **Then the screen next door.** Open the nearest existing screen of the same kind (the
   dashboard beside it, a sibling workspace, the CMS's own version of the feature) and match
   it: how boxes are used and spaced, whether tables run edge to edge inside a box, how
   headers, actions and help icons look, which icon colours it uses.
3. **Then Umbraco core.** If the product has no sibling, use how the CMS does it: property
   actions in the "..." menu by a property label, pickers that open a modal, editors with
   groups in boxes.
4. **Built-in before custom.** If the CMS already has the feature (a filter, a property
   editor, a picker, a collection view), use it instead of building a lookalike.

Spacing and colour come from UUI's custom properties (`--uui-size-*`, `--uui-color-*`), never
hand-picked values, so the screen moves with the backoffice when its theme changes, including
dark mode:

```css
/* BAD — hardcoded, ignores the active theme */
.thing-card {
  background: #ffffff;
  padding: 12px;
  color: #1b264f;
}

/* GOOD — tracks whatever theme (including dark mode) is active */
.thing-card {
  background: var(--uui-color-surface);
  padding: var(--uui-size-space-4);
  color: var(--uui-color-text);
}
```

## Choosing things: picker, not select

The plainest working control satisfies the acceptance criteria with the least code, so it's
what gets picked by default: a bare `<select>` for anything that references another piece of
content, media, a member, a user, or any other entity. Umbraco's convention is a **picker**:

- a `uui-ref-list` of `uui-ref-node` rows showing what's picked, with enough context to tell
  items apart (icon, path or detail, a status tag)
- a "Choose" button (`look="placeholder"`) underneath to add more
- a modal that opens to search or browse

The same shape applies when each chosen item needs its own settings: a ref list, an add button,
and a modal per item to configure it. Not an inline list of rows with fields in each.

A `<select>` or combobox is a deliberate choice only for a short, fixed list of simple values
(an enum-like setting) that needs no extra context to pick correctly. When you choose it over
a picker, say so in `ARCHITECTURE.md` with the reason, so it reads as a decision.

## The five moments

Most requests describe only the main action. Walk these for every screen and decide,
deliberately, whether each needs handling:

1. **First run.** Nothing's been created yet. Does the empty state say what goes here and
   offer the first action, or is it a blank table?
2. **The mistake.** The editor picks a bad value or clicks the wrong thing. Does the error say
   what happened and what to do next, or just "invalid input"?
3. **The wait.** Something takes more than a second (a save, a fetch, an import). Does the
   editor know it's working?
4. **The finish.** It worked. How do they know, beyond a modal just closing?
5. **The return.** They come back tomorrow, or reopen the same item. Is what they last chose
   or saw (a filter, a tab, a sort order, a selected value) still there?

A moment that genuinely doesn't apply is a deliberate skip, noted as such, not left
unconsidered.

## Every place it appears

A component often renders in more than one place: a narrow sidebar and a full-width
workspace, a modal and an inline editor, a dashboard and a content app. Design and check it in
every place it will appear, not just the first one built. Make it respond to the width of its
container rather than the window, and when the same small piece of UI repeats across places,
build it once as a shared component.

## Details that get sent back

- **Help and info buttons** are a compact, borderless button holding just the icon. An
  outlined button makes the row taller and draws more attention than help should.
- **Icons exist in Umbraco's set.** The backoffice ships its own icon set, not every Lucide
  icon, so an icon name that looks right can render blank. Check each new icon name against
  the project's Umbraco version and look at it on screen. Where items sit side by side (a list
  of actions, a picker), give each one its own icon that fits what it does.
- **Disabled controls** show the not-allowed cursor and say why they're disabled where that
  isn't obvious.
- **Colour and contrast**: use UUI colour tokens; never put text, tags or icons in a colour
  close to their background. Check dark mode too, including chart legends and anything with a
  custom colour.
- **Labels and names** say what the thing is or does, in the same casing as the labels around
  them. Replace placeholder names ("Dashboard", "Settings") with real ones ("Usage").
- **Every user-facing string is localized**, including `aria-label`, `title` and placeholder
  text, and is checked to render the text, not the raw key.
- **Table columns earn their width.** Drop a column whose value can sit in a tooltip, a tag on
  another column, or a detail view.
- **New settings go in the group they belong to** on an existing editor, not in a new group of
  their own.
- **Notices and disclaimers** are subtle and inline, styled like the content around them (an
  info icon and a line of text), not a loud box.
- **Numbers say what they mean.** A dashboard figure that's an estimate, a sample or a partial
  count says so where it's shown.

## Reviewing a UI diff

Things to look for in the code, before anyone sees the screen:

- `uui-select`, `<select>` or `uui-combobox` whose options are entities (content, media,
  members, users, or any record with its own ID) rather than fixed values
- hard-coded colours, pixel spacing or font sizes where a `--uui-*` token exists
- user-facing strings, `aria-label`s or placeholders that aren't localized
- a list or table with no empty state, a fetch with no loading state, a save with no
  confirmation
- a component used in more than one place that sets a fixed width
- a new `icon-*` name that hasn't been checked against the backoffice icon set
