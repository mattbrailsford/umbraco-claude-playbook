---
description: A converter inheriting PropertyValueConverterBase must override GetPropertyCacheLevel; the base returns Snapshot, which runs as None.
tags: [umbraco-performance, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package has a property editor with the alias `MyPackage.Color`. It stores JSON
like `{"hex":"#ff0000","label":"Red"}`. Write the property value converter that turns it into
a `ColorValue(string Hex, string Label)` record. Inherit from `PropertyValueConverterBase`.
Show the whole class.
