---
description: Adding EF Core to a package with a CMS 17.0 floor; versions must match the floor (10.0.0), not the latest 10.0.x.
tags: [umbraco-dependencies, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco package needs its own database tables. Add the EF Core packages for SQL Server
and SQLite, plus the design-time package for migrations, to the project. Just the package
references for now; I'll write the DbContext myself. Git and dotnet can't run here.
