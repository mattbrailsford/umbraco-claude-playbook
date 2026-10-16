---
type: llm
focus: trace
---
PASS if the import handles a zone key that doesn't exist on the target without failing the
whole import (for example skips it and logs a warning), or declares the zones as
dependencies so uSync brings or orders them, or both.

FAIL if an unknown zone key is saved onto the store unchecked, or makes the import throw.
