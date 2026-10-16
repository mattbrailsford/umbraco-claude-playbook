---
type: llm
weight: 2
---
Context: a site can run on several servers. Cache refresher notifications
(`ContentCacheRefresherNotification` and similar) and `ICacheRefresher.Refresh` run on
every server as each one processes the change. Action notifications
(`ContentPublishedNotification`) run once, on the server where the publish happened.

PASS if the final code sends the webhook once per publish, not once per server: from an
action notification such as `ContentPublishedNotification` (optionally deferring the send,
for example to after the scope completes), or by recording the work and sending it from
something that runs once (such as an `IDistributedBackgroundJob`), or from a cache refresher
notification guarded so only one server sends (for example only when the change originated
on this server, or a claim on a shared row).

FAIL if the webhook is sent from `ContentCacheRefresherNotification` (or another cache
refresher notification or `ICacheRefresher`) with no guard, so a site on three servers
sends it three times.
