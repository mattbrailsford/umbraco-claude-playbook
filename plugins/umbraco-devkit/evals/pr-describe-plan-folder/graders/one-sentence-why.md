---
type: llm
focus: {source: file, path: docs/plans/tag-filters/PR-DESCRIPTION.md}
---
Look only at the text under the "Why the change" heading (up to the next heading). Ignore the
rest of the file for the sentence count.

PASS if that text is a single sentence (one full stop at the end; commas, clauses and inline
code inside it are fine), and the file has no "What it looks like" section or screenshots (this
change has no UI).

FAIL if the text under "Why the change" is two or more sentences, or the file adds a UI section
or screenshots.
