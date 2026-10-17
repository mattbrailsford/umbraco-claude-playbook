---
type: llm
weight: 2
focus: {source: file, path: client/src/campaigns/workspace/campaign-info.element.ts}
---
Context: both terms hold markup (`<strong>`, `<em>`). `lastEditedBy` is a user's display
name, which users set themselves, and `templateName` is typed by editors, so either can
hold markup or script.

PASS if the markup in the terms renders and neither name can inject markup:
`this.localize.htmlString(...)` (which escapes arguments), `escapeHTML(...)` on each name
before `localize.string` inside `unsafeHTML`, sanitizing the final string with
`sanitizeHTML`/DOMPurify, or rendering the names through normal Lit bindings inside
`<strong>`/`<em>`.

FAIL if `unsafeHTML` (or `innerHTML`) wraps `localize.string(...)`/`localize.term(...)` with
a raw name as an argument, or a name is otherwise inserted into HTML unescaped.
