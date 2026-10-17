---
type: llm
weight: 2
---
Context: the handler runs on every content save, for every tag list property, including
bulk saves and imports of many items.

PASS if the handler reads each data type's configuration from a cache rather than the
database on each call: `IDataTypeConfigurationCache.GetConfigurationAs<TagListConfiguration>(key)`,
or `IDataTypeService` results cached by the package with clearing when the data type is
saved.

FAIL if the code calls `IDataTypeService` (`GetAsync`, `GetDataType` or similar) for each
property on each save with no caching.
