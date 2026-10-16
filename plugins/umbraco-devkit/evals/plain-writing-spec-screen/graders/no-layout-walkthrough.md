---
type: llm
weight: 2
focus: {source: file, path: docs/plans/connections/SPEC.md}
---
Judge only the "Connections screen" section.

PASS if the text does not describe what the screenshot already shows: it doesn't list the
table's columns (Name, Provider, Last used), say where the Create connection button sits or
that it's primary, repeat the headline, or say there's a Test button on each row as layout.
Mentioning a column or button by name inside a behaviour or rule ("Last used shows...",
"Clicking Test...") is fine.

FAIL if the section walks through the layout: a list or sentence naming the columns, the
button positions or looks, or the headline as a description of the screen.
