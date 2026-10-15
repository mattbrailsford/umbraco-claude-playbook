---
type: llm
weight: 2
---
PASS if the answer keeps the old one-parameter constructor (marked [Obsolete]) chaining to a
new two-parameter constructor, resolves the missing IItemPermissionChecker for the old path
(for example StaticServiceProvider.Instance.GetRequiredService<IItemPermissionChecker>()),
and marks the new constructor with [ActivatorUtilitiesConstructor] so the framework picks it.

FAIL if it changes the existing constructor in place, adds an optional or nullable parameter
to the existing constructor, or keeps two public constructors without saying how the
framework chooses between them.
