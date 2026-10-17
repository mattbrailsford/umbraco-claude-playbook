---
type: llm
weight: 2
---
Context: the package's `ImportWorker` is a hosted service, so it runs on every server of a
site, and all servers share one database. A run that is Running may be in progress on
another server that is still alive.

PASS if the final code only puts a Running run back to Pending (or restarts it) once no
live server can still own it: for example a lease or heartbeat column the worker keeps
updating and that must have expired, recording which server or process owns the run and
only requeuing runs owned by this server or by one that is gone, or a timeout well beyond
a normal import.

FAIL if, when a server starts (or on a timer), the code requeues or restarts every Running
run with no ownership, lease, heartbeat or age check, so one server starting up re-runs an
import another server is still running.
