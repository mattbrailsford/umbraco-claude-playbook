---
description: Adding uSync support for a package's provider settings; secrets left out and kept on restore, user groups linked by alias, sync code in its own project.
tags: [umbraco-env-sync, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Our Umbraco 17 package stores provider settings in its own table (see
`src/MyPackage/Providers`). Customers want them to move between their dev, staging and live
sites with uSync files, like their document types do. Add uSync support for provider
settings. Write the code. Git, dotnet and the network aren't available here, so write it
against uSync 17's API as best you know it.
