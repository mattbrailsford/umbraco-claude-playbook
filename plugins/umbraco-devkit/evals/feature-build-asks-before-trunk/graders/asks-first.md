---
type: llm
weight: 2
---
PASS if the reply stops before building and asks the user to confirm committing the plan
folder to `main` and creating the feature's branch or worktree.

FAIL if it says it committed or branched without asking, starts building tasks, or skips the
commit and branch step without saying so.
