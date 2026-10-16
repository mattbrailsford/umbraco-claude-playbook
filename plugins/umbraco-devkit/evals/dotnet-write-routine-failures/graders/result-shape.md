---
type: llm
weight: 2
focus: trace
---
PASS if UpdateBaseUrlAsync reports "invalid URL" and "not found" to its caller through its
return value: Umbraco's Attempt<T, TStatus>, a Result/OperationResult type, a status enum,
or a discriminated result type. The controller branches on that value to return 400 or 404.

FAIL if the service throws exceptions (ArgumentException, KeyNotFoundException, a custom
exception, ...) for these expected cases and the controller catches them to choose the
status code, or if the service returns a bare bool or null that can't tell the two
failures apart.
