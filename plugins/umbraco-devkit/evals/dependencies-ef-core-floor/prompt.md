---
description: A locked dependency stays at the CMS floor's version, so a Dependabot bump above it should not merge.
tags: [umbraco-dependencies, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco package references `Umbraco.Cms.Core` with the range `[17.0.0, 18.0.0)`. It also
keeps its own tables with EF Core, and references `Microsoft.EntityFrameworkCore.SqlServer`
at `10.0.0`, the version Umbraco 17.0.0 uses.

Dependabot opened a PR that bumps `Microsoft.EntityFrameworkCore.SqlServer` to `10.0.10`, the
version the latest Umbraco 17 uses. CI is green. Should I merge it?
