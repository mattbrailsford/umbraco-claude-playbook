---
type: llm
focus: {source: file, path: .github/dependabot.yml}
---
PASS if the npm entry also ignores, for all versions, the libraries the backoffice provides
at runtime that this client could depend on: at least lit, @umbraco-ui/uui and marked
(marked is a peer of @umbraco-cms/backoffice in the lockfile, so its version is set by the
CMS).

FAIL if marked is treated as an ordinary dependency with only majors (or nothing) ignored,
or lit and @umbraco-ui/uui are not ignored.
