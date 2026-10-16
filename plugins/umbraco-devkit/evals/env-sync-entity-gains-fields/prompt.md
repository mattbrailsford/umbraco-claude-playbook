---
description: Adding fields to an entity the package already syncs; the uSync code must change with it, read old files, and export the new list stably.
tags: [umbraco-env-sync, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Stores in my Umbraco 17 package need two new settings: a `TaxRegion` (a short code like
"EU" or "US-CA") and the shipping zones the store ships to (zones are their own entity,
see `src/MyPackage/Shipping`). Add both to the Store entity and everywhere stores are
handled in this repo. Git, dotnet and the network aren't available here.
