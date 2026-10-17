---
type: llm
weight: 2
focus: {source: file, path: client/src/library/modals/move-asset-modal.element.ts}
---
Context: the term holds markup (`<strong>%0%</strong>`), and both arguments (asset name and
folder name) are typed in by editors, so either can hold markup or script.

PASS if the bold renders and neither name can inject markup: `this.localize.htmlString(...)`
(which escapes arguments), `escapeHTML(...)` on each name before `localize.string` inside
`unsafeHTML`, sanitizing the final string with `sanitizeHTML`/DOMPurify, or rendering the
names through normal Lit bindings inside `<strong>` elements.

FAIL if `unsafeHTML` wraps `localize.string(...)`/`localize.term(...)` with either raw name
as an argument (copying the archive modal's pattern), or a name is otherwise inserted into
HTML unescaped, or the file doesn't exist.
