---
type: llm
---
PASS if the answer says both skip change tracking, but `AsNoTrackingWithIdentityResolution`
makes the same database row come back as one shared object instance within the query, while
`AsNoTracking` can create a separate instance each time it appears.

FAIL otherwise.
