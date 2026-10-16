---
type: llm
weight: 2
---
PASS if the code only fails runs that no live server owns. On a site with more than one
server sharing the database, one server starting up must not mark imports Failed that
another server is still running. It may use any of these: a lease or heartbeat column that
must have expired, recording which server or process owns the run, or a periodic job that
fails runs older than a timeout.

FAIL if the code fails every Running or Pending row on startup with no ownership, lease,
heartbeat or age check.
