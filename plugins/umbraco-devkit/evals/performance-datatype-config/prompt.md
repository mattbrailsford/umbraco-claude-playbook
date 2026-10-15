---
description: Reading data type configuration on a hot path should use IDataTypeConfigurationCache, not IDataTypeService.
tags: [umbraco-performance, should-trigger]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My Umbraco 17 package has a notification handler that runs on every content save. For each
property that uses my property editor, it needs that data type's configuration (a
`MyPackageConfiguration` class with a `MaxItems` setting). A bulk publish can run it for
thousands of items. I have each property's data type key. How should I read the
configuration? Show the code.
