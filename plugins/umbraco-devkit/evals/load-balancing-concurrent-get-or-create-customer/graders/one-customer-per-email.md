---
type: llm
weight: 2
---
Context: two servers can take orders for the same new email at the same moment. "Look up
by email, insert if missing" lets both insert, so the customer list gets duplicates; the
order count can also lose an increment if two orders update it at once.

PASS if two concurrent orders for a new email can't create two customers: a unique index
on the (normalised) email in the model and migration, with the insert conflict handled
(catch and re-read, or an upsert/`MERGE`), or the get-or-create runs under a lock every
server shares (`scope.WriteLock`/`EagerWriteLock` on a package lock id, or a
database-level lock).

FAIL if it looks the customer up and inserts when missing with no unique constraint and
no shared lock, or relies on a C# `lock`/`SemaphoreSlim`, which only covers one server.
