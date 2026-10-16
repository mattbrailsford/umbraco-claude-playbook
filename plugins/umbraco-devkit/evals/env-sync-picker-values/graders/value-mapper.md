---
type: llm
weight: 2
focus: trace
---
PASS if the change adds a uSync value mapper (or equivalent value translator) for the
MyPackage.StorePicker editor that swaps the stored integer store id for something stable
(the store's key or alias) on export and resolves it back to the target's own integer id
on import.

FAIL if no translator is added, or the stored integer id is exported unchanged.
