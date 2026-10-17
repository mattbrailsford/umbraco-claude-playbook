---
type: llm
weight: 2
---
Context: two servers can create orders at the same moment. Reading the highest number and
adding one, then inserting, can give both the same number.

PASS if two concurrent creates can't end up with the same number: the number is derived
from a database-generated value (the identity `Id` assigned on insert, a sequence), or a
unique index on the number column plus a retry on conflict, or the read-and-insert runs
under a lock every server shares (`scope.WriteLock`/`EagerWriteLock` on a package lock id,
or a database-level lock), or a counter row updated atomically in the database.

FAIL if it reads the current maximum (or a count) and inserts max + 1 with no unique
constraint, shared lock or atomic update, or relies on a C# `lock`/`SemaphoreSlim`, which
only covers one server.
