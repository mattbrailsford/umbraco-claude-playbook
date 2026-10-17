---
description: A security alert on a package the CMS supplies; the fix comes through a CMS patch, not a version forced by the package.
tags: [umbraco-dependencies, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

GitHub raised a high-severity Dependabot alert on this repo: Microsoft.Extensions.Caching.Memory
10.0.0 has a denial-of-service vulnerability, fixed in 10.0.3. It comes in transitively.
Clear the alert. Git and dotnet can't run here.
