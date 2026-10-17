---
description: "Preparing a release; from 17.6 the umbraco-package.json version is the browser cache key, so it must change every release."
tags: [umbraco-backoffice-conventions, should-trigger]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Get my Umbraco package ready for the 2.4.0 release. This release changes the slug preview
in the backoffice client (the client changes are already in) and adds a "lowercase only"
rule. Bump whatever needs bumping and add the changelog entry.

Git, dotnet and npm can't run here; just make the file changes.
