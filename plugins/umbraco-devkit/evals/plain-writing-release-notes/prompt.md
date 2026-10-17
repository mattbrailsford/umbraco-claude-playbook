---
description: Writing release notes for package users should load plain-writing.
tags: [plain-writing, should-trigger]
# covers: ["Concise is not vague"]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

Write the GitHub release notes for v4.1.0 of my Umbraco package from these commits. Reply
with the Markdown.

- feat(search): boost configured document types in site search results
- fix(dashboard): stop the stats dashboard double-counting unpublished nodes
- fix(api): return 404 instead of 500 for a missing profile
- chore(deps): bump vite to 7.1.2
- refactor(search): extract BoostCalculator
- feat(settings): add MyPackage:SearchBoost:CacheDuration setting (default 10 minutes)
