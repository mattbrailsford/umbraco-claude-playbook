---
description: Porting an EF Core migration to another branch must copy the files and keep the migration ID, not regenerate.
tags: [ef-core-data, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco package keeps one branch per CMS major: `v16/main` and `v17/main`. It stores its
own data with EF Core, with separate SQL Server and SQLite migration projects. I've added a
new nullable column to one entity on `v17/main` and generated the migrations there. The same
change now needs to go to `v16/main` too, and sites will later upgrade from v16 to v17. What
are the steps to get the migration onto `v16/main`?
