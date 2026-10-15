---
type: llm
weight: 2
---
PASS if the answer says ContentCacheRefresherNotification (a cache refresher notification)
fires on every server, so on a load-balanced site the webhook is sent once per server, and
it moves the webhook to a notification that fires once, on the server where the publish
happened (for example ContentPublishedNotification), or to another mechanism that sends it
exactly once (such as recording the work and sending it from a distributed background job).

FAIL if the answer keeps sending the webhook from the cache refresher notification, or does
not notice that it would be sent once per server.
