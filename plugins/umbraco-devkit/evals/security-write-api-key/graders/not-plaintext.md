---
type: llm
weight: 2
focus: trace
---
PASS if the API key is not stored as plain text in the database: either the entity stores
a reference to a configuration key or secret store (resolved at use, with the allowed
configuration sections restricted), or the value is encrypted at rest (for example
ASP.NET Core Data Protection).

FAIL if the raw API key is saved in a database column as entered.
