---
type: llm
weight: 2
focus: trace
---
In this package an empty allowed list means every member may download, and a denied group
blocks access. PASS if the import never widens access when a member group in the file
doesn't exist on the target: an unresolved denied group is not silently dropped, and an
allowed list whose groups can't all be resolved is not saved as empty (or reduced so it
grants more than the source did). Failing that item with a clear message, or keeping the
target's existing rules, both count.

FAIL if unresolved groups are simply skipped so a deny rule disappears or the allowed list
can end up empty, or if the import saves the source's keys unchecked.
