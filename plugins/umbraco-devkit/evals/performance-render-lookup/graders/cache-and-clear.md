---
type: llm
weight: 2
---
PASS if the answer flags that every page view loads and deserializes all form steps from
the database, and recommends computing "needs consent" once and caching it (for example in
Umbraco's runtime cache or IMemoryCache, or stored on the form when it's saved), cleared or
updated when the form's steps are saved (a save notification, a cache refresher, or the
save path itself).

FAIL if the answer does not flag the per-render database work, or adds a cache with only a
time-based expiry and no clearing when the steps change.
