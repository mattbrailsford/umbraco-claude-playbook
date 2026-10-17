---
description: "uSync for a self-referencing category tree; children can be read before their parents exist on a new environment."
tags: [umbraco-env-sync, should-trigger]
# covers: ["Restore order"]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 catalog package has product categories (`src/MyPackage/Catalog`). The
`MyPackage.uSync` project references uSync but has no code yet. Add a uSync serializer and
handler for categories, so developers can move them between environments and set up new
environments from an existing site's export.

Git, dotnet and the network aren't available here, so write it against uSync 17's API as
best you know it.
