---
type: llm
focus: trace
---
PASS if importing a value whose store doesn't exist on the target leaves the property empty
(or keeps the target's value) and doesn't throw, ideally with a warning.

FAIL if a missing store throws, or the source's integer id is written into the target's
content.
