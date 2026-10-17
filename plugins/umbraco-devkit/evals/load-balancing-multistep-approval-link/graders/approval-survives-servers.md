---
type: llm
weight: 2
---
Context: the request, the manager opening the link and the Approve click are separate
requests days apart, and on a load-balanced site each can reach a different server, which
may also have restarted in between.

PASS if a pending approval can be found and checked on any server: stored in the database
(a table, or Umbraco's `IKeyValueService`) with its expiry and used flag, or carried in the
link as a signed or protected token (`IDataProtector`/`ITimeLimitedDataProtector`, an HMAC
with a configured key) with "used" recorded somewhere every server reads.

FAIL if pending approvals are kept in one server's memory (a static or singleton
dictionary, `IMemoryCache`) or in session, or "used" is tracked only in memory so a link
can be used again on another server.
