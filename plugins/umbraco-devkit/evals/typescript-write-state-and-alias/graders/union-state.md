---
type: llm
weight: 2
focus: {source: file, path: client/src/connections/test-panel.ts}
---
PASS if the panel state is a discriminated union (for example a `status` or `kind` field
with one member per state), where the round-trip time exists only on the passed state and
the error message only on the failed state, and describeState narrows on that field
without non-null assertions (`!`) or optional chaining on the payload.

FAIL if the state is a single interface or object type with optional fields such as
`latencyMs?` and `error?` alongside a status field, or separate booleans like
`isTesting`/`hasError`.
