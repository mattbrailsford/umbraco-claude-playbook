---
type: llm
weight: 2
---
Context: the shops can run on several servers, each with its own `AppCaches.RuntimeCache`.
`ClearByKey` (as `CurrencyRatesService` does) clears only the server that handled the save;
the other servers keep pricing with the old zones until the entry expires.

PASS if, in the final code, saving or deleting a zone clears or refreshes the cached zones
on every server: through a cache refresher (`ICacheRefresher`, `CacheRefresherBase`,
`JsonCacheRefresherBase`, `PayloadCacheRefresherBase` or similar) registered with Umbraco
and triggered via `DistributedCache`, or by keeping zones in a shared cache every server
reads.

FAIL if save or delete clears the zones only with `ClearByKey`/`ClearOfType`/
`IMemoryCache.Remove` on the local server, relies on an expiry, or doesn't clear on delete.
