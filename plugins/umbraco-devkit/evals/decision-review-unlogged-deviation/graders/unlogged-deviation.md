---
type: llm
weight: 2
focus: trace
---
SPEC.md says prefixes match ignoring case. The code compares prefixes with
`StringComparison.Ordinal`, so "Internal-IT" is not hidden by the prefix "internal-". Nothing
in DECISION-LOG.md mentions this.

PASS if the review lists this as a deviation from the spec and recommends a decision or a fix.

FAIL if it misses it, or calls the build consistent with the spec.
