---
type: llm
weight: 2
---
PASS if both are true:
- The element imports Lit (html, css, decorators) from the backoffice, for example
  `@umbraco-cms/backoffice/external/lit`, optionally with `UmbLitElement` from
  `@umbraco-cms/backoffice/lit-element`.
- The Vite config keeps the backoffice out of the bundle, for example
  `external: [/^@umbraco/]` or an equivalent list covering `@umbraco-cms/backoffice`.

FAIL if the element imports from the bare `lit` package (or `lit/decorators.js`), or if
the config bundles Lit or `@umbraco-cms/backoffice` into the output. Marking bare `lit` as
external also FAILS: the backoffice import map does not provide a bare `lit` module.
