---
type: llm
focus: {source: file, path: docs/plans/tag-reports/STORIES.md}
---
Look only at the acceptance criteria of the new stories (not STORY-1 or STORY-2).

How to count outcomes: `Given`/`And` lines before `When` are setup, not outcomes. One result
described with several values ("the file has the rows `news,4` and `old,0`", "the CSV attached
with those rows") is one outcome. Two outcomes means two separate results joined in one `Then`,
such as "the request is refused and no file is returned" or "no email is sent and a warning is
logged".

PASS if every new criterion's `Then` has one outcome, and the empty-export case (download still
works, header row only) is written as its own criterion, apart from the success cases.

FAIL if any new criterion's `Then` has two outcomes, or the empty-export case is missing or
folded into another criterion.
