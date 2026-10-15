---
type: llm
weight: 2
---
PASS if the answer generates the migration separately for each provider (two
`dotnet ef migrations add` runs, or equivalent, each targeting a SQL Server or a SQLite
migrations project or assembly), so both providers get their own migrations from the one
entity model.

FAIL if it produces only one set of migrations and expects it to work on both SQL Server
and SQLite, or only covers one provider.
