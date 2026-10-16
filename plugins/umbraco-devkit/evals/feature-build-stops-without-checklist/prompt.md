---
description: feature-build must stop and send the user to feature-plan when PLAN.md isn't a checklist.
tags: [feature-build, workflow]
max_turns: 15
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Use the feature-build skill for the tag-filters feature. Git can't run here; we're on `main`.
