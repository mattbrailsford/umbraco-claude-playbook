---
type: llm
weight: 2
---
Context: on a load-balanced site each front-end server holds its own copy of the map.
Action notifications (`ContentPublishedNotification`, `ContentUnpublishedNotification`,
`ContentSavedNotification`, `ContentDeletedNotification`, `ContentMovedToRecycleBinNotification`)
fire only on the server where the editor acted. Cache refresher notifications
(`ContentCacheRefresherNotification`) and an `ICacheRefresher`'s `Refresh` run on every server.

PASS if, in the final code, a published, unpublished or changed redirect rebuilds or clears
the map on every server: from `ContentCacheRefresherNotification`, from the package's own
cache refresher triggered via `DistributedCache`, or by re-reading from a source every
server shares on each change.

FAIL if the map is cleared or rebuilt only from action notifications (so other servers keep
the old map), only on an expiry timer, or never.
