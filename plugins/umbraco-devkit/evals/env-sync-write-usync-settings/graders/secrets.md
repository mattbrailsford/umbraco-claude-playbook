---
type: llm
weight: 2
focus: trace
---
PASS if the uSync export written in this run leaves ApiKey and WebhookSecret out of the
exported file by default (an opt-in setting to include them is fine), AND importing a file
without them keeps the target site's existing values instead of overwriting them with empty
strings.

FAIL if either secret is written to the export by default, or if a restore would blank the
target's ApiKey or WebhookSecret.
