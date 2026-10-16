---
type: llm
focus: {source: file, path: .github/dependabot.yml}
---
PASS if the file has entries for nuget at the repository root, npm at
/src/MyPackage/Client, and github-actions.

FAIL if any of the three is missing or points at the wrong directory.
