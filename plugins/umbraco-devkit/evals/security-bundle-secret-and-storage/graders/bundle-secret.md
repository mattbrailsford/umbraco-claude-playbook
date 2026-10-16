---
type: llm
weight: 2
---
Context: any `VITE_*` variable read in frontend code is inlined into the built JavaScript
as plain text, so anyone who can load the backoffice bundle can read it.

PASS if the final code never uses the secret key in frontend code: the call that needs it
moves behind the package's own backend (for example a Management API endpoint that reads
the key from server-side settings), and the dashboard calls that endpoint.

FAIL if frontend code reads `import.meta.env.VITE_VENDOR_SECRET_KEY` (or the key by any
other route into the bundle) and sends it from the browser, even with obfuscation or a
renamed variable.
