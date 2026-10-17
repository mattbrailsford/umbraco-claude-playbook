---
type: llm
weight: 2
---
Context: the import job runs on one server, but the dashboard's polling requests can reach
any server on a load-balanced site, so progress must be readable from every server.

PASS if the job writes its progress somewhere every server reads: a database row or
table (including Umbraco's `IKeyValueService`), or a distributed cache; and the endpoint
reads it from there.

FAIL if progress is kept only in the job's server's memory: a singleton or static
progress tracker, `IMemoryCache`, a static field on the job, an in-process `Channel` or
event, so a poll that reaches another server sees no import or stale numbers.
