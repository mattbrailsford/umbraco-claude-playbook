---
description: Syncing member-group access rules; a group missing on the target must not widen access.
tags: [umbraco-env-sync, should-trigger]
# covers: ["Users, groups, and members"]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package has download areas (see `src/MyPackage/Downloads`). Developers set
them up once and customers want them to move between dev, staging and live with uSync, like
their document types. Add uSync support for download areas in a new
`src/MyPackage.uSync` project. Git, dotnet and the network aren't available here, so write
it against uSync 17's API as best you know it.
