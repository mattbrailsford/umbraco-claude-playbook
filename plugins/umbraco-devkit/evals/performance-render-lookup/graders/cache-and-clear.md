---
type: llm
weight: 2
---
Context: the view component runs on every front-end page view that shows the form.
`GetStepsForFormAsync` queries the database and deserializes every step's settings.

PASS if the final code does not load the form's steps from the database on every render:
"needs consent" is cached per form (Umbraco's runtime cache, `IMemoryCache`, or a value
stored on the form when steps are saved), and the cached value is cleared or updated when
steps are saved (in `SaveAsync`, a notification, or a cache refresher).

FAIL if the view component calls `GetStepsForFormAsync` on every render, or caches with
only a time-based expiry and nothing that clears it when steps change.
