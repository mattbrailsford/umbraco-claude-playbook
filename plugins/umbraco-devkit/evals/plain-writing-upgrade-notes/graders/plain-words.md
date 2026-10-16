---
type: llm
weight: 2
focus: {source: file, path: docs/upgrading-to-v4.md}
---
PASS if the document either avoids "idempotent" and "resumable" or explains what they mean
for the reader in plain words the first time (for example "a sync that stops part way
picks up from the last finished batch instead of starting again"), and drops the notes'
hedging ("it might be worth considering", "could potentially") in favour of a plain
statement of the fact.

FAIL if "idempotent" (or "resumable") appears with no plain explanation, or the hedged
sentence is carried over in hedged form.
