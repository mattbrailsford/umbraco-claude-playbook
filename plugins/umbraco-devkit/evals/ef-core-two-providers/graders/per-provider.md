---
type: llm
weight: 2
focus: trace
---
PASS if the setup gives each provider its own migrations from the one entity model:
separate SQL Server and SQLite migrations (projects, assemblies or folders), and
`scripts/add-migration.sh` generates a migration for each provider (two `dotnet ef
migrations add` runs or equivalent), with the first migration written for both.

FAIL if there's only one set of migrations expected to work on both SQL Server and SQLite,
or only one provider is covered, by the script or by the first migration.
