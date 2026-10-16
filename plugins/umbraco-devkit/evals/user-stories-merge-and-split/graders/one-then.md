---
type: llm
focus: {source: file, path: docs/plans/tag-reports/STORIES.md}
---
Look only at the acceptance criteria of the new stories.

PASS if each criterion has exactly one Then outcome, with no second outcome joined on by "and"
or "and also", and the empty-export case (download still works, header row only) is written as
its own criterion, apart from the success cases.

FAIL if any new criterion's Then states two outcomes, or the empty-export case is missing or
folded into another criterion.
