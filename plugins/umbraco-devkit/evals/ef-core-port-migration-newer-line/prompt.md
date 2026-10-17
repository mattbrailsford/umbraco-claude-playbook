---
description: "Bringing a v17 migration forward to a v18 branch that already has a later migration of its own; the ID must still match v17's."
tags: [ef-core-data, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

This checkout of my Umbraco package is the `v18/main` branch. On `v17/main` we added a
nullable `VerifiedAtUtc` column to `Review` last month, with migrations for both providers.
The `v17/main` worktree is at `.worktrees/v17-main`. Since then this branch got its own
`ReplyText` migration. Add `VerifiedAtUtc` here too.

There's no git, dotnet or network here, so you can't cherry-pick, generate migrations or
build; make the change by editing files.
