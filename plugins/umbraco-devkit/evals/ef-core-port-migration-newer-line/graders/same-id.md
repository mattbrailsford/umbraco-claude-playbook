---
type: llm
weight: 2
focus: trace
---
Context: sites upgrade from the v17 line to the v18 line. EF Core records each applied
migration by its ID. An upgrading site already has v17's
`20260912103000_AcmeReviews_AddVerifiedAt` in its history. If v18's copy has a different ID
(for example a new timestamp after `AddReplies`), the site runs it again and fails on the
duplicate column. EF orders migrations by ID, and a copied ID older than `AddReplies` is
fine: a fresh site applies both, an upgraded site skips the one it has.

PASS if the new migration files on this branch (outside `.worktrees/`), for both SQL Server
and SQLite, keep the ID `20260912103000_AcmeReviews_AddVerifiedAt` in the `[Migration]`
attribute and the matching class/file name.

FAIL if either provider's migration gets a different ID or timestamp, only one provider
gets a migration, or the column is added to the entity with no migration.
