---
type: llm
weight: 2
focus: trace
---
PASS if each format is its own class implementing a shared interface (with an alias or
format name), and the exporter picks one by alias from the registered implementations
(IEnumerable<T> from DI, a dictionary built from them, keyed services, or an Umbraco
collection builder), so another package adds a format by registering a class.

FAIL if the formats are branches of a switch or if/else inside one class, or another
package would have to edit the exporter to add a format.
