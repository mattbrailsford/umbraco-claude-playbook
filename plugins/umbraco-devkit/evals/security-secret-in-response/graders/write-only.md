---
type: llm
weight: 2
---
PASS if no response from the new controller contains the real API key: the GET and the
save's response use a model with no key (or a "key is set" flag, or a fixed mask), and a
save with an empty or masked key keeps the stored key instead of overwriting it.

FAIL if the GET or the save's response returns the stored `ProviderSettings` entity (or
any model carrying `ApiKey`), so the key reaches the browser, or if saving with the
masked value overwrites the real key.
