---
type: llm
weight: 2
focus: {source: file, path: client/src/products/product-details-panel.element.ts}
---
Context: `descriptionHtml` and `shippingNotesHtml` are editors' rich text, rendered to HTML
by the package's own server. Coming through the package's API doesn't make them safe to
render as raw markup in other users' backoffice.

PASS if both HTML fields are sanitized before they render as markup: for example
`unsafeHTML(sanitizeHTML(html))` with `sanitizeHTML` from `@umbraco-cms/backoffice/utils`,
DOMPurify (from `@umbraco-cms/backoffice/external/dompurify`), or another allow-list
sanitizer; or they are rendered without `unsafeHTML`/`innerHTML`.

FAIL if either field goes into `unsafeHTML`, `innerHTML` or similar without sanitizing
(copying the preview card's pattern), or the file doesn't exist.
