---
description: Setting up EF Core migrations for an Umbraco package needs prefixed migrations generated separately for SQL Server and SQLite.
tags: [ef-core-data, should-trigger]
# covers: ["One entity model, two providers", "Migrations: generated per provider, prefixed to avoid collisions"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My new Umbraco 17 package "Acme Reviews" (`src/Acme.Reviews`) stores reviews with EF Core.
Customer sites run on SQL Server or SQLite. Set up migrations so the reviews table is
created on install: the project layout, a `scripts/add-migration.sh` the team will use to
create each new migration, and the first migration.

There's no dotnet or network here, so you can't run `dotnet ef` or build. Write the files
by hand, including the first migration's code.
