---
description: "Backporting a fix whose migration must be rewritten for an older branch's different project layout; the ID must still match."
tags: [ef-core-data, should-trigger]
# covers: ["Migrations: generated per provider, prefixed to avoid collisions"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

This checkout of my Umbraco package is `v16/main`. On `v17/main` (worktree at
`.worktrees/v17-main`) we shipped issue #212: reviews can be marked verified, which added
`Review.VerifiedAtUtc` and `ReviewService.MarkVerifiedAsync`. Customers on 2.x want it too.
Backport it to this branch.

There's no git, dotnet or network here, so you can't cherry-pick, generate migrations or
build; make the change by editing files.
