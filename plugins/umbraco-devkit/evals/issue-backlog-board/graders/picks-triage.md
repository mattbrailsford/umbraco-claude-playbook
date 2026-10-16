---
type: llm
weight: 2
focus: trace
---
PASS if the reply picks triage of the two unlabeled issues as the next stage, says why in a
line, and asks for a yes before running it.

FAIL if it picks another stage first, or runs a stage without asking.
