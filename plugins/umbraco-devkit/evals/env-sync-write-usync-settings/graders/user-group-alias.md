---
type: llm
weight: 2
focus: trace
---
PASS if ApproverUserGroupKey is exported as the user group's alias (looked up from the key)
and on import resolved back to the target site's user group by alias, since user group keys
differ between sites. Handling an alias the target doesn't have (skip with a warning, or
fail clearly) is a bonus, not required.

FAIL if the export writes the raw user group key (or omits the link) and import uses that
key as-is.
