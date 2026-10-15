---
type: llm
weight: 2
---
PASS if the answer tells the package author to bump the `version` in `umbraco-package.json`
for every release, because Umbraco (17.6 and later) appends that version to the package's
entry point and import map URLs as a cache-busting query string. Extra advice (content-hashed
chunk file names, cache headers) is fine alongside it.

FAIL if the answer never mentions bumping the umbraco-package.json version, and instead
relies only on things like telling editors to hard-refresh, hand-added `?v=` query strings,
server cache headers, or content-hashed file names for the entry point.
