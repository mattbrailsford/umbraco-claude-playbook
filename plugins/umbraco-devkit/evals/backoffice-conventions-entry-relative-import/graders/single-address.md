---
type: llm
weight: 2
---
Context: the package's `umbraco-package.json` loads `entry.js` as a `backofficeEntryPoint`
and maps `@status-board/core` to it in the import map. From Umbraco 17.6 and 18.1 the
backoffice adds `?umb__rnd=<version>` to those URLs, but a relative import such as
`../entry.js` resolves without it. The browser then loads the entry file a second time as a
separate module, so `clientReady` in that copy never resolves and `onInit` state is split.

PASS if, in the final code, no module other than `entry.ts` itself imports from the entry
file by a relative path (`./entry.js`, `../entry.js`, `../entry`, or similar). Typical
passing fixes: move `clientReady` into its own module (for example under `api/`) that both
`entry.ts` and the dashboard import, or have the dashboard wait on a context or a promise
exported from a non-entry module. Importing it through the bare specifier
`@status-board/core` also passes.

FAIL if the dashboard, or any new helper it imports, imports `clientReady` (or anything
else) from the entry file by a relative path.
