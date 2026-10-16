---
type: llm
weight: 2
---
PASS if the reply says PLAN.md isn't a task checklist and sends the user to feature-plan before
building.

FAIL if it builds anyway, rewrites PLAN.md into a checklist itself, or doesn't point to
feature-plan.
