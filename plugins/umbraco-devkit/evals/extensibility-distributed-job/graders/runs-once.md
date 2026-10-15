---
type: llm
weight: 2
---
PASS if the answer uses IDistributedBackgroundJob (or Umbraco's distributed background job
mechanism) to make the digest run on one server only.

FAIL if the answer relies on RecurringBackgroundJobBase with the default or a custom
ServerRoles value (for example SchedulingPublisher) as the way to guarantee a single run.
On a v17 load-balanced backoffice every server is SchedulingPublisher, so that does not
stop the job running on all three.
