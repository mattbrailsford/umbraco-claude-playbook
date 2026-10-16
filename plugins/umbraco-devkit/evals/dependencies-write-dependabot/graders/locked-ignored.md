---
type: llm
weight: 2
focus: {source: file, path: .github/dependabot.yml}
---
PASS if the NuGet entry ignores the Umbraco CMS packages (Umbraco.Cms* or each by name) and
the EF Core packages (Microsoft.EntityFrameworkCore* or each by name) for ALL versions (an
ignore entry with no update-types, or every update type), and the npm entry ignores
@umbraco-cms/backoffice for all versions.

FAIL if any of those is not ignored, or is ignored only for major updates, or if a prefix
wildcard covers packages that aren't locked to the CMS (for example "Microsoft.*",
"Microsoft.Extensions.*" or "Umbraco.*").
