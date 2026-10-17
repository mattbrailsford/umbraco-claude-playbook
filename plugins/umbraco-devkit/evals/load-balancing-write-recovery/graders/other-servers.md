---
type: llm
weight: 2
---
Context: the package's `ImportWorker` is a hosted service, so it runs on every server of a
site, and all servers share one database. A run that is Running may be in progress on
another server that is still alive.

PASS if the final code only marks a Running run Failed once no live server can still own
it: for example a lease or heartbeat column the worker keeps updating and that must have
expired, recording which server or process owns the run and checking that owner, or a
periodic check that fails runs whose last heartbeat or start is older than a timeout well
beyond a normal import.

FAIL if the code marks every Running (or Pending) run Failed when a server starts, or on
a timer, with no ownership, lease, heartbeat or age check, so one server starting up kills
imports another server is running.
