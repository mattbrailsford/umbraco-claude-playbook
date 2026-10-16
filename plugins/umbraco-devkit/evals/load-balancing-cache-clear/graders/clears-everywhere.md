---
type: llm
weight: 2
---
Context: a site can run on several servers, each with its own in-memory cache. Clearing a
key in `AppCaches.RuntimeCache` (or an `IMemoryCache`) on save only clears it on the
server that handled the save; the others keep the old settings until the entry expires.

PASS if the final code makes a save clear (or refresh) the cached settings on every
server: a cache refresher (`ICacheRefresher`, `CacheRefresherBase`,
`JsonCacheRefresherBase`, `PayloadCacheRefresherBase` or similar) registered with Umbraco
and triggered through `DistributedCache` (for example `RefreshAll` or `Refresh` with the
refresher's id), or a shared out-of-process cache all servers read from.

FAIL if the save clears only the local cache (`ClearByKey`, `ClearOfType`, `IMemoryCache.Remove`
called directly), relies on a short expiry, or doesn't clear the cache on save at all.
