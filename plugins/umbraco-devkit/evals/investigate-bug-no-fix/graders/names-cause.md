---
type: llm
weight: 2
---
PASS if the report names the cause in StatsService.CountPages: the query counts content
versions, not documents, so a page whose published version and current draft are separate
rows is counted twice (it should count distinct nodes). It should point at the query and
explain why 3 pages become 4.

FAIL if the cause is wrong or missing, or blamed on the frontend.
