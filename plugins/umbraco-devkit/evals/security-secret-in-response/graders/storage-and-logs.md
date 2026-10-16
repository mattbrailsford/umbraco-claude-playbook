---
type: llm
---
PASS if the answer flags at least one of: the key stored in plaintext in the database (fix by
encrypting it, or storing only a reference to configuration or a secret store), or the key
written to the log by the {@Settings} structured logging call.

FAIL if it flags neither.
