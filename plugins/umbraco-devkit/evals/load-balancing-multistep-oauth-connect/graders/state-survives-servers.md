---
type: llm
weight: 2
---
Context: the `Connect` request and Mailchimp's redirect back to `Callback` are separate
requests, and on a load-balanced site they can reach different servers.

PASS if the state and PKCE verifier created in `Connect` can be read in `Callback` on any
server: stored in the database (for example `IKeyValueService` or a table), in a distributed
cache, or sent to the browser protected so any server can check it (a cookie or the state
value protected with `IDataProtector`/`ITimeLimitedDataProtector`, which needs the host's
shared data protection keys that Umbraco requires for load balancing).

FAIL if the state or verifier is kept only in one server's memory (a static or singleton
dictionary, `IMemoryCache`), or in session without a distributed session store being
set up or called out as a requirement.
