---
description: "feature-close must not archive a plan whose PR is still open: no move, no status line."
tags: [feature-close, workflow]
max_turns: 15
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

tag-filters is done, so close out its plan. Git and gh can't reach anything here; we're on
`main`. For what it's worth, its PR (#88, from the `tag-filters` branch) is still open, waiting
on one more review.
