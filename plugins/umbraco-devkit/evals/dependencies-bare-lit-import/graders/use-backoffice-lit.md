---
type: llm
weight: 2
---
PASS if the answer says this bundles a second copy of Lit into the extension, and fixes it by
importing from the backoffice instead: `@umbraco-cms/backoffice/external/lit`, or
UmbLitElement from `@umbraco-cms/backoffice/lit-element`. Removing `lit` from
`dependencies` is a fine extra.

FAIL if it says the setup is fine, or only suggests a change that keeps importing from bare
`lit`.
