---
description: "decision-review cross-checks the diff against SPEC.md and surfaces an unlogged deviation, skips decisions settled before the build, and writes no file."
tags: [decision-review, workflow]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Use decision-review on tag-filters before I open the PR. We're on the `tag-filters` branch.
Git can't run here, so the branch's diff against `main` is in `CHANGE.diff`.
