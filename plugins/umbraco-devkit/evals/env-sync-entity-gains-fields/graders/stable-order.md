---
type: llm
focus: trace
---
PASS if the zone keys are written in a fixed order (for example sorted), so the same store
always exports to the same file regardless of the order the database or list returns them.

FAIL if the zone keys are written in whatever order the list holds.
