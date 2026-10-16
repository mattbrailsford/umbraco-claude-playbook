---
type: llm
weight: 2
focus: {source: file, path: docs/upgrading-to-v4.md}
---
PASS if every one of these survives with its specific value: the old and new setting keys
(MyPackage:BatchSize to MyPackage:Sync:BatchSize), the old key still read in v4 with a log
warning and removed in v5; default 500, maximum 5000, larger values clamped;
ISyncProvider.Fetch(int page) replaced by FetchAsync(SyncCursor, CancellationToken), the old
one obsolete and removed in v5; Umbraco 17.2 or later now required (was 17.0); the
migration runs automatically on startup, needs no downtime, and can't be undone by
downgrading (restore a database backup); the first sync after upgrading takes about 10%
longer, once.

FAIL if any item is missing or loses its number or name.
