---
type: llm
weight: 2
focus: trace
---
The package's NuGet dependency is Umbraco.Cms.Core 10.0.0 with no maximum, so the Umbraco
Marketplace assumes it doesn't support Umbraco 14+. The user wants the listing fixed without a
new release, and the PackageProjectUrl is the GitHub repo, so Marketplace reads
`umbraco-marketplace.json` from the repo root.

PASS if the change adds `umbraco-marketplace.json` at the repo root with
`"VersionDependencyMode": "SemVer"`.

FAIL if the fix relies on a field Marketplace doesn't read (for example a list of supported
Umbraco versions in the JSON file or in PackageTags), only changes the .csproj dependency range
(which needs a new release to take effect), puts the file somewhere other than the repo root,
or says the user has to contact Umbraco or submit the change through a form.
