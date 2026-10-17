---
description: Enforcing a data type setting on save; reading the configuration through IDataTypeService runs a database query per property per save.
tags: [umbraco-performance, should-trigger]
# covers: ["Read data type configuration from its cache"]
max_turns: 25
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/MyPackage`) has a tag list property editor with a "Max items"
setting on its data type. The backoffice UI respects it, but values saved through the
Management API or by imports can have more tags. When content is saved, trim every tag
list value to its data type's max items. Sites using the package import products in batches
of several thousand items. Add the notification handler and register it.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
