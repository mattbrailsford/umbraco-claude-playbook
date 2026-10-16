---
type: llm
focus: trace
---
The repo's CONTRIBUTING.md asks for one change per PR and a test for any behavior change. The
PR changes behavior (it filters out tags with empty text) but adds no test, and it bundles
unrelated changes.

PASS if the drafted review points out at least one of these against CONTRIBUTING.md: the
missing test, or that the PR mixes more than one change.

FAIL if the review never checks the PR against CONTRIBUTING.md.
