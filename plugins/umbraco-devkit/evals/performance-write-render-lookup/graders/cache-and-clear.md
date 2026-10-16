---
type: llm
weight: 2
---
PASS if the code does not load and deserialize the form's steps from the database on every
render: it caches "needs consent" per form (runtime cache, IMemoryCache, or a value stored
on the form when it's saved), and the cached value is cleared or updated when steps are
saved (a save notification, a cache refresher, or inside the save path).

FAIL if the view component calls GetStepsForFormAsync on every render, or caches with only
a time-based expiry and nothing that clears it when the steps change.
