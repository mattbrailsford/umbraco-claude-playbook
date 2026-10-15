---
type: llm
weight: 2
---
PASS if the configuration is read from a cache rather than the database on each call: for
example IDataTypeConfigurationCache.GetConfigurationAs<MyPackageConfiguration>(key), the
property type's already-loaded data type configuration, or IDataTypeService results cached
by the package with a rule for clearing them when the data type is saved.

FAIL if the code calls IDataTypeService (GetAsync, GetDataType or similar) for every
property on every save with no caching.
