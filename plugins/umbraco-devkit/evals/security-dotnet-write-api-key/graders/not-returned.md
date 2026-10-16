---
type: llm
weight: 2
focus: trace
---
PASS if no read endpoint or response model written in this run sends the stored API key
back to the client: responses omit it or return only whether one is set (or a fixed
mask), and saving treats an empty or masked value as "keep the existing key".

FAIL if any GET or list response includes the actual API key value.
