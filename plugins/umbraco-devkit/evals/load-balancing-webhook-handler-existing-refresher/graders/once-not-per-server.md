---
type: llm
weight: 2
---
Context: `ContentCacheRefresherNotification` (which the existing handler uses) and any
`ICacheRefresher.Refresh` run on every server as each one processes the change. Action
notifications (`ContentPublishedNotification`, `ContentUnpublishedNotification`) run once,
on the server where the editor acted.

PASS if, in the final code, each publish or unpublish sends one POST, not one per server:
from action notifications (optionally deferred until after the scope completes), from
something that runs once such as an `IDistributedBackgroundJob` fed by a queue, or from the
cache refresher notification with a guard so only one server sends (for example only for
changes that originated on this server, or a claim on a shared row).

FAIL if the POST is sent from `ContentCacheRefresherNotification` (including inside the
existing handler) or another cache refresher with no such guard, so a three-server site
POSTs three times.
