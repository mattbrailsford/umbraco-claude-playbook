---
type: llm
weight: 2
focus: {source: file, path: src/Umbraco.Community.Items/Controllers/ItemController.cs}
---
PASS if the controller keeps the old one-parameter constructor `ItemController(IItemService)`,
marked [Obsolete], and it still works for a subclass that calls it: it gets the new
dependencies some other way (chaining to the new constructor with
StaticServiceProvider.Instance.GetRequiredService<T>(), or resolving them later from the
request's services). The new constructor (with IItemPermissionChecker and any other new
dependencies; how many parameters it has doesn't matter) is marked
[ActivatorUtilitiesConstructor] so the framework picks it.

FAIL if the existing constructor is changed in place or removed, an optional or nullable
parameter is added to the existing constructor, or there are two public constructors and
the new one lacks [ActivatorUtilitiesConstructor].
