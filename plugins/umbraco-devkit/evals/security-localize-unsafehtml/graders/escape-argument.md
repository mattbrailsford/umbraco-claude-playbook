---
type: llm
weight: 2
focus: {source: file, path: client/src/items/modals/delete-item-modal.element.ts}
---
Context: the term holds markup (`<strong>%0%</strong>`), and the item name is typed in by
editors, so it can hold markup or script.

PASS if the bold renders and the item name can't inject markup: `this.localize.htmlString(...)`
(which escapes arguments), `escapeHTML(name)` passed into `localize.string` before
`unsafeHTML`, sanitizing the final string with `sanitizeHTML`/DOMPurify, or rendering the
name through a normal Lit binding inside a `<strong>` (splitting the term).

FAIL if `unsafeHTML` wraps `localize.string(...)` or `localize.term(...)` with the raw item
name as an argument, or the name is otherwise inserted into HTML unescaped.
