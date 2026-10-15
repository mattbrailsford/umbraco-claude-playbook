---
type: llm
weight: 2
---
PASS if the answer explains that ClearByKey only clears the cache on the server that handled
the save, and fixes it so every server drops its copy. Accept a custom cache refresher
(ICacheRefresher, CacheRefresherBase, JsonCacheRefresherBase or similar) triggered through
DistributedCache, or a shared out-of-process cache that all servers read from.

FAIL if the fix only shortens the cache expiry, removes caching without explaining the
cause, relies on sticky sessions, or still clears only the local server's cache.
