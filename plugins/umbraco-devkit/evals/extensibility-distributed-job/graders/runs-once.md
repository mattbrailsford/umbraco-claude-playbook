---
type: llm
weight: 2
---
Context: on a v17 load-balanced backoffice every server has the SchedulingPublisher role,
so an `IRecurringBackgroundJob` (or `RecurringBackgroundJobBase`) runs on all three servers
whatever its `ServerRoles` say, and the digest would be sent three times a night.

PASS if the final code implements the job as `IDistributedBackgroundJob` (registered as
one), so Umbraco runs each period on one server only.

FAIL if it uses `IRecurringBackgroundJob`/`RecurringBackgroundJobBase` (with default or
custom `ServerRoles`), a hosted service, or a timer, relying on server roles or nothing to
send the digest once.
