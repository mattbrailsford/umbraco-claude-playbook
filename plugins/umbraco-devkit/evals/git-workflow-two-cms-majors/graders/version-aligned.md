---
type: llm
weight: 2
focus: {source: file, path: docs/versioning.md}
---
PASS if the plan's default is that the package's major version tracks the CMS major: Umbraco 17
releases are 17.x.x and Umbraco 13 releases are 13.x.x. Naming independent SemVer as an
alternative is fine but not needed.

FAIL if its default is independent versioning (for example 1.x for Umbraco 13 and 2.x for 17),
or it lists both schemes without picking the version-aligned one.
