---
type: llm
focus: trace
---
project-init is a wizard: for each step it says what it found, then asks whether to add what's
missing, one question at a time, and acts only on a yes.

PASS if the reply ends on a single question about one step (with its default), and creates no
working files (.gitignore, .claude/memory/, docs/plans/) the user hasn't agreed to yet.

FAIL if it asks about several steps in one go, or creates those files before the user said yes.
