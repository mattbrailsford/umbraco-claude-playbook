---
type: llm
weight: 2
focus: trace
---
PASS if, before creating any solution or project, the reply asks how to create the solution and
offers a real `dotnet new` template: the `opinionated-package-starter` template as the default,
with the official Umbraco templates as the alternative. Showing the commands to run and waiting
for a yes is the expected outcome.

FAIL if it writes solution or project files by hand, or creates the solution without asking.
