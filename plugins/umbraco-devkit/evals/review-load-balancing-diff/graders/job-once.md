---
type: llm
---
PASS if the review flags that WeeklyReportJob can run on more than one server and send the
email several times (for example because every server in a v17 load-balanced backoffice is
SchedulingPublisher, or because the default ServerRoles don't guarantee one server), and
suggests making it run once, for example IDistributedBackgroundJob or another single-runner
mechanism.

FAIL if the review does not raise duplicate sending across servers.
