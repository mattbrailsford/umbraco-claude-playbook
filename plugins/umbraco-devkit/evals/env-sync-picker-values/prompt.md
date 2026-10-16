---
description: A property editor that stores an entity's integer id needs a value mapper so content moves between environments.
tags: [umbraco-env-sync, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package's stores already sync with uSync (`src/MyPackage.uSync`). Editors
also pick a store on content pages with the package's Store Picker property editor. Our
customers sync their content with uSync too. Make sure everything the package adds to
content works across their environments. Git, dotnet and the network aren't available
here.
