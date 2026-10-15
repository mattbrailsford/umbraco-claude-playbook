---
type: llm
---
PASS if the answer handles ContentPublishedNotification (or ContentPublishingNotification)
with an INotificationHandler<T> (or its async variant) and registers it, for example with
AddNotificationHandler in a composer.

FAIL if it gives no working way to react to publishing.
