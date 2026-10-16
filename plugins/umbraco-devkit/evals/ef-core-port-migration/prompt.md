---
description: Porting an EF Core migration to another major's branch must copy the files and keep the migration ID, not create a new one.
tags: [ef-core-data, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

This checkout of my Umbraco package is the `v16/main` branch. On `v17/main` we added a
nullable `VerifiedAtUtc` column to `Review`, with migrations for both providers. The
`v17/main` worktree is at `.worktrees/v17-main`. Add the same column on this branch.

There's no git, dotnet or network here, so you can't cherry-pick, generate migrations or
build; make the change by editing files.
