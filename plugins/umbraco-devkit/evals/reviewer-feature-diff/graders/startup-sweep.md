---
type: llm
---
PASS if the review flags ImportRecoveryHandler: on a site with more than one server sharing
the database, one server starting up marks imports Failed that another server is still
running. Any suggested fix that limits it to runs nobody owns (lease, heartbeat, owner
column, or age-based cleanup) is fine.

FAIL if the review does not raise this multi-server problem with the startup reset.
