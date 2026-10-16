---
type: llm
weight: 2
focus: {source: file, path: client/src/connections/connection.data-source.ts}
---
PASS if both the load and save methods return their outcome in the resolved value instead
of throwing for routine failures: for example Promise<{ data?: Connection; error?: ... }>
or another result/union type with a success and an error branch. A 404, a 400 with a
ProblemDetails body, and a network failure (fetch rejecting) must all come back as an
error value, so a caller can't forget to handle them.

FAIL if either method throws (or lets the fetch rejection escape) for a 404, a 400 or a
network failure, so the caller needs try/catch to handle routine errors.
