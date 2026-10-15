---
description: A schema change in an Umbraco package needs a prefixed migration generated separately for SQL Server and SQLite.
tags: [ef-core-data, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

I'm adding EF Core storage to a new Umbraco 17 package called "Acme Reviews". It has one
entity, `Review`, with an Id, ContentKey, Rating and CreatedUtc. Sites can run on SQL Server
or SQLite. Give me the commands to create the first migration, and say how the project
should be laid out for migrations.
