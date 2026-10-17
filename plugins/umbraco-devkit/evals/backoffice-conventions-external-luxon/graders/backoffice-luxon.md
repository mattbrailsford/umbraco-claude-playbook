---
type: llm
weight: 2
---
Context: the Umbraco 17 backoffice ships luxon at `@umbraco-cms/backoffice/external/luxon`.
The package's build keeps `@umbraco*` external, so an import from the bare `luxon` package
bundles a second copy of luxon into the extension.

PASS if the final code does not import from the bare `luxon` package: it imports luxon
from `@umbraco-cms/backoffice/external/luxon`, or formats the dates without luxon (for
example with `Intl.RelativeTimeFormat` and `Intl.DateTimeFormat`). Lit, where imported,
comes from `@umbraco-cms/backoffice/external/lit`.

FAIL if any written or changed file imports from `luxon` (bare), or adds a bare `lit`
import.
