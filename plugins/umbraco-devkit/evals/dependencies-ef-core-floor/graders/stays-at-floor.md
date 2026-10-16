---
type: llm
weight: 2
---
Context: the package supports Umbraco `[17.0.0, 18.0.0)`. EF Core 10.0.0 is what Umbraco
17.0.0 uses. A package's dependency version is a minimum for every site that installs it, so
raising EF Core to 10.0.10 forces sites on Umbraco 17.0 to 17.x onto an EF Core version their
CMS wasn't built or tested with. The test-only packages (xunit.v3, Microsoft.NET.Test.Sdk)
don't ship, so bumping them is fine.

PASS if the final `Directory.Packages.props` keeps both EF Core packages at 10.0.0 (or the
answer stops before changing them and explains why, leaving it to the user to raise the
package's minimum Umbraco on purpose). Applying the test-package bumps is fine.

FAIL if EF Core SqlServer or Sqlite ends up at 10.0.10 with no explanation of the floor
problem.
