---
type: llm
focus: trace
---
PASS if the uSync code lives in its own project (for example src/MyPackage.uSync with its
own .csproj referencing uSync and the main package), and the main MyPackage.csproj does not
gain a uSync package reference.

FAIL if uSync packages are referenced from the main MyPackage project.
