---
type: llm
weight: 2
---
Context: on a load-balanced site a member's requests are spread over several servers, so a
count kept in one server's memory only sees that server's share.

PASS if the limit is counted from state every server shares: counting the member's rows in
the last hour in the database (the `Entries` table already has `MemberKey` and
`CreatedUtc`), a database counter, or a distributed cache (`IDistributedCache`, Redis).

FAIL if the count lives in one server's memory: `IMemoryCache`, a static or singleton
`ConcurrentDictionary`, ASP.NET Core's in-memory rate limiter (`AddRateLimiter` with a
fixed or sliding window partitioned per member) with no shared store, or similar.
