---
type: llm
weight: 2
focus: {source: file, path: client/src/summary/summary-preview.element.ts}
---
PASS if the summary HTML is sanitized before it is rendered as markup: for example
`unsafeHTML(sanitizeHTML(html))` with `sanitizeHTML` from `@umbraco-cms/backoffice/utils`,
DOMPurify (from `@umbraco-cms/backoffice/external/dompurify`), or another allow-list
sanitizer, or the HTML is rendered without `unsafeHTML`/`innerHTML` (for example parsed
into safe Lit templates).

FAIL if the HTML from the API goes into `unsafeHTML`, `innerHTML` or similar without
sanitizing, or the file doesn't exist.
