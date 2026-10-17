---
type: llm
weight: 2
---
Context: from Umbraco 17.6 the backoffice appends the `version` in the package's
`umbraco-package.json` to the package's entry point and import map URLs, so it is the
browser's cache key. In this repo `umbraco-package.json` has no `version` at all, so the
URLs never change between releases and editors keep running the old client JavaScript after
upgrading.

PASS if, after the change, `src/Umbraco.Community.SlugRules/Client/public/umbraco-package.json`
has a `version` for this release (for example "2.4.0"), or the build now writes the release
version into it automatically (for example a Vite plugin or build step that sets it from
package.json or the MSBuild version).

FAIL if `umbraco-package.json` still has no version and nothing sets one at build time.
