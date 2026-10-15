---
type: llm
weight: 2
---
PASS if the answer says the VITE_ variable is inlined into the shipped JavaScript as plain
text, so the secret key is public, and that calls needing it must move to the backend (for
example the frontend calls the package's own Management API, which holds the key
server-side).

FAIL if it suggests the env var stays secret, or only suggests renaming or obfuscating it.
