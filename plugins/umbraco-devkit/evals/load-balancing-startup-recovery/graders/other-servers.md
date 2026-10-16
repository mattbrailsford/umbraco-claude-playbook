---
type: llm
weight: 2
---
PASS if the answer flags that on a site with more than one server sharing the database,
one server starting up marks imports Failed that another server is still running, and
proposes a fix that only fails runs nobody owns any more. Any of these count: a lease or
heartbeat column that must have expired, recording which server or process owns the run,
or a periodic job that fails runs older than a timeout.

FAIL if the answer does not raise the multi-server problem, or only suggests changes that
still fail every Running row on startup (for example adding logging, a try/catch, or
moving it to UmbracoApplicationStartedNotification).
