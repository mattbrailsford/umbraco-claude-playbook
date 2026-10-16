---
type: llm
weight: 2
focus: trace
---
PASS if caching lives in its own class that implements IItemClient and wraps an inner
IItemClient (a decorator), ItemClient itself is left without caching code, and DI is set
up so ItemPickerService gets the cached client while ItemSyncService still gets the
uncached one (for example a keyed service, a separate interface or registration for the
cached client, or injecting the inner client explicitly).

FAIL if caching is added inside ItemClient or inside each calling service, or if
ItemSyncService ends up reading from the cache.
