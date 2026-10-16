---
type: llm
weight: 2
focus: trace
---
PASS if the code written in this run makes export formats pluggable: each format (at least
CSV, and JSON/XML moved over or wrapped) is its own implementation of a format interface,
found through DI or an Umbraco collection builder, so another package can add a format by
registering a class without editing the exporter.

FAIL if CSV is added as another case in the existing switch (or an if/else chain), so a
new format still means editing SubmissionExporter.
