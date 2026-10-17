---
description: A property editor that stores an entity's integer id needs a value mapper so content moves between environments.
tags: [umbraco-env-sync, should-trigger]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package's stores already sync with uSync (`src/MyPackage.uSync`). Editors
also pick a store on content pages with the package's Store Picker property editor, and our
customers sync their content with uSync too. Add uSync support for the content side of the
package, the way we did for stores.

Git, dotnet and the network aren't available here, so just make the code change.
