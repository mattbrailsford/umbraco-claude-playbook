---
type: llm
focus: trace
---
PASS if member groups are written to the file by name (or another value that's the same in
every environment) and looked up by that value on import, not written as member group keys
or ids.

FAIL if the file stores member group keys or ids.
