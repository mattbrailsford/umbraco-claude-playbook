---
type: llm
weight: 2
focus: {source: file, path: docs/plans/tag-filters/PR-DESCRIPTION.md}
---
The code matches prefixes case-sensitively, but SPEC.md says ignoring case. That's a spec
deviation a reviewer must decide on.

PASS if the description's "Special things to note" section has a bullet for this deviation that
starts with a visible `**Needs a decision:**` or `**Consider reverting:**` prefix.

FAIL if the deviation is missing, or mentioned only as plain prose without that prefix.
