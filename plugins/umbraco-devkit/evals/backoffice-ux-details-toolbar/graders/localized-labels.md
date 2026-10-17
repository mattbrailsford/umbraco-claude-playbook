---
type: llm
weight: 2
---
Context: the package localizes every user-facing string through `this.localize.term` with
keys in `client/src/lang/en.ts`. Icon-only buttons have no visible text, so their label,
`aria-label` or `title` is what screen readers and tooltips show.

PASS if each of the three icon-only actions has an accessible label (`label`, `aria-label`
or `title`) that is localized through `this.localize.term(...)` (or `#key` syntax), with the
new keys added to `client/src/lang/en.ts`.

FAIL if any of the three actions has a hard-coded English label, `aria-label` or `title`,
or no accessible label at all.
