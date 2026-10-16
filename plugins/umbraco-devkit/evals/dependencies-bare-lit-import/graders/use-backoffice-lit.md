---
type: llm
weight: 2
---
Context: the backoffice already provides Lit. Importing from the bare `lit` package with
`external: [/^@umbraco/]` bundles a second copy of Lit into the extension. The fix is to
import from `@umbraco-cms/backoffice/external/lit` (and optionally extend `UmbLitElement`
from `@umbraco-cms/backoffice/lit-element`).

PASS if the new `order-status-badge.element.ts` imports Lit from the backoffice, not from
bare `lit` or `lit/decorators.js`.

FAIL if the new element imports from bare `lit` or `lit/decorators.js`.
