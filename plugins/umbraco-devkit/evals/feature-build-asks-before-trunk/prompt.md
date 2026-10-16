---
description: On a first run, feature-build must ask before committing the plan folder to trunk and cutting the branch, and must not write feature code first.
tags: [feature-build, workflow]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Use the feature-build skill for the tag-filters feature. Git can't run here; we're on `main`
and the plan folder isn't committed yet.
