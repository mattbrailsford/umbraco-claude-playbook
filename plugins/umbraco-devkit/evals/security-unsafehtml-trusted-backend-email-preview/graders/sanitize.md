---
type: llm
weight: 2
focus: {source: file, path: client/src/notifications/email-template-editor.element.ts}
---
Context: `bodyHtml` is built from an editor-written template and a member's own fields
(which members set when they sign up), so it can hold script.

PASS if the body is shown without running script in the backoffice: sanitized before
rendering as markup (`sanitizeHTML` from `@umbraco-cms/backoffice/utils`, DOMPurify from
`@umbraco-cms/backoffice/external/dompurify`, or another allow-list sanitizer), or put in an
`<iframe srcdoc>` with a `sandbox` attribute that does not include `allow-scripts`.

FAIL if `bodyHtml` goes into `unsafeHTML`, `innerHTML` or an iframe without `sandbox` (or
with `allow-scripts` together with `allow-same-origin`) unsanitized.
