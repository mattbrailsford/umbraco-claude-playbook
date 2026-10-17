---
description: "Applying Dependabot's EF Core bump; a package's EF Core version is a floor and should match what its minimum Umbraco uses."
tags: [umbraco-dependencies, should-trigger]
# covers: ["Which CMS version: the floor"]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Dependabot's open PRs for my Umbraco package are listed in `DEPENDABOT-PRS.md`. Rather than
merge them one by one, apply them all to `Directory.Packages.props` in one change so I can
close the PRs.

Git and dotnet can't run here.
