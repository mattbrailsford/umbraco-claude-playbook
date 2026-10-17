---
description: uSync for linked entities; links exported as keys not integer ids, and a store/country cycle broken with a fill-in pass.
tags: [umbraco-env-sync, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Our Umbraco 17 commerce package already has a `MyPackage.uSync` project with the uSync
package referenced but no code yet. Add uSync serializers and handlers for stores,
countries and tax rates (`src/MyPackage/Stores`). Developers use uSync to set up new
environments from an existing site's export. Write the code.

Git, dotnet and the network aren't available here, so write it against uSync 17's API as
best you know it.
