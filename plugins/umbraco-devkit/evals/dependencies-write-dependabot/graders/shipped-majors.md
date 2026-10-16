---
type: llm
focus: {source: file, path: .github/dependabot.yml}
---
PASS if Markdig (a NuGet dependency that ships to sites) is ignored for major updates only
(update-types: ["version-update:semver-major"]), so patches and minors still come through.

FAIL if Markdig is not mentioned in an ignore rule, or is ignored for all versions.
