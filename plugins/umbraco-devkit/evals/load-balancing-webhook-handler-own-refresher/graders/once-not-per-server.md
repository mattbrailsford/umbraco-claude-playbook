---
type: llm
weight: 2
---
Context: `PriceListCacheRefresher.Refresh` and `PriceListCacheRefresherNotification` run on
every server when `DistributedCache.RefreshByPayload` is called. `PriceListService.SaveAsync`
runs once, on the server that handled the save.

PASS if, in the final code, each price list change sends one POST, not one per server:
from `SaveAsync` (or a notification the package publishes once from there, handled by the
ERP code), from an `IDistributedBackgroundJob` fed by a queue, or from the refresher side
with a guard so only the originating server sends.

FAIL if the POST is sent from `PriceListCacheRefresher.Refresh`, from a handler of
`PriceListCacheRefresherNotification`, or from another cache refresher with no such guard,
so a three-server site POSTs three times.
