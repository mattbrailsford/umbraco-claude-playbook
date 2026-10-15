---
type: llm
---
PASS if the answer says this is a SQL injection risk and suggests FromSqlInterpolated,
FromSql, explicit parameters, or plain LINQ instead.

FAIL if it says the call is safe.
