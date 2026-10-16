---
type: llm
weight: 2
focus: trace
---
PASS if the data access written in this run is internal to the subscription service: the
repository (or data-access class and its interface) is not public, the controller depends
only on the subscription service, and only the service talks to the repository. Putting
the data access directly inside an internal service, with no separate repository, also
passes.

FAIL if the repository or its interface is public, or the controller injects the repository
or the DbContext directly.
