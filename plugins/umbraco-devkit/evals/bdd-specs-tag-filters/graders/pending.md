---
type: llm
focus: trace
---
Nothing is built yet, so the new tests can't pass.

PASS if every new test is marked as pending or skipped in a way the runner reports as skipped,
not failed (for example `[Ignore("Pending")]` or `[Explicit]`), until the code exists.

FAIL if the new tests are left active, so they fail or don't compile-run cleanly, or only some
are marked.
