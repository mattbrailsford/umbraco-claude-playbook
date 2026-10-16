---
type: llm
focus: trace
---
PASS if CheckAsync accepts a CancellationToken and passes it to both the EF Core lookup
and the HttpClient call.

FAIL if it has no CancellationToken, or drops it before either call.
