---
description: Writing dependabot.yml for an Umbraco package; locked deps ignored for all versions, shipped majors held, commit prefix matching commitlint.
tags: [umbraco-dependencies, should-trigger]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Set up Dependabot for this repo: write `.github/dependabot.yml`. It's my Umbraco package
(NuGet plus a backoffice client). Git can't run here, but everything is in the working tree.
