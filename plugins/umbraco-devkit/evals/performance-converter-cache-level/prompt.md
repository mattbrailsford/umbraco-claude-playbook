---
description: Adding a value converter next to an existing one; PropertyValueConverterBase's default cache level is Snapshot, which runs as None.
tags: [umbraco-performance, should-trigger]
# covers: ["Property value converters: set the cache level"]
max_turns: 20
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

My Umbraco 17 package (`src/MyPackage`) has a new color property editor with the alias
`MyPackage.Color`. It stores JSON like `{"hex":"#ff0000","label":"Red"}`. Add a property
value converter that turns it into the `ColorValue` record, so templates can use
`Model.Value<ColorValue>("color")`. Follow the existing rating converter.

There's no dotnet or network here, so you can't build or run tests; just make the code
change.
