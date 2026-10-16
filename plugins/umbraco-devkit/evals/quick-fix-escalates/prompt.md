---
description: quick-fix must escalate a request that is really a feature (new setting, backoffice UI, behavior across modules) instead of making it.
tags: [quick-fix, workflow]
max_turns: 15
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Use the quick-fix skill: add a setting to my package that lets editors turn search boosting
off, with a toggle in the backoffice settings dashboard, and have SearchService skip
boosting when it's off. Git and dotnet can't run here.
