---
type: llm
focus: trace
---
Nothing is built yet, so the new tests can't pass.

PASS if every new test method carries a pending or skip marker the runner reports as skipped,
not failed (for example `[Ignore("Pending")]`, `[Explicit]`, `[Fact(Skip = ...)]`). Judge only
the markers in the test code. A note that the test project won't compile until the new types
exist is fine and doesn't affect this.

FAIL if any new test method has no such marker.
