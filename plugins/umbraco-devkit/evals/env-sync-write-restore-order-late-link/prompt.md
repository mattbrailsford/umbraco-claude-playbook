---
description: "Adding a store's default tax rate to working uSync code; tax rates import after stores, so the new link needs filling in later."
tags: [umbraco-env-sync, should-trigger]
# covers: ["Restore order"]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Stores in my Umbraco 17 commerce package need a default tax rate: one of the tax rates of
the store's own countries, used when a product has no tax rate set. Add it to `Store`
(`src/MyPackage/Stores`) and to the uSync support in `src/MyPackage.uSync`. Developers use
uSync to set up new environments from an existing site's export.

Git, dotnet and the network aren't available here, so write it against uSync 17's API as
best you know it.
