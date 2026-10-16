---
type: llm
---
PASS if the review flags that VITE_OPENAI_API_KEY is compiled into the public JavaScript
bundle, so anyone who can load the backoffice script can read the key, and says the OpenAI
call must move to the package's backend.

FAIL if the review does not raise the API key ending up in the bundle.
