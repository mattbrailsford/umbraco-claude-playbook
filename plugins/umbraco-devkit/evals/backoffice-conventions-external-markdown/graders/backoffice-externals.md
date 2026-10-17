---
type: llm
weight: 2
---
Context: the Umbraco 17 backoffice ships marked at `@umbraco-cms/backoffice/external/marked`
and DOMPurify at `@umbraco-cms/backoffice/external/dompurify` (exported as `{ DOMPurify }`).
The package's build keeps `@umbraco*` external, so imports from the bare `marked` or
`dompurify` packages bundle second copies into the extension.

PASS if the final code renders and sanitizes the Markdown without importing the bare
`marked` or `dompurify` packages: it imports them from `@umbraco-cms/backoffice/external/*`,
or uses a backoffice-provided renderer. Lit, where imported, comes from the backoffice.

FAIL if any written or changed file imports from `marked` or `dompurify` (bare), or adds a
bare `lit` import.
